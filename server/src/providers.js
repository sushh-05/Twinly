const axios = require('axios'); const cheerio = require('cheerio'); const { client } = require('@gradio/client');
const Replicate = require('replicate');
const FormData = require('form-data');

const replicate = new Replicate({ auth: process.env.REPLICATE_API_TOKEN });

const fallback = { category: 'dress', color: 'soft neutral', pattern: 'solid', sleeveLength: 'short', neckline: 'round', styleNotes: 'clean, everyday style' };

async function uploadBufferToPublicUrl(buffer, filename) {
  const form = new FormData();
  form.append('reqtype', 'fileupload');
  form.append('fileToUpload', buffer, filename);
  const res = await axios.post('https://catbox.moe/user/api.php', form, {
    headers: form.getHeaders()
  });
  return res.data; // returns the raw URL string
}

async function generateVirtualTryOnReplicate(humanImageUrl, garmentImageUrl, garmentDescription) {
  try {
    const output = await replicate.run(
      "cuuupid/idm-vton:0513734a452173b8173e907e3a59d19a36266e55b48528559432bd21c7d7e985",
      {
        input: {
          garm_img: garmentImageUrl,
          human_img: humanImageUrl,
          garment_des: garmentDescription || "a garment"
        }
      }
    );
    return output.url ? output.url() : (Array.isArray(output) ? output[0] : output);
  } catch (e) {
    console.error('Replicate IDM-VTON error:', e.message);
    return null;
  }
}
async function analyzeGarmentImage(imageBuffer, mimeType = 'image/jpeg') {
  // Swappable provider function: replace this Hugging Face call if a free-tier provider changes.
  if (!process.env.HUGGINGFACE_API_KEY) return fallback;
  try {
    const r = await axios.post('https://router.huggingface.co/hf-inference/models/Salesforce/blip-image-captioning-large', imageBuffer, { headers: { Authorization: `Bearer ${process.env.HUGGINGFACE_API_KEY}`, 'Content-Type': 'application/octet-stream' }, timeout: 15000 });
    const caption = r.data?.[0]?.generated_text || 'fashion garment'; return { ...fallback, styleNotes: caption };
  } catch (e) {
    console.error('Hugging Face API error (BLIP):', e.message, e.response?.data);

    // Second fallback: Vision-capable chat model
    try {
      console.log('Falling back to vision chat model...');
      const base64Image = imageBuffer.toString('base64');
      const dataUrl = `data:${mimeType};base64,${base64Image}`;

      const r2 = await axios.post('https://router.huggingface.co/hf-inference/v1/chat/completions', {
        model: 'meta-llama/Llama-3.2-11B-Vision-Instruct',
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: 'Describe this garment in a few words (category, color, style).' },
              { type: 'image_url', image_url: { url: dataUrl } }
            ]
          }
        ],
        max_tokens: 50
      }, {
        headers: { Authorization: `Bearer ${process.env.HUGGINGFACE_API_KEY}`, 'Content-Type': 'application/json' },
        timeout: 15000
      });

      const caption = r2.data?.choices?.[0]?.message?.content || 'fashion garment';
      return { ...fallback, styleNotes: caption.trim() };
    } catch (e2) {
      console.error('Hugging Face API error (Vision Chat):', e2.message, e2.response?.data);
      return fallback;
    }
  }
}
async function analyzeGarmentUrl(url) {
  if (!url) throw new Error('Add a product URL or upload a screenshot.');
  const r = await axios.get(url, { timeout: 15000, headers: { 'User-Agent': 'Twinly/1.0' } });
  const $ = cheerio.load(r.data);

  let title = $('meta[property="og:title"]').attr('content') || $('title').text();
  let description = $('meta[property="og:description"]').attr('content') || $('meta[name="description"]').attr('content');
  let image = $('meta[property="og:image"]').attr('content');

  if (!image) {
    const imgSelectors = ['img[itemprop="image"]', '.product-image img', '.product-gallery img', '#main-image', '.main-image', 'img.product', 'img'];
    for (const selector of imgSelectors) {
      const src = $(selector).first().attr('src') || $(selector).first().attr('data-src');
      if (src) {
        try { image = new URL(src, url).href; break; } catch (e) { }
      }
    }
  }

  if (!image) throw new Error('We could not find the product image. Please upload a screenshot instead.');

  const imageResponse = await axios.get(image, { responseType: 'arraybuffer', timeout: 20000 });
  const analyzed = await analyzeGarmentImage(Buffer.from(imageResponse.data), imageResponse.headers['content-type'] || 'image/jpeg');

  let styleNotes = title ? `Inspired by ${title.trim()}. ` : '';
  if (description) styleNotes += `${description.trim()} `;
  styleNotes += analyzed.styleNotes;

  return { ...analyzed, styleNotes: styleNotes.trim() };
}
async function generateStyleImage(prompt, humanImageBuffer, garmentImageBuffer, garment) {
  const garmentDesc = `${garment?.color || ''} ${garment?.category || ''} ${garment?.styleNotes || ''}`.trim();

  // 1. Try Replicate first if we have both images and a token
  if (process.env.REPLICATE_API_TOKEN && humanImageBuffer && garmentImageBuffer) {
    try {
      console.log('Attempting Replicate IDM-VTON generation...');
      const humanUrl = await uploadBufferToPublicUrl(humanImageBuffer, 'human.jpg');
      const garmentUrl = await uploadBufferToPublicUrl(garmentImageBuffer, 'garment.jpg');

      const resultUrl = await generateVirtualTryOnReplicate(humanUrl, garmentUrl, garmentDesc);
      if (resultUrl) {
        console.log('Replicate generation successful');
        return resultUrl;
      }
    } catch (e) {
      console.error('Replicate fallback error:', e.message);
    }
  }

  // 2. Try IDM-VTON Space next
  if (humanImageBuffer && garmentImageBuffer) {
    try {
      console.log('Attempting IDM-VTON generation...');
      const hfToken = process.env.HUGGINGFACE_API_KEY;
      console.log('HF Token check - exists:', !!hfToken, 'length:', hfToken ? hfToken.length : 0, 'prefix:', hfToken ? hfToken.substring(0, 4) : 'none');

      const app = await client("yisol/IDM-VTON", { token: hfToken });

      // Convert buffers to Blobs for Gradio client
      const humanBlob = new Blob([humanImageBuffer], { type: 'image/jpeg' });
      const garmentBlob = new Blob([garmentImageBuffer], { type: 'image/jpeg' });

      // The human image input expects a dict with background/layers/composite. 
      // We pass the blob as both background and composite to ensure it's not malformed.
      const humanDict = { background: humanBlob, layers: [], composite: humanBlob };

      // Call the tryon endpoint with the exact 7 parameters
      // inputs: [human_dict, garment_image, garment_desc, is_checked, is_checked_crop, denoise_steps, seed]
      // We set is_checked_crop to false as it often preserves proportions better for full-body avatars
      const result = await Promise.race([
        app.predict("/tryon", [
          humanDict,
          garmentBlob,
          garmentDesc || "garment",
          true, // use auto-mask
          false, // use auto-crop (false preserves avatar proportions better)
          30, // denoise_steps
          42 // seed
        ]),
        new Promise((_, reject) => setTimeout(() => reject(new Error('IDM-VTON timeout')), 45000))
      ]);

      if (result?.data?.[0]?.url) {
        console.log('IDM-VTON generation successful');
        return result.data[0].url;
      }
    } catch (e) {
      console.error('IDM-VTON API error:', e);
      // Fall through to next provider
    }
  }

  // 3. Together AI (Commented out)
  /*
  // Together AI free tier confirmed unavailable as of Sep 2026, kept for reference only
  try {
    if (process.env.TOGETHER_API_KEY) {
      console.log('Falling back to Together AI...');
      const r = await axios.post('https://api.together.xyz/v1/images/generations', { model: 'black-forest-labs/FLUX.1-schnell-Free', prompt, n: 1, size: '512x768', response_format: 'url' }, { headers: { Authorization: `Bearer ${process.env.TOGETHER_API_KEY}` }, timeout: 15000 });
      if (r.data?.data?.[0]?.url) return r.data.data[0].url;
    }
  } catch (e) {
    console.error('Together AI API error:', e.message, e.response?.data);
  }
  */

  // 4. Fallback to Pollinations.ai
  console.log('Falling back to Pollinations.ai for image generation');
  return `https://image.pollinations.ai/prompt/${encodeURIComponent(prompt)}?width=512&height=768&nologo=true`;
}
module.exports = { analyzeGarmentImage, analyzeGarmentUrl, generateStyleImage };

const { Client } = require('@gradio/client');

async function generateVirtualTryOn(avatarImageBuffer, garmentImageBuffer, garmentDescription = 'a garment') {
  try {
    const client = await Client.connect('yisol/IDM-VTON', {
      hf_token: process.env.HUGGINGFACE_API_KEY
    });

    const result = await client.predict('/tryon', [
      {
        background: new Blob([avatarImageBuffer], { type: 'image/jpeg' }),
        layers: [],
        composite: null
      },                                          // imgs (human image + mask editor)
      new Blob([garmentImageBuffer], { type: 'image/jpeg' }), // garm_img
      garmentDescription,                          // prompt (e.g. "Soft Neutral Dress, short sleeves, round neckline")
      true,                                        // is_checked (use auto-generated mask)
      true,                                        // is_checked_crop (use auto-crop & resizing)
      30,                                          // denoise_steps
      42                                           // seed
    ]);

    return result.data[0]?.url || result.data[0];  // image_out
  } catch (e) {
    console.error('IDM-VTON Space error:', e.message);
    return null;
  }
}

module.exports = { analyzeGarmentImage, analyzeGarmentUrl, generateStyleImage, generateVirtualTryOn };
