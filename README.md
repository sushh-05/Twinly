# Twinly local setup

Twinly currently contains two runnable services:

- `backend/`: FastAPI fit and styling API, backed by the JSON files in `catalog/`.
- `mobile/`: Android-first Flutter demo app. Its catalog, fit rendering, saved looks, and free-tier limits are currently local Dart state; it does not call the FastAPI API yet.

## Prerequisites

- Python 3.11 or later
- Flutter SDK (the project was created with Dart 3.13)
- Android Studio, an Android emulator, or a physical Android device with USB debugging enabled

Run `flutter doctor` and resolve any Android toolchain/device issues it reports before starting the mobile app.

## 1. Start the backend

From the repository root, in PowerShell:

```powershell
cd backend
.\venv\Scripts\Activate.ps1
uvicorn app.main:app --reload --port 8000
```

If `backend\venv` is missing, create it and install the pinned dependencies first:

```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Verify it at `http://127.0.0.1:8000/health` or open `http://127.0.0.1:8000/docs` for the interactive API.

## 2. Start the Flutter app

Keep the backend terminal open, then use a second PowerShell terminal:

```powershell
cd mobile
flutter pub get
flutter devices
flutter run
```

Choose an Android device when prompted. On a physical phone, Firebase is already included in the Android project. RevenueCat is deliberately disabled by default so a fresh clone can run without a purchase key.

Chrome or Edge can also be selected for a quick UI preview. Purchases are
automatically disabled on web because they require the Android/iOS store SDK.

To test a configured RevenueCat project, use its Android **public** SDK key:

```powershell
flutter run --dart-define=REVENUECAT_ANDROID_KEY=goog_your_public_key
```

## Checks

```powershell
cd backend
.\venv\Scripts\python.exe -m pytest -q

cd ..\mobile
flutter analyze
flutter test
```

## Current integration boundary

The backend endpoints are ready at `POST /fit-check` and `POST /style-suggestions`, but no Flutter HTTP client has been connected yet. Therefore, starting both processes is useful for backend testing, but the app currently shows its built-in demo garments and computes the fit on-device. Firebase configuration is present, though sign-in and Firestore persistence have not been connected to the screens. The paywall is still a placeholder screen; supplying a RevenueCat key only configures the SDK and does not make purchasing functional by itself.
