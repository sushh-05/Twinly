# Twinly Express API

From the repository root:

```powershell
cd server
npm install
copy .env.example .env
npm run dev
```

The server still returns a structured demo garment when no Hugging Face key is configured. Image generation uses the configured Hugging Face provider or a non-persistent prompt-only fallback; the frontend always computes and displays its rule-based fit card independently.

Profile saving and account deletion require Firebase ID-token verification. Configure `FIREBASE_PROJECT_ID` and the Firebase web API key as `FIREBASE_WEB_API_KEY`. The web API key is client configuration, not a service-account credential.

The authenticated endpoints are:

- `POST /api/profile` — stores the profile under the authenticated Firebase UID.
- `DELETE /api/account` — idempotently deletes that authenticated user's profile.

Never commit service-account files or private credentials.
