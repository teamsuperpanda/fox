# Dependency and Upgrade Policy

Fox is small enough that dependencies are a real risk: the editor package alone
has shipped breaking configuration changes in 8.x and 11.x. This policy keeps
upgrades boring.

## Pinning

- Direct dependencies use caret ranges in `pubspec.yaml`, for example
  `flutter_quill: ^11.6.0`.
- `pubspec.lock` is committed. CI and release builds resolve from it, so an
  upgrade is always an explicit, reviewable change.
- Transitive dependencies are not pinned by hand. They move with the direct
  dependency that owns them.
- Add a dependency only when the platform or an existing package cannot do the
  job. A new dependency needs a reason in the pull request.

## The monthly dependency pass

Once a month, a maintainer clears the Dependabot queue.

| Update type | Rule |
|---|---|
| Patch and minor | Auto-merge after green CI, one grouped pull request per ecosystem |
| Major | Manual, using the checklist below |
| Security advisory | Fast track, before the monthly pass |

A grouped pull request still gets a read of the changelog and a local test run.
Green CI is necessary, not sufficient.

## Major upgrade checklist

1. Read the package changelog and migration notes for every major version
   skipped. Follow the upstream documentation, not memory.
2. Bump the constraint in `pubspec.yaml`, run `flutter pub get`, and commit the
   lockfile change on its own.
3. Run the full gate: `dart format --output=none --set-exit-if-changed lib test`,
   `flutter analyze`, `flutter test --exclude-tags golden`.
4. Exercise the affected feature by hand on Android or iOS. For editor changes,
   type formatted text, save, reopen, and check an existing note.
5. Record the new version in `ARCHITECTURE.md` and in the release notes.
6. If the upgrade needs code changes, keep the upgrade and the migration in one
   pull request so they can be reverted together.

## flutter_quill upgrade runbook

The editor is the highest-risk dependency. Use this runbook for every major
upgrade, and for minor upgrades that touch configuration.

1. **Read the migration guide.** Check the flutter_quill changelog and the
   migration notes for the target version. List every breaking change that
   touches `QuillEditor`, `QuillController`, `QuillSimpleToolbar` or their
   configuration classes.
2. **Bump and resolve.** Update `pubspec.yaml`, run `flutter pub get`, and check
   that no other package pins a conflicting Quill version.
3. **Compile.** Run `flutter analyze`. Toolbar configuration classes are renamed
   often; fix the compile errors before running tests.
4. **Test the data path.** Run `flutter test --exclude-tags golden`. The note
   tests cover Delta read and write, the repository round-trip and the detail
   page. Confirm a note written before the upgrade still opens and keeps its
   formatting.
5. **Exercise the editor by hand.** On a device or emulator, create a note with
   bold, italic, a bullet list, an ordered list and a note colour, then save,
   reopen and edit it. Check cursor position after save, paste, undo and the
   keyboard on both platforms.
6. **Check the toolbar.** Every button still works, no control is missing, and
   the toolbar fits a 360 dp wide screen.
7. **Update the record.** Set the new version in `ARCHITECTURE.md` (section 3.3)
   and add the version to the release notes for the next release.
8. **Keep the fallback.** If the upgrade cannot be finished, revert the bump and
   the migration together. Do not leave the app on a half-migrated editor.

## Release checklist: dependency debt

Add this to every release:

- [ ] Dependabot queue is clear, or every open pull request has a reason to wait.
- [ ] No dependency is more than one major version behind its latest release.
- [ ] Flutter and flutter_quill versions are recorded below and in the release notes.
- [ ] `flutter pub outdated` was reviewed, and the remaining "newer versions
      incompatible with constraints" entries are understood.
- [ ] No security advisory applies to a direct dependency.

## Version record

Update this table on every release. It records what the build actually used.

| Release | Flutter | Dart | flutter_quill | Notes |
|---|---|---|---|---|
| Unreleased (3.0) | 3.47.6 | 3.13.5 | 11.6.x | Development toolchain |
