# App Store Information & Metadata — Bratify

Ye document **Bratify: Aesthetic Meme & Frame Studio** ke liye **App Store Connect** submission aur **ASO (App Store Optimization)** ka complete, up-to-date metadata guide provide karta hai.

---

## 📌 App Identity & Bundle Configuration

| Metadata Field | Value | Constraints / Details |
| :--- | :--- | :--- |
| **App Name (Primary)** | `Bratify: Aesthetic Meme Maker` | 29 Chars (Max 30 allowed) — High ASO weight for "Meme Maker" |
| **Alternative Name** | `Bratify: Meme & Frame Studio` | 28 Chars (Max 30 allowed) — Highlights 500+ frames |
| **Subtitle** | `500+ Viral Frames & Collages` | 28 Chars (Max 30 allowed) — High conversion callout |
| **Alternative Subtitle** | `Multi-Photo Frames & Text Art` | 29 Chars (Max 30 allowed) |
| **Bundle Identifier** | `com.manav.bratify` | Configured in `ios/Runner.xcodeproj/project.pbxproj` |
| **SKU** | `BRATIFY_001` | Internal unique reference |
| **Apple ID / App ID** | *Assigned by App Store Connect* | Sync with `AppConfig.appRateId` after app creation |
| **Primary Category** | `Photo & Video` | Best fit for image editing, framing & text overlay |
| **Secondary Category** | `Entertainment` | Captures pop culture & viral meme audience |
| **Primary Language** | English (U.S. / U.K.) | Default storefront language |
| **Content / Age Rating** | `12+` | User-generated text humor & creative expression |

---

## 🔑 ASO Keywords (100-Character String)

> [!IMPORTANT]
> Apple App Store keyword field has a **strict 100-character limit**. Commas separate keywords; spaces after commas are omitted to save character budget.

### 99-Character Optimized String:
```text
brat,meme,generator,maker,polaroid,frame,collage,aesthetic,y2k,green,text,editor,creator,photo,crop,viral
```
*(Total Characters: 99 / 100)*

### Target Search Queries & Long-Tail Combinations:
* brat meme generator
* multi photo polaroid frames
* aesthetic photo collage maker
* brat green text maker
* full screen photo crop editor
* y2k digicam photo frames
* viral pop culture memes
* retro 90s meme studio

---

## 📢 Promotional Text (170 Chars Max)
> *Can be updated anytime in App Store Connect without submitting a new binary build.*

```text
Create iconic lime-green memes, explore 500+ aesthetic frames, compose multi-photo collages, crop with pro precision, and share viral vibes instantly!
```
*(Character count: 147 / 170)*

---

## 📄 Full App Store Description

```text
Turn your thoughts into iconic pop-culture moments with Bratify — the ultimate aesthetic meme maker and creative frame studio!

Inspired by the iconic lime-green album trend and Y2K internet culture, Bratify makes it effortless to create minimalist, bold, and viral memes in just seconds. With over 500 curated aesthetic frames, multi-photo collage templates, a dedicated full-screen crop studio, and authentic film effects, your creativity has no limits.

✨ WHAT MAKES BRATIFY ICONIC:

🟢 AUTHENTIC BRAT TEXT STUDIO
• Instant iconic lime-green canvas with signature low-res blur styling.
• Total color freedom: Classic Lime, Crisp White, Studio Dark Mode, or custom palette picker.
• 30+ Google Fonts: Bold display fonts, retro monospace, modern sans, and elegant serifs.
• Complete text controls: letter spacing, line height, text shadows, and alignment.
• 120+ Viral Quotes: Browse 10 trending categories (Brat Summer, Pop Culture, Relatable Vibes, Sassy) and load them directly into your canvas with a single tap.

🖼️ 500+ CURATED AESTHETIC FRAMES & COLLAGES
• Explore 500+ aesthetic templates across curated categories.
• Multi-Photo Collages: Support for 1 to 4 photos per frame — 2-photo split layouts, polaroid duos, 3-photo filmstrips & triptychs, and 4-photo grid collages!
• Digicam ISO, Polaroid snapshots, VHS REC overlays, Spotify music players, and retro Windows 98 dialogs.
• Step-by-step pre-flight checklist: see required photos, aspect ratios (1:1, 9:16, 4:5), and effects before you start.

✂️ DEDICATED FULL-SCREEN IMAGE CROP & ADJUST STUDIO
• Fine-tune each photo slot with an expansive, dedicated crop workspace.
• Smooth pinch-to-zoom and drag-to-pan positioning with interactive 3x3 rule-of-thirds grid.
• Instant 90° rotation, horizontal mirror flips, and vertical flips.
• Social aspect ratio presets: 1:1 Square, 4:5 Portrait, 9:16 Story/Reel, 16:9 Landscape, and 3:4 Classic.

🎨 DEDICATED POST EDITOR WORKFLOW
• Clean separation between Templates Discovery and the creative Studio.
• Effortless navigation with 1-tap back to templates, template title header, and aspect ratio indicator.
• Unlimited Undo & Redo history for stress-free designing.
• Multi-slot photo switcher toolbar to easily adjust, crop, swap, or clear individual photos.

⚡ AUTHENTIC BRAT FX & GRAIN
• Add nostalgic texture with 35mm film grain overlays.
• Vintage camera blur and subtle vignettes for that authentic 2000s internet vibe.
• Custom overlay tinting and brightness balancing.

💾 ULTRA-HD EXPORT & 1-TAP SHARING
• Save ultra-crisp, high-resolution memes directly to your Apple Photos library via native PhotoKit.
• Real-time Library Sync: Every saved design immediately updates your in-app Drafts collection.
• One-tap instant sharing to Instagram Stories, TikTok, Snapchat, WhatsApp, X (Twitter), and iMessage.
• iPad popover safe: Anchored share sheet ensures smooth, crash-free presentation on all iPads and iPhones.

🔒 100% PRIVATE & ON-DEVICE
• No accounts, no logins, and zero cloud uploads.
• All rendering, photo positioning, and effects processing run 100% locally on your iPhone or iPad.
• Your photos stay private and never leave your device.

Download Bratify today and start creating memes that define your energy!
```

---

## 🛡️ Apple App Review Information (Reviewer Demo Notes)

> [!TIP]
> Paste this exact message into the **"App Review Information -> Notes"** field in App Store Connect. This proactively answers all reviewer questions regarding camera/photo permissions and prevents unnecessary "Guideline 2.1 Information Needed" review delays.

```text
Dear Apple Review Team,

Thank you for reviewing Bratify!

Please note the following key architectural details about our app:
1. No Account / Login Required: All features, including the 500+ frame library, multi-photo collage layouts, full-screen crop studio, meme editor, and typography tools, are accessible immediately upon launch without any account registration or subscription.
2. 100% On-Device Processing: All image compositing, photo transformations, frame rendering, and text layout execute strictly on-device using Flutter's native Canvas rendering engine. No user photos, text strings, or creations are ever transmitted to any external server or third-party AI service.
3. Permission Transparency:
   - Camera Permission (NSCameraUsageDescription): Used exclusively when the user opts to capture a live photo to place into an aesthetic frame slot.
   - Photo Library Access (NSPhotoLibraryUsageDescription & NSPhotoLibraryAddUsageDescription): Used to let the user select photos for frame slots and save rendered memes to their Photos album via native iOS PhotoKit APIs.
4. Ad-Free & Subscription-Free: The app contains zero third-party advertising SDKs and zero in-app purchases.
5. In-App Privacy Information: Users can view our full privacy declaration directly in the app via Settings > "Privacy & Data Safety".

If you have any questions or require additional details, please reach out to us at support@manav.dev.
```

---

## 🔗 URLs & App Store Connect Support Information

| Link Type | Recommended Value | Purpose |
| :--- | :--- | :--- |
| **Privacy Policy URL** | Hosted online webpage (GitHub Pages / Notion) | **Mandatory** on App Store Connect and in Settings |
| **Support URL** | Hosted webpage or support contact link | **Mandatory** for user inquiry and App Store Connect |
| **Marketing URL** | `https://apps.apple.com/app/id<ASSIGNED_ID>` | Optional promotional landing link |
| **Terms of Use (EULA)** | `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/` | Standard Apple Licensed Application End User License Agreement |

---

## 💰 Monetization & Data Safety Declaration

* **Monetization Model:** 100% Free Creative Studio (No paywalls, no subscriptions).
* **Contains Ads:** **No** (In App Store Connect, select **"No"** under Advertising declaration).
* **App Tracking Transparency (ATT):** **Not Required** (No third-party ad networks, no tracking identifiers, and no user profiling).
* **Data Collection Declaration:**
  - In App Store Connect **App Privacy** section, declare:
    - **"Data Not Collected"**: The app does not collect or link any user data from the app.
