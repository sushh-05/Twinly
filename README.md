# Twinly

Twinly is an Android-first Flutter virtual styling and fitting app. The repository contains the Flutter client, an Express fashion API, an optional FastAPI API, and the original Expo prototype.

## Repository layout

| Directory | Purpose |
| --- | --- |
| `mobile/` | Flutter application (`com.teamsapphire.twinlyapp`) |
| `server/` | Express API for profile persistence, garment analysis, and AI try-on generation |
| `backend/` | Optional FastAPI catalog and fit-report API |
| `catalog/` | Catalog data used by the FastAPI backend |
| `app/` | Expo/React Native prototype; not required for Flutter |

## Flutter features

- Firebase email/password authentication and local session persistence.
- Four tabs: Avatar, Catalog, Try On, and Saved Looks.
- Slider-based mannequin editor for height, shoulder width, chest/bust, waist, hip, skin tone, hair type, and hair color.
- Two-step fashion profile onboarding shared with the avatar editor.
- Restored dress catalog with products, brand/category filters, search, images, details, size charts, favorites, and try-on entry points.
- Garment photo upload or product URL analysis and AI style-preview generation.
- Local saved looks and free-tier usage limits.
- RevenueCat purchases and restore flow using entitlement `twinly_pro`.
- Settings page with Premium, privacy policy, support, photo consent, account deletion, theme, and logout controls.
- Demo mode for UI work without Firebase or RevenueCat credentials.

## Prerequisites

- Git
- Flutter stable with Dart 3.13+
- Android Studio, Android SDK, and an Android emulator or physical device
- Node.js 18+
- Python 3.11+ for the optional `backend/` API
- Firebase CLI and FlutterFire CLI when regenerating Firebase configuration

```powershell
flutter doctor
node --version
python --version
```

RevenueCat purchases must run on Android or iOS. Chrome/web can preview UI, but `purchases_flutter` is unavailable there.

## Clone and install

```powershell
git clone <REPOSITORY_URL>
cd Twinly

cd mobile
flutter pub get
cd ..

cd server
npm install
cd ..
```

Never commit `.env` files, RevenueCat secret keys, Firebase service-account JSON, or Android signing files.

## Firebase setup

The Android application ID is:

```text
com.teamsapphire.twinlyapp
```

For a new Firebase project:

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
cd mobile
flutterfire configure
```

In Firebase Console, enable Email/Password Authentication. Regenerate `mobile/lib/firebase_options.dart` and `mobile/android/app/google-services.json` for a different Firebase project instead of editing credentials into Dart code.

## RevenueCat setup

Use the existing RevenueCat entitlement:

```text
twinly_pro
```

Attach the existing Monthly, Yearly, and Lifetime Test Store products to the current offering. Use only the public Android SDK key in the app.

Run RevenueCat on an Android device:

```powershell
cd mobile
flutter devices
flutter run -d <ANDROID_DEVICE_ID> `
  --dart-define=DEMO_MODE=false `
  --dart-define=USE_REVENUECAT=true `
  --dart-define=RC_ANDROID_API_KEY=test_YOUR_PUBLIC_ANDROID_KEY
```

Stop and fully rerun after changing any `--dart-define`; hot reload does not change compile-time defines.

## Demo mode

Demo mode skips Firebase initialization and disables RevenueCat. It intentionally does not show real purchase offerings.

```powershell
cd mobile
flutter run -d <ANDROID_DEVICE_ID> `
  --dart-define=DEMO_MODE=true `
  --dart-define=USE_REVENUECAT=false
```

## Express fashion API

The Flutter fashion API defaults to `http://localhost:3000`, while the Express server defaults to port `4000`. For an Android emulator, use `10.0.2.2`:

```powershell
cd server
Copy-Item .env.example .env
npm install
npm run dev
```

Start Flutter with:

```powershell
cd mobile
flutter run -d <ANDROID_DEVICE_ID> `
  --dart-define=API_BASE_URL=http://10.0.2.2:4000 `
  --dart-define=DEMO_MODE=true `
  --dart-define=USE_REVENUECAT=false
```

For a physical phone, replace `10.0.2.2` with the development computer's LAN IP. Verify the server at `http://localhost:4000/health`.

Optional provider keys belong in `server/.env`:

```text
PORT=4000
HUGGINGFACE_API_KEY=your_huggingface_token
TOGETHER_API_KEY=your_together_key
```

## Optional FastAPI backend

```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

This backend is separate from the Express API used by the current fashion try-on flow.

## Flutter configuration defines

| Define | Default | Purpose |
| --- | --- | --- |
| `DEMO_MODE` | `false` | Skip Firebase initialization for local UI work |
| `USE_REVENUECAT` | `false` | Enable native RevenueCat configuration |
| `RC_ANDROID_API_KEY` | empty | Public Android RevenueCat SDK key |
| `REVENUECAT_IOS_KEY` | empty | Public iOS RevenueCat SDK key |
| `API_BASE_URL` | `http://localhost:3000` | Express fashion API base URL |
| `SUPPORT_EMAIL` | empty | Settings support link |
| `PRIVACY_POLICY_URL` | empty | Privacy Policy link |
| `DELETE_ACCOUNT_URL` | empty | Reserved account-deletion link |

## Checks and builds

```powershell
cd mobile
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define=DEMO_MODE=true --dart-define=USE_REVENUECAT=false
```

Production bundle example:

```powershell
flutter build appbundle --release `
  --dart-define=DEMO_MODE=false `
  --dart-define=USE_REVENUECAT=true `
  --dart-define=RC_ANDROID_API_KEY=test_OR_PRODUCTION_PUBLIC_KEY `
  --dart-define=SUPPORT_EMAIL=support@example.com `
  --dart-define=PRIVACY_POLICY_URL=https://example.com/privacy
```

## Troubleshooting

- **RevenueCat unavailable on web:** select an Android emulator or physical device.
- **Premium fallback appears:** confirm `USE_REVENUECAT=true`, pass the public Android key, and fully restart the app.
- **API connection refused on Android emulator:** use `http://10.0.2.2:4000`, not `localhost`.
- **Firebase initialization fails:** verify the package ID and regenerate Firebase files with `flutterfire configure`.
- **Products do not appear:** verify the Test Store products are attached to the current offering and the app uses `twinly_pro`.
- **Stale build behavior:** stop the app, run `flutter clean` if needed, then run `flutter pub get` and restart.
