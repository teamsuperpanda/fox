# Fox

<img src="assets/images/icon/icon.png" width="100" alt="Fox Icon">

Fox is a friendly, local-first notes app built with Flutter and Hive. It's designed to be fast, minimal, and private by default. Your notes stay on your device and are always available offline.

> Built with care by [Team Super Panda](https://www.teamsuperpanda.com)

---

## Download

Get Fox on the Google Play Store:

<a href="https://play.google.com/store/apps/details?id=com.teamsuperpanda.fox"><img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" width="200" alt="Get it on Google Play"></a>

---

## What is Fox?

Fox is a simple notes app for people who want:

- Quick note-taking: Capture ideas, todos, and drafts in seconds
- Pinned notes: Keep your most important notes at the top
- Dark & light themes: Easy on the eyes, day or night
- Fast search: Find notes by title or content, case-insensitive
- Smart sorting: Sort by date or title (asc/desc), with pinned notes always first
- Local-first storage: All data stays on your device via Hive
- Zero cloud overhead: No accounts, no sync setup, no third-party services

If you want a focused, distraction‑free place to write that "just works" on your device, Fox is for you.

---

## How it works

Fox uses a clean architecture to keep the app reliable and easy to extend.

### Data & persistence

- Local database: [Hive](https://github.com/hivedb/hive) stores all notes and settings on-device
- Hive boxes:
  - `notes_db` - All user notes
  - `settings_db` - Theme, sort order, and other preferences
  - `migration_flags` - Tracks data migrations between versions

### Business logic

- `NotesController` (`lib/services/notes_controller.dart`)
  - Handles all note actions: create, update, delete, search, sort, pin/unpin
  - Exposes a reactive list of notes for the UI
- `SettingsService` (`lib/services/settings_service.dart`)
  - Manages theme and other user preferences
- `StorageService` (`lib/services/storage_service.dart`)
  - Initializes Hive, opens boxes, and registers adapters before the app runs

### UI & state management

- `HomePage` (`lib/home_page.dart`)
  - Main list of notes with search, sorting, and pinning controls
- `NoteDetailPage` (`lib/note_detail_page.dart`)
  - Rich text editor powered by [Flutter Quill](https://pub.dev/packages/flutter_quill)
- `NoteList` (`lib/widgets/note_list.dart`)
  - Reusable list widget for rendering notes
- `ThemeProvider` (`lib/providers/theme_provider.dart`)
  - Toggles and persists light/dark mode using Provider

All state is managed with [Provider](https://pub.dev/packages/provider), so UI widgets automatically rebuild when notes or settings change.

---

## Features

- **Create & edit notes** with rich text (bold, italics, lists, and more)
- **Pin important notes** so they stay at the top
- **Search** by title or content (case-insensitive)
- **Sort** by date or title, ascending or descending
- **Dark mode** with persistent theme preference
- **Local-first storage** using Hive (no network required)
- **UUID‑based IDs** for unique notes across sessions

---

## Tech stack

- **Framework**: [Flutter](https://flutter.dev) (Dart ^3.6.0)
- **Local storage**: [Hive](https://github.com/hivedb/hive)
- **State management**: [Provider](https://pub.dev/packages/provider)
- **Rich text editor**: [Flutter Quill](https://pub.dev/packages/flutter_quill)
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts)
- **Utilities**: [UUID](https://pub.dev/packages/uuid)

---

## Getting started

### Prerequisites

- Flutter SDK: `^3.6.0`
- Dart: `^3.6.0`

Make sure Flutter is installed and configured for your platform (Android, iOS, web, desktop).

### Install & run

1. **Clone the repository**

   ```bash
   git clone https://github.com/teamsuperpanda/fox.git
   cd fox
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   ```bash
   flutter run
   ```

By default, Flutter will prompt you to pick a connected device or emulator/simulator.

### Running tests

Run the full test suite with coverage:

```bash
flutter test --coverage
```

Run tests for specific components:

```bash
flutter test test/notes_controller_test.dart        # Core business logic
flutter test test/home_page_test.dart              # UI: home screen
flutter test test/hive_notes_repository_test.dart  # Data layer
```

---

## Contributing

We'd love your help making Fox better.

Whether it's a bug report, feature idea, design tweak, or documentation improvement—contributions of all sizes are welcome.

### Ways to contribute

- Report bugs – Open a GitHub issue with steps to reproduce
- Suggest features – Share what you'd like to see next
- Improve tests – Add or refine unit and widget tests
- Polish the UI/UX – Small design improvements are very welcome
- Docs – Help make the project easier to understand

### Contribution flow

1. **Fork** the repository
2. **Create a branch** for your idea

   ```bash
   git checkout -b feature/your-idea
   ```

3. **Make your changes**
   - Keep the existing architecture and style in mind
   - Add or update tests where it makes sense

4. **Run tests**

   ```bash
   flutter test
   ```

5. **Open a Pull Request**
   - Describe what you changed and why
   - Include screenshots/GIFs for UI changes if possible

We'll review and discuss your contribution. Thank you for helping Fox grow.

---

## License & assets

The application source code is licensed under the [MIT License](LICENSE).

**Important notes:**

- The MIT License allows commercial use, but rebranding this app as your own and selling it without meaningful modifications is **not** in the spirit of this project.
- We encourage contributions and derivative works that add value and respect the original branding.

### Assets

Unless otherwise noted, all application assets (including icons and launch screen images under `assets/images/`) are **not** licensed under MIT and are copyright © 2025 Team Super Panda.

See [ASSETS-LICENSE.md](ASSETS-LICENSE.md) for full asset licensing details.

---

## Learn more about Team Super Panda

Fox is maintained by **Team Super Panda**, a small group that loves building thoughtful, privacy-friendly tools.

Visit us at **[www.teamsuperpanda.com](https://www.teamsuperpanda.com)** to learn more, follow our work, or say hi.

If you ship something cool with Fox—or build your own spin‑off—let us know. We'd love to see what you create.
