# Twinly Expo MVP

The requested Android-first React Native app lives in `app/` and the companion Express API in `server/`. The existing Flutter/Python implementation is preserved in `mobile/` and `backend/`.

```powershell
cd server
npm install
npm run dev

# another terminal
cd app
npm install
npx expo start
```

For an Android emulator the default API URL is `http://10.0.2.2:4000`. For a physical device, create `app/.env` with `EXPO_PUBLIC_API_URL=http://YOUR_COMPUTER_LAN_IP:4000`.
