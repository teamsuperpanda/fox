<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/images/github/banner.png">
  <img src="assets/images/github/banner.png" alt="Fox">
</picture>

<p align="center">
  <a href="https://github.com/teamsuperpanda/fox/actions/workflows/ci.yml"><img src="https://github.com/teamsuperpanda/fox/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="License: MIT"></a>
  <a href="https://github.com/teamsuperpanda/fox/releases"><img src="https://img.shields.io/github/v/release/teamsuperpanda/fox" alt="Latest release"></a>
  <a href="https://github.com/teamsuperpanda/fox/releases"><img src="https://img.shields.io/github/downloads/teamsuperpanda/fox/total" alt="Downloads"></a>
</p>

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.teamsuperpanda.fox"><img src="https://img.shields.io/badge/Google%20Play-414141?logo=google-play&logoColor=white" alt="Google Play"></a>
  <a href="https://apps.apple.com/app/fox-list/id1625597940"><img src="https://img.shields.io/badge/App%20Store-0D96F6?logo=apple&logoColor=white" alt="App Store"></a>
</p>

Fox is a local-first notes app with rich text, folders, search and dark mode. No account, no subscription, no cloud dependency. The code is MIT licensed.

Built by [Team Super Panda](https://www.teamsuperpanda.com).

---

## What it does

- **Rich text**: bold, italic, bullet and ordered lists, and eight note colours. No markdown to remember.
- **Organise**: folders, pinning, tags and a sort order that stays put.
- **Search**: filter notes as you type, with the match highlighted.
- **Dark mode**: light and dark themes with ten accent colours.
- **31 languages**: English plus 30 translations, with a searchable language picker.
- **Offline-first**: notes live in a local Hive database on your device. The app makes no network requests at runtime.
- **No accounts**: open it and type. There is no sign-up screen.

## What it deliberately does not do

- **No sync.** There is no account and no server, so there is nothing to sync with.
- **No cloud or analytics.** No telemetry, no crash reporting, no third-party SDKs that phone home.
- **No encryption at rest.** Notes are stored unencrypted in the app's private directory. See the threat model in [SECURITY.md](SECURITY.md).
- **No web or desktop app.** The repository builds Android and iOS only. The `web/` directory is gitignored local output, not a supported target.
- **No plugin system or custom themes.** The app stays small on purpose.

## Install

- [Google Play](https://play.google.com/store/apps/details?id=com.teamsuperpanda.fox)
- [App Store](https://apps.apple.com/app/fox-list/id1625597940)

### Build from source

You need Flutter on the stable channel (Dart 3.6 or newer) and the Android or iOS toolchain for your target.

```bash
git clone https://github.com/teamsuperpanda/fox.git
cd fox
flutter pub get
flutter run
```

Run the checks before sending a change:

```bash
dart format --output=none --set-exit-if-changed lib/ test/
flutter analyze
flutter test --exclude-tags golden
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for branches, commits, localisation and the golden screenshot workflow.

---

## Tech

| Layer | Choice |
|---|---|
| UI | Flutter, Material 3, Provider |
| Storage | Hive (local key-value database, no server) |
| Editor | flutter_quill 11.x, Quill Delta JSON |
| Fonts | Inter, bundled (no network calls) |
| Platforms | Android, iOS |

Fox is a layered Flutter app: pages compose widgets, `providers/` holds theme and locale state, `services/` holds business logic and the Hive repository, and `models/` are plain data with handwritten Hive adapters. There is no `build_runner` step. Read [ARCHITECTURE.md](ARCHITECTURE.md) for the full map.

## Roadmap

Work is tracked in [GitHub milestones](https://github.com/teamsuperpanda/fox/milestones). A summary of what is planned:

| Milestone | Focus |
|---|---|
| [3.0 - Open Source Relaunch](https://github.com/teamsuperpanda/fox/milestone/1) | MIT relicence, contribution plumbing, security policy, README and docs |
| [3.1 - Data Safety](https://github.com/teamsuperpanda/fox/milestone/2) | Storage migration, backups and data safety |
| [3.2 - Capture & Platform](https://github.com/teamsuperpanda/fox/milestone/3) | Faster capture and platform integration |
| [3.3 - Editor & Organisation](https://github.com/teamsuperpanda/fox/milestone/4) | Editor features and folder, tag and pin improvements |
| [3.4 - Search & Performance](https://github.com/teamsuperpanda/fox/milestone/5) | Search quality and startup performance |
| [3.5 - UX & Polish](https://github.com/teamsuperpanda/fox/milestone/6) | Visual polish and interaction details |
| [3.6 - Accessibility & i18n](https://github.com/teamsuperpanda/fox/milestone/7) | Accessibility and translation workflow |
| [Engineering Health](https://github.com/teamsuperpanda/fox/milestone/8) | Tests, CI, dependencies and docs that match the code |

The milestone list is the source of truth. This table is a summary and may lag behind it.

## Versioning

Fox uses [Semantic Versioning](https://semver.org): `MAJOR.MINOR.PATCH`, with the store build number in `pubspec.yaml` as `version: 2.1.1+20`.

- **MAJOR** for a release that breaks the stored data format without an automatic migration, or drops a supported platform.
- **MINOR** for new features and for storage changes that ship with a migration.
- **PATCH** for fixes, dependency updates and translation updates.
- **Build number** increases by one for every store upload, including rebuilds of the same version.

The stored data format (Hive boxes and the Quill Delta JSON in notes) is stable within a major version. If a format change is unavoidable, the release ships with a migration, the old format is read for at least one minor release after deprecation, and the change is called out in the release notes.

Release notes are written per version in `release_notes.json` (localised store text) and copied into the Fastlane changelogs. The Git tag and GitHub release use the same `vMAJOR.MINOR.PATCH` string.

## Community

- Questions, ideas and show and tell: [Discussions](https://github.com/teamsuperpanda/fox/discussions)
- Bugs and feature requests: [issues](https://github.com/teamsuperpanda/fox/issues)
- How to contribute: [CONTRIBUTING.md](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## Security

Fox stores your notes on your device and sends nothing anywhere. Found a vulnerability? Report it privately, not in a public issue. See [SECURITY.md](SECURITY.md) for scope, response times and the threat model.

## License

The code is [MIT licensed](LICENSE). You can use it, modify it and ship it, including commercially.

The Fox name, logo and brand assets are proprietary and are not covered by the MIT licence. See [ASSETS-LICENSE.md](ASSETS-LICENSE.md), [NOTICE](NOTICE) and the [trademark and brand policy](TRADEMARKS.md) for what forks may and may not do.
