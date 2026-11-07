import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/export/export_codec.dart';
import 'package:fox/services/export/export_service.dart';
import 'package:fox/services/export/markdown_codec.dart';

import 'test_helpers.dart';

void main() {
  late Directory tempDir;
  late FoxExporter exporter;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fox_export_test');
    exporter = FoxExporter(clock: () => DateTime(2026, 11, 7, 9, 30));
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  Archive decodeArchive(ExportResult result) =>
      ZipDecoder().decodeBytes(result.bytes);

  test('writes the zip with JSON, Markdown and README', () async {
    final notes = [
      makeNote(
        id: 'note-1',
        title: 'Groceries',
        content: r'[{"insert":"milk and eggs\n"}]',
        tags: ['home'],
        folderId: 'folder-1',
        color: '#FF5252',
        updatedAt: DateTime.utc(2026, 3, 4),
      ),
      makeNote(id: 'note-2', title: 'Ideas', content: '[]'),
    ];
    final folders = [
      Folder(
        id: 'folder-1',
        name: 'Home',
        createdAt: DateTime.utc(2026),
      ),
    ];

    final result = await exporter.export(
      notes: notes,
      folders: folders,
      settings: Settings(themeMode: 'dark'),
      outputDirectory: tempDir,
    );

    expect(result.noteCount, 2);
    expect(result.folderCount, 1);
    expect(
      result.archive.path,
      endsWith('fox-export-20261107-0930.zip'),
    );
    expect(result.archive.existsSync(), isTrue);

    final archive = decodeArchive(result);
    expect(archive.findFile(FoxExportArchive.jsonFileName), isNotNull);
    expect(archive.findFile('README.txt'), isNotNull);
    expect(archive.findFile('markdown/Home/Groceries.md'), isNotNull);
    expect(archive.findFile('markdown/Unfiled/Ideas.md'), isNotNull);

    final envelope = FoxExportArchive.decode(
      utf8.decode(
        archive.findFile(FoxExportArchive.jsonFileName)!.content,
      ),
    );
    expect(envelope.notes, hasLength(2));
    expect(envelope.folders, hasLength(1));
    expect(envelope.settings.themeMode, 'dark');

    final markdown = utf8.decode(
      archive.findFile('markdown/Home/Groceries.md')!.content,
    );
    expect(markdown, startsWith('---\n'));
    expect(markdown, contains('id: "note-1"'));
    expect(markdown, contains('title: "Groceries"'));
    expect(markdown, contains('tags: ["home"]'));
    expect(markdown, contains('color: "#FF5252"'));
    expect(markdown, contains('folder: "Home"'));
    expect(markdown, contains('milk and eggs'));

    final readme = utf8.decode(archive.findFile('README.txt')!.content);
    expect(readme, contains('fox-backup.json'));
    expect(readme, contains('schemaVersion'));
  });

  test('does not mutate the notes it exports', () async {
    final notes = [
      makeNote(id: 'note-1', title: 'Groceries', tags: ['home']),
    ];
    final before = jsonEncode(notes.single.toMap());

    await exporter.export(
      notes: notes,
      folders: const [],
      settings: Settings(themeMode: 'system'),
      outputDirectory: tempDir,
    );

    expect(jsonEncode(notes.single.toMap()), before);
    expect(notes, hasLength(1));
  });

  test('reports progress while writing', () async {
    final updates = <ExportProgress>[];
    final notes = [
      for (var i = 0; i < 40; i++) makeNote(id: 'n$i', title: 'Note $i'),
    ];

    await exporter.export(
      notes: notes,
      folders: const [],
      settings: Settings(themeMode: 'system'),
      outputDirectory: tempDir,
      onProgress: updates.add,
    );

    expect(updates, isNotEmpty);
    expect(updates.last.stage, 'done');
    expect(updates.last.completed, 40);
    expect(updates.any((u) => u.stage == 'zip'), isTrue);
  });

  test('gives duplicate titles distinct file names', () async {
    final result = await exporter.export(
      notes: [
        makeNote(id: 'a', title: 'Same'),
        makeNote(id: 'b', title: 'Same'),
      ],
      folders: const [],
      settings: Settings(themeMode: 'system'),
      outputDirectory: tempDir,
    );

    final archive = decodeArchive(result);
    expect(archive.findFile('markdown/Unfiled/Same.md'), isNotNull);
    expect(archive.findFile('markdown/Unfiled/Same (2).md'), isNotNull);
  });

  test('exports 500 notes in under five seconds', () async {
    final notes = [
      for (var i = 0; i < 500; i++)
        makeNote(
          id: 'note-$i',
          title: 'Note number $i',
          content: r'[{"insert":"Body of note $i with some words\n"}]',
          tags: ['tag${i % 10}'],
          updatedAt: DateTime.utc(2026).add(Duration(minutes: i)),
        ),
    ];

    final stopwatch = Stopwatch()..start();
    final result = await exporter.export(
      notes: notes,
      folders: const [],
      settings: Settings(themeMode: 'system'),
      outputDirectory: tempDir,
    );
    stopwatch.stop();

    expect(result.noteCount, 500);
    expect(
      stopwatch.elapsed,
      lessThan(const Duration(seconds: 5)),
      reason: 'export of 500 notes must stay under the 5s budget',
    );
    expect(decodeArchive(result).files.length, 502);
  });

  group('MarkdownCodec', () {
    test('renders headings, lists and inline styles', () {
      final note = makeNote(
        id: 'n',
        title: '',
        content: jsonEncode([
          {
            'insert': 'Title',
            'attributes': {'header': 2},
          },
          {'insert': '\n'},
          {
            'insert': 'bold',
            'attributes': {'bold': true},
          },
          {'insert': '\n'},
          {
            'insert': 'one',
            'attributes': {'list': 'bullet'},
          },
          {'insert': '\n'},
        ]),
      );

      final markdown = MarkdownCodec.deltaToMarkdown(note);
      expect(markdown, '## Title\n**bold**\n- one');
    });

    test('converts plain text to Delta content', () {
      final content = MarkdownCodec.plainTextToContent('first\nsecond');
      expect(jsonDecode(content), [
        {'insert': 'first'},
        {'insert': '\n'},
        {'insert': 'second'},
      ]);
    });

    test('sanitises file names', () {
      expect(MarkdownCodec.safeFileName('a/b:c*?'), 'a-b-c--');
      expect(MarkdownCodec.safeFileName('   '), 'Untitled');
      expect(MarkdownCodec.safeFileName('.hidden'), 'hidden');
      expect(MarkdownCodec.safeFileName('x' * 200).length, 80);
    });
  });
}
