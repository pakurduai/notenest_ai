# AGENTS.md — NoteNest Project Context & Memory Guidelines

This document stores the complete project state, design system rules, completed features, and production release specifications for **NoteNest**. Antigravity AI reads this file automatically at the start of any new chat session.

---

## 📌 Project Overview
- **App Name**: NoteNest
- **Play Store Title**: `NoteNest: Offline Notes`
- **Android Launcher Label**: `NoteNest`
- **Package ID / Namespace**: `com.notenest.ai`
- **Version**: `1.0.0` (Build `1`)
- **Framework**: Flutter (Dart)
- **Target Platforms**: Android (Edge-to-Edge API 21-35) & Web (`http://localhost:8080`)
- **Branding Colors**:
  - Primary Purple: `#7C3AED` / `#8A2BE2`
  - Accent Cyan / Blue: `#00C6FF` / `#2563EB`
  - Onboarding Dark Background: Deep Navy/Purple Gradient (`#070415` -> `#0D0628` -> `#14093C`)
  - Home Screen Background: Light Lavender Tint (`#F6F5FA`)

---

## 🚀 Production Build & Play Store Readiness (Phase 11 Bug Fixes Completed)

### 📦 Signed Production Deliverables
- **Release App Bundle (AAB)**: `build/app/outputs/bundle/release/app-release.aab` (Size: **49.30 MB**)
- **Release Testing APK**: `build/app/outputs/flutter-apk/app-release.apk` (Size: **50.50 MB**)
- **Signing Keystore**: `android/app/upload-keystore.jks` (RSA 2048-bit, 10,000 days validity)
- **Signing Credentials**: Configured in `android/key.properties` and `android/app/build.gradle.kts`
- **R8 Optimizations**: `isMinifyEnabled = true`, `isShrinkResources = true`, MaterialIcons tree-shaken (99.2% reduction)
- **JVM Heap Fix**: `android/gradle.properties` tuned to `-Xmx1536m` to fit within 5GB RAM limits cleanly
- **Flutter Code Analysis**: `No issues found!` (0 errors, 0 warnings)

### 📄 Legal & Store Submission Assets
- **Privacy Policy**: `privacy-policy.html` (100% Offline, Zero data collection, `NoteNest` branding)
- **Terms & Conditions**: `terms-and-conditions.html` (`NoteNest` branding)
- **Support Page**: `support.html` (FAQs & troubleshooting, `NoteNest` branding)
- **Store Listing Metadata**: `STORE_LISTING.md` (Title options, 80-char short description, 4000-char long description)
- **Graphics Assets**: Located in `assets/playstore/`
  - `icon_512.png` (512x512 High Quality PNG)
  - `feature_graphic_1024x500.png` (1024x500 Feature Graphic)
  - `screenshot_1_home.png` through `screenshot_5_settings.png` (100% real Flutter screenshots in branded phone mockups)
- **Submission Documents**:
  - `GOOGLE_PLAY_SUBMISSION_CHECKLIST.md` (Step-by-step 11-step Google Play Console upload guide & answers)
  - `FINAL_CONSISTENCY_REPORT.md` (100% clean audit confirming identical `NoteNest` branding across all assets)

---

## 💻 Completed Screens & Architecture

### 1. Splash Screen
- **File**: `lib/features/splash/presentation/screens/splash_screen.dart`
- **Asset**: `assets/images/splash_screen_v2.png` (`BoxFit.cover`, full-screen edge-to-edge)
- **Behavior**: Auto-navigates to `OnboardingScreen` after exactly **1.5 seconds** (1500 ms) with a smooth FadeTransition.

### 2. Onboarding Flow (Screens 1, 2, & 3)
- **Files**:
  - `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
  - `lib/features/onboarding/presentation/widgets/onboarding_page.dart`
  - `lib/features/onboarding/presentation/widgets/onboarding_widgets.dart`
- **Assets**: `assets/images/onboarding_screen_1.png`, `onboarding_screen_2.png`, `onboarding_screen_3.png`
- **Behavior**: Edge-to-edge dark purple layout with interactive bottom tap targets for `Skip` and `Next →` / `Get Started →`.

### 3. Home Screen (Pixel-Perfect Light Theme)
- **File**: `lib/features/home/presentation/screens/home_screen.dart`
- **Components**: Monogram logo, greeting header, AI Assistant banner card with transparent 3D mascot (`assets/images/home_robot.png`), 5 quick action cards, recent notes, FAB `+`, and floating bottom navigation bar.

### 4. Create Note & Editor Screen
- **Files**: `lib/features/notes/presentation/screens/create_note_screen.dart`, `note_model.dart`
- **Features**: Top bar category picker, pin toggle, auto timestamp & word count, rich text formatting toolbar (`B`, `I`, `U`, lists, checkboxes, image & voice triggers).

### 5. Search Screen
- **Files**: `lib/features/search/presentation/screens/search_screen.dart`, `search_result_model.dart`
- **Features**: Top search bar, category chips, advanced filters (categories, tags, colors, sort order), recent searches, AI smart search card, and list/grid toggle.

### 6. Categories Screen
- **Files**: `lib/features/categories/presentation/screens/categories_screen.dart`, `category_model.dart`
- **Features**: Summary statistics card, 8-category grid (`Work`, `Study`, `Ideas`, `Personal`, `Travel`, `Shopping`, `Favorites`, `Archive`), notes in work section with note cards.

### 7. AI Assistant Screen
- **Files**: `lib/features/ai_assistant/presentation/screens/ai_assistant_screen.dart`, `ai_tool_model.dart`
- **Features**: 3D mascot welcome card, 9 AI tool tiles, example prompt chips, ask/paste mode selector, and bottom prompt bar.

### 8. Settings Screen
- **Files**: `lib/features/settings/presentation/screens/settings_screen.dart`, `settings_item_model.dart`
- **Features**: Monogram profile banner card, storage usage indicator, Pro upgrade card, app preferences group, data management group, and about section.

---

## 🛠️ How to Resume Next Session

When starting a new conversation, simply message Antigravity AI:

> **"NoteNest project continue karo"**  
> or  
> **"Google Play submission guidance perform karo"**

Antigravity AI will automatically load this `AGENTS.md` file, maintain 100% project context, and continue seamlessly!
