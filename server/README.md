# Twinly Express API

From the repository root:

```powershell
cd server
npm install
copy .env.example .env
npm run dev
```

The server still returns a structured demo garment when no Hugging Face key is configured. Image generation requires `TOGETHER_API_KEY`; the frontend always computes and displays its rule-based fit card independently.
