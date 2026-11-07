import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/export/export_codec.dart';

import 'test_helpers.dart';

void main() {
  group('FoxExportArchive', () {
    final updatedAt = DateTime.utc(2026, 3, 4, 5, 6, 7);
    final createdAt = DateTime.utc(2026, 1, 2, 3, 4, 5);

    FoxExportArchive buildArchive() => FoxExportArchive(
          exportedAt: DateTime.utc(2026, 11, 7, 8, 9, 10),
          appVersion: '2.1.1+20',
          notes: [
            makeNote(
              id: 'note-1',
              title: 'Groceries',
              content: r'[{"insert":"milk\n"}]',
              pinned: true,
              updatedAt: updatedAt,
              tags: ['home', 'food'],
              folderId: 'folder-1',
              color: '#FF5252',
            ),
          ],
          folders: [
            Folder(id: 'folder-1', name: 'Home', createdAt: createdAt),
          ],
          settings: Settings(
            themeMode: 'dark',
            locale: 'pt_BR',
            showTags: false,
            showContent: false,
            alternatingColors: true,
            fabAnimation: false,
            sortBy: 'titleAsc',
            accentColor: '#8B9A6B',
          ),
        );

    test('round-trips every persisted note field', () {
      final archive = buildArchive();
      final decoded = FoxExportArchive.decode(archive.encode());

      expect(decoded.schemaVersion, FoxExportArchive.currentSchemaVersion);
      expect(decoded.appVersion, '2.1.1+20');
      expect(decoded.exportedAt, DateTime.utc(2026, 11, 7, 8, 9, 10));
      expect(decoded.notes, hasLength(1));

      final note = decoded.notes.single;
      expect(note.id, 'note-1');
      expect(note.title, 'Groceries');
      expect(note.content, r'[{"insert":"milk\n"}]');
      expect(note.pinned, isTrue);
      expect(note.updatedAt, updatedAt);
      expect(note.tags, ['home', 'food']);
      expect(note.folderId, 'folder-1');
      expect(note.color, '#FF5252');
    });

    test('round-trips folders and settings', () {
      final decoded = FoxExportArchive.decode(buildArchive().encode());

      expect(decoded.folders.single.id, 'folder-1');
      expect(decoded.folders.single.name, 'Home');
      expect(decoded.folders.single.createdAt, createdAt);

      final settings = decoded.settings;
      expect(settings.themeMode, 'dark');
      expect(settings.locale, 'pt_BR');
      expect(settings.showTags, isFalse);
      expect(settings.showContent, isFalse);
      expect(settings.alternatingColors, isTrue);
      expect(settings.fabAnimation, isFalse);
      expect(settings.sortBy, 'titleAsc');
      expect(settings.accentColor, '#8B9A6B');
    });

    test('writes a manifest with note and folder counts', () {
      final json = jsonDecode(buildArchive().encode()) as Map<String, dynamic>;
      final manifest = json['manifest'] as Map<String, dynamic>;

      expect(manifest['notes'], 1);
      expect(manifest['folders'], 1);
      expect(json['format'], FoxExportArchive.formatId);
      expect(json['schemaVersion'], FoxExportArchive.currentSchemaVersion);
    });

    test('rejects a newer schema version with a readable message', () {
      final json = jsonDecode(buildArchive().encode()) as Map<String, dynamic>;
      json['schemaVersion'] = FoxExportArchive.currentSchemaVersion + 1;

      expect(
        () => FoxExportArchive.decode(jsonEncode(json)),
        throwsA(
          isA<ExportFormatException>().having(
            (e) => e.message,
            'message',
            contains('Update Fox'),
          ),
        ),
      );
    });

    test('rejects files that are not a Fox backup', () {
      expect(
        () => FoxExportArchive.decode('{"notes": []}'),
        throwsA(isA<ExportFormatException>()),
      );
      expect(
        () => FoxExportArchive.decode('not json at all'),
        throwsA(isA<ExportFormatException>()),
      );
      expect(
        () => FoxExportArchive.decode('[]'),
        throwsA(isA<ExportFormatException>()),
      );
    });

    test('rejects a truncated archive whose manifest disagrees', () {
      final json = jsonDecode(buildArchive().encode()) as Map<String, dynamic>;
      (json['notes'] as List<dynamic>).clear();

      expect(
        () => FoxExportArchive.decode(jsonEncode(json)),
        throwsA(
          isA<ExportFormatException>().having(
            (e) => e.message,
            'message',
            contains('incomplete'),
          ),
        ),
      );
    });

    test('rejects a note without an id', () {
      final json = jsonDecode(buildArchive().encode()) as Map<String, dynamic>;
      (json['notes'] as List<dynamic>).clear();
      json['notes'] = [
        {'title': 'no id'},
      ];
      (json['manifest'] as Map<String, dynamic>)['notes'] = 1;

      expect(
        () => FoxExportArchive.decode(jsonEncode(json)),
        throwsA(isA<ExportFormatException>()),
      );
    });

    test('rejects a malformed timestamp', () {
      final json = jsonDecode(buildArchive().encode()) as Map<String, dynamic>;
      final note =
          (json['notes'] as List<dynamic>).single as Map<String, dynamic>;
      note['updatedAt'] = 'yesterday';

      expect(
        () => FoxExportArchive.decode(jsonEncode(json)),
        throwsA(isA<ExportFormatException>()),
      );
    });

    test('handles an empty library', () {
      final archive = FoxExportArchive(
        exportedAt: DateTime.utc(2026),
        appVersion: 'test',
        notes: const [],
        folders: const [],
        settings: Settings(themeMode: 'system'),
      );
      final decoded = FoxExportArchive.decode(archive.encode());

      expect(decoded.notes, isEmpty);
      expect(decoded.folders, isEmpty);
      expect(decoded.settings.themeMode, 'system');
    });
  });
}
