Fox is a notes app written in flutter

## Migration: shared_preferences + sqflite -> Hive

Goal
- Migrate local persistence to Hive following the same structure used by Pandoo.
- Phase 1 (this ticket): implement user preferences (theme/locale) using Hive `settings_db` and a `Settings` model.

Why
- Notes app data is simple (single notes table) and user prefs are small and object-like. Hive reduces boilerplate, works on web + mobile with `hive_flutter`, and matches Pandoo's approach.

High-level plan
1. Add dependencies: `hive`, `hive_flutter`, dev: `hive_generator`, `build_runner`.
2. Create a `StorageService` (or `Storage.init`) to initialize Hive, register adapters, and open boxes. Mirror Pandoo's startup pattern.
3. Implement a `Settings` Hive model (typeId: 2 to match Pandoo convention). Create a TypeAdapter via codegen or manually.
4. Open a `settings_db` box and persist a single `Settings` instance under key `app_settings` (same as Pandoo).
5. Replace `shared_preferences` usages for theme/locale with `SettingsService` that reads/writes the Settings object.
6. Add one-time migration that reads the old shared_preferences value and writes the `Settings` object to Hive; mark migration complete.
7. Tests: unit tests for SettingsService and migration steps. Smoke test on web & mobile.

Phase 1 — Implement user preferences (detailed)

Checklist (phase 1)
- [ ] Add Hive deps to `pubspec.yaml`.
- [ ] Create `lib/services/storage_service.dart` with `init()` that:
  - calls `await Hive.initFlutter()`
  - registers adapters (`SettingsAdapter()`)
  - opens `settings_db` (Box<Settings>)
- [ ] Create `lib/models/settings.dart` with Hive annotations or a handwritten TypeAdapter. Use `typeId: 2`.
- [ ] Create `lib/services/settings_service.dart` that exposes:
  - `Future<Settings> getSettings()`
  - `ThemeMode getThemeMode()` (or `Future<ThemeMode>` if async)
  - `Future<void> setThemeMode(ThemeMode mode)` which writes a new `Settings` object to `settings_db` at key `app_settings`.
- [ ] Replace `lib/providers/theme_provider.dart` persistent calls to use `SettingsService` (read on startup, write on change).
- [ ] Implement migration helper `migrate_prefs_to_hive()` that:
  - reads `SharedPreferences` keys used today (e.g., `themeMode`) and creates `Settings` object
  - writes into Hive `settings_db['app_settings'] = settings`
  - sets flag `settings_db['migrated_prefs_v1'] = true`
- [ ] Add small unit tests that run storage init in a test environment and verify read/write.

File map (what we'll add/edit)
- `pubspec.yaml` — add dependencies (line items).
- `lib/services/storage_service.dart` — new.
- `lib/models/settings.dart` — new (+ generated `settings.g.dart` if codegen used).
- `lib/services/settings_service.dart` — new.
- `lib/providers/theme_provider.dart` — edit to read/write via `SettingsService` (or wrap SettingsService into provider).
- `lib/migrations/migrate_prefs.dart` — new migration helper invoked once from startup flow.

Settings model (contract)
- Input: persisted string fields (themeMode as String), locale code (optional), any other small settings.
- Stored under `settings_db` box at key `app_settings` as a single `Settings` object.
- Error modes: storage not initialized, adapter mismatch — Surface a sensible default (ThemeMode.system) and continue.

Code snippets (examples you can copy)

- Storage init (concept):

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings.dart';

class StorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SettingsAdapter());
    await Hive.openBox<Settings>('settings_db');
  }
}
```

- Settings model (concept using annotations):

```dart
import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  final String themeMode; // 'system'|'light'|'dark'

  @HiveField(1)
  final String? locale;

  Settings({required this.themeMode, this.locale});
}
```

- SettingsService (concept):

```dart
class SettingsService {
  static const _key = 'app_settings';
  final Box _box = Hive.box('settings_db');

  Settings getSettings() {
    return _box.get(_key) as Settings? ?? Settings(themeMode: 'system');
  }

  ThemeMode getThemeMode() {
    final s = getSettings();
    return switch (s.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final s = Settings(themeMode: mode.toString().split('.').last);
    await _box.put(_key, s);
  }
}
```

Migration helper (concept):

```dart
Future<void> migratePrefsToHive() async {
  final settingsBox = Hive.box('settings_db');
  if (settingsBox.get('migrated_prefs_v1') == true) return;

  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString('themeMode') ?? 'system';
  final settings = Settings(themeMode: stored);
  await settingsBox.put('app_settings', settings);
  await settingsBox.put('migrated_prefs_v1', true);
}
```

Quality gates & tests
- Run `flutter analyze` and `flutter test` after adding codegen.
- Test migration by pre-populating a `SharedPreferences` test instance and running `migratePrefsToHive()`.

Risks & mitigations
- If adapter `typeId` collides with future models, pick a naming/ID registry file and document `typeId`s.
- If migration fails mid-way, code is idempotent (guard via `migrated_prefs_v1`). Keep old shared_preferences code until migration is fully verified and shipped.

Next concrete tasks I can implement now
1) Edit `pubspec.yaml` to add Hive deps + dev deps.  
2) Add `lib/models/settings.dart` and auto-generate adapter (or hand-write adapter).  
3) Add `lib/services/storage_service.dart` and `lib/services/settings_service.dart`.  
4) Update `lib/providers/theme_provider.dart` to use `SettingsService`.

If you want I can implement tasks 1–4 now and run the tests. Tell me to proceed and whether you prefer codegen (`hive_generator`) or a handwritten adapter.

---
Generated: 2025-08-27
