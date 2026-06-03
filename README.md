# Fox

<img src="assets/images/icon/icon.png" width="80" alt="Fox Icon">

A friendly, local-first notes app. Fast, minimal, and private by default. Your notes stay on your device and are always available offline.

> Built by [Team Super Panda](https://www.teamsuperpanda.com)

---

## Features

- **Rich Text**: Create and edit notes with formatting.
- **Organization**: Tag, pin, and search your notes quickly.
- **Customization**: Dark/light themes and custom sort orders.
- **Privacy First**: Zero cloud overhead. No accounts. Anonymous analytics, opt-out anytime.
- **Modern UI**: Clean design with alternating list colors.

---

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (^3.6.0)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Persistence**: [Hive](https://pub.dev/packages/hive)
- **Editor**: [Flutter Quill](https://pub.dev/packages/flutter_quill)
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts)

---

## Getting Started

### Prerequisites
- Flutter SDK & Dart: `^3.6.0`

### Install & Run
```bash
git clone https://github.com/teamsuperpanda/fox.git
cd fox
flutter pub get
flutter run
```

### Tests
```bash
flutter test --coverage
```

---

## Architecture Overview

- **Data**: `Hive` stores notes in `notes_db` and settings in `settings_db`.
- **Logic**: `NotesController` manages CRUD and state; `SettingsService` for preferences.
- **UI**: Reactive updates via `Provider`. `NoteDetailPage` uses `flutter_quill`.

---

## License

- **Code**: [PolyForm Noncommercial License 1.0.0](LICENSE).
- **Assets**: Copyright © 2026 Team Super Panda. See [ASSETS-LICENSE.md](ASSETS-LICENSE.md).

For more, visit [www.teamsuperpanda.com](https://www.teamsuperpanda.com).
