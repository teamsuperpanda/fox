// Checks the localisation files:
//   * every ARB has the same key set as app_en.arb,
//   * every key is used somewhere in lib/,
//   * every supported locale has an entry in lib/data/locale_display_names.dart.
//
// Run with `dart run tool/check_l10n.dart`. Exits non-zero on a problem.
// Keys whose value still equals the English string are reported as fallbacks
// (warnings only) so untranslated strings can be found.
import 'dart:convert';
import 'dart:io';

const _englishArb = 'app_en.arb';
const _l10nDir = 'lib/l10n';
const _displayNamesFile = 'lib/data/locale_display_names.dart';

/// Locale tag for an ARB file name: `app_es_419.arb` -> `es_419`.
String? _localeTag(String fileName) {
  final match = RegExp(r'^app_([A-Za-z0-9_]+)\.arb$').firstMatch(fileName);
  return match?.group(1);
}

Map<String, String> _messages(String path) {
  final json = jsonDecode(File(path).readAsStringSync());
  if (json is! Map<String, dynamic>) return const {};
  return {
    for (final entry in json.entries)
      if (!entry.key.startsWith('@') && entry.value is String)
        entry.key: entry.value as String,
  };
}

/// Problems that should fail the build.
List<String> l10nProblems({String root = '.'}) {
  final l10nDir = Directory('$root/$_l10nDir');
  if (!l10nDir.existsSync()) return ['missing $_l10nDir'];

  final arbs = l10nDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final english = _messages('$root/$_l10nDir/$_englishArb');
  final problems = <String>[];

  for (final file in arbs) {
    final name = file.uri.pathSegments.last;
    if (name == _englishArb) continue;
    final messages = _messages(file.path);
    final missing = english.keys.toSet().difference(messages.keys.toSet());
    final extra = messages.keys.toSet().difference(english.keys.toSet());
    if (missing.isNotEmpty) {
      problems.add('$name is missing: ${missing.toList()..sort()}');
    }
    if (extra.isNotEmpty) {
      problems
          .add('$name has keys not in $_englishArb: ${extra.toList()..sort()}');
    }
  }

  // Unused keys: any message key never referenced as `.key` in lib/.
  final libSources = Directory('$root/lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.contains('/$_l10nDir/'))
      .map((f) => f.readAsStringSync())
      .join('\n');
  for (final key in english.keys.toList()..sort()) {
    if (!RegExp('\\.$key\\b').hasMatch(libSources)) {
      problems.add('key "$key" is defined but never used in lib/');
    }
  }

  // Display names: one per supported locale, and no stale entries.
  final displaySource = File('$root/$_displayNamesFile').readAsStringSync();
  final displayTags = RegExp("'([A-Za-z0-9_]+)':")
      .allMatches(displaySource)
      .map((m) => m.group(1)!)
      .toSet();
  final localeTags = {
    for (final file in arbs)
      if (_localeTag(file.uri.pathSegments.last) case final tag?) tag,
  };
  for (final tag in localeTags.toList()..sort()) {
    if (!displayTags.contains(tag)) {
      problems.add('locale "$tag" has no display name in $_displayNamesFile');
    }
  }
  for (final tag in displayTags.toList()..sort()) {
    if (!localeTags.contains(tag)) {
      problems.add('display name "$tag" has no ARB file');
    }
  }

  return problems;
}

/// Keys still carrying the English string in each locale.
Map<String, List<String>> untranslatedKeys({String root = '.'}) {
  final english = _messages('$root/$_l10nDir/$_englishArb');
  final result = <String, List<String>>{};
  final dir = Directory('$root/$_l10nDir');
  for (final file in dir.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    final tag = _localeTag(name);
    if (tag == null || name == _englishArb) continue;
    final messages = _messages(file.path);
    final untranslated = [
      for (final entry in messages.entries)
        if (english[entry.key] == entry.value) entry.key,
    ];
    result[tag] = untranslated;
  }
  return result;
}

void main() {
  final problems = l10nProblems();
  if (problems.isNotEmpty) {
    stderr.writeln('Localisation check failed:');
    for (final problem in problems) {
      stderr.writeln('  - $problem');
    }
    exitCode = 1;
    return;
  }

  final untranslated = untranslatedKeys();
  final fallbacks = untranslated.values.fold<int>(0, (a, b) => a + b.length);
  stdout.writeln('l10n OK: all ARB key sets match $_englishArb, every key is '
      'used, and every locale has a display name.');
  if (fallbacks > 0) {
    stdout
        .writeln('$fallbacks untranslated values still use the English text:');
    for (final entry in untranslated.entries) {
      if (entry.value.isNotEmpty) {
        stdout.writeln('  ${entry.key}: ${entry.value.join(', ')}');
      }
    }
  }
}
