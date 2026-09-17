const axios = require('axios');

async function verifyFirebaseIdToken(token) {
  const apiKey = process.env.FIREBASE_WEB_API_KEY;
  if (!apiKey) {
    throw new Error('FIREBASE_WEB_API_KEY is not configured.');
  }

  const response = await axios.post(
    `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${encodeURIComponent(apiKey)}`,
    { idToken: token },
    { timeout: 10000 },
  );
  const user = response.data?.users?.[0];
  if (!user?.localId) throw new Error('Firebase token has no user ID.');
  return { uid: user.localId };
}

async function requireFirebaseUser(req, res, next) {
  const authorization = req.get('authorization') || '';
  if (!authorization.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Firebase authorization is required.' });
  }

  try {
    const token = authorization.substring('Bearer '.length).trim();
    req.firebaseUser = await verifyFirebaseIdToken(token);
    return next();
  } catch (error) {
    console.error('Firebase token verification failed:', error.message);
    return res.status(401).json({ error: 'Firebase authorization is invalid.' });
  }
}

module.exports = { requireFirebaseUser };
