import 'dart:io';

import 'package:flutter/widgets.dart' show FileImage;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fox/models/note.dart';
import 'package:fox/services/image_store.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:path/path.dart' as p;

import 'test_helpers.dart';

Document _documentWithImages(List<String> images) {
  return Document.fromJson([
    {'insert': 'A note\n'},
    for (final image in images) ...[
      {
        'insert': {'image': image},
      },
      {'insert': '\n'},
    ],
  ]);
}

String _contentWithImages(List<String> images) =>
    Note.documentToContent(_documentWithImages(images));

void main() {
  group('Note.embeddedImagePaths', () {
    test('returns every image embed path', () {
      final note = makeNote(
        content: _contentWithImages(['attachments/a.jpg', 'attachments/b.png']),
      );
      expect(note.embeddedImagePaths, [
        'attachments/a.jpg',
        'attachments/b.png',
      ]);
    });

    test('is empty without image embeds', () {
      final note = makeNote(
        content: r'{"ops":[{"insert":"plain\n"}]}',
      );
      expect(note.embeddedImagePaths, isEmpty);
    });

    test('is empty for corrupt content', () {
      expect(makeNote(content: '{nope}').embeddedImagePaths, isEmpty);
    });
  });

  group('ImageStore', () {
    late Directory root;
    late ImageStore store;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('fox_images');
      store = ImageStore(rootPath: root.path);
    });

    tearDown(() async {
      if (root.existsSync()) await root.delete(recursive: true);
    });

    Future<File> attachment(String name) async {
      final dir = Directory(p.join(root.path, ImageStore.attachmentsDirectory));
      await dir.create(recursive: true);
      return File(p.join(dir.path, name))..writeAsBytesSync([1, 2, 3]);
    }

    test('is ready when a root is supplied', () {
      expect(store.isReady, isTrue);
      expect(store.isSupported, isTrue);
    });

    test('save copies the file into attachments and returns a relative path',
        () async {
      final source = File(p.join(root.path, 'picked.jpg'))
        ..writeAsBytesSync([9, 8, 7]);

      final relative = await store.save(source.path);

      expect(p.basename(p.dirname(relative)), 'attachments');
      expect(p.extension(relative), '.jpg');
      final saved = File(p.join(root.path, relative));
      expect(saved.existsSync(), isTrue);
      expect(saved.readAsBytesSync(), [9, 8, 7]);
      // The original is left alone: copying is not moving.
      expect(source.existsSync(), isTrue);
    });

    test('imageProvider resolves a stored relative path', () async {
      final file = await attachment('one.png');
      final provider = store.imageProvider(
        p.join('attachments', p.basename(file.path)),
      );
      expect(provider, isA<FileImage>());
      expect((provider! as FileImage).file.path, file.path);
    });

    test('imageProvider returns null when the store is not ready', () {
      expect(ImageStore().imageProvider('attachments/x.jpg'), isNull);
    });

    test('deleteUnreferenced removes only unreferenced attachments', () async {
      final kept = await attachment('keep.jpg');
      final dropped = await attachment('drop.jpg');
      final keptPath = p.join('attachments', 'keep.jpg');
      final droppedPath = p.join('attachments', 'drop.jpg');

      await store.deleteUnreferenced(
        [keptPath, droppedPath],
        stillReferenced: [keptPath],
      );

      expect(kept.existsSync(), isTrue);
      expect(dropped.existsSync(), isFalse);
    });

    test('deleteUnreferenced ignores paths outside attachments', () async {
      final outside = File(p.join(root.path, 'outside.jpg'))
        ..writeAsBytesSync([1]);

      await store.deleteUnreferenced([p.join('..', 'outside.jpg')]);

      expect(outside.existsSync(), isTrue);
    });

    test('deleteUnreferenced tolerates missing files', () async {
      await expectLater(
        store.deleteUnreferenced(['attachments/missing.jpg']),
        completes,
      );
    });
  });

  group('NotesController image cleanup', () {
    late Directory root;
    late ImageStore store;
    late MemoryRepo repo;
    late NotesController controller;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('fox_images_cleanup');
      store = ImageStore(rootPath: root.path);
      repo = MemoryRepo();
      controller = NotesController(repo, imageStore: store);
      await controller.load();
    });

    tearDown(() async {
      if (root.existsSync()) await root.delete(recursive: true);
    });

    Future<File> attachment(String name) async {
      final dir = Directory(p.join(root.path, ImageStore.attachmentsDirectory));
      await dir.create(recursive: true);
      return File(p.join(dir.path, name))..writeAsBytesSync([1]);
    }

    test('removing a note keeps its images for undo', () async {
      final image = await attachment('a.jpg');
      final relative = p.join('attachments', 'a.jpg');
      await controller.addOrUpdate(
        title: 'With image',
        content: Document.fromJson([
          {'insert': 'text\n'},
          {
            'insert': {'image': relative},
          },
          {'insert': '\n'},
        ]),
      );
      final id = controller.notes.single.id;

      await controller.remove(id);

      expect(image.existsSync(), isTrue);
      expect(controller.lastRemovedNote?.embeddedImagePaths, [relative]);

      await controller.undoRemove();
      expect(controller.notes.single.id, id);
      expect(image.existsSync(), isTrue);
    });

    test('removing a second note deletes the first note images', () async {
      final firstImage = await attachment('first.jpg');
      await controller.addOrUpdate(
        title: 'First',
        content: _documentWithImages(['attachments/first.jpg']),
      );
      await controller.addOrUpdate(title: 'Second', content: Document());

      final first = controller.notes.firstWhere((n) => n.title == 'First');
      final second = controller.notes.firstWhere((n) => n.title == 'Second');

      await controller.remove(first.id);
      expect(firstImage.existsSync(), isTrue);

      await controller.remove(second.id);
      expect(firstImage.existsSync(), isFalse);
    });

    test('an image still referenced by another note is kept', () async {
      final shared = await attachment('shared.jpg');
      await controller.addOrUpdate(
        title: 'First',
        content: _documentWithImages(['attachments/shared.jpg']),
      );
      await controller.addOrUpdate(
        title: 'Second',
        content: _documentWithImages(['attachments/shared.jpg']),
      );
      await controller.addOrUpdate(title: 'Third', content: Document());

      final first = controller.notes.firstWhere((n) => n.title == 'First');
      final third = controller.notes.firstWhere((n) => n.title == 'Third');

      await controller.remove(first.id);
      await controller.remove(third.id);

      expect(shared.existsSync(), isTrue);
    });

    test('removing an image from a note deletes the file', () async {
      final image = await attachment('removed.jpg');
      await controller.addOrUpdate(
        title: 'Edited',
        content: _documentWithImages(['attachments/removed.jpg']),
      );
      final id = controller.notes.single.id;

      await controller.addOrUpdate(
        id: id,
        title: 'Edited',
        content: Document.fromJson([
          {'insert': 'text only\n'},
        ]),
      );

      expect(image.existsSync(), isFalse);
    });

    test('adding an image keeps the file', () async {
      final image = await attachment('added.jpg');
      await controller.addOrUpdate(title: 'New', content: Document());
      final id = controller.notes.single.id;

      await controller.addOrUpdate(
        id: id,
        title: 'New',
        content: _documentWithImages(['attachments/added.jpg']),
      );

      expect(image.existsSync(), isTrue);
    });
  });
}
