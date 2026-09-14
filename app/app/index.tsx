import { Redirect } from 'expo-router';
import { useEffect, useState } from 'react';
import { readProfile } from '../lib';
export default function Index() { const [ready, setReady] = useState(false); const [hasProfile, setHasProfile] = useState(false); useEffect(() => { readProfile().then(p => { setHasProfile(!!p); setReady(true); }); }, []); if (!ready) return null; return <Redirect href={hasProfile ? '/(tabs)' : '/onboarding'} />; }
