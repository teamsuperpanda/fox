# Releasing Fox

Releases are driven by a git tag. Pushing a tag that matches the version in
`pubspec.yaml` runs `.github/workflows/release.yml`.

## Tag format

```
vMAJOR.MINOR.PATCH
```

The build number stays in `pubspec.yaml` as `version: MAJOR.MINOR.PATCH+BUILD`.
So `version: 2.1.1+20` is released with tag `v2.1.1`. A tag like `v2.1.1+20`,
`2.1.1` or `v2.1.0` (mismatched version) fails the `Validate tag` job with a
clear message before anything is built.

## Changelogs

`release_notes.json` is the single source of store copy. It holds one entry per
locale (`{"language": "...", "text": "..."}`). The release workflow runs:

```bash
dart tool/release_notes.dart
```

which writes:

- `android/fastlane/metadata/android/<locale>/changelogs/<build>.txt` for Play
  (Fastlane's `upload_to_play_store` picks these up automatically),
- `ios/fastlane/metadata/<locale>/release_notes.txt` for the App Store and the
  TestFlight "what to test" note,
- and, with `--github-body`, the GitHub Release body from the `en-US` text.

Nothing is copied by hand. iOS metadata folders use region-qualified codes for
`ar`, `id` and `vi`; the script maps them.

## Validate locally

```bash
dart tool/release_notes.dart --tag v2.1.1
dart tool/release_notes.dart                  # regenerate store files
```

## Required secrets

Android:

| Secret | Purpose |
|---|---|
| `KEYSTORE_BASE64` | base64 of the upload keystore (`base64 -w0 upload-keystore.jks`) |
| `KEYSTORE_PASSWORD` | keystore password |
| `KEY_ALIAS` | upload key alias |
| `KEY_PASSWORD` | upload key password |
| `PLAY_SERVICE_ACCOUNT_KEY` | JSON contents of the Play service account key |

iOS:

| Secret | Purpose |
|---|---|
| `APPLE_ID` | Apple ID used by Fastlane |
| `TEAM_ID` | Apple Developer team id |
| `MATCH_GIT_URL` | git URL of the private certificates/profiles repo |
| `MATCH_PASSWORD` | `match` encryption password |
| `MATCH_KEYCHAIN_PASSWORD` | temporary keychain password on the runner |
| `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` | app-specific password for the Apple ID |

`ios/fastlane/Matchfile` points `match` at `MATCH_GIT_URL` in git storage mode
with type `appstore`.

## What the workflow does

1. `validate_tag` checks the tag against `pubspec.yaml`.
2. `android` restores the keystore, generates the store changelogs, and runs
   `bundle exec fastlane beta` in `android/` which builds the appbundle and
   uploads it to the Play internal track.
3. `ios` runs `bundle exec fastlane beta` in `ios/`, which signs with `match`,
   builds, and uploads to TestFlight with the generated changelog.
4. `github_release` builds a body from `release_notes.json` plus the merge
   commits since the previous tag and creates the GitHub Release.

Promotion from the internal track to production is still a manual Play Console
step (`fastlane release` does it from a workstation).
