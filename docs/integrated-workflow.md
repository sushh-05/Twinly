# Twinly integrated workflow

This is the shared reference for connecting the Flutter app (Person A), 3D avatar assets (Person B), and fit/styling/monetization services (Person C).

## Architecture

```text
Flutter mobile app
  ├─ onboarding/profile and avatar measurements
  ├─ catalog, avatar, fitting, saved looks, account/paywall UI
  ├─ Person B GLB avatar + garment assets and visual overlays
  └─ HTTP calls
       └─ FastAPI backend
            ├─ catalog JSON
            ├─ fit engine
            ├─ styling rules
            └─ later: Firebase and RevenueCat server-side checks

Firebase: authentication + persistent user profile/saved looks
RevenueCat: subscription entitlement (`premium_access`)
Merchant: external purchase URL opened only after an explicit user tap
```

## End-to-end user journey

1. The user opens the Flutter app and creates a local profile with name, email, and profile type.
2. The avatar screen collects or adjusts height, chest/bust, waist, hip, and inseam. These values are the shared `AvatarMeasurements` state.
3. The user chooses a garment in the catalog. The app keeps the selected garment ID, requested size, and catalog metadata in shared state.
4. On **Try on**, the app sends the selected garment, size, and measurements to the backend. The backend loads the garment's size chart and returns regional fit estimates.
5. Flutter renders Person B's body and garment assets, then overlays the fit result: red = tight, green = good, blue = loose. The screen always says the result is an estimate, not a guarantee.
6. Flutter requests styling suggestions using the chosen occasion and budget, and shows hairstyle/accessory/footwear/makeup guidance.
7. A free user is limited to three fitting results and one saved look. A RevenueCat entitlement changes these limits to unlimited for premium users.
8. A saved look stores a snapshot: name, measurements, garment ID, chosen size, and fit result. It must not change when the active avatar later changes.
9. **Buy now** opens the product's merchant URL outside Twinly, with a clear leaving-app disclosure.

## Backend contract

Start the API from `backend/`:

```powershell
.\venv\Scripts\Activate.ps1
uvicorn app.main:app --reload --port 8000
```

| Endpoint | Request | Response/use |
| --- | --- | --- |
| `GET /health` | none | `{ "status": "ok" }` |
| `POST /fit-check` | `garment_id`, `size`, `user_measurements` | regional fit report for the requested garment size |
| `POST /style-suggestions` | `occasion`, `budget` | hairstyle, up to two accessories, and explanatory text |

Example fit request:

```json
{
  "garment_id": "dress_001",
  "size": "M",
  "user_measurements": {
    "bustCm": 92,
    "waistCm": 76,
    "hipCm": 100
  }
}
```

For an Android emulator, use `http://10.0.2.2:8000`; for Chrome use `http://localhost:8000`; and for a physical phone use the computer's LAN IP, for example `http://192.168.x.x:8000`. The backend will need a CORS policy before Flutter web sends requests.

## Current implementation status

The repository runs today, but it is not fully wired end-to-end yet:

- Flutter currently uses a local Dart demo catalog and a local fit calculation.
- FastAPI independently uses `catalog/garments.json` and exposes the endpoints above.
- Flutter garment IDs (`g001` through `g006`) do not match backend IDs (`dress_001`, `shirt_001`). The catalog must become a single shared source before API wiring.
- Flutter's measurement names are `chest`, `waist`, and `hip`; the backend dress chart uses `bustCm`, `waistCm`, and `hipCm`. Add an explicit mapping at the HTTP boundary.
- The tight/loose rule direction differs between the current Flutter and Python engines. Agree on one meaning and test it before displaying backend results.
- Firebase configuration exists, but sign-in and Firestore persistence are not connected to the screens.
- RevenueCat is initialized only when a public SDK key is passed at build time. The paywall UI is still a placeholder.
- Browser mode is supported for UI previews only; RevenueCat is skipped there. Use Android to test purchases.

## Integration order

1. Make the catalog schema and garment IDs identical on client and backend.
2. Add a Flutter API client, including emulator/phone base URLs and user-friendly loading/error states.
3. Replace the local fit result with the backend response, retaining the local calculation only as an offline fallback if wanted.
4. Integrate Person B's `model_viewer_plus` GLB assets and map the backend regional verdicts to visible overlays.
5. Persist authenticated profiles and saved-look snapshots to Firestore.
6. Fetch RevenueCat customer information, derive `isPremium` from `premium_access`, and implement purchase/restore flows.
7. Test the complete journey on a physical Android device.

## Ownership

| Owner | Responsible for |
| --- | --- |
| Person A | Flutter screens, shared UI state, API client, Firebase UI flows, Android UI testing |
| Person B | Base avatar and garment GLBs, body-slider visual mapping, regional overlay anchors, mobile rendering performance |
| Person C | Catalog schema/data, FastAPI fit and styling behavior, API contract, Firebase persistence rules, RevenueCat configuration |

