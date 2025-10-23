# Fox - Flutter Notes App

## Architecture Overview

**Local-first notes application** built with Flutter, using Hive for persistent storage and Provider for state management. Clean architecture with repository pattern separates business logic from data persistence.

### Core Components

- **Data Layer**: `NoteRepository` interface with `HiveNoteRepository` implementation
- **Business Logic**: `NotesController` manages notes CRUD, search, sorting, and pinning
- **UI Layer**: `HomePage` (list view), `NoteDetailPage` (editor), `NoteList` widget
- **State Management**: `ThemeProvider` for light/dark mode, `NotesController` extends `ChangeNotifier`

### Key Data Structures

```dart
// Current Note model (services/repository.dart)
class Note {
  final String id;
  final String title;
  final String content;
  final bool pinned;
  final DateTime updatedAt;
}
```

Notes are sorted by pinned status first, then by `updatedAt` (newest first by default). Note IDs use UUID v4 for uniqueness.

## Development Workflow

### Setup & Run
```bash
flutter pub get
flutter run
```

### Testing
```bash
flutter test --coverage  # Runs all tests with coverage
```

### Build & Analyze
```bash
flutter analyze          # Static analysis
flutter build apk        # Android build
flutter build ios        # iOS build (requires macOS)
```

### Database Management
- Hive boxes: `notes_db`, `settings_db`, `migration_flags`
- Adapters registered manually (no build_runner): `NoteAdapter` (typeId: 3), `SettingsAdapter` (typeId: 2)
- Storage initialized in `StorageService.init()` before app startup

## Project Conventions

### State Management
- Use `ChangeNotifier` for reactive updates
- Access controllers via `Provider.of<T>(context)` or `context.watch<T>()`
- Load data in `initState()` and listen to controller changes

### Navigation
```dart
final result = await Navigator.of(context).push<bool>(MaterialPageRoute(
  builder: (_) => NoteDetailPage(controller: controller),
));
if (result == true) setState(() {});  // Refresh if needed
```

### Assets
- Icons: `assets/images/icon/`
- Launch screens: `assets/images/launchscreen/`
- Native splash configured in `pubspec.yaml`

### Testing Patterns
- Use `MemoryRepo` for unit tests (implements `NoteRepository`)
- Test widgets with `flutter_test`
- Mock dependencies for isolated testing

### Versioning & Releases
- Semantic versioning (current: 1.3.3+9)
- Release notes in `release_notes.json` with multi-language support
- CI runs on PRs to main branch

## Common Patterns

### Adding New Notes
```dart
await controller.addOrUpdate(
  title: title.trim(),
  content: content,
  pinned: false,
);
```

### Search & Sort
- Search filters by title/content (case-insensitive)
- Sort options: date (asc/desc), title (asc/desc)
- Pinned notes always appear first

### Error Handling
- Repository methods throw `StateError` if not initialized
- Use try/catch in async operations
- Validate input data before persistence

## Dependencies

- **hive/hive_flutter**: Local database
- **provider**: State management
- **google_fonts**: Typography
- **flutter_native_splash**: App launch experience
- **flutter_launcher_icons**: App icons
- **uuid**: Unique identifier generation

## Context7 MCP Access

Latest library documentation available via Context7 MCP server for dependency research and API exploration.</content>
<parameter name="filePath">/home/howley/Documents/GitHub/fox/.github/copilot-instructions.md