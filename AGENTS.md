# AGENTS.md — NoteNest Project Context & Memory Guidelines

This document stores the complete project state, design system rules, completed features, and production release specifications for **NoteNest**. Antigravity AI reads this file automatically at the start of any new chat session.

---

## 📌 Project Overview
- **App Name**: NoteNest
- **Play Store Title**: `NoteNest: Offline Notes`
- **Android Launcher Label**: `NoteNest`
- **Package ID / Namespace**: `com.notenest.ai`
- **Version**: `1.0.9` (Build `10`)
- **Framework**: Flutter (Dart)
- **Target Platforms**: Android (Edge-to-Edge API 21-35) & Web (`http://localhost:8080`)
- **Branding Colors**:
  - Primary Purple: `#7C3AED` / `#8A2BE2`
  - Accent Cyan / Blue: `#00C6FF` / `#2563EB`
  - Home Screen Background: Light Lavender Tint (`#F6F5FA`)

---

## 🔒 LOCKED APPLICATION ARCHITECTURE & RECENT COMPLETED FEATURES

### 1. App Launch Brand Screen (1.5s Launch Screen)
- **File**: `lib/main.dart`, `lib/features/splash/presentation/screens/splash_screen.dart`
- **Behavior**: Opens to a clean launch screen with centered NoteNest AI logo badge for **1.5 seconds**, smoothly fading into `HomeScreen`.

### 2. Header & Navigation Bar UI (Pixel-Perfect Alignment)
- **File**: `lib/features/home/presentation/screens/home_screen.dart`
- **Features**:
  - **Direct List View vs Grid View Toggle Buttons**:
    - Tapping **List View Icon** (`☰`) directly switches layout to **Single-Column List View** (`_isGridView = false`) with audio/haptic feedback & purple indicator.
    - Tapping **Grid View Icon** (`⊞`) directly switches layout to **2-Column Grid View** (`_isGridView = true`).
  - **Modal Bottom Sheet Tabs (100% Non-Overlapping)**: `Color / Tag`, `Sort Order`, and `View Layout` tabs rendered cleanly without text clipping.
  - **Create New Bottom Sheet Overflow Fix**: `childAspectRatio` tuned to `1.75` with `TextOverflow.ellipsis` on `Text Note`, `Checklist`, `Voice Note`, `Scan Document`, `AI Note`, and `Premium` tiles.
  - **Equal Width Floating Navigation Bar**: All 4 tabs (`Home`, `Categories`, `AI Assistant`, `Settings`) balanced with compact pill for `Home`.

### 3. Note Editor & ColorNote View/Edit Modes
- **File**: `lib/features/notes/presentation/screens/create_note_screen.dart`
- **Features**:
  - Checkmark `✓` tap saves note and locks into Read/View Mode.
  - **Single-tap or Double-tap Toggles**: Tapping/double-tapping anywhere on the note text area or "Tap to edit note content..." placeholder in View Mode seamlessly unlocks Edit Mode. Double-tapping the editor canvas in Edit Mode saves and locks into View Mode.
  - Top 3-dots menu (`⋮`): Reminder, Send/Share, Lock, Discard/Delete.
  - Auto Link Detection: Web URLs, Emails, and Phone Numbers render as clickable blue links.

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

### 8. Single-Page Editor with Collapsible Full-Screen Writing Canvas (📝 🖼️ 🎯)
- **File**: `lib/features/notes/presentation/screens/create_note_screen.dart`
- **Features**:
  - **Unified Single-Page Note Editor**: All writing and rich text formatting (Bold, Italic, Underline, Strikethrough, Text Colors, Background Note Colors, Tags) remain on the single primary Note Editor screen (no separate pages).
  - **1-Tap & Double-Tap Toolbar Collapse (`_hideToolbars`)**: Double-tapping the editor canvas or tapping `Full-Screen Canvas` in the meta bar collapses top toolbars to maximize writing space. Tapping `Show Toolbars` expands all formatting tools instantly.
  - **Zero Overflow Meta Bar**: Meta bar is wrapped in a horizontal scroll view to eliminate any RenderFlex layout overflows across all mobile and web device screen sizes.

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
