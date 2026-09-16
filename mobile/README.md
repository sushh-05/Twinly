# Twinly Flutter app

This directory contains the Android-first Flutter client. The package ID is `com.teamsapphire.twinlyapp`.

For full repository setup, Firebase, RevenueCat, backend, and teammate instructions, read the [repository README](../README.md).

## Quick start: UI/demo mode

```powershell
flutter pub get
flutter devices
flutter run -d <ANDROID_DEVICE_ID> `
  --dart-define=DEMO_MODE=true `
  --dart-define=USE_REVENUECAT=false
```

Demo mode keeps the UI runnable without Firebase or RevenueCat credentials. It does not perform real purchases.

## RevenueCat Test Store mode

Run on Android, not Chrome/web:

```powershell
flutter run -d <ANDROID_DEVICE_ID> `
  --dart-define=DEMO_MODE=false `
  --dart-define=USE_REVENUECAT=true `
  --dart-define=RC_ANDROID_API_KEY=test_YOUR_PUBLIC_ANDROID_KEY
```

The existing RevenueCat entitlement is `twinly_pro`. The Monthly, Yearly, and Lifetime products must be attached to the current offering in RevenueCat.

## Fashion API mode

Start the Express API from the repository root with `npm run dev` in `server/`, then use:

```powershell
flutter run -d <ANDROID_DEVICE_ID> `
  --dart-define=API_BASE_URL=http://10.0.2.2:4000 `
  --dart-define=DEMO_MODE=true `
  --dart-define=USE_REVENUECAT=false
```

Use the computer's LAN IP instead of `10.0.2.2` on a physical phone.

## App structure

- `lib/main.dart`: Firebase, RevenueCat, and provider registration.
- `lib/core/router.dart`: onboarding, settings, and four-tab navigation.
- `lib/features/avatar/`: slider/mannequin avatar editor.
- `lib/features/catalog/` and `lib/core/data/garment_catalog.dart`: restored dress catalog.
- `lib/features/fashion/`: profile onboarding, fashion catalog, try-on, and saved-look flows.
- `lib/features/paywall/`: RevenueCat purchase and restore UI.
- `lib/features/settings/`: dedicated Settings entry point.
- `lib/services/`: authentication, RevenueCat, fashion API, and persisted fashion state.

## Validation

```powershell
dart format lib test
flutter analyze
flutter test
```

Do not commit `.env` files, API keys, RevenueCat secret keys, service-account JSON, keystores, or signing credentials.
