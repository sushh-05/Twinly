# fit_style_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



# App spec — measurements, navigation, and saved avatars

## 1. Core measurement state

- One shared `AvatarMeasurements` object: `height`, `chest`, `waist`, `hip`, `inseam`, `isFeminine`.
- Implemented as a Riverpod `Notifier` (not the older `StateNotifier`) — matches `flutter_riverpod: ^3.4.1`.
- `setHeight()` auto-recalculates `inseam = height * 0.45`.
- `isFeminine` matches the existing `BodyPainter`'s expected field — no renaming needed there.
- **Gender toggle behavior**: `setGender()` replaces the *entire* measurement object with that gender's defaults. It does **not** preserve previously customized numbers — switching gender is treated as switching to a different person, not relabeling the same body. Confirmed and accepted.
- This state is the single source of truth read by the Avatar screen, Catalog (where relevant), Fitting screen, and the Fitting tab's "last result."

## 2. Bottom navigation — 4 tabs, always reachable

| Tab | Purpose |
|---|---|
| Avatar | Sliders + gender toggle — editable anytime, for anyone |
| Catalog | Browse dresses |
| Fitting | Last try-on result — updates each time the user tries something on |
| Account | Subscription status, upgrade button, saved looks (if premium), log out |

## 3. Signup

- Fields collected once: **gender, email, name**. No phone number.
- The gender picked at signup immediately loads that gender's default measurements into the Avatar tab.

## 4. Free vs. premium limits

Two separate, independent limits on the free tier:

- **Try-on views**: 3 lifetime views total (Fitting results).
- **Saves**: of those, only **1** can be kept as a persistent saved entry.
- These limits are independent — using up try-on views does not affect the save limit, and vice versa.
- **Premium**: unlimited try-on views, unlimited saves.
- **Share**: explicitly out of scope for now.

## 5. Saved-avatar feature

- Saving takes a **snapshot** of the current state at the moment of saving — it is not live-linked. Later changes to the working avatar (including gender toggles) do not retroactively affect anything already saved.
- A saved entry is **re-rendered live** every time it's opened (body shape + dress drawn fresh from data) — no image is ever stored.
- A saved entry stores exactly:
  - The 6 measurement fields
  - A name (e.g. "Me", "Brother")
  - A garment reference (an ID/key identifying the dress — not the dress's image)
- Garment selection happens on the **Catalog** page and flows into the **Fitting** page, where the save action itself occurs and the garment reference is attached.
- **Free tier**: 1 save allowed, free. A 2nd save attempt is hard-blocked with an upgrade prompt. The 1st saved entry is never touched or overwritten by this.
- **Premium tier**: unlimited saves. Each save creates a new, separate entry — never overwrites an existing one.
- **Duplicate check**: before creating a new entry, compare name + measurements + garment reference against all existing saved entries.
  - If **all three** match an existing entry exactly → prompt: "Already saved — save as a new copy, or skip?"
  - If **any** of the three differs → save silently as a new entry, no prompt.

## Not yet decided / not yet built

- Catalog and Fitting pages themselves don't exist yet — no screens, no garment-selection state, no "currently selected dress" provider.
- No `savedAvatarsProvider` (or equivalent list-of-saved-entries state) has been designed or written yet.
- No tier-check (free vs. premium) logic has been designed yet — only the behavior it needs to enforce.
- No code has been written for the saved-avatar decisions — everything above is spec only.