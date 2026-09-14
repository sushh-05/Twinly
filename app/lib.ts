import AsyncStorage from '@react-native-async-storage/async-storage';

export const API_URL = process.env.EXPO_PUBLIC_API_URL || 'http://10.0.2.2:4000';
export type Profile = { height?: string; bust?: string; waist?: string; hip?: string; bodyShape: string; preferredFit: string; skinTone: string; style: string; budget: string };
export type Garment = { category: string; color: string; pattern: string; sleeveLength: string; neckline: string; styleNotes: string };
export type Fit = { recommendedSize: string; confidence: string; regions: { bust: string; waist: string; hip: string }; summary: string };
export type Look = { id: string; imageUrl?: string; garment: Garment; fit: Fit; createdAt: string };
export const profileKey = 'twinly.profile';
export const looksKey = 'twinly.looks';
export async function readProfile(): Promise<Profile | null> { const raw = await AsyncStorage.getItem(profileKey); return raw ? JSON.parse(raw) : null; }
export async function saveProfile(profile: Profile) { await AsyncStorage.setItem(profileKey, JSON.stringify(profile)); try { await fetch(`${API_URL}/api/profile`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(profile) }); } catch {} }
export async function readLooks(): Promise<Look[]> { const raw = await AsyncStorage.getItem(looksKey); return raw ? JSON.parse(raw) : []; }
export async function saveLook(look: Look) { const all = [look, ...(await readLooks())]; await AsyncStorage.setItem(looksKey, JSON.stringify(all)); }
