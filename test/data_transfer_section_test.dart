import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';
import 'package:fox/services/export/export_service.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/widgets/data_transfer_section.dart';

import 'test_helpers.dart';

class _StubExporter extends FoxExporter {
  _StubExporter(this.onExport);

  final Future<ExportResult> Function() onExport;

  @override
  Future<ExportResult> export({
    required List<Note> notes,
    required List<Folder> folders,
    required Settings settings,
    required Directory outputDirectory,
    ValueChanged<ExportProgress>? onProgress,
  }) {
    return onExport();
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fox_transfer_test');
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  testWidgets('exports and shares through injected dependencies', (
    tester,
  ) async {
    final controller = NotesController(MemoryRepo());
    await controller.load();
    await controller.addOrUpdate(
      title: 'One',
      content: Document()..insert(0, 'hello'),
    );

    File? shared;
    final file = File('${tempDir.path}/fox-export.zip')
      ..writeAsBytesSync(<int>[]);
    final exporter = _StubExporter(
      () async => ExportResult(
        archive: file,
        noteCount: 1,
        folderCount: 0,
        bytes: Uint8List(0),
      ),
    );

    await tester.pumpWidget(
      buildTestApp(
        Scaffold(
          body: SingleChildScrollView(
            child: DataTransferSection(
              controller: controller,
              settingsService: SettingsService(),
              exporter: exporter,
              outputDirectoryProvider: () async => tempDir,
              shareFile: (f) async => shared = f,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Export all notes'));
    await tester.pumpAndSettle();

    expect(shared?.path, file.path);
    expect(find.text('Exported 1 notes'), findsOneWidget);
  });

  testWidgets('surfaces export failures in a dialog', (tester) async {
    final controller = NotesController(MemoryRepo());
    await controller.load();

    final exporter = _StubExporter(
      () async => throw const ExportException('disk full'),
    );

    await tester.pumpWidget(
      buildTestApp(
        Scaffold(
          body: SingleChildScrollView(
            child: DataTransferSection(
              controller: controller,
              settingsService: SettingsService(),
              exporter: exporter,
              outputDirectoryProvider: () async => tempDir,
              shareFile: (_) async {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Export all notes'));
    await tester.pumpAndSettle();

    expect(find.textContaining('disk full'), findsOneWidget);
  });
}
