# Architecture Overview

A map of the Fox codebase, kept in step with the tree. If a change adds, removes
or moves a module, a box, a dependency or a documented command, update this file
in the same pull request.

## 1. Project Structure

```
fox/
├── lib/                    # Application source
│   ├── main.dart           # Entry point, DI wiring, splash and app shell
│   ├── home_page.dart      # Note list with search, FAB and folder filter
│   ├── note_detail_page.dart # Note editor with Flutter Quill
│   ├── data/
│   │   └── locale_display_names.dart # Native language names for the locale picker
│   ├── l10n/               # 31 ARB files and generated AppLocalizations
│   ├── models/
│   │   ├── note.dart       # Note model, Quill Delta JSON content
│   │   ├── folder.dart     # Folder model
│   │   ├── settings.dart   # Settings model
│   │   ├── note_colors.dart # Accent and note colour palettes
│   │   ├── note_adapter.dart     # Handwritten Hive adapter
│   │   ├── folder_adapter.dart   # Handwritten Hive adapter
│   │   └── settings_adapter.dart # Handwritten Hive adapter
│   ├── providers/
│   │   ├── theme_provider.dart   # Theme mode and accent colour
│   │   └── locale_provider.dart  # Locale override, persisted through SettingsService
│   ├── services/
│   │   ├── notes_controller.dart  # Notes business logic: CRUD, sort, filter, search
│   │   ├── repository_hive.dart   # Hive implementation of the note and folder repository
│   │   ├── storage_service.dart   # Hive init, adapter registration, box opening
│   │   ├── settings_service.dart  # Persisted settings CRUD via Hive
│   │   ├── box_names.dart         # Hive box name constants
│   │   └── constants.dart         # Locale helpers and app constants
│   ├── theme/
│   │   └── app_theme.dart  # Material 3 light and dark themes with dynamic accent
│   └── widgets/            # Reusable UI widgets, no business logic
│       ├── note_list.dart
│       ├── dialogs.dart
│       ├── empty_state.dart
│       ├── folders_dialog.dart
│       ├── language_picker_dialog.dart
│       └── view_options_sheet.dart
├── test/                   # 20 test files, 209 tests
│   ├── flutter_test_config.dart # Font preloading, tolerant golden comparator
│   ├── golden_test.dart         # Store screenshot goldens (tag: golden)
│   ├── store_frame.dart
│   ├── test_helpers.dart        # MemoryRepo, MockRepository
│   └── hive_*/                  # Hive box fixtures used by storage tests
├── integration_test/
│   └── app_test.dart       # Smoke test
├── assets/
│   ├── fonts/              # Inter family (4 weights), bundled
│   └── images/             # Icons, launch screen art, GitHub banner
├── tool/
│   └── ci_test.sh          # Test entrypoint used by CI (excludes golden tests)
├── android/                # Android platform files (Gradle, Fastlane, res)
├── ios/                    # iOS platform files (Xcode, Fastlane, Runner)
├── pubspec.yaml            # Project manifest
├── analysis_options.yaml   # very_good_analysis + dart_code_linter
├── l10n.yaml               # Localization config
└── README.md, CONTRIBUTING.md, SECURITY.md, ASSETS-LICENSE.md, ARCHITECTURE.md
```

There is no `web/` directory in the repository. `.gitignore` ignores `web/`
because it is local Flutter output only, and web is not a supported target.

## 2. High-Level System Diagram

```
[User] <--> [Flutter App (Hive)]
                  |
                  No backend. No cloud. No accounts.
                  All data stays on device.
```

Hive (key-value NoSQL) is the sole authoritative store. The app is offline-first
with no sync, no accounts and no cloud dependency.

## 3. Core Components

### 3.1. Flutter App

**Name:** Fox

**Description:** A local-first notes app with rich text editing, folders, search,
dark mode and 31 locales.

**Technologies:** Flutter, Dart 3.6+, Provider, Hive, Flutter Quill

**Platforms and distribution:** Android and iOS, through Google Play and the App
Store. Release builds are produced by CI and the platform toolchains.

### 3.2. Data Layer

**Name:** Hive Storage

**Description:** Three Hive boxes (`notes_db`, `folders_db`, `settings_db`) with
handwritten TypeAdapters. There is no `build_runner` step and no `*.g.dart`
files. Note content is stored as Quill Delta JSON.

**Technologies:** Hive, Hive Flutter

**Storage boxes:**

- `notes_db`: Note objects (UUID key, Quill Delta content, pinned, tags, folderId,
  colour, timestamps)
- `folders_db`: Folder objects (UUID key, name, timestamps)
- `settings_db`: a single Settings object (theme, locale, view preferences, sort,
  accent colour)

### 3.3. Rich Text Editor

**Name:** Flutter Quill integration

**Description:** A Quill Delta-based editor embedded in `NoteDetailPage`, with
bold, italic, bullet and ordered lists and a formatting toolbar.

**Technologies:** flutter_quill ^11.6.0

### 3.4. State Management

**Name:** Provider (ChangeNotifier)

**Description:** Three ChangeNotifiers:

- `ThemeProvider`: theme mode and accent colour
- `LocaleProvider`: language override, persisted in the `settings_db` Hive box
  through `SettingsService`
- `NotesController`: notes business logic (sort, filter, search, CRUD)

**Technologies:** provider ^6.1.5

### 3.5. Theme Engine

**Name:** AppTheme

**Description:** Material 3 light and dark themes with a dynamic accent colour.
A single `AppTheme` class exposes `light(Color)` and `dark(Color)`. Ten accent
colours are defined in `models/note_colors.dart`.

**Technologies:** Material 3, `ThemeData`, the bundled Inter font family. There
is no `google_fonts` dependency and no runtime font download.

## 4. Module Boundary Convention

- **`widgets/`**: reusable UI components. No business logic.
- **Pages** (`home_page.dart`, `note_detail_page.dart`): full-screen pages that
  compose widgets and may use providers and services.
- **`providers/`**: ChangeNotifier providers for theme and locale state.
- **`services/`**: business logic and data access. `NotesController` is the
  central notes state holder (also a ChangeNotifier).
- **`models/`**: pure data models with handwritten Hive adapters. No Flutter
  widgets, no Hive box access.

**Dependency rule:** `widgets/` never imports pages. Pages may import `widgets/`,
`providers/` and `services/`. `services/` may import `models/`. `models/` imports
no app code above it.

## 5. Data Stores

### 5.1. Primary Database

**Name:** Hive

**Type:** Key-value NoSQL (embedded)

**Purpose:** Authoritative store for all app data. Never bypassed.

**Key Boxes:** `notes_db`, `folders_db`, `settings_db`

## 6. External Integrations / APIs

None. There are no network requests, no analytics and no telemetry at runtime.

## 7. Deployment and Infrastructure

- **CI:** GitHub Actions, `.github/workflows/ci.yml` (format check, analyze, tests)
- **Platforms:** Android, iOS
- **Code generation:** localization only (`flutter gen-l10n`). Hive adapters are
  handwritten.
- **Distribution:** Google Play, Apple App Store

## 8. Security Considerations

- **Data at rest:** stored locally in Hive boxes under the app data directory, not
  encrypted.
- **Network:** no requests, no telemetry, no analytics.
- **Threat model:** see `SECURITY.md` for what the app does and does not protect
  against.

## 9. Development and Testing

- **Tests:** `flutter_test`. 20 test files, 209 tests. Golden screenshot tests are
  tagged `golden` and excluded from the default run.
- **Linting:** `very_good_analysis` + `dart_code_linter`
- **Formatting:** `dart format lib/ test/`
- **Localization:** ARB-based (`l10n.yaml`, 31 ARB files, 31 locales)
- **CI script:** `tool/ci_test.sh` runs `flutter test --exclude-tags golden`

## 10. Future Considerations

- Named routing as pages grow beyond the current two screens
- Data export and backup
- Search ranking and filters
- Wider dialog and form test coverage

## 11. Project Identification

**Project Name:** Fox

**Version:** 2.1.1 (build 20)

**Repository URL:** https://github.com/teamsuperpanda/fox

**License:** PolyForm Noncommercial 1.0.0 for the code; the Fox name and brand
assets are proprietary, see `ASSETS-LICENSE.md`.

**Date of Last Update:** 2026-11-07

## 12. Glossary

**Hive:** fast key-value database for Flutter and Dart

**Provider:** state management library built on ChangeNotifier and InheritedWidget

**Flutter Quill:** rich text editor based on the Quill Delta format

**ChangeNotifier:** observable object that notifies listeners of state changes

**Delta:** JSON-based rich text format used by the Quill editor
