# Fashion Fit App — Shipaton 2026 Build Plan

Team of 3 · Android-first · International audience · 3D avatar + fit + styling MVP

---

## 1. How to Get Started From Scratch (Each Person, Independently)

### Shared setup (do together first, Day 1 — 1 hour max)

1. Pick the app name (placeholder is fine, e.g. "FitMuse").
2. Create a shared GitHub organization/repo with three folders: `mobile/`, `backend/`, `catalog/`.
3. Create a shared Google account or Firebase project owner account.
4. Create a shared Notion/Google Doc for daily standups (what I did / what's blocked).
5. Create a shared Figma (free) file for screens, even rough boxes.
6. Decide the app's primary color palette and name so nobody blocks on branding later.
7. Create a private Discord/WhatsApp group for the 3 of you + a #blockers channel.

Once this is done, each person works independently using their own task list below.

---

### PERSON A — Mobile App & UI (Flutter)

**Goal:** Everything the user sees and taps.

**Setup from scratch:**
1. Install Flutter SDK + Android Studio + VS Code (Flutter/Dart extensions).
2. Run `flutter doctor` until all checks pass.
3. Create project: `flutter create fashion_fit_app`.
4. Set up folder structure: `lib/core`, `lib/models`, `lib/services`, `lib/features/{onboarding,avatar,catalog,fitting,styling,saved_looks,paywall}`.
5. Add packages: `model_viewer_plus`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `purchases_flutter` (RevenueCat), `provider` or `riverpod` for state management.
6. Connect Firebase to the Flutter app (Android app registration, `google-services.json`).
7. Build a basic 5-screen skeleton with dummy data first (no backend yet): Onboarding → Avatar → Catalog → Fit Result → Saved Looks.
8. Push to GitHub, confirm the app runs on a real Android phone or emulator.

**Ongoing responsibility:** UI/UX for every screen, camera permission handling, avatar slider UI, catalog browsing UI, paywall screen, store listing assets (icon, screenshots), demo video recording.

---

### PERSON B — 3D Pipeline & Computer Vision

**Goal:** The avatar, garments, and visual overlay system.

**Setup from scratch:**
1. Install Blender (free) for creating/editing the base avatar mesh.
2. Get a free base humanoid mesh from MakeHuman (open-source, free) or Ready Player Me free tier.
3. Add basic shape keys/blend shapes for height, waist, hip, chest, leg length (Blender tutorial: "shape keys for body sliders").
4. Export the avatar as `.glb`.
5. Install `model_viewer_plus` in a throwaway Flutter test project and confirm the `.glb` renders and rotates on a phone.
6. Set up MediaPipe Tasks (Pose Landmarker + Face Landmarker) — start with their official sample app to confirm on-device detection works on your test phone before integrating.
7. Prepare 3–5 placeholder garment meshes (simple flat/tagged shapes are fine initially — visual polish comes later).
8. Push all 3D assets (`.glb`, textures) to the shared repo under `mobile/assets/`.

**Ongoing responsibility:** Avatar mesh + sliders, garment region-tagging, regional mesh scaling logic, color-coded fit overlay rendering, hairstyle/accessory asset integration, MediaPipe landmark pipeline, on-device performance testing across at least 2 different phones.

---

### PERSON C — Backend, Fit Logic & Monetization

**Goal:** Data, rules engine, RevenueCat, and shopping links.

**Setup from scratch:**
1. Install Python 3.11+, create a virtual environment.
2. `pip install fastapi uvicorn firebase-admin pydantic`.
3. Scaffold: `backend/app/main.py`, `app/api/`, `app/models/`, `app/services/`.
4. Create the Firestore schema by hand first as JSON files in `catalog/` — `garments.json`, `size_charts.json`, `accessories.json`, `hairstyles.json`.
5. Write the fit-engine function as pure Python (input: user measurements + garment size chart → output: tight/good/loose per region) and unit-test it with 5 sample cases before connecting anything else.
6. Write the styling-rules function (input: garment color/category/occasion/budget → output: hairstyle + accessory + footwear suggestion) using the catalog JSON.
7. Create a RevenueCat account (free), create the app entry, create one entitlement (`premium_access`), and two placeholder packages (monthly/annual) — do this even before the app has purchases wired up, so the dashboard exists.
8. Deploy the FastAPI app to a free host (Render free tier or Fly.io free tier) so Person A has a real URL to call early.

**Ongoing responsibility:** Fit engine, styling engine, catalog data management, RevenueCat configuration (offerings, entitlements, paywall), merchant/affiliate link structure, analytics events, privacy policy + data-safety form draft, Play Console account setup and closed-testing track.

---

### Daily sync rule (all 3)

Every day, each person answers in the shared doc: **(1)** what I finished, **(2)** what I need from another person, **(3)** what's blocking me. This prevents three people building disconnected pieces.

---

## 2. Full Feature Checklist (Step by Step)

Use this to track progress. Mark each `[ ]` as `[x]` when done. Items marked **(optional)** are stretch/future features — build only after everything non-optional works end-to-end.

### A. Team & Project Setup
- [ ] Shared GitHub repo created with `mobile/`, `backend/`, `catalog/` folders
- [ ] Shared Firebase project created
- [ ] Shared Figma/design doc created
- [ ] Roles assigned (Person A/B/C as above)
- [ ] Daily standup doc/channel created

### B. Store & Legal Prerequisites
- [ ] Google Play Console account registered ($25 fee paid)
- [ ] Identity verification completed on Play Console
- [ ] Closed testing track started with 12 opted-in testers (14-day clock, start Week 1)
- [ ] Privacy Policy page written and hosted
- [ ] Data Safety form drafted (declares photo + measurement data usage)
- [ ] App icon (512×512) created
- [ ] Feature graphic (1024×500) created
- [ ] App set to target required Android API level

### C. User Profile & Onboarding
- [ ] Onboarding screens (welcome, permissions explainer)
- [ ] Manual measurement input form (height, bust/chest, waist, hip)
- [ ] Fit preference selector (fitted/regular/loose)
- [ ] Occasion selector (casual, formal, party, workwear, etc.)
- [ ] Budget input filter
- [ ] Skin-tone selector
- [ ] Style preference selector
- [ ] Photo-based measurement estimation using MediaPipe Pose Landmarker **(optional)**
- [ ] Editable slider confirmation screen before applying photo-estimated measurements **(optional, required if above is built)**

### D. 3D Avatar
- [ ] Base avatar mesh (GLB) created/sourced
- [ ] Avatar renders in-app via model_viewer_plus
- [ ] Height slider connected to avatar
- [ ] Waist slider connected to avatar
- [ ] Hip slider connected to avatar
- [ ] Chest/bust slider connected to avatar
- [ ] Leg length slider connected to avatar
- [ ] Skin tone applied to avatar
- [ ] Preset hairstyle picker (8–12 presets)
- [ ] Hair color auto-sampled from onboarding photo **(optional)**
- [ ] Mannequin/no-face mode for privacy-conscious users **(optional)**
- [ ] Full Sims-style unrestricted mesh editing **(optional, future — do not build now)**

### E. Clothing Catalog
- [ ] Catalog JSON schema defined (id, name, category, color, occasion, price, sizes, size chart, stretch, merchant, purchase URL)
- [ ] 5–10 demo garments added with full data
- [ ] Catalog browsing screen (grid/list)
- [ ] Product detail screen
- [ ] Occasion filter on catalog
- [ ] Budget filter on catalog
- [ ] Upload own dress image as input **(optional)**
- [ ] Paste a product link (Amazon/Meesho/etc.) as input **(optional)**
- [ ] Automatic scraping/search across multiple retailers for price comparison **(optional, future)**

### F. Garment Fit (Core Feature)
- [ ] Garment region tagging (bust, waist, hip, length)
- [ ] Regional mesh scaling logic (user measurement ÷ garment measurement)
- [ ] Scale clamp (~15% max) implemented
- [ ] Color-coded fit overlay (red/green/blue) rendered on avatar
- [ ] Plain-language fit note per region ("snug at waist")
- [ ] Overall recommended size shown
- [ ] Confidence label shown (e.g. "medium confidence")
- [ ] Alternate size suggestion shown when fit is borderline
- [ ] Real-time cloth physics simulation **(optional, future — not for MVP)**
- [ ] Exact guaranteed-fit claims **(never build — always show as estimate)**

### G. Styling Recommendations
- [ ] Rules-based recommendation engine (garment + occasion + budget → suggestions)
- [ ] Hairstyle suggestion shown per outfit
- [ ] Accessory suggestion shown per outfit (with reason text)
- [ ] Footwear suggestion shown per outfit
- [ ] Makeup direction suggestion shown per outfit (text only)
- [ ] Skin-undertone vs garment-color matching (rule-based, no ML) **(optional)**
- [ ] Try curly/wavy/straight hairstyle variants on request **(optional)**
- [ ] Hairstyle tutorial slideshow/video **(optional, future)**
- [ ] Makeup application tutorial **(optional, future)**
- [ ] Full hair/makeup photorealistic try-on **(optional, future)**

### H. Style/Outfit Score
- [ ] "Style Match" or "Occasion Match" score (0–100) implemented
- [ ] Score explanation shown (why it scored that way)
- [ ] Attractiveness-based rating **(never build — replaced by style/occasion match)**

### I. Photorealistic AI Preview (Layered On Top, Not Core)
- [ ] AI try-on API selected (e.g. trial-credit service or pay-per-use)
- [ ] Backend endpoint for sending photo + garment to API **(optional)**
- [ ] Generated preview displayed in-app **(optional)**
- [ ] Preview result cached to avoid duplicate API cost **(optional)**
- [ ] Credit/usage limit enforced for free users **(optional)**

### J. Save, Compare & Share
- [ ] Save a try-on result (avatar config + garment + fit verdict) to Firestore
- [ ] Saved-looks list screen
- [ ] Side-by-side/carousel comparison of 2–3 saved looks **(optional)**
- [ ] Cached thumbnail snapshots for comparison view **(optional)**
- [ ] Share a look (image/link export)
- [ ] Recipient can view shared look without signing up first
- [ ] Recipient can try other garments on the shared model **(optional)**
- [ ] Recipient can vote/comment on shared looks **(optional)**
- [ ] Public social feed of shared looks **(optional, future — not for MVP)**

### K. Shopping & Monetization
- [ ] Product card shows price, size, merchant, return info
- [ ] "Buy Now" button links to merchant/affiliate page
- [ ] Clear disclosure that user leaves the app to purchase
- [ ] Affiliate relationship disclosed if applicable **(optional)**
- [ ] Price-drop / back-in-stock alerts **(optional, future)**
- [ ] Full price comparison across multiple online stores **(optional, future)**

### L. RevenueCat & Paywall
- [ ] RevenueCat account created
- [ ] One entitlement created (e.g. `premium_access`)
- [ ] Monthly package configured
- [ ] Annual package configured
- [ ] Default offering configured
- [ ] Paywall screen built and connected to RevenueCat
- [ ] Free tier limits enforced (e.g. 3 try-ons/month, 1 saved look)
- [ ] Premium tier unlocks unlimited try-ons, HD export, saved wardrobe, advanced styling
- [ ] Restore-purchases flow implemented
- [ ] Free trial or promo code set up for judges
- [ ] Sandbox/test purchase verified before demo
- [ ] Credit-based add-on packages for expensive AI previews **(optional)**

### M. Privacy & Safety
- [ ] Camera/photo permission requested only when needed, with explanation
- [ ] User photos not uploaded to server without explicit consent
- [ ] Delete-photo option implemented
- [ ] Delete-account option implemented
- [ ] No long-term storage of raw biometric face data
- [ ] All results labeled as "estimate"/"visual preview," never as guaranteed fit
- [ ] Only licensed/original assets used (no unauthorized brand or music assets in app or demo video)

### N. Testing & Submission
- [ ] Full flow tested end-to-end on a real Android device
- [ ] Tested across at least 2 different phone models
- [ ] Error/loading/low-network states handled
- [ ] App published to Play Store (closed test → production)
- [ ] 1024×1024 app icon prepared for Devpost
- [ ] Screenshot at 1179×2556px (no device frame) prepared
- [ ] 2-minute demo video recorded and uploaded to YouTube/Vimeo
- [ ] Devpost submission text written
- [ ] Free trial or promo code included for judges
- [ ] Final QA pass completed

---

## Notes
- Items marked **(optional)** should only be attempted after every non-optional item in that section is done and working.
- Items marked **(never build)** are safety/credibility risks flagged in prior research — avoid these regardless of time remaining.
- Re-check this list every 3–4 days as a team to catch anything falling behind schedule before the September 30 deadline.
