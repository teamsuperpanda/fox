# Security Policy

Fox is a local-first notes app. Your notes stay on your device and the app makes
no network requests, so the security surface is small. It is not zero, and
reports are welcome.

## Supported versions

| Version | Supported |
|---|---|
| 2.x | Yes |
| 1.x | No |

Security fixes ship on the latest 2.x release. Older 2.x releases do not get
backports unless the issue is critical.

## Reporting a vulnerability

**Do not open a public issue.** Public reports expose users before a fix exists.

Report privately with GitHub private vulnerability reporting:

1. Go to https://github.com/teamsuperpanda/fox/security/advisories/new
2. Or open the repository's **Security** tab and choose **Report a vulnerability**.

If you cannot use GitHub reporting, open a minimal public issue that asks for a
private channel, without disclosing the vulnerability itself.

Include:

- Fox version and platform (Android, iOS, or web build)
- Device and OS version
- Steps to reproduce, with a proof of concept if you have one
- The impact you believe it has

## What to expect

| Stage | Target |
|---|---|
| Acknowledgement of your report | within 72 hours |
| Initial triage and severity assessment | within 7 days |
| Fix or mitigation plan | within 30 days for high and critical issues |

We will keep you updated in the private advisory, credit you in the release notes
unless you ask otherwise, and coordinate disclosure with you. Please give us a
reasonable window to ship a fix before publishing details.

## Scope

In scope:

- The Flutter app on Android, iOS and web
- Local storage and the Hive database format
- Data import and export formats
- The release pipeline and published build artifacts

Out of scope:

- Issues that require a rooted or jailbroken device, unless the app itself can be
  escaped without one
- Physical access attacks against an unlocked device
- Vulnerabilities in third-party packages, unless Fox uses them in an unsafe way
  (report those upstream as well)
- Social engineering and denial of service against the user's own device

## Threat model

Fox is designed for privacy, not for defending against a determined attacker with
control of your device.

What Fox does:

- Stores all notes locally in Hive boxes under the app's private data directory
- Sends no analytics, telemetry or crash reports
- Makes no network requests at runtime
- Keeps optional language and theme preferences on device

What Fox does **not** do:

- Encrypt data at rest. Notes are stored as plain Hive files. Anyone who can read
  the app's data directory (a rooted or jailbroken device, a device backup, or
  malware with the right permissions) can read the notes.
- Protect against a compromised OS, a malicious keyboard, or screen capture
- Hide metadata such as note counts and timestamps from someone with file access
- Provide a sync or account layer, so there is no server-side data to breach
- Prevent a user from exporting their notes in clear text

If you need encryption at rest, use full-disk encryption on the device.

## Safe harbour

We will not pursue legal action against researchers who report in good faith,
follow this policy, and avoid privacy violations, data destruction, and service
disruption.
