# Security and data safety

Fox is local-only: no accounts, no servers, no telemetry, no network requests.

## Device backups

The public claim is that note data never leaves the device. That is only true
if the operating system backup excludes it.

**iOS:** at launch, before Flutter starts and therefore before Hive opens a
box, `AppDelegate.application(_:didFinishLaunchingWithOptions:)` sets
`NSURLIsExcludedFromBackupKey` on the app's Documents directory (where
`hive_flutter` keeps its boxes) and on Application Support. Neither is included
in iCloud or iTunes device backups.

Trade-off: there is no iCloud backup path for notes. Exporting notes is the only
backup route until an export feature ships.

**Android:** `android:allowBackup="false"` in `android/app/src/main/AndroidManifest.xml`,
so the Hive database is not part of Auto Backup. This was already correct.

## Copy

README, store listings and the privacy policy must say that Fox stores data on
the device and that device backups exclude it. If the backup exclusion is ever
removed, the copy must change to "no Fox servers" rather than "never leaves
your device".

## Release checklist

- [ ] On a device, create a note, run an encrypted local backup, and confirm the
      app's container is absent (or `xattr -l` on the container shows the
      excluded-from-backup flag in a debug build).
- [ ] Confirm `android:allowBackup="false"` is still in the manifest.
- [ ] Confirm README and store copy still match the code.
- [ ] Re-read the iOS privacy manifest checklist in `docs/PRIVACY.md`.
