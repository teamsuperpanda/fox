import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/repository_hive.dart';

/// In-memory repository with O(1) bulk insert, so the benchmark measures the
/// controller rather than the test double.
class _BulkRepo implements NoteAndFolderRepository {
  final Map<String, Note> notes = {};
  final Map<String, Folder> folders = {};

  @override
  Future<void> init() async {}

  @override
  Future<List<Note>> getAll() async => notes.values.toList();

  @override
  Future<void> upsert(Note note) async {
    notes[note.id] = note;
  }

  @override
  Future<void> upsertAll(List<Note> batch) async {
    for (final note in batch) {
      notes[note.id] = note;
    }
  }

  @override
  Future<void> delete(String id) async {
    notes.remove(id);
  }

  @override
  Future<List<Folder>> getAllFolders() async => folders.values.toList();

  @override
  Future<void> upsertFolder(Folder folder) async {
    folders[folder.id] = folder;
  }

  @override
  Future<void> deleteFolder(String id) async {
    folders.remove(id);
  }

  int get unreadableRecords => 0;
}

const int noteCount = 5000;

/// Budgets are documented in ARCHITECTURE.md section 9.
const Duration loadBudget = Duration(seconds: 2);
const Duration warmSearchBudget = Duration(milliseconds: 100);
const Duration firstSearchBudget = Duration(milliseconds: 1500);
const Duration sortBudget = Duration(milliseconds: 100);
const Duration pinBudget = Duration(milliseconds: 50);

List<Note> buildLibrary() {
  final base = DateTime.utc(2026);
  return [
    for (var i = 0; i < noteCount; i++)
      Note(
        id: 'note-$i',
        title: 'Note number $i',
        content: jsonEncode([
          {
            'insert':
                'Body of note $i with a sentence that is long enough to make '
                    'plain text extraction realistic, repeated once.\n',
          },
        ]),
        pinned: i % 50 == 0,
        updatedAt: base.add(Duration(minutes: i)),
        tags: ['tag${i % 20}'],
        folderId: i % 10 == 0 ? 'folder-${i % 5}' : null,
      ),
  ];
}

void main() {
  test('$noteCount notes load, search, sort and pin within budget', () async {
    final repo = _BulkRepo();
    for (final folder in List.generate(5, (i) => 'folder-$i')) {
      repo.folders[folder] = Folder(
        id: folder,
        name: 'Folder $folder',
        createdAt: DateTime.utc(2026),
      );
    }
    repo.notes.addEntries(buildLibrary().map((n) => MapEntry(n.id, n)));

    final controller = NotesController(repo);

    final load = Stopwatch()..start();
    await controller.load();
    load.stop();

    debugPrint('bench load: ${load.elapsed.inMilliseconds}ms');
    expect(controller.notes, hasLength(noteCount));
    expect(
      load.elapsed,
      lessThan(loadBudget),
      reason: 'cold load of $noteCount notes took ${load.elapsed}',
    );

    final firstSearch = Stopwatch()..start();
    controller.setSearchTerm('note number 4999');
    firstSearch.stop();
    debugPrint('bench first search: ${firstSearch.elapsed.inMilliseconds}ms');
    expect(controller.notes.single.title, 'Note number 4999');
    expect(
      firstSearch.elapsed,
      lessThan(firstSearchBudget),
      reason: 'first (cold cache) search took ${firstSearch.elapsed}',
    );

    final warmSearches = <Duration>[];
    for (var i = 0; i < 10; i++) {
      final stopwatch = Stopwatch()..start();
      controller.setSearchTerm(i.isEven ? 'note number 12' : 'note number 499');
      stopwatch.stop();
      warmSearches.add(stopwatch.elapsed);
    }
    final worstWarm = warmSearches.reduce((a, b) => a > b ? a : b);
    debugPrint('bench worst warm search: ${worstWarm.inMilliseconds}ms');
    expect(
      worstWarm,
      lessThan(warmSearchBudget),
      reason: 'warm search took $worstWarm',
    );

    controller.setSearchTerm('');

    final sort = Stopwatch()..start();
    controller.setSortBy(SortBy.titleAsc);
    sort.stop();
    debugPrint('bench sort: ${sort.elapsed.inMilliseconds}ms');
    expect(
      sort.elapsed,
      lessThan(sortBudget),
      reason: 'sorting $noteCount notes took ${sort.elapsed}',
    );

    final pin = Stopwatch()..start();
    await controller.setPinned('note-1234', true);
    pin.stop();
    debugPrint('bench pin: ${pin.elapsed.inMilliseconds}ms');
    expect(
      pin.elapsed,
      lessThan(pinBudget),
      reason: 'pinning one note in a $noteCount library took ${pin.elapsed}',
    );
    expect(controller.notes.first.pinned, isTrue);
  });

  test('folder filtering stays linear', () async {
    final repo = _BulkRepo();
    repo.notes.addEntries(buildLibrary().map((n) => MapEntry(n.id, n)));
    final controller = NotesController(repo);
    await controller.load();

    final stopwatch = Stopwatch()..start();
    controller.setSelectedFolder('folder-0');
    stopwatch.stop();

    expect(controller.notes, isNotEmpty);
    expect(
      stopwatch.elapsed,
      lessThan(warmSearchBudget),
      reason: 'folder filter took ${stopwatch.elapsed}',
    );
  });
}
