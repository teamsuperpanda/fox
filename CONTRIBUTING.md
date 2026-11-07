# Contributing

Contributions are welcome! Please follow these guidelines.

## Prerequisites

- Flutter SDK (stable channel)
- Dart (included with Flutter SDK)

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

> `*.g.dart` files are gitignored -- you must run code generation before building.

## Running Tests

```bash
flutter test
```

The suite under `test/` is the regression gate and runs in CI.

### Store screenshots

`tool/store_screenshots_test.dart` is a screenshot generator, not a regression test. It renders the
store listing frames for five device sizes and writes PNGs to `assets/images/screenshots/`, which is
gitignored. Because it is outside `test/`, `flutter test` does not pick it up, and CI does not run
it. A widget test change can never be blocked by a screenshot diff.

Regenerate the store screenshots in one command:

```bash
flutter test tool/store_screenshots_test.dart --update-goldens
```

Treat the output as build artifacts: preview it locally, then copy the images into the store
listing. Do not commit them.

## Architecture

- `lib/data/` - Local persistence and data sources
- `lib/l10n/` - Localization ARB files
- `lib/models/` - Data models
- `lib/providers/` - State management (Provider)
- `lib/services/` - Business logic and services
- `lib/theme/` - App theming
- `lib/widgets/` - Reusable UI components

## Code Style

- Run `dart fix --apply` before committing
- Run `flutter analyze` -- zero issues required
- Run `dart format lib/ test/` to auto-format

## Localization

This app supports 30+ languages via ARB files in `lib/l10n/`.

**Adding a new locale:**
1. Create `lib/l10n/app_{locale}.arb` (copy `app_en.arb` as a template)
2. Run `flutter gen-l10n` to regenerate localizations
3. Add the locale to any locale picker UI

**Rules:**
- Always include all keys from `app_en.arb` (the source of truth)
- Do not modify generated `AppLocalizations` files directly
- Run `flutter gen-l10n` after any ARB change

## Release Screenshots

Store screenshots are generated with `tool/store_screenshots_test.dart` (see above). The images are
not committed; regenerate them with `--update-goldens` and copy them into the Android/iOS Fastlane
metadata when cutting a release.

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes
3. Ensure `flutter analyze` and all tests pass
4. Update tests if adding functionality
5. Submit a PR with a clear description
