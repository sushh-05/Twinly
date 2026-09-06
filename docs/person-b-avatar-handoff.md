# Person B handoff: avatar and 3D integration

Hi Person B — the Flutter shell is now in `mobile/`. This document is your contract with the rest of the app.

## What exists for you

- `mobile/lib/features/avatar/screen.dart`: editable avatar screen.
- `mobile/lib/core/providers/avatar_state.dart`: shared measurement state.
- `mobile/lib/features/avatar/body_painter.dart`: temporary 2D silhouette; replace this visual layer, not the shared measurements.
- `mobile/lib/features/fitting/screen.dart`: temporary garment rectangle and regional text results; this is where the 3D try-on belongs.
- `mobile/lib/core/providers/garment_state.dart`: current garment selection.

The app uses `flutter_riverpod`. Read measurements with:

```dart
final measurements = ref.watch(avatarMeasurementsProvider);
```

Available fields are `height`, `chest`, `waist`, `hip`, `inseam`, and `isFeminine`. Values are centimetres, except `isFeminine`, which selects the current profile default.

## Deliverables

1. A lightweight base humanoid `.glb`, ideally one compatible with the sliders below.
2. Three to five simple garment `.glb` assets tied to catalog garment IDs.
3. A documented mapping from each measurement to your blend shapes or scale factors.
4. Named anchors/material groups for `bust`, `waist`, `hip`, and `length` so the fitting screen can color these regions.
5. A fallback image or 2D render if the device cannot render the model.

Put assets under `mobile/assets/models/` and use stable, lowercase names, for example:

```text
mobile/assets/models/avatar_feminine.glb
mobile/assets/models/avatar_masculine.glb
mobile/assets/models/dress_001.glb
```

When adding assets, also add the directory to Flutter's `assets:` list in `mobile/pubspec.yaml`.

## Slider mapping

Use the default body as the scale baseline. Clamp visual deformation to roughly plus/minus 15% so extreme inputs remain believable and avoid clipping garments.

| App field | Region to affect | Suggested behavior |
| --- | --- | --- |
| `height` | whole body | vertical scale; recompute inseam only in shared state |
| `chest` | bust/chest | width/depth blend shape or regional scale |
| `waist` | waist | width/depth blend shape or regional scale |
| `hip` | hips | width/depth blend shape or regional scale |
| `inseam` | legs | leg-length scale, not overall body scale |
| `isFeminine` | base mesh/preset | choose a feminine/masculine default asset or preset |

Do not write slider values into a separate local model state; the Riverpod provider is the source of truth.

## Fit-result visual contract

The backend will eventually return a verdict per region. Use this display mapping:

- `tight` → red overlay, label such as “Snug at waist”
- `good` → green overlay, label such as “Good fit at waist”
- `loose` → blue overlay, label such as “Loose at waist”

Keep overlay material/color code separate from avatar measurement code. Person C and Person A are aligning the backend rule direction before the API is connected.

## Performance and compatibility

- Target Android first. Test on a real mid-range Android phone, not only desktop/web.
- Keep textures small, preferably 1024 px or less for the MVP, and minimize material count/draw calls.
- Avoid cloth physics for the hackathon MVP; the required result is a visual estimate.
- Test with missing/slow asset loading and show a loading indicator plus 2D fallback.
- Browser is an acceptable UI preview, but the delivery target is Android.

## Before handing back

Send Person A/C:

1. Asset paths and the catalog garment ID each asset represents.
2. Exact slider mapping and baseline measurements.
3. Region/material names used for overlays.
4. A short device/performance test result.
5. Any package/platform requirements (for example, `model_viewer_plus`).

The full cross-team workflow is in `docs/integrated-workflow.md`.
