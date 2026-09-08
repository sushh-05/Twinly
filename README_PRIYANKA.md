# Person 3 Deliverables — Assets, Catalog Data, Quality, UI & Demo
**Branch:** `priyanka`  
**Author:** Priyanka (Person 3)  
**Deliverables:** Catalog assets, verified brand size charts, neutral avatars, light/dark mode UI, categories, dress details, fitting analytics, and quality testing.

---

## 📌 Overview

This branch delivers all **Person 3** responsibilities outlined in the Shipaton build plan and Figma UX specifications:
1. **Curated & Verified Dress Catalog:** 8 real-world dress products from leading brands (**Aurelia**, **Vero Moda**, **ZARA**, **H&M**).
2. **Fashion Categories & Brand Filters:**
   - **Categories**: `All Dresses`, `Wrap Midi`, `A-Line`, `Party & Satin`, `Floral`, `Casual Poplin`
   - **Brands**: `All`, `Aurelia`, `Vero Moda`, `ZARA`, `H&M`
3. **Dynamic Light & Dark Theme System:**
   - One-tap toggle via AppBar or Account settings.
   - **Dark Theme**: OLED pitch black (`#000000`) with sleek `#161616` cards and teal accents (`#26A69A`).
   - **Light Theme**: Crisp `#F7F8FA` background, pure white `#FFFFFF` cards, dark charcoal typography, and subtle shadows.
4. **Verified Size Charts:** Authentic tailoring measurements in **cm** (Bust, Waist, Hip, Length) across sizes **S, M, L, XL** with fabric stretch and silhouette metadata.
5. **High-Fidelity Assets:**
   - 8 product catalog photos standardized to 600×800 px (3:4 portrait ratio).
   - 6 neutral 3D avatar placeholders (Female/Male × Slim/Average/Curvy/Broad).
   - App branding assets: `app_logo.png`, `empty_state.png`, and `placeholder_dress.png`.
6. **Figma Screen Implementation:**
   - **Catalog Screen**: Verified badges, interactive search, favorite hearts, individual teal `Try on` button per card.
   - **Dress Details Screen**: Hero studio imagery, silhouette/stretch specs, interactive `S/M/L/XL` selector, `View size chart` link, and `Check my fit` CTA.
   - **Structural Size Chart Sheet**: Modal displaying tailored bust, waist, and length ranges in cm.
   - **Fitting Screen**: Color-coded fit breakdown (`Bust`, `Waist`, `Hips`, `Length`), explainable `Why L?` box, avatar/dress visual toggle, and `Save look` overlay with quota enforcement.
   - **Account Screen**: Greeting (`Hi, Anushila`), real-time usage progress bars (try-ons and saves remaining), theme switcher, photo privacy consent dialog, and avatar data deletion.
   - **Paywall Screen**: Golden Crown presentation (`Unlock Twinly Premium`), feature checklist, mock purchase upgrade.
7. **Testing & QA:** Zero lint warnings on `flutter analyze` (`0 issues`), 100% passing tests (`flutter test`), and verified on Android emulator (`API 35`).

---

## 👗 Verified Dresses Catalog

| ID | Brand | Name | Category & Silhouette | Fabric Stretch & Material | Price | Local Asset |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `dress_aurelia_01` | **Aurelia** | Blue Floral Wrap Midi Dress | Wrap Midi • Floral | Low stretch • 100% Rayon Viscose | ₹2,499 | `assets/dresses/dress_aurelia_blue.png` |
| `dress_veromoda_02` | **Vero Moda** | Charcoal Floral Wrap Midi Dress | Wrap Midi • Floral | Medium stretch • 95% Poly, 5% Elastane | ₹2,499 | `assets/dresses/dress_veromoda_charcoal.png` |
| `dress_zara_03` | **ZARA** | Printed Satin Wrap Midi Dress | Party & Satin • Wrap | Non-stretch • 100% Satin Viscose | ₹3,590 | `assets/dresses/dress_zara_satin.png` |
| `dress_hm_04` | **H&M** | Floral V-Neck Smocked Dress | A-Line • Floral | High stretch • 98% Cotton, 2% Elastane | ₹1,999 | `assets/dresses/dress_hm_floral.png` |
| `dress_aurelia_05` | **Aurelia** | Coral Red A-Line Wrap Midi Dress | A-Line • Wrap | Low stretch • 100% Chanderi Viscose | ₹2,499 | `assets/dresses/dress_aurelia_coral.png` |
| `dress_aurelia_06` | **Aurelia** | Sage Mint Floral Wrap Midi Dress | Wrap Midi • Floral | Low stretch • 100% Cotton Cambric | ₹2,499 | `assets/dresses/dress_aurelia_sage.png` |
| `dress_veromoda_07` | **Vero Moda** | Maroon Wine Wrap Midi Dress | Wrap Midi • Crepe | Medium stretch • 97% Crepe, 3% Spandex | ₹2,499 | `assets/dresses/dress_veromoda_maroon.png` |
| `dress_zara_08` | **ZARA** | Poplin Cut-Out Tiered Dress | Casual Poplin • Tiered | Low stretch • 100% Cotton Poplin | ₹2,990 | `assets/dresses/dress_zara_poplin.png` |

---

## 📂 File & Directory Architecture

```text
Twinly/
├── README_PRIYANKA.md                       <-- This file
├── catalog/
│   ├── dresses.json                         <-- Standard Person 2 JSON dataset
│   ├── garments.json                        <-- Enriched backend/Firestore schema (8 items)
│   └── size_charts.json                     <-- Complete size chart dictionary by garment ID
└── mobile/
    ├── pubspec.yaml                         <-- Registered dresses, avatars, images & data assets
    ├── assets/
    │   ├── dresses/                         <-- 8 product images (600x800 px)
    │   ├── avatars/                         <-- 6 neutral avatar silhouettes
    │   ├── images/                          <-- app_logo.png, empty_state.png, placeholder_dress.png
    │   └── data/dresses.json                <-- Offline bundled catalog
    └── lib/
        ├── models/garment.dart              <-- Extended with brand, imagery, price & verified chart
        ├── core/
        │   ├── providers/theme_state.dart   <-- Riverpod NotifierProvider for Light/Dark mode
        │   └── data/garment_catalog.dart   <-- 8 verified dresses populated in offline fallback
        ├── widgets/
        │   ├── garment_image.dart           <-- Asset-first image loader with network fallback
        │   └── size_chart_sheet.dart        <-- 4-column modal sheet for structural measurements
        └── features/
            ├── catalog/
            │   ├── screen.dart              <-- Light/Dark catalog with category tabs & brand chips
            │   └── dress_details_screen.dart <-- Hero details screen with size selector & CTA
            ├── fitting/screen.dart          <-- Fit breakdown, Why [Size] box, save look modal
            ├── account/screen.dart          <-- Free plan usage bars, theme switcher, privacy controls
            └── paywall/screen.dart          <-- Unlock Twinly Premium with Golden Crown presentation
```

---

## 🚀 How to Run & Verify

### 1. Analyze Code Quality
```powershell
cd mobile
flutter analyze --no-pub
```
*Result: `No issues found!`*

### 2. Run Automated Tests
```powershell
cd mobile
flutter test --no-pub
```
*Result: `All tests passed!` (Includes `fit_report_test.dart` and `widget_test.dart`).*

### 3. Run on Device / Emulator
```powershell
cd mobile
flutter run
```
- **Phase 1 Complete UI Overhaul (Catalog, Details, Fitting, Avatar, Paywall, Auth & Multi-Person Profiles)**:
  - **Account Screen Clean Session Management**: Removed redundant "Create new account" button from the bottom of Account Screen; kept only the prominent, secure "Log out" button with confirmation dialog.
  - **Best-in-Class Auth & Onboarding (`SignInSignUpScreen`)**:
    - Segmented switcher for **Create Account** and **Sign In**.
    - Account creation captures **Full Name**, **Email**, **Password**, **Body Frame / Gender** (Feminine vs Masculine styled cards), and **Standard Size Presets** (`XS`, `S`, `M`, `L`, `XL`, `XXL`).
    - Live real-time preview of starting dimensions (`Height`, `Bust/Chest`, `Waist`, `Hip`).
    - Quick guest mode bypass for demo testing.
  - **Multiple Named Avatar Profiles Under One Account**:
    - Users can save and switch between multiple named person profiles under their single login (e.g. "Priya (Me)", "Sister", "Mom", "Friend").
    - Profile Switcher banner embedded at the top of both **Fitting Screen** and **Avatar Screen**.
    - Tapping the banner opens the **Avatar Profiles Bottom Sheet** with instant switching, deleting, and a dialog to "+ Add another person / profile".
    - Size presets and custom centimetre sliders update immediately per person.
    - Saved looks record which person the garment was fitted for.
  - **Router & Theme Stability**: Navigation route caching ensures dark/light mode switches maintain the user's exact screen without unwanted navigation resets.

---

## 🔄 Git Push Instructions

To stage, commit, and push these deliverables to your remote `priyanka` branch on GitHub:

```powershell
git add .
git commit -m "feat(catalog): add categories, dark/light theme, dress details, and fitting analytics UI"
git push -u origin priyanka
```

Then create your Pull Request against `dev` at:
👉 **https://github.com/sushh-05/Twinly/pull/new/priyanka**
