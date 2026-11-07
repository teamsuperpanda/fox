# Privacy manifest and store declarations

Fox stores everything on the device and makes no network requests. The iOS
privacy manifest (`ios/Runner/PrivacyInfo.xcprivacy`) declares only the
required-reason APIs the app and its plugins actually reach:

| API category | Reason | Used for |
|---|---|---|
| `NSPrivacyAccessedAPICategoryFileTimestamp` | `C617.1` | Hive and `path_provider` read file timestamps when opening the database |
| `NSPrivacyAccessedAPICategoryUserDefaults` | `CA92.1` | Flutter and platform plugins store small preference values |
| `NSPrivacyAccessedAPICategoryDiskSpace` | `E174.1` | checking free space before writing Hive boxes |

`NSPrivacyTracking` is `false`, `NSPrivacyTrackingDomains` is empty and
`NSPrivacyCollectedDataTypes` is empty: nothing is collected.

The manifest is listed in the Runner target's Copy Bundle Resources phase in
`ios/Runner.xcodeproj/project.pbxproj`, so it ships inside `Runner.app`.

`ITSAppUsesNonExemptEncryption` in `ios/Runner/Info.plist` is `false` and stays
accurate: the app uses only OS-provided encryption for files at rest, no custom
cryptography and no network transport.

## Android

The Android equivalent is the Play Console Data safety form. Fox has no
accounts, no analytics and no network access, so every data type is "not
collected" and data is "not shared". Android already disables backups
(`android:allowBackup="false"`).

## Release checklist

- [ ] Re-check the manifest whenever a dependency is added or bumped
      (`find ios -name '*.xcprivacy'` lists every bundled manifest).
- [ ] Confirm any new plugin's required-reason APIs are listed in
      `ios/Runner/PrivacyInfo.xcprivacy` with the correct reason code.
- [ ] Confirm `ITSAppUsesNonExemptEncryption` is still `false`.
- [ ] Re-check the Play Data safety form against the current dependency list.
- [ ] Confirm the manifest is still in the Runner Copy Bundle Resources phase.
