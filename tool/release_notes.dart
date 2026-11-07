import 'dart:convert';
import 'dart:io';

/// Generates store changelogs from `release_notes.json` and validates release
/// tags.
///
///   dart run tool/release_notes.dart                          # write store files
///   dart run tool/release_notes.dart --tag v2.1.1             # validate a tag
///   dart run tool/release_notes.dart --github-body body.md --prs prs.md
///
/// Play changelogs are written to
/// `android/fastlane/metadata/android/<locale>/changelogs/<build>.txt` and iOS
/// notes to `ios/fastlane/metadata/<locale>/release_notes.txt`. The language
/// codes come from `release_notes.json`; the build number comes from
/// `pubspec.yaml`.
Future<void> main(List<String> args) async {
  final root = _arg(args, '--root') ?? '.';
  final pubspecPath = _arg(args, '--pubspec') ?? '$root/pubspec.yaml';
  final notesPath = _arg(args, '--notes') ?? '$root/release_notes.json';
  final version = parsePubspecVersion(File(pubspecPath).readAsStringSync());
  final notes = loadReleaseNotes(File(notesPath).readAsStringSync());

  final tag = _arg(args, '--tag');
  if (tag != null) {
    validateTag(tag, version);
    stdout.writeln('Tag $tag matches pubspec version ${version.version}.');
    return;
  }

  var written = 0;
  for (final entry in notes.entries) {
    final androidFile = File(
      '$root/android/fastlane/metadata/android/${entry.key}/changelogs/'
      '${version.build}.txt',
    )..createSync(recursive: true);
    androidFile.writeAsStringSync('${entry.value}\n');
    written++;

    final iosFile = File(
      '$root/ios/fastlane/metadata/${iosLocaleFor(entry.key)}/'
      'release_notes.txt',
    )..createSync(recursive: true);
    iosFile.writeAsStringSync('${entry.value}\n');
    written++;
  }
  stdout.writeln(
    'Wrote $written changelog files for ${version.version}+${version.build} '
    '(${notes.length} locales).',
  );

  final githubBody = _arg(args, '--github-body');
  if (githubBody != null) {
    final buffer = StringBuffer()
      ..writeln(notes['en-US'] ?? notes.values.first)
      ..writeln();
    final prs = _arg(args, '--prs');
    if (prs != null && File(prs).existsSync()) {
      final list = File(prs).readAsStringSync().trim();
      if (list.isNotEmpty) {
        buffer
          ..writeln('## Merged PRs')
          ..writeln()
          ..writeln(list)
          ..writeln();
      }
    }
    File(githubBody).writeAsStringSync(buffer.toString());
    stdout.writeln('GitHub release body written to $githubBody.');
  }
}

/// Parses `version: 2.1.1+20` from pubspec.yaml.
({String version, int build}) parsePubspecVersion(String pubspec) {
  final match = RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
          multiLine: true)
      .firstMatch(pubspec);
  if (match == null) {
    throw const FormatException(
      'pubspec.yaml must set version: MAJOR.MINOR.PATCH+BUILD',
    );
  }
  return (version: match.group(1)!, build: int.parse(match.group(2)!));
}

/// Rejects anything that is not `vMAJOR.MINOR.PATCH` matching pubspec.
void validateTag(String tag, ({String version, int build}) pubspecVersion) {
  final match = RegExp(r'^v([0-9]+\.[0-9]+\.[0-9]+)$').firstMatch(tag);
  if (match == null) {
    throw FormatException(
      'Tag "$tag" is invalid. Use vMAJOR.MINOR.PATCH, for example '
      'v${pubspecVersion.version}. The build number lives in pubspec.yaml.',
    );
  }
  if (match.group(1) != pubspecVersion.version) {
    throw FormatException(
      'Tag "$tag" does not match pubspec version ${pubspecVersion.version}. '
      'Bump pubspec.yaml or retag.',
    );
  }
}

/// Loads `[{"language": "...", "text": "..."}]` into a locale map.
Map<String, String> loadReleaseNotes(String json) {
  final decoded = jsonDecode(json) as List<dynamic>;
  final notes = <String, String>{};
  for (final entry in decoded.cast<Map<String, dynamic>>()) {
    final language = entry['language'] as String;
    final text = entry['text'] as String;
    if (text.length > 500) {
      throw FormatException(
        'release note for $language is ${text.length} characters; '
        'Play allows 500.',
      );
    }
    notes[language] = text;
  }
  return notes;
}

/// iOS metadata uses a few region-qualified locale codes.
String iosLocaleFor(String language) {
  const aliases = {'ar': 'ar-SA', 'id': 'id-ID', 'vi': 'vi-VN'};
  return aliases[language] ?? language;
}

String? _arg(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index == args.length - 1) return null;
  return args[index + 1];
}
