# Accessibility checklist

Kept current as accessibility work lands. Last updated with the audit in #108.

## Covered by automated tests

`test/accessibility_test.dart` runs in CI and covers:

- Theme contrast: `onSurface`/`onSurfaceVariant` on the scaffold background,
  `onPrimary`/`primary`, `onError`/`error`, `error`/`surface` and
  `onTertiary`/`tertiary` meet WCAG AA (4.5:1) in light and dark, for the
  default accent. Every accent option keeps `onPrimary` readable.
- Screen reader labels: note tiles and folder tiles are announced once (no
  duplicated "Note: X, X" or hardcoded English "Folder: X" prefix), and the
  home page actions expose tooltips.
- Tap targets: the folder filter clear button and the accent colour swatches
  are at least 48x48 logical pixels.
- Text scaling: the home page renders without overflow at 200 percent text
  scale on a 360x640 viewport with a long folder name, long title and long tag.
- RTL: the home page renders in Arabic with a right-to-left `Directionality`
  and no layout exceptions.
- Reduced motion: the decorative FAB wiggle stays still when the platform asks
  for reduced animations.

## Manually checked here

- Directional widgets: Dismissible backgrounds use `AlignmentDirectional`, the
  note colour stripe uses `BorderDirectional`, and the app bar leading and
  trailing padding use `EdgeInsetsDirectional`.
- Directional icons: `chevron_right` and `arrow_back` already mirror with text
  direction in Flutter, so the editor back arrow and the language row chevron
  need no change.

## Still to do (needs a device or a designer)

- VoiceOver (iOS) and TalkBack (Android) pass on every screen and dialog.
  Automated semantics tests only assert labels, not the spoken order.
- Contrast of alpha-blended surfaces: tag chips use
  `secondaryContainer` at 50 percent opacity and alternating rows use
  `surfaceContainerHighest` at 30 percent. The blended values are not covered
  by the scheme-pair test.
- Contrast of text drawn on the eight note colours in the editor and colour
  picker.
- Keyboard and switch-access focus order, and focus trapping in dialogs.
- Arabic and Hebrew with long strings on real devices (the widget test only
  uses one short note).
- The Quill editor toolbar at 200 percent text scale on a phone.
