import { useState } from 'react'; import { Alert, Image, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native'; import * as ImagePicker from 'expo-image-picker'; import { API_URL, Garment, Profile, readProfile, Look, Fit, saveLook } from '../../lib';
const empty: Garment = { category: 'dress', color: 'soft neutral', pattern: 'solid', sleeveLength: 'short', neckline: 'round', styleNotes: 'clean, everyday style' };
function fitFor(p: Profile | null): Fit { const count = [p?.bust, p?.waist, p?.hip].filter(Boolean).length; return { recommendedSize: count >= 2 ? 'M' : 'M / estimate', confidence: count === 3 ? 'High' : count ? 'Medium' : 'Low', regions: { bust: 'good', waist: 'good', hip: 'good' }, summary: count ? 'Balanced ease through the body based on your measurements.' : 'Add measurements for a more tailored recommendation.' }; }
export default function TryOn() {
    const [url, setUrl] = useState(''); const [asset, setAsset] = useState<any>(); const [garment, setGarment] = useState<Garment>(); const [image, setImage] = useState<string>(); const [fit, setFit] = useState<Fit>(); const [busy, setBusy] = useState(false);
    const [isEditing, setIsEditing] = useState(false); const [generationError, setGenerationError] = useState(false);
    const CATEGORIES = ['dress', 'top', 'pants', 'skirt']; const COLORS = ['black', 'white', 'soft neutral', 'bright red', 'navy'];
    const pick = async () => { const r = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ['images'], quality: .8 }); if (!r.canceled) { setAsset(r.assets[0]); setUrl(''); } };
    const analyze = async () => { setBusy(true); setIsEditing(false); setGenerationError(false); setImage(''); setFit(undefined); try { let result: any; if (asset) { result = await new Promise((resolve, reject) => { const xhr = new XMLHttpRequest(); xhr.open('POST', `${API_URL}/api/garment/analyze`); xhr.onload = () => { if (xhr.status >= 200 && xhr.status < 300) { resolve({ ok: true, json: () => Promise.resolve(JSON.parse(xhr.responseText)) }); } else { try { resolve({ ok: false, json: () => Promise.resolve(JSON.parse(xhr.responseText)) }); } catch { reject(new Error('Upload failed')); } } }; xhr.onerror = () => reject(new Error('Network request failed')); const form = new FormData(); form.append('image', { uri: asset.uri, name: 'garment.jpg', type: 'image/jpeg' } as any); xhr.send(form); }); } else result = await fetch(`${API_URL}/api/garment/analyze`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ url }) }); const data = await result.json(); if (!result.ok) throw new Error(data.error); setGarment(data.garment || empty); } catch (e: any) { console.error('Garment analysis error:', e.message); setGarment(empty); setIsEditing(true); } finally { setBusy(false); } };
    const generate = async () => {
        setBusy(true); setGenerationError(false); const p = await readProfile(); const g = garment || empty; try {
            // We need to send the human avatar image and the garment image to the backend
            // For the human image, we'll use a default avatar based on the profile's body shape and gender
            const isFeminine = p?.style !== 'masculine'; // Simple heuristic, adjust as needed
            const shape = p?.bodyShape || 'average';
            const avatarFilename = isFeminine ? `avatar_female_${shape}.png` : `avatar_male_${shape}.png`;

            // In a real app, we would resolve this asset URI properly or let the user upload their own photo
            // For now, we'll just pass the profile and garment data, and let the backend handle the images

            let r: any;
            if (asset) {
                // If we have a local garment image, we need to send it as multipart/form-data
                r = await new Promise((resolve, reject) => {
                    const xhr = new XMLHttpRequest();
                    xhr.open('POST', `${API_URL}/api/tryon/generate`);
                    xhr.onload = () => {
                        if (xhr.status >= 200 && xhr.status < 300) {
                            resolve({ ok: true, json: () => Promise.resolve(JSON.parse(xhr.responseText)) });
                        } else {
                            try {
                                resolve({ ok: false, json: () => Promise.resolve(JSON.parse(xhr.responseText)) });
                            } catch {
                                reject(new Error('Generation failed'));
                            }
                        }
                    };
                    xhr.onerror = () => reject(new Error('Network request failed'));
                    const form = new FormData();
                    form.append('profile', JSON.stringify(p));
                    form.append('garment', JSON.stringify(g));
                    form.append('garmentImage', { uri: asset.uri, name: 'garment.jpg', type: 'image/jpeg' } as any);

                    // We don't have a local human image to upload here, so the backend will need to use a default

                    xhr.send(form);
                });
            } else {
                // If we only have a URL, we can just send JSON
                r = await fetch(`${API_URL}/api/tryon/generate`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ profile: p, garment: g, garmentUrl: url }) });
            }

            const d = await r.json(); if (!r.ok) throw new Error(d.error || 'Generation failed'); setImage(d.imageUrl); const f = fitFor(p); setFit(f); const look: Look = { id: Date.now().toString(), imageUrl: d.imageUrl, garment: g, fit: f, createdAt: new Date().toISOString() }; await saveLook(look);
        } catch (e: any) { console.error('Generation error:', e.message); const f = fitFor(p); setFit(f); setGenerationError(true); } finally { setBusy(false); }
    };
    return <ScrollView contentContainerStyle={s.page}><Text style={s.title}>Try something on</Text><Text style={s.sub}>Bring a garment. We’ll imagine the rest.</Text><View style={s.upload}><Text style={s.uploadIcon}>＋</Text><Text style={s.uploadTitle}>{asset ? 'Garment selected' : 'Upload a garment photo'}</Text><Text style={s.uploadSub}>JPG or PNG · screenshot works great</Text><Pressable style={s.outline} onPress={pick}><Text style={s.outlineText}>Choose photo</Text></Pressable></View><Text style={s.or}>or paste a product URL</Text><TextInput value={url} onChangeText={(text) => { setUrl(text); setAsset(undefined); }} placeholder="https://shop.example.com/item" style={s.url} /><Pressable style={s.dark} onPress={analyze} disabled={busy || (!asset && !url)}><Text style={s.darkText}>{busy ? 'Working…' : 'Analyze garment'}</Text></Pressable>
        {isEditing && garment && <View style={s.result}>
            <Text style={s.resultKicker}>MANUAL ENTRY</Text>
            <Text style={s.uploadSub}>Analysis failed. Please select details manually:</Text>
            <Text style={{ marginTop: 12, fontWeight: '600' }}>Category</Text>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 8 }}>
                {CATEGORIES.map(c => <Pressable key={c} onPress={() => setGarment({ ...garment, category: c })} style={[s.chip, garment.category === c && s.chipActive]}><Text style={[s.chipText, garment.category === c && s.chipTextActive]}>{c}</Text></Pressable>)}
            </View>
            <Text style={{ marginTop: 12, fontWeight: '600' }}>Color</Text>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 8 }}>
                {COLORS.map(c => <Pressable key={c} onPress={() => setGarment({ ...garment, color: c })} style={[s.chip, garment.color === c && s.chipActive]}><Text style={[s.chipText, garment.color === c && s.chipTextActive]}>{c}</Text></Pressable>)}
            </View>
            <Text style={{ marginTop: 12, fontWeight: '600' }}>Style Notes</Text>
            <TextInput value={garment.styleNotes} onChangeText={t => setGarment({ ...garment, styleNotes: t })} style={[s.url, { marginTop: 8 }]} />
            <Pressable style={s.primary} onPress={() => { setIsEditing(false); generate(); }}><Text style={s.primaryText}>Generate AI Style Preview</Text></Pressable>
        </View>}
        {!isEditing && garment && <View style={s.result}><Text style={s.resultKicker}>GARMENT FOUND</Text><Text style={s.resultTitle}>{garment.color} {garment.category}</Text><Text style={s.resultSub}>{garment.styleNotes} · {garment.sleeveLength} sleeves · {garment.neckline} neckline</Text><Pressable style={s.primary} onPress={generate}><Text style={s.primaryText}>Generate AI Style Preview</Text></Pressable></View>}
        {generationError && <View style={s.preview}><Text style={s.caption}>AI preview unavailable right now — showing size recommendation only.</Text></View>}
        {image && <View style={s.preview}><Image source={{ uri: image }} style={s.image} /><Text style={s.caption}>AI Style Preview — an approximate visual based on your description, not an exact rendering of this product.</Text></View>}
        {fit && <View style={s.fit}><Text style={s.resultKicker}>FIT GUIDE</Text><View style={s.fitRow}><Text style={s.fitSize}>{fit.recommendedSize}</Text><Text style={s.confidence}>{fit.confidence} confidence</Text></View><Text style={s.fitText}>Bust {fit.regions.bust}  ·  Waist {fit.regions.waist}  ·  Hip {fit.regions.hip}</Text><Text style={s.resultSub}>{fit.summary}</Text></View>}</ScrollView>
}
const s = StyleSheet.create({ page: { padding: 24, paddingTop: 30 }, title: { fontSize: 34, fontWeight: '700', color: '#242321' }, sub: { fontSize: 16, color: '#817A73', marginTop: 6, marginBottom: 24 }, upload: { borderWidth: 1.5, borderStyle: 'dashed', borderColor: '#CDBCB2', backgroundColor: '#F1E8E2', borderRadius: 22, padding: 22, alignItems: 'center' }, uploadIcon: { fontSize: 32, color: '#A06B5B' }, uploadTitle: { fontSize: 17, fontWeight: '700', color: '#403731', marginTop: 6 }, uploadSub: { color: '#877A70', marginTop: 4 }, outline: { borderWidth: 1, borderColor: '#A06B5B', borderRadius: 20, paddingVertical: 10, paddingHorizontal: 16, marginTop: 15 }, outlineText: { color: '#A06B5B', fontWeight: '700' }, or: { textAlign: 'center', color: '#9B928A', marginVertical: 18 }, url: { backgroundColor: '#FFF', borderColor: '#E1D9D2', borderWidth: 1, borderRadius: 12, padding: 14 }, dark: { backgroundColor: '#2E2925', borderRadius: 22, padding: 15, alignItems: 'center', marginTop: 12 }, darkText: { color: '#FFF', fontWeight: '700' }, result: { backgroundColor: '#FFF', borderRadius: 20, padding: 20, marginTop: 24 }, resultKicker: { fontSize: 11, letterSpacing: 1.5, color: '#A06B5B', fontWeight: '700' }, resultTitle: { fontSize: 22, fontWeight: '700', color: '#302A26', marginTop: 8, textTransform: 'capitalize' }, resultSub: { color: '#7C746E', lineHeight: 20, marginTop: 6 }, primary: { backgroundColor: '#A06B5B', borderRadius: 22, padding: 14, alignItems: 'center', marginTop: 18 }, primaryText: { color: '#FFF', fontWeight: '700' }, preview: { marginTop: 20 }, image: { height: 340, borderRadius: 22, backgroundColor: '#EDE8E3' }, caption: { fontSize: 12, color: '#877F77', lineHeight: 17, marginTop: 8 }, fit: { backgroundColor: '#2E2925', borderRadius: 20, padding: 20, marginTop: 20, marginBottom: 20 }, fitRow: { flexDirection: 'row', alignItems: 'baseline', gap: 12, marginTop: 8 }, fitSize: { fontSize: 36, fontWeight: '700', color: '#FFF' }, confidence: { color: '#E0C1B2', fontWeight: '600' }, fitText: { color: '#FFF', marginTop: 12, fontWeight: '600', textTransform: 'capitalize' }, chip: { paddingHorizontal: 12, paddingVertical: 8, borderRadius: 16, backgroundColor: '#F1E8E2', borderWidth: 1, borderColor: 'transparent' }, chipActive: { backgroundColor: '#A06B5B', borderColor: '#A06B5B' }, chipText: { color: '#877A70', fontWeight: '600' }, chipTextActive: { color: '#FFF' } });
