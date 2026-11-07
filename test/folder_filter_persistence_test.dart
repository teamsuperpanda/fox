import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';

import 'test_helpers.dart';

void main() {
  group('Folder filter persistence', () {
    late MemoryRepo repo;
    late SettingsService settings;
    late NotesController controller;

    setUp(() async {
      await hiveTestSetup('./test/hive_folder_filter_test');
      repo = MemoryRepo();
      settings = SettingsService();
      controller = NotesController(repo, settingsRepository: settings);
      await controller.load();
    });

    tearDown(() async {
      await hiveTestTeardown();
    });

    Future<void> addFolders() async {
      await controller.addFolder('Work');
      await controller.addFolder('Recipes');
    }

    test('restores the selected folder on the next launch', () async {
      await addFolders();
      final work = controller.folders.firstWhere((f) => f.name == 'Work');
      await controller.addOrUpdate(
        title: 'Work note',
        content: Document(),
        folderId: work.id,
      );
      await controller.setSelectedFolder(work.id);

      final restarted = NotesController(repo, settingsRepository: settings);
      await restarted.load();

      expect(restarted.selectedFolderId, work.id);
      expect(restarted.notes.single.title, 'Work note');
    });

    test('restores the unfiled filter', () async {
      await controller.setSelectedFolder('__unfiled__');

      final restarted = NotesController(repo, settingsRepository: settings);
      await restarted.load();

      expect(restarted.selectedFolderId, '__unfiled__');
    });

    test('a deleted folder resets the filter safely', () async {
      await addFolders();
      final work = controller.folders.firstWhere((f) => f.name == 'Work');
      await settings.setSelectedFolderId(work.id);
      await controller.deleteFolder(work.id);

      final restarted = NotesController(repo, settingsRepository: settings);
      await restarted.load();

      expect(restarted.selectedFolderId, isNull);
      expect(settings.getSelectedFolderId(), isNull);
    });

    test('a stored folder id that no longer exists is cleared on load',
        () async {
      await settings.setSelectedFolderId('missing-folder');

      final restarted = NotesController(repo, settingsRepository: settings);
      await restarted.load();

      expect(restarted.selectedFolderId, isNull);
      expect(settings.getSelectedFolderId(), isNull);
    });

    test('two folders can use different sort modes', () async {
      await addFolders();
      final work = controller.folders.firstWhere((f) => f.name == 'Work');
      final recipes = controller.folders.firstWhere((f) => f.name == 'Recipes');

      await controller.setSelectedFolder(work.id);
      await controller.setSortBy(SortBy.titleAsc);
      await controller.setSelectedFolder(recipes.id);
      await controller.setSortBy(SortBy.dateAsc);

      expect(controller.sortByFor(work.id), SortBy.titleAsc);
      expect(controller.sortByFor(recipes.id), SortBy.dateAsc);
      expect(controller.globalSortBy, SortBy.dateDesc);

      final restarted = NotesController(repo, settingsRepository: settings);
      await restarted.load();
      await restarted.setSelectedFolder(work.id);
      expect(restarted.sortBy, SortBy.titleAsc);
      await restarted.setSelectedFolder(recipes.id);
      expect(restarted.sortBy, SortBy.dateAsc);
    });

    test('per-folder sort orders that folder only', () async {
      await addFolders();
      final work = controller.folders.firstWhere((f) => f.name == 'Work');
      final recipes = controller.folders.firstWhere((f) => f.name == 'Recipes');
      await repo.upsert(
        makeNote(
          id: 'work-b',
          title: 'B',
          folderId: work.id,
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      );
      await repo.upsert(
        makeNote(
          id: 'work-a',
          title: 'A',
          folderId: work.id,
          updatedAt: DateTime.now(),
        ),
      );
      await repo.upsert(
        makeNote(
          id: 'recipes-a',
          title: 'A',
          folderId: recipes.id,
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      );
      await repo.upsert(
        makeNote(
          id: 'recipes-b',
          title: 'B',
          folderId: recipes.id,
          updatedAt: DateTime.now(),
        ),
      );
      await controller.load();

      await controller.setSelectedFolder(work.id);
      await controller.setSortBy(SortBy.titleAsc);
      expect(controller.notes.map((n) => n.title), ['A', 'B']);

      await controller.setSelectedFolder(recipes.id);
      expect(
        controller.notes.map((n) => n.id),
        ['recipes-b', 'recipes-a'],
      );
    });

    test('deleting a folder clears its per-folder sort', () async {
      await addFolders();
      final work = controller.folders.firstWhere((f) => f.name == 'Work');
      await controller.setSelectedFolder(work.id);
      await controller.setSortBy(SortBy.titleDesc);

      await controller.deleteFolder(work.id);

      expect(settings.getFolderSort(work.id), isNull);
      expect(settings.getSelectedFolderId(), isNull);
    });

    test('a global sort is kept as the fallback', () async {
      await controller.setSortBy(SortBy.titleDesc);
      expect(settings.getSortBy(), 'titleDesc');

      final restarted = NotesController(repo, settingsRepository: settings);
      await restarted.load();

      expect(restarted.sortBy, SortBy.titleDesc);
    });
  });
}
