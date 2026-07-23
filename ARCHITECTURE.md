# Architecture Overview

[architecture.md](https://architecture.md/) template for rapid codebase comprehension. Update as the codebase evolves.

## 1. Project Structure

```
fox/
├── lib/                    # Main application source code
│   ├── main.dart           # App entry point, DI container, splash screen
│   ├── home_page.dart      # Main note list view with search, FAB, folder filter
│   ├── note_detail_page.dart # Note editor with Flutter Quill rich text
│   ├── data/               # Static data
│   │   └── locale_display_names.dart  # Native language name map for 31 locales
│   ├── l10n/               # Localization (31 ARB files, generated code)
│   ├── models/             # Data models
│   │   ├── note.dart       # Note model with Quill Delta JSON content
│   │   ├── folder.dart     # Folder model
│   │   ├── settings.dart   # Settings model
│   │   ├── note_colors.dart # 9 pre-defined note highlight colors
│   │   └── *_adapter.dart  # Handwritten Hive TypeAdapters (note, folder, settings)
│   ├── providers/           # ChangeNotifier providers (theme, locale)
│   │   ├── theme_provider.dart
│   │   └── locale_provider.dart
│   ├── services/            # Business logic layer
│   │   ├── notes_controller.dart   # Central business logic + sort/filter/search
│   │   ├── repository_hive.dart    # Hive implementation of NoteAndFolderRepository
│   │   ├── storage_service.dart    # Hive init, adapter registration, box opening
│   │   ├── settings_service.dart   # Persisted settings CRUD via Hive
│   │   ├── box_names.dart          # Hive box name constants
│   │   └── constants.dart          # Locale helpers, app constants
│   ├── theme/               # Material 3 light/dark theme with dynamic accent
│   │   └── app_theme.dart
│   └── widgets/             # Reusable UI widgets
│       ├── note_list.dart          # Dismissible note list with search highlighting
│       ├── dialogs.dart            # Delete confirmation, undo snackbar
│       ├── empty_state.dart        # Empty state widget
│       ├── folders_dialog.dart     # Folder management dialog
│       ├── language_picker_dialog.dart # Language selector with search
│       └── view_options_sheet.dart # Bottom sheet: sort, view, accent, language
├── test/                   # Unit and widget tests (~28 test files)
│   ├── flutter_test_config.dart    # Custom golden comparator, font preloading
│   ├── golden_test.dart            # Store screenshot goldens
│   ├── store_frame.dart            # Store listing screenshot frame widget
│   ├── test_helpers.dart           # MemoryRepo, MockRepository
│   └── hive_*/                     # Test Hive box fixtures
├── integration_test/       # Smoke tests
│   └── app_test.dart
├── assets/                 # Static assets
│   ├── fonts/              # Inter font family (4 weights)
│   └── images/             # Icons, launch screen branding, GitHub banner
├── tool/                   # Development tools
│   └── ci_test.sh          # CI test script (excludes golden tests)
├── android/                # Android platform files (Gradle, Fastlane, res)
├── ios/                    # iOS platform files (Xcode, Fastlane, Runner)
├── web/                    # Web platform PWA artifacts
├── pubspec.yaml            # Project manifest
├── analysis_options.yaml   # Linting rules (very_good_analysis + dart_code_linter)
├── l10n.yaml               # Localization config
├── README.md               # Project overview
├── CONTRIBUTING.md         # Contribution guidelines
├── ASSETS-LICENSE.md       # Asset copyright notice
└── ARCHITECTURE.md         # This document
```

## 2. High-Level System Diagram

```
[User] <--> [Flutter App (Hive)]
                  |
                  No backend. No cloud. No accounts.
                  All data stays on device.
```

Hive (key-value NoSQL) is the sole authoritative store. The app is fully offline-first with no sync, no accounts, and no cloud dependency.

## 3. Core Components

### 3.1. Flutter App

**Name:** Fox

**Description:** A simple, local-first notes app with rich text editing. Supports folders, search, dark mode, and 30+ languages. Zero cloud dependency.

**Technologies:** Flutter, Dart 3.6+, Provider, Hive, Flutter Quill

**Deployment:** GitHub Releases (web), App Store / Play Store (mobile)

### 3.2. Data Layer

**Name:** Hive Storage

**Description:** Three Hive boxes (`notes_db`, `folders_db`, `settings_db`) with handwritten TypeAdapters (no build_runner dependency). Note content stored as Quill Delta JSON.

**Technologies:** Hive, Hive Flutter

**Storage boxes:**
- `notes_db` — Note objects (UUID key, Quill Delta content, pinned, tags, folderId, color, timestamps)
- `folders_db` — Folder objects (UUID key, name, timestamps)
- `settings_db` — Single Settings object (theme, locale, view preferences, sort, accent color)

### 3.3. Rich Text Editor

**Name:** Flutter Quill Integration

**Description:** Quill Delta-based rich text editor embedded in `NoteDetailPage`. Supports bold, italic, bullets, ordered lists. Toolbar provides formatting controls.

**Technologies:** Flutter Quill ^11.5.0

### 3.4. State Management

**Name:** Provider (ChangeNotifier)

**Description:** Three providers via the `provider` package:
- `ThemeProvider` — Theme mode and accent color
- `LocaleProvider` — Language override with SharedPreferences persistence
- `NotesController` — Central notes business logic (sort, filter, search, CRUD)

**Technologies:** provider ^6.1.5

### 3.5. Theme Engine

**Name:** AppTheme

**Description:** Material 3 theme system with light/dark modes and dynamic accent colors. Single `AppTheme` class with `light(Color)` and `dark(Color)` factory methods.

**Technologies:** Material 3, `ThemeData`, Google Fonts (Inter)

## 4. Module Boundary Convention

The app follows a simple layered architecture:

- **`widgets/`** — Reusable UI components that are shared across pages. No business logic.
- **`pages/`** (root: `home_page.dart`, `note_detail_page.dart`) — Full-screen pages composing widgets. May use providers and services directly.
- **`providers/`** — ChangeNotifier providers for theme and locale state.
- **`services/`** — Business logic and data access. `NotesController` is the central state manager for notes (also a ChangeNotifier).
- **`models/`** — Pure data models with Hive annotations.

**Dependency rule:** `widgets/` never imports from `pages/`. `pages/` may import from `widgets/`, `providers/`, and `services/`. `services/` may import from `models/`.

## 5. Data Stores

### 5.1. Primary Database

**Name:** Hive

**Type:** Key-value NoSQL (embedded)

**Purpose:** Authoritative data store for all app data. Offline-first — never bypassed.

**Key Boxes:** notes_db, folders_db, settings_db

## 6. External Integrations / APIs

None. This is a fully offline, local-first application with no network dependencies.

## 7. Deployment & Infrastructure

- **CI/CD:** GitHub Actions (`ci.yml`)
- **Platforms:** Android, iOS, Web
- **Code Generation:** Handwritten Hive TypeAdapters (no build_runner needed)
- **Distribution:** Google Play, Apple App Store, GitHub Releases (web)

## 8. Security Considerations

- **Data at rest:** Stored locally in Hive boxes via path_provider. No encryption.
- **Network:** No network requests. No telemetry. No analytics.

## 9. Development & Testing

- **Testing:** `flutter_test` for unit and widget tests (~28 test files). Golden screenshot tests for store listing. Integration smoke tests.
- **Linting:** `very_good_analysis` + `dart_code_linter`
- **Localization:** ARB-based (`l10n.yaml`, 31 ARB files, 31 supported locales)
- **CI Script:** `tool/ci_test.sh` runs `flutter test --exclude-tags golden`

## 10. Future Considerations

- **Named Routing:** Consider as pages grow beyond current two screens
- **Data export/backup:** Add export to file or cloud backup
- **Search improvements:** Full-text search across all notes
- **Widget testing coverage:** Expand dialog and form interaction tests

## 11. Project Identification

**Project Name:** Fox

**Repository URL:** https://github.com/teamsuperpanda/fox

**License:** PolyForm Noncommercial 1.0.0

**Date of Last Update:** 2026-07-24

## 12. Glossary

**Hive:** Lightweight, fast key-value database for Flutter/Dart

**Provider:** State management library using ChangeNotifier and InheritedWidget

**Flutter Quill:** Rich text editor based on the Quill Delta format

**ChangeNotifier:** Observable object that notifies listeners of state changes

**Delta:** JSON-based rich text format used by Quill editor
