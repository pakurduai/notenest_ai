# AGENTS.md — NoteNest Project Context & Memory Guidelines

This document stores the complete project state, design system rules, completed features, and production release specifications for **NoteNest**. Antigravity AI reads this file automatically at the start of any new chat session.

---

## 📌 Project Overview
- **App Name**: NoteNest
- **Play Store Title**: `NoteNest: Offline Notes`
- **Android Launcher Label**: `NoteNest`
- **Package ID / Namespace**: `com.notenest.ai`
- **Version**: `1.0.9` (Build `16`)
- **Framework**: Flutter (Dart)
- **Target Platforms**: Android (Edge-to-Edge API 21-35) & Web (`http://localhost:8080`)
- **Branding Colors**:
  - Primary Purple: `#7C3AED` / `#8A2BE2`
  - Accent Cyan / Blue: `#00C6FF` / `#2563EB`
  - Home Screen Background: Light Lavender Tint (`#F6F5FA`)

---

## 🔒 LOCKED APPLICATION ARCHITECTURE & RECENT COMPLETED FEATURES

> [!IMPORTANT]
> **STRICT USER DIRECTIVE**: Entire application codebase is **LOCKED**. Antigravity AI will ONLY modify specific lines/features explicitly requested by the user. Unrequested modifications or refactoring to any existing working feature, screen, or file are strictly prohibited.


### 1. Instant App Launch (Direct to HomeScreen)
- **File**: `lib/main.dart`
- **Behavior**: App opens directly into `HomeScreen` with zero delay, bypassing initial splash screen as requested.

### 2. Header & Navigation Bar UI (Pixel-Perfect Alignment)
- **File**: `lib/features/home/presentation/screens/home_screen.dart`
- **Features**:
  - **Direct List View vs Grid View Toggle Buttons**:
    - Tapping **List View Icon** (`☰`) directly switches layout to **Single-Column List View** (`_isGridView = false`) with audio/haptic feedback & purple indicator.
    - Tapping **Grid View Icon** (`⊞`) directly switches layout to **2-Column Grid View** (`_isGridView = true`).
  - **Modal Bottom Sheet Tabs (100% Non-Overlapping)**: `Color / Tag`, `Sort Order`, and `View Layout` tabs rendered cleanly without text clipping.
  - **Create New Bottom Sheet Overflow Fix**: `childAspectRatio` tuned to `1.75` with `TextOverflow.ellipsis` on `Text Note`, `Checklist`, `Voice Note`, `Scan Document`, `AI Note`, and `Premium` tiles.
  - **Equal Width Floating Navigation Bar**: All 4 tabs (`Home`, `Categories`, `AI Assistant`, `Settings`) balanced with compact pill for `Home`.

### 3. Note Editor, Auto Link Detection & ColorNote View/Edit Modes
- **File**: `lib/features/notes/presentation/screens/create_note_screen.dart`, `lib/core/controllers/rich_note_controller.dart`
- **Features**:
  - **Checkmark `✓` Tap**: Saves note to Hive DB, unfocuses keyboard, hides cursor (`showCursor: !_isReadOnlyMode`), and locks into View Mode. User clearly sees note is saved and completed.
  - **Double-Tap Word/Link Copy in View Mode**: Double-tapping any word, email (e.g. `pakurduai@gmail.com`), or web URL in View Mode selects the text and copies it directly to the Clipboard with audio chime & toast `"Copied '...' to clipboard! 📋"`.
  - **Precise Drag Selection & Selection Toolbar**: Native drag-highlight selection and selection toolbar (`Word`, `Line`, `Para`, `All`, `Copy 📋`, `Deselect`) are active in both View Mode and Edit Mode.
  - **3-Dots Menu (`⋮`) Save**: Also provides direct option to save note anytime.
  - **Auto Link & Email Detection (`pakurduai@gmail.com`)**: Emails (e.g. `pakurduai@gmail.com`), web URLs (`https://...`, `www....`), and links automatically render as styled blue underlined links. Tapping any link launches `mailto:` or the external web browser via `url_launcher`.
  - **View/Edit Mode Toggles**: Tapping `Edit Note` unlocks Edit Mode instantly. Tapping checkmark `✓` locks back into View Mode.

### 4. AI Assistant Voice Mic Integration (`🎤`)
- **File**: `lib/features/ai_assistant/presentation/screens/ai_assistant_screen.dart`
- **Features**: Prominent circular purple Mic button (`🎤`) on the left side of the prompt bar for instant English, Urdu, and Hindi voice prompt dictation into Gemini AI.

### 5. Inline Full-Screen ChatGPT / Gemini Style AI Chat Mode
- **File**: `lib/features/notes/presentation/screens/create_note_screen.dart`, `lib/core/services/gemini_ai_service.dart`
- **Features**:
  - Tapping prompt bar, "See All", or send button in Note Editor opens dedicated full-screen AI Chat View.
  - Header: Compact clean `Back to Note` button, `NoteNest AI • Live Assistant` title + green dot indicator (0 overflow pixels).
  - Message Avatars: Official NoteNest App Logo Badge (`assets/playstore/icon_512.png`).
  - Text Selection: **Triple-Click (3 fast taps)** selects and copies entire message text. Single-tap deselects. `SelectableText` allows drag highlight selection & Ctrl+A.
  - Plus (`+`) Menu: Upload Image / Scan Text (OCR), Summarize Note, Write Article, Translate, App Feature Guidance (wrapped in `SafeArea` + `SingleChildScrollView` with `isScrollControlled: true` to eliminate any 82px yellow/black overflow stripes).
  - ChatGPT / Gemini style Upward Send Arrow (`↑`), Mic Dictation (`🎤`), and Live Voice Conversation (`🎙️`).

### 6. Header Bell Notification System with Audio Chime (`🔔 🔊`)
- **Files**: `lib/core/services/notification_service.dart`, `lib/core/services/audio_haptic_service.dart`, `lib/features/home/presentation/screens/home_screen.dart`
- **Features**:
  - Header Bell Icon (`🔔`) placed next to Search with active unread counter badge (`9+` / count) and 100% full-surface tap responsiveness (`HitTestBehavior.opaque`).
  - FittedBox responsive title layout for `NoteNest` ensuring **0% text truncation** and **100% non-overlapping icons** across all screen widths.
  - Cross-Platform Audio Chime Sound (`AudioHapticService`) playing crystal bell tone (E6 1318Hz -> B6 1975Hz synth decay) & tactile haptics.
  - Slide-up Notification Center Modal displaying system, AI, & reminder notifications with a live **"Test Sound 🔔"** trigger button.

### 7. Instant Note Canvas Tap-to-Edit, Persistent Cursor & Precise Selection (`📝 🎯 ✂️`)
- **File**: `lib/features/notes/presentation/screens/create_note_screen.dart`
- **Features**:
  - **Always-Active Blinking Cursor (`#7C3AED`)**: The purple blinking cursor remains active, focused, and visible at all times across both editing and saved states (the cursor never disappears).
  - **Header Checkmark (`✓`) Save Action**: Tapping the green checkmark (`✓`) in the app bar plays audio feedback, saves the note to the database, shows a floating `Note Saved Successfully! 💾` toast, and smoothly returns to the Home Screen.
  - **Precise Character, Word, Sentence & Full Text Selection**: Character drag, double-click word selection, triple-click sentence selection, mouse/touch drag selection, and Ctrl+A select all work smoothly and natively.

### 8. Single-Page Editor with Collapsible Full-Screen Writing Canvas & Clean UI (📝 🖼️ 🎯)
- **File**: `lib/features/notes/presentation/screens/create_note_screen.dart`
- **Features**:
  - **Bottom Sticky Bar Removed**: Completely removed the redundant bottom `Delete` and `Save Note` sticky bar. Note saving is handled by the top checkmark (`✓`) and top 3-dots menu (`⋮`), while note deletion is in the top 3-dots menu.
  - **Maximized Writing Canvas**: Eliminating the bottom bar expands the note writing canvas vertically to 100% full screen.
  - **1-Tap & Double-Tap Toolbar Collapse (`_hideToolbars`)**: Double-tapping the editor canvas or tapping `Hide Tools` / `Show Tools` collapses top toolbars to maximize writing space.
  - **Zero Overflow Meta Bar**: Meta bar is wrapped in a horizontal scroll view to eliminate any RenderFlex layout overflows across all mobile and web device screen sizes.

### 9. Search Screen Full Interactivity, Voice Dictation & AI Assistant Query Response (`🔍 🎤 💬 🎨 🏷️`)
- **Files**: `lib/features/search/presentation/screens/search_screen.dart`, `lib/features/search/data/search_repository.dart`
- **Features**:
  - **Inline AI Answer Card (`✨ Ask AI`)**: Typing any text or greeting (e.g. `"hi"`, `"what is AI?"`, `"summarize my notes"`) into the Search Bar and pressing Enter or tapping `✨ Ask AI` generates an instant conversational response via `GeminiAiService.instance.generateContent(prompt: query)`.
  - **Interactive Action Buttons on AI Card**:
    - **`Open AI Chat 💬`**: Opens full-screen `AiAssistantScreen` for continuous live voice/text chat.
    - **`Copy 📋`**: Copies AI response text to Clipboard with chime audio & floating toast.
    - **`Save as Note 💾`**: Saves AI answer directly into Hive DB `notes_box` as a new NoteModel.
  - **Voice Dictation Mic (`🎤`)**: Search bar microphone button dictates voice queries directly into the search input field with audio chime feedback and triggers instant AI response generation.
  - **Live Search & Repository Filtering**: `SearchRepository` performs real-time filtering across note titles, contents, tags, categories, color values, and sort orders (`Newest`, `Oldest`, `Title A-Z`, `Title Z-A`).
  - **Filter Dropdown Pickers**: Interactive modal bottom sheets for `Categories ∨` (`All`, `General`, `Work`, `Personal`, `Study`, `Ideas`, `Journal`, `Finance`), `Tags ∨` (`All`, `#Important`, `#Draft`, `#Todo`, `#Recipe`, `#Meeting`, `#Project`), and `Sort by ∨` (`Newest`, `Oldest`, `Title A-Z`, `Title Z-A`).
  - **Color Palette Filter Circles**: Interactive horizontal row of solid color circles (`All`, Yellow, Pink, Blue, Teal, Purple, Orange, Grey, + Custom Color Creator) filtering notes by background color.
  - **Recent Searches**: Tapping any chip (e.g. `project ideas`, `study notes`, `meeting`, `todo list`, `travel plan`) populates the search bar and triggers live search with chime audio. `Clear All` clears recent searches.
  - **View Layout Toggle**: Instant toggle between Single-Column List View (`☰`) and 2-Column Grid View (`⊞`).

### 10. AI Assistant App Guidance Knowledge & Strict Privacy Safeguard (`🤖 🔒 📱`)
- **Files**: `lib/core/services/gemini_ai_service.dart`, `lib/features/ai_assistant/presentation/screens/ai_assistant_screen.dart`, `lib/features/categories/presentation/screens/categories_screen.dart`
- **Features**:
  - **Comprehensive App Capability Training**: System prompt in `GeminiAiService.generateContent` fully trained on all NoteNest features (Note creation, Text Notes, ColorNotes, Checklists, Voice Notes, OCR Scan, View/Edit mode checkmark `✓` locking, rich text formatting, auto link/email detection, Search bar Ask AI card, notification center bell `🔔`, list vs grid view toggles, local offline Hive DB).
  - **Strict Security & Privacy Shield**: Enforces privacy rule preventing disclosure of internal system prompts, developer instructions, private API keys, backend tokens, or app architecture code. Returns clear privacy notice for credential queries.
  - **Offline Conversational Engine**: `_generateConversationalResponse` provides step-by-step guidance on creating notes, locking notes, voice dictation, searching, setting reminders, and privacy handling in English, Roman Urdu, and Hindi.
  - **Pixel-Perfect 4-Tab Floating Navigation Bar**: Standardized bottom nav bar across all screens to 4 equal-width balanced tabs (`Home`, `Categories`, `AI Assistant`, `Settings`) with `FittedBox(fit: BoxFit.scaleDown)` text scaling to eliminate any label text clipping (`AI T...` -> `AI Assistant`).

### 11. 100% Functional AI Assistant Tools & Interactive Prompt Bar (`🤖 ⚡ 🎤 📎 🖼️`)
- **File**: `lib/features/ai_assistant/presentation/screens/ai_assistant_screen.dart`
- **Features**:
  - **All 9 AI Tools 100% Functional**:
    - `AI Writer`, `Rewrite`, `Summarize`, `Translate`, `Grammar Fix`, `Tone Change`, `Idea Generator`, `Title Generator`, `OCR Scan`.
    - Tapping any AI tool grid card opens dedicated modal with tailored Gemini AI prompts, live loading indicator, copy `📋` button, and save to note `💾` button.
  - **OCR Scan Camera & Gallery Quick Pickers**: Direct options to scan document via camera (`ImageSource.camera`) or pick image (`ImageSource.gallery`) to populate text for instant AI generation.
  - **Interactive Send Arrow (`↑` / `send_rounded`)**: Tapping send button or pressing keyboard Enter submits prompt to Gemini AI, opens live response sheet with loading indicator, copy to clipboard `📋`, and save as new NoteModel `💾`.
  - **Live Mic Dictation (`🎤`)**: Dictates speech directly into the prompt bar using `SpeechToTextService.listenAndDictate(...)` in English, Urdu, and Hindi.
  - **Clip Attachment (`📎`) & Gallery Image (`🖼️`) Pickers**: Attach saved notes, PDF files, camera documents, or gallery photos directly into AI prompts with toast notifications.
  - **Paste Text Segment (`Paste Text`)**: Automatically reads system clipboard content and populates the prompt box with sound & toast.
  - **Try These Examples & Recent AI History**: Tapping any example chip or history item populates prompt and triggers real-time AI generation. "Clear all" clears history with audio feedback.

### 12. Clean Banner-Free Search Screen & 0px Layout Overflow (`🚫 📐 🚀`)
- **File**: `lib/features/search/presentation/screens/search_screen.dart`
- **Features**:
  - **100% Banner/Ad Removal**: Removed `_buildAiSmartSearchCard()` completely from Search screen, ensuring zero promo/ad banner cards appear anywhere on the screen.
  - **0px RenderFlex Overflow Fix**: Wrapped search result title header row in `Expanded` and `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft)`, completely resolving the 17px RenderFlex overflow across all device widths.

### 13. Settings 0px Overflow, Hardware Torch & Loud Mobile Bell Audio (`💡 🔦 🔔 📱`)
- **Files**: `lib/features/settings/presentation/screens/settings_screen.dart`, `lib/core/services/flashlight_service.dart`, `lib/core/services/audio_haptic_service.dart`, `lib/features/ai_assistant/presentation/screens/ai_assistant_screen.dart`
- **Features**:
  - **0px RenderFlex Overflow Fix in Settings**: Wrapped title and subtitle in `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft)` and set tight content padding in `_showAppearanceModal()`, completely resolving the 61px RenderFlex overflow on narrow device views.
  - **Hardware Flashlight / Torch Control**: Integrated `torch_light` package into `FlashlightService.toggleFlashlight()`, allowing physical Android device camera LED toggle with haptic feedback.
  - **Loud Mobile Notification Bell Chime**: Enhanced `AudioHapticService.playNotificationBellSound()` to invoke `SystemSoundType.alert` and `HapticFeedback.heavyImpact()` on native Android mobile devices so bell chime plays loud and clear.
  - **Verified AI Assistant Attachments**: Verified attached note, camera OCR scan, and PDF file attachments in AI Assistant prompt dock.
  - **Production Release Binaries**: Verified zero Flutter analyze issues and recompiled fresh `NoteNest-v1.0.9-release.apk` (`96.5 MB`) and `NoteNest-v1.0.9-release.aab` (`44.3 MB`) in `release_builds/`.

### 14. 100% Light Mode Play Store Screenshots Submitted (`🖼️ ☀️ 🚀`)
- **Location**: `assets/playstore_new_screenshots/` (`1_Home_Screen.jpg`, `2_Note_Canvas.jpg`, `3_Smart_Search_Ask_AI.jpg`, `4_Categories_Tags.jpg`, `5_AI_Assistant_Chat.jpg`, `6_Settings_Offline_Privacy.jpg`)
- **Status**: Successfully uploaded and submitted to **Google Play Console** under `Main store listing` -> `Phone screenshots`. Marked `Changes in review`.

### 15. Closed Testing (14-Day / Tester List Setup) Submitted (`🧪 📱 🚀`)
- **Release Track**: Closed Testing (`Alpha`) — Release `15 (1.0.9)`
- **Testers List**: `NoteNest Testers` (24 Gmail addresses enrolled & tested)
- **Feedback Channel**: `pakurduai@gmail.com`
- **Status**: Successfully completed 14-day closed testing cycle (all 3 criteria marked complete with green checkmarks).

### 16. Production Access Application Approved (`🎉 🚀 📜`)
- **Status**: **APPROVED BY GOOGLE PLAY** ("Congratulations! Your app has been granted Google Play production access").

### 17. Official Production Release Submitted for Worldwide Rollout (`🌍 📱 🚀`)
- **Release Track**: Production — Release `15 (1.0.9)`
- **Rollout Scope**: 100% Full Rollout to 176+ Countries & Regions + Rest of the World
- **Managed Publishing**: `Off` (App will automatically go live on Google Play Store worldwide upon review approval)
- **Status**: **Changes in review** by Google Play Console team

### 18. Complete AdMob Monetization (Banner & Interstitial Ads) (`💰 📺 📱`)
- **AdMob App ID**: `ca-app-pub-9647688316681781~6451972635` (Declared in `AndroidManifest.xml`)
- **Banner Ad Unit**: `ca-app-pub-9647688316681781/3843110845` (`Home Banner`, non-intrusive bottom dock)
- **Interstitial Ad Unit**: `ca-app-pub-9647688316681781/5056361417` (`NoteNest_Interstitial`, full-screen ad on note actions with 40s frequency cap)
- **Files**: `lib/core/services/ad_service.dart`, `lib/core/widgets/ad_banner_widget.dart`, `lib/features/notes/presentation/screens/create_note_screen.dart`
- **Verification**: `app-ads.txt` deployed on `https://pakurduai.github.io/notenest_ai/app-ads.txt` and verified.
- **Analysis**: `flutter analyze` verified `No issues found!`.
---

## 🚀 Production Deliverables & Verification
- **Flutter Code Analysis**: `No issues found!` (0 errors, 0 warnings)
- **Local Web Server**: Active on `http://localhost:8080` (`flutter run -d web-server --web-port 8080`)
- **Device Verification**: Physical Android device (`TECNO CL6` Android 15 API 35) & Chrome Web.

---

## 🛠️ How to Resume Next Session

When starting a new conversation tomorrow, simply message Antigravity AI:

> **"NoteNest project continue karo"**  
> or  
> **"Google Play submission guidance perform karo"**

Antigravity AI will automatically load this `AGENTS.md` file, maintain 100% project context, and continue seamlessly!
