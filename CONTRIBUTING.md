# Contributing

Contributions are welcome! Please follow these guidelines.

## Prerequisites

- Flutter SDK (stable channel)
- Dart (included with Flutter SDK)

## Setup

```bash
flutter pub get
```

> Hive adapters in `lib/models/` are handwritten. There is no `build_runner` step
> and no `*.g.dart` files to generate.

## Running Tests

**Fast tests (no golden comparisons):**
```bash
flutter test --exclude-tags golden
```

**Golden screenshot tests:**
```bash
flutter test test/golden_test.dart
```

**Update golden screenshots (after intentional UI changes):**
```bash
flutter test test/golden_test.dart --update-goldens
```

Golden test failures with small pixel diffs? Regenerate with `--update-goldens`
and inspect the result. The generated images live in
`assets/images/screenshots/`, which is gitignored and rebuilt on demand, so they
are not committed.

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

Store screenshots are generated from the golden tests. Run locally to preview
and regenerate:

```bash
flutter test test/golden_test.dart --update-goldens
```

The images are written to `assets/images/screenshots/`, which is gitignored and
not committed. There is no release screenshot workflow; `ci.yml` is the only
workflow in the repository.

## Pull Request Process

1. Create a feature branch from `v3`
2. Make your changes
3. Ensure `flutter analyze` and `flutter test --exclude-tags golden` pass
4. Update tests if adding functionality
5. Submit a PR against `v3` with a clear description
