require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
require('dotenv').config({ path: require('path').join(__dirname, '..', '..', '.env') });
const express = require('express'); const cors = require('cors'); const multer = require('multer'); const fs = require('fs'); const path = require('path'); const { analyzeGarmentImage, analyzeGarmentUrl, generateStyleImage } = require('./providers'); const { requireFirebaseUser } = require('./firebase_auth');
const app = express(); const upload = multer({ storage: multer.memoryStorage() }); app.use(cors()); app.use(express.json({ limit: '2mb' }));
const dataDir = path.join(__dirname, '..', 'data'); const profilesDir = path.join(dataDir, 'profiles'); fs.mkdirSync(profilesDir, { recursive: true }); const profilePath = (uid) => path.join(profilesDir, `${encodeURIComponent(uid)}.json`); const saveProfile = (uid, value) => fs.writeFileSync(profilePath(uid), JSON.stringify({ uid, profile: value }, null, 2));
app.get('/health', (req, res) => res.json({ status: 'ok', service: 'twinly-express' })); app.get('/api/health', (req, res) => res.json({ status: 'ok' }));
app.post('/api/profile', requireFirebaseUser, (req, res) => { saveProfile(req.firebaseUser.uid, req.body); res.json({ ok: true, profile: req.body }); });
app.delete('/api/account', requireFirebaseUser, (req, res) => { const file = profilePath(req.firebaseUser.uid); try { if (fs.existsSync(file)) fs.unlinkSync(file); return res.json({ ok: true }); } catch (error) { console.error('Profile deletion failed:', error.message); return res.status(500).json({ error: 'Profile deletion failed.' }); } });
app.post('/api/garment/analyze', upload.single('image'), async (req, res) => { try { const garment = req.file ? await analyzeGarmentImage(req.file.buffer, req.file.mimetype) : await analyzeGarmentUrl(req.body.url); res.json({ garment }); } catch (e) { res.status(422).json({ error: e.message || 'We could not read that garment. Please upload a screenshot instead.' }); } });
app.post('/api/tryon/generate', upload.fields([{ name: 'humanImage', maxCount: 1 }, { name: 'garmentImage', maxCount: 1 }]), async (req, res) => {
    try {
        let profile, garment, garmentUrl;
        if (req.body.profile) profile = typeof req.body.profile === 'string' ? JSON.parse(req.body.profile) : req.body.profile;
        if (req.body.garment) garment = typeof req.body.garment === 'string' ? JSON.parse(req.body.garment) : req.body.garment;
        if (req.body.garmentUrl) garmentUrl = req.body.garmentUrl;

        const prompt = `A realistic full-body photo of a ${profile?.bodyShape || 'person'} with ${profile?.skinTone || 'natural'} skin, wearing a ${garment?.color || 'neutral'} ${garment?.category || 'garment'} with ${garment?.sleeveLength || 'short'} sleeves and a ${garment?.neckline || 'classic'} neckline, ${garment?.styleNotes || 'modern style'}, standing in a neutral studio background, front-facing, soft lighting.`;

        let humanImageBuffer = req.files?.['humanImage']?.[0]?.buffer;
        let garmentImageBuffer = req.files?.['garmentImage']?.[0]?.buffer;

        // If no human image was uploaded, load a default avatar based on the profile
        if (!humanImageBuffer) {
            const isFeminine = profile?.style !== 'masculine';
            const shape = profile?.bodyShape || 'average';
            // Map the profile body shape to the available avatar files
            let mappedShape = 'average';
            if (shape === 'hourglass' || shape === 'curvy') mappedShape = 'curvy';
            if (shape === 'rectangle' || shape === 'athletic' || shape === 'slim') mappedShape = 'slim';
            if (!isFeminine && shape === 'curvy') mappedShape = 'broad'; // Male avatars use 'broad' instead of 'curvy'

            const avatarFilename = isFeminine ? `avatar_female_${mappedShape}.png` : `avatar_male_${mappedShape}.png`;
            const avatarPath = path.join(__dirname, '..', '..', 'mobile', 'assets', 'avatars', avatarFilename);

            try {
                humanImageBuffer = fs.readFileSync(avatarPath);
            } catch (e) {
                console.error(`Could not load default avatar ${avatarFilename}:`, e.message);
                // Fallback to a guaranteed existing avatar if the specific one fails
                try {
                    humanImageBuffer = fs.readFileSync(path.join(__dirname, '..', '..', 'mobile', 'assets', 'avatars', 'avatar_female_average.png'));
                } catch (e2) {
                    console.error('Could not load fallback avatar either:', e2.message);
                }
            }
        }

        // If no garment image was uploaded but we have a URL, try to fetch it
        if (!garmentImageBuffer && garmentUrl) {
            try {
                const cheerio = require('cheerio');
                const axios = require('axios');
                const r = await axios.get(garmentUrl, { timeout: 15000, headers: { 'User-Agent': 'Twinly/1.0' } });
                const $ = cheerio.load(r.data);
                let image = $('meta[property="og:image"]').attr('content');
                if (!image) {
                    const imgSelectors = ['img[itemprop="image"]', '.product-image img', '.product-gallery img', '#main-image', '.main-image', 'img.product', 'img'];
                    for (const selector of imgSelectors) {
                        const src = $(selector).first().attr('src') || $(selector).first().attr('data-src');
                        if (src) {
                            try { image = new URL(src, garmentUrl).href; break; } catch (e) { }
                        }
                    }
                }
                if (image) {
                    const imageResponse = await axios.get(image, { responseType: 'arraybuffer', timeout: 20000 });
                    garmentImageBuffer = Buffer.from(imageResponse.data);
                }
            } catch (e) {
                console.error('Failed to fetch garment image from URL for try-on:', e.message);
            }
        }

        const imageUrl = await generateStyleImage(prompt, humanImageBuffer, garmentImageBuffer, garment);
        res.json({ imageUrl, prompt });
    } catch (e) {
        res.status(503).json({ error: e.message || 'Image generation is unavailable right now.', prompt: '' });
    }
});
const port = process.env.PORT || 4000; app.listen(port, () => console.log(`Twinly API listening on ${port}`));
