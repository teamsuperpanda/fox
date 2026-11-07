# Translating Fox

Fox ships 31 locales: English plus 30 translations. Translations are contributed
through pull requests against the ARB files. There is no translation platform and
no separate translator account; a pull request is the whole process.

If you only want to fix one string, do that. You do not need to translate every
key.

## How the files work

- `lib/l10n/app_en.arb` is the source of truth. Every key exists there first.
- `lib/l10n/app_<locale>.arb` holds one translation. The `@@locale` value at the
  top must match the file name: `app_pt.arb` is `pt`, `app_pt_PT.arb` is `pt_PT`.
- `flutter gen-l10n` regenerates `lib/l10n/app_localizations*.dart`. Never edit
  those generated files by hand.
- The app calls `AppLocalizations.of(context)`, so a missing key falls back to
  English at runtime instead of showing a blank string.

## Adding a key

1. Add the key to `app_en.arb`.
2. Add a `@key` entry with a description when the meaning is not obvious to
   someone who cannot see the screen. The description is the translator's only
   context:

   ```json
   "unfiled": "Unfiled",
   "@unfiled": {
     "description": "Label for a note that belongs to no folder."
   },
   ```

3. If the string has a placeholder, declare it in the `@key` entry:

   ```json
   "errorSavingNote": "Error saving note: {error}",
   "@errorSavingNote": {
     "description": "Shown when a note cannot be saved.",
     "placeholders": {
       "error": {
         "type": "String"
       }
     }
   },
   ```

4. Add the same key to the priority locales in the same pull request: Spanish
   (`es`), German (`de`), French (`fr`), Portuguese Brazil (`pt`) and Chinese
   Simplified (`zh`). If you cannot translate one, leave it out rather than
   pasting machine output without review; English fallback is better than a bad
   translation.
5. Run `flutter gen-l10n` and commit only the ARB change.

## Rules for translators

- Keep placeholders exactly as they are: `{error}`, `{count}` and so on. You may
  move them, but do not rename them.
- Preserve line breaks (`\n`) and leading or trailing punctuation that the UI
  relies on.
- Do not translate the app name, "Fox", or language names in
  `lib/data/locale_display_names.dart`; those stay in their native form.
- Use the same tone as the English string. The app is direct and short; do not
  expand a button label into a sentence.
- Plural forms follow the locale's CLDR rules. If a key needs plurals, add the
  plural metadata to `app_en.arb` first so translators can see it.
- Screenshots help. The store screenshots and the app itself are the best
  context; if a string is still unclear, ask in the pull request and do not
  guess.

## Adding a locale

1. Copy `app_en.arb` to `lib/l10n/app_<locale>.arb`.
2. Set `"@@locale"` to the locale code and translate every key.
3. Add the native language name to `lib/data/locale_display_names.dart`, for
   example `'sv': 'Svenska'`.
4. Run `flutter gen-l10n`. `AppLocalizations.supportedLocales` picks the new
   locale up from the ARB file.
5. Run the app, open view options and switch to the new language. Check the home
   page, the editor, the folder dialog and the view options sheet for clipped
   text.

6. Run `flutter analyze` and `flutter test --exclude-tags golden`.

## Checking a translation locally

- `flutter gen-l10n` must finish without warnings about missing keys or
  placeholders.
- Set the language in the app, then walk the home page, the editor, the folder
  dialog and the view options sheet. Look for clipped text on a 360 dp wide
  screen.
- RTL locales (`ar`, `he`) must be checked with the whole flow, not one screen.

## Status

All 30 translations currently have 59 of the 66 keys (89 percent). The seven keys
missing from translations are `addNote`, `folderAlreadyExists`, `folderFilter`,
`note`, `searchLanguages`, `searchNotes` and `startupFailed`. Untranslated keys
fall back to English.

Priority locales: English, Spanish, German, French, Portuguese (Brazil) and
Chinese (Simplified). Maintainers review this list at each major release.

To see per-file counts:

```bash
grep -cE '^  "[^@"].*":' lib/l10n/app_*.arb
```
