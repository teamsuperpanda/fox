# Contributing to Fox

Thanks for helping. Fox is a small, local-first notes app and the codebase is
deliberately simple, so a useful contribution is usually a short one.

By taking part you agree to the [Code of Conduct](CODE_OF_CONDUCT.md). Security
issues go through [SECURITY.md](SECURITY.md), never a public issue.

## Before you start

- Search the [issues](https://github.com/teamsuperpanda/fox/issues) and
  [pull requests](https://github.com/teamsuperpanda/fox/pulls) first.
- Ask in [Discussions Q&A](https://github.com/teamsuperpanda/fox/discussions/categories/q-a)
  if you are not sure an idea fits.
- Open an issue before a large change. Small fixes and docs can go straight to a
  pull request.
- New here? The [`good first issue`](https://github.com/teamsuperpanda/fox/labels/good%20first%20issue)
  label marks issues that are self-contained and have clear acceptance criteria.

## Setup

You need the Flutter SDK on the stable channel (Dart 3.6 or newer).

```bash
git clone https://github.com/teamsuperpanda/fox.git
cd fox
flutter pub get
flutter run
```

There is no code generation step. Hive adapters in `lib/models/` are
handwritten, and the repository does not use `build_runner` or `*.g.dart` files.
Localizations are generated from ARB files, see [Localization](#localization).

`ARCHITECTURE.md` explains the layers and where code belongs. Read it before
adding a service or a provider.

## Checks

Run these before pushing. They are the same checks CI runs on every pull request.

```bash
flutter pub get
dart format lib/ test/
dart format --output=none --set-exit-if-changed lib/ test/
flutter analyze
flutter test --exclude-tags golden
```

`flutter analyze` must report zero issues. Fix warnings rather than adding
`// ignore:` comments.

### Golden screenshot tests

`test/golden_test.dart` renders the store screenshots. It is tagged `golden` and
excluded from the normal test run and from CI. Run it when you change the UI:

```bash
flutter test test/golden_test.dart
```

Regenerate the images after an intentional UI change:

```bash
flutter test test/golden_test.dart --update-goldens
```

The images are written to `assets/images/screenshots/`, which is gitignored and
regenerated on demand. Do not commit them.

## Branches, commits and pull requests

- Branch from `v3`, the current development branch, and open pull requests
  against `v3`.
- One logical change per pull request. Keep unrelated refactors out.
- Commit messages follow conventional commits: `feat:`, `fix:`, `docs:`,
  `chore:`, `test:`, `refactor:`, with an optional scope, for example
  `fix(editor): keep cursor position after save`. Reference the issue number in
  the body when one exists.
- Fill in the pull request template. Say what changed, why, and how you tested
  it. Add a screenshot or recording for UI changes, and note new strings for
  translators.

CI must be green before review. A maintainer merges; do not merge your own pull
request or push to `v3` directly.

## Localization

User-facing strings live in `lib/l10n/app_en.arb`, the source of truth. Generated
`AppLocalizations` files are committed and regenerated with:

```bash
flutter gen-l10n
```

When you add a key, add it to `app_en.arb` with a description, run `flutter gen-l10n`,
and use `AppLocalizations.of(context)` in the widget. Do not edit the generated
`app_localizations*.dart` files by hand. See [ARCHITECTURE.md](ARCHITECTURE.md)
for the current locale list.

## Code style

- Follow the existing layer boundaries: `widgets/` has no business logic,
  `services/` has no UI, `models/` stay pure data.
- Prefer the smallest change that solves the problem. No speculative abstraction.
- Use `AppLocalizations` for text, `AppTheme` for colour and typography, and the
  existing providers for state.
- No em dashes in user-facing text or comments.

## Licensing of contributions

Fox code is MIT licensed. By opening a pull request you agree that your
contribution is licensed under the same terms. The Fox name, logo and brand
assets are proprietary and are not covered by MIT, see
[ASSETS-LICENSE.md](ASSETS-LICENSE.md). Do not add assets you do not have the
right to license.

## Security

Do not open a public issue for a vulnerability. Report it privately through
GitHub's [private vulnerability reporting](https://github.com/teamsuperpanda/fox/security/advisories/new).
See [SECURITY.md](SECURITY.md) for the supported versions, response times, scope
and the threat model.
