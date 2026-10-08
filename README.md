# 🟢 Bratify — Viral Meme, Multi-Photo Frame & Collage Studio

<p align="center">
  <img src="ios/Runner/Assets.xcassets/AppIcon.appiconset/180.png" width="96" height="96" alt="Bratify App Icon" style="border-radius: 20px; box-shadow: 0 4px 14px rgba(0,0,0,0.25);" />
</p>

<p align="center">
  <b>Bratify</b> is an aesthetic meme creator, multi-photo collage maker, and creative frame studio built for iOS with Flutter. Inspired by the iconic lime-green album trend and Y2K internet culture, Bratify lets creators design viral text memes, compose multi-photo collages into 500+ curated frames, fine-tune imagery in a dedicated full-screen crop studio, apply curated color-grading filters and authentic film grain effects, layer unconstrained draggable text, and export ultra-sharp HD creations to Apple Photos.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2015.0%2B-black?style=flat-square&logo=apple" alt="iOS" />
  <img src="https://img.shields.io/badge/Flutter-%5E3.12-02569B?style=flat-square&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/PhotoKit-Gal%202.3-green?style=flat-square" alt="Gal" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20On--Device-success?style=flat-square" alt="Privacy" />
  <img src="https://img.shields.io/badge/Monetization-100%25%20Free%20%26%20Ad--Free-blue?style=flat-square" alt="Ad Free" />
  <img src="https://img.shields.io/badge/Tests-49%2F49%20Passing-brightgreen?style=flat-square" alt="Tests" />
</p>

---

## ✨ Key Features & Capabilities

### 🟢 1. Iconic Brat Meme Studio & 120+ Viral Quotes Engine
* **Signature Aesthetic:** Authentic lime-green background (`#8ACE00`), low-res blur styling, and high-contrast typography.
* **Instant Palette Switching:** Switch seamlessly between Classic Lime, Crisp White, Studio Dark Carbon (`#121212`), or custom palette color pickers.
* **120+ Viral Quotes Engine:** 10 curated categories (*Brat Summer, Pop Culture, Relatable, Sassy, Minimalist, etc.*). Tapping any quote instantly opens the creative editor and synchronizes canvas text layers and frame captions.
* **Live Dynamic Canvas Preview:** Immediate, responsive updates with dual-mode inline and modal text editing.

### 🖼️ 2. Multi-Photo Collages & 500+ Aesthetic Frame Studio
* **Dynamic Multi-Photo Layouts (1–4 Photos):** Full native support for:
  * `single`: 1 photo (standard classic view)
  * `split2H`: 2 photos side by side
  * `split2V`: 2 photos stacked vertically
  * `polaroidDuo`: 2 vintage polaroid snapshots side by side
  * `triptych3`: 3 photos side by side
  * `filmstrip3`: 3 photos in a vertical filmstrip layout
  * `grid4`: 4 photos arranged in a balanced 2x2 grid collage
* **Per-Slot Photo Control Toolbar:** Dedicated slot selector pills (`Slot 1`, `Slot 2`, etc.), individual photo picking, per-slot crop studio shortcuts, and slot-clear actions.
* **Non-Destructive Frame Switching:** Switch between single-photo frames, split collages, or 4-photo grids on the fly without losing previously assigned slot photos or custom text layers.
* **Granular Frame Customization:** Adjustable border width, border color, corner radius (`borderRadius`), and slot spacing (`slotSpacing`).
* **500+ Curated Frame Templates:** Categorized into Polaroid & Vintage, Digicam ISO, Cyber Y2K, Music Players, Windows 98, and Multi-Photo Collages.
* **Interactive Pre-Flight Guidance (`FramePreflightSheet`):** Informative modal displaying required photo count, aspect ratios (1:1, 9:16, 4:5), and effect requirements before entering the editor.

### 🌄 3. Dual Background Engine (Solid Color vs. Custom Canvas Image)
* **Dual Background Modes:** Instant toggle between **Solid Color / Gradient** and dedicated **Canvas Background Image** mode.
* **Custom Background Photo Upload:** Import custom background wallpapers, aesthetic textures, or photo backdrops directly from Camera or Photo Library.
* **Background Opacity Slider:** Fine-tune background image transparency from `0%` to `100%` for subtle watermark or high-contrast blending.
* **Background Gaussian Blur:** Smooth blur slider to create artistic bokeh behind frame slots and text overlays.
* **Background BoxFit Options:** Switch effortlessly between `Cover`, `Contain`, and `Fill` display modes.
* **1-Tap Quick Reset:** Revert back to solid Brat Lime or custom colors at any time with a single tap.

### 🔤 4. Unconstrained Multi-Text Drag Engine & Typography Studio
* **Free Drag-and-Drop Positioning:** Move text layers freely across any coordinate on the canvas with normalized relative `(X, Y)` position persistence.
* **Multi-Text Layers Manager (`TextLayersManagerWidget`):** Add unlimited text layers, edit captions, duplicate, reorder, or delete layers in a clean bottom sheet.
* **30+ Curated Google Fonts:** Bold display fonts, retro monospace, modern clean sans-serifs, and editorial serifs.
* **Granular Typography Controls:**
  * Interactive Font Size slider
  * Font Weight selection (Normal, Medium, Bold, Extra Bold, Black)
  * Letter Spacing & Line Height adjustments
  * Text Blur slider for iconic low-res album styling
  * Text Alignment (Left, Center, Right)
  * Text Case transformations (UPPERCASE, lowercase, Title Case)
  * Custom text colors, drop shadows, and automatic caption synchronization

### 🎨 5. 12 Curated Color-Grading Filters & Studio FX Suite
* **12 Curated Aesthetic Filters (`StudioFilterCatalog`):**
  1. **Normal:** Original crisp, unaltered look
  2. **🍏 Brat Lime (`brat`):** Iconic Charli XCX high-key neon lime matrix aura
  3. **🎬 Noir B&W (`noir`):** Deep high-contrast monochrome silver gelatin film
  4. **📷 Vintage 90s (`vintage`):** Warm nostalgic 90s disposable camera & Polaroid tone
  5. **⚡ Cyber Neon (`cyberpunk`):** Electric cyan and vivid magenta duotone
  6. **🌅 Golden Hour (`golden`):** Sun-drenched amber glow with warm skin tones
  7. **❄️ Cold Indie (`cold`):** Atmospheric twilight chill with moody blue shadows
  8. **💥 Vivid Pop (`vivid`):** Ultra-saturated punchy pop festival colors
  9. **☕ Warm Sepia (`sepia`):** Antique brown parchment authentic sepia tone
  10. **🧪 Acid Rave (`acid`):** High-energy fluorescent ultraviolet acid trip
  11. **🌸 Pastel Dream (`pastel`):** Soft dreamy bubblegum pink & lavender fairy vibe
  12. **🎞️ Teal & Orange (`cinematic`):** Hollywood blockbuster rich contrast
  13. **🩻 Invert X-Ray (`invert`):** Striking negative spectrum inverted exposure
* **Smooth Intensity Interpolation Slider:** Real-time blending slider from `0%` to `100%` calculated via 4x5 ColorFilter matrix interpolation against the Identity matrix.
* **Authentic Studio FX:**
  * Authentic low-res blur slider (`blurSigma` up to `10.0`)
  * 35mm film grain noise overlay slider (`grainOpacity`)
  * Vignette corner shadowing
  * Instant color inversion toggle

### ✂️ 6. Dedicated Full-Screen Image Crop & Adjust Studio (`ImageCropScreen`)
* **Expansive Workspace:** Clean, full-screen editing interface separated from canvas clutter.
* **Interactive Gestures:** Fluid multi-touch pinch-to-zoom and drag-to-pan positioning.
* **Precision Transform Controls:**
  * 90° clockwise rotation
  * Custom tilt angle slider (`-45°` to `+45°`)
  * Flip Horizontal & Flip Vertical mirror tools
  * Rule-of-Thirds 3x3 alignment guide grid
* **Social Aspect Ratio Presets:** 1-tap switching between `1:1 Square`, `4:5 Portrait`, `9:16 Story/Reel`, `16:9 Landscape`, and `3:4 Classic`.

### 💾 7. Real-Time Library, Safe Draft Persistence & Full Re-Editing
* **SQLite Local Database (`DatabaseHelper`):** Automatic local persistence of all designs without loss of fidelity.
* **Zero-Loss Re-Editing:** Tapping any saved draft in the Library reloads all design elements:
  * Selected frame layout and slot assignments (`slotImagePathsJson`)
  * Dedicated canvas background image, opacity, and fit mode (`frameBgImagePath`, `bgMode`, `frameBgOpacity`, `frameBgFit`)
  * All multi-text layers and exact relative `(X, Y)` drag coordinates (`textLayersJson`, `textOffsetX`, `textOffsetY`)
  * Active filter ID and filter intensity (`filterId`, `filterIntensity`)
  * Studio effects (blur, film grain, vignette, invert, aspect ratio)
  * Per-slot photo transformations (scale, offset, rotation, flip)
* **Real-Time Reactive Library Sync:** `DatabaseHelper.savedMemesChangeNotifier` instantly broadcasts updates so `SaveScreen` displays newly saved or updated creations without manual refreshes.
* **Native PhotoKit Ultra-HD Export:** Crystal-clear 3x Retina PNG export directly to Apple Photos powered by `gal: ^2.3.1` (100% Swift Package Manager compatible).
* **iPad Popover Crash-Safe Sharing:** Contextual `sharePositionOrigin` anchored to the Share button's `RenderBox` prevents `UIActivityViewController` presentation crashes on iPads.

### ↩️ 8. Undo & Redo History System
* **Multi-Step History Stack:** Integrated undo and redo engine in `GenerateScreen` allowing creators to revert or reapply edits across canvas changes, text adjustments, and effect toggles.

### ❓ 9. Modern Interactive FAQs & Help Guide (`FaqsScreen`)
* **Interactive Category Filter Chips:** *All, Frames & Collages, Backgrounds, Text & Typography, Filters & FX, Crop & Editing, Library & Export, Privacy & Offline*.
* **Real-Time Search Bar:** Instant query filtering across questions and detailed answers.
* **19 Curated In-App Q&As:** Clear, comprehensive troubleshooting and workflow guidance directly in the app.

### 🔒 10. 100% Private, On-Device & Zero-Tracking Architecture
* **Zero Cloud Uploads:** All image compositing, photo transformations, and filter rendering execute strictly on-device using Flutter's native Canvas rendering engine.
* **Zero Tracking & Zero Ads:** No advertising SDKs, no user analytics beacons, no tracking identifiers.
* **Zero Friction:** Instant launch with no registration, no accounts, and no subscriptions.
* **In-App Privacy Policy:** Clear on-device declaration accessible via Settings > Privacy & Data Safety.

---

## 🏗️ Architecture & Project Structure

```text
brat_generator/
├── lib/
│   ├── config/              # App constants, store URLs & configuration (app_config.dart)
│   ├── constants/           # Color tokens (bratGreen), font lists, theme definitions
│   ├── features/
│   │   ├── frames/          # Frame pre-flight guidance modal & requirements checklist
│   │   ├── photo_transform/ # PhotoTransformModel & per-slot transform logic
│   │   └── studio_effects/  # Film grain, blur, vignette, and StudioEffectsSheet
│   ├── models/
│   │   ├── frame_model.dart         # FrameTemplate, FramePhotoLayout (1-4 slots), overlays
│   │   ├── meme_design_model.dart   # SQLite persistence model with complete slot/text/filter serialization
│   │   ├── studio_filter_model.dart # StudioFilterCatalog, 12 filters & 4x5 matrix interpolation
│   │   └── text_layer_model.dart    # TextLayerModel with relative (X,Y) coordinate persistence
│   ├── screens/
│   │   ├── generate_screen.dart     # Dedicated studio canvas, slot toolbar, filter bar & editor
│   │   ├── home_screen.dart         # Clean Studio Hub & DIY frame layout starters
│   │   ├── image_crop_screen.dart   # Dedicated full-screen image crop & adjust studio
│   │   ├── main_screen.dart         # Root bottom navigation controller with persistent tab state
│   │   ├── maintenance_screen.dart  # Graceful error boundary fallback screen
│   │   ├── onboarding_screen.dart   # Lightweight vector custom-painted introduction
│   │   ├── process_screen.dart      # Modern export & processing overlay modal
│   │   ├── save_screen.dart         # Real-time reactive drafts library with iPad-safe share
│   │   ├── splash_screen.dart       # iOS-style startup sequence with diagnostic log
│   │   └── settings/
│   │       ├── faqs_screen.dart     # Categorized FAQs with chips, search & 19 interactive Q&As
│   │       └── settings_screen.dart # Privacy policy modal, rating deep-link & app info
│   ├── services/
│   │   ├── app_update_service.dart  # Store version check using Universal HTTPS links
│   │   ├── database_service.dart    # SQLite database operations with savedMemesChangeNotifier
│   │   └── logger_service.dart      # Diagnostic logging & error boundary
│   ├── widgets/
│   │   ├── app_bar_widget.dart              # Reusable top app bar
│   │   ├── app_button.dart                  # Themed tactile buttons
│   │   ├── app_svg_icon.dart                # Vector icon renderer
│   │   ├── frame_canvas_widget.dart         # Multi-photo slot layout renderer (1–4 photos & bg modes)
│   │   ├── interactive_text_overlay.dart    # Draggable, resizable canvas text layers
│   │   ├── studio_reusable_widgets.dart     # Reusable studio cards & controls
│   │   └── text_layers_manager_widget.dart  # Text layers bottom sheet manager
│   └── my_app.dart                          # MaterialApp root, theme, and system overlays
├── ios/
│   ├── Runner/
│   │   ├── Assets.xcassets/ # Option 2 (Dark Studio) AppIcon (1024 down to 20px)
│   │   ├── Base.lproj/      # Dark LaunchScreen.storyboard (zero white flash)
│   │   └── Info.plist       # Purpose-driven permission strings & dynamic versioning
│   ├── Podfile              # iOS 15.0 deployment target & modular headers
│   └── Runner.xcodeproj/    # Configured with bundle ID `com.manav.bratify`
├── test/
│   ├── faqs_screen_test.dart          # Categorized FAQs chips & search filtering test
│   ├── frame_bg_image_test.dart       # Dedicated canvas background image rendering & opacity test
│   ├── frame_preflight_test.dart      # Preflight modal requirements & checklist test
│   ├── mainscreen_test.dart           # Multi-screen capture & layout regression suite
│   ├── multi_photo_and_crop_test.dart # Multi-photo frame layouts (1-4 photos) & crop tests
│   ├── save_library_flow_test.dart    # Database persistence, reactive notifications & re-editing test
│   ├── studio_filter_test.dart        # 12 studio filters matrix interpolation tests
│   ├── text_engine_test.dart          # Multi-text layers & draggable coordinate tests
│   └── widget_test.dart               # Splash boot sequence test
├── app_info.md              # App Store Connect metadata, keywords & reviewer notes
├── ios_issues.md            # App Store review audit report & resolved issues archive
└── pubspec.yaml             # Lean dependency manifest (zero bloat)
```

---

## 🚀 Getting Started

### Prerequisites
* **macOS** with Xcode 15+ installed
* **Flutter SDK:** `^3.12.2` (Channel stable)
* **CocoaPods:** `1.14+`

### Installation & Local Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/MrManavRamani-Flutter/bratify_ios.git brat_generator
   cd brat_generator
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Install iOS Pods:**
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   ```

4. **Run on iOS Simulator or Connected Device:**
   ```bash
   flutter run -d iphone
   ```

---

## 🧪 Testing & Code Quality

Run tests and analysis to ensure high code quality:

```bash
# Run static analysis (0 warnings, 0 errors)
flutter analyze

# Run all 49 automated unit and widget tests
flutter test
```

### Test Coverage Highlights:
* **`multi_photo_and_crop_test.dart`:** Tests all frame layouts (`single`, `split2H`, `split2V`, `polaroidDuo`, `triptych3`, `filmstrip3`, `grid4`), per-slot image assignments, and crop interactions.
* **`frame_bg_image_test.dart`:** Validates background mode toggling, custom wallpaper bytes rendering, opacity adjustments, and fit modes.
* **`text_engine_test.dart`:** Validates interactive draggable text layers, font styling, bounds safety, and relative coordinate math.
* **`studio_filter_test.dart`:** Tests 4x5 ColorFilter matrix calculations, identity interpolation, and all 12 filters.
* **`save_library_flow_test.dart`:** Validates SQLite round-trip serialization, reactive notifier updates, and full draft re-editing fidelity.
* **`faqs_screen_test.dart`:** Validates categorized chip filtering, query search, and 19 interactive Q&As.

---

## 📦 Building for Production (App Store Release)

1. **Clean and Prepare:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build iOS Archive (IPA):**
   ```bash
   flutter build ipa --release
   ```

3. **Distribute via Xcode Organizer:**
   * Open the generated Xcode archive in `build/ios/archive/Runner.xcarchive`.
   * Click **Distribute App** -> **App Store Connect** -> **Upload**.

---

## 📋 App Store Review Guidelines Compliance

| Guideline | Requirement | How Bratify Complies |
| :--- | :--- | :--- |
| **5.1.1 (Privacy)** | Purpose-driven permission strings & data safety | `Info.plist` includes user-facing descriptions for Camera & Photo Library. 100% on-device processing. In-app privacy sheet accessible in Settings. |
| **4.2 (Minimum Functionality)** | Rich, differentiated user experience | 500+ aesthetic frames, multi-photo collages (1–4 photos), custom background photo mode, full-screen crop studio, 12 studio filters with intensity control, draggable text engine, 120+ viral quotes, 30+ Google fonts, and lossless draft re-editing. |
| **5.6.1 (Customer Reviews)** | No forced or unearned rating dialogs | No first-launch rating popups. Ratings are 100% user-initiated from Settings using direct App Store deep-link. |
| **2.1 (App Completeness)** | Stable, crash-free execution | Tested on iPad & iPhone with bounds checks, button-anchored iPad share sheet popovers, and error boundaries. |

---

## 📄 Documentation References
* [app_info.md](file:///Users/manavramani/Documents/ios_apps/pending/brat_generator/app_info.md): Complete App Store Connect metadata, 100-character keyword strings, promotional text, and Apple Reviewer Notes.
* [ios_issues.md](file:///Users/manavramani/Documents/ios_apps/pending/brat_generator/ios_issues.md): App Store review audit report, pre-submission checklist, and resolution changelog.

---

## ⚖️ License & Disclaimer
Bratify is an independent creative photo editing application. All meme templates, filters, and fonts are generated locally for creative expression.
