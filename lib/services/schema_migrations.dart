import 'package:fox/models/folder.dart';
import 'package:fox/models/note.dart';
import 'package:fox/models/settings.dart';
import 'package:hive/hive.dart';

/// Version of the on-disk schema. Bump it for every model or adapter change.
///
/// Rules for changing a stored model:
/// 1. Never reuse a field index that an older version wrote.
/// 2. Never renumber a `typeId`: it identifies the model inside a box.
/// 3. Append new fields at the next free index and give the adapter a default
///    for boxes that do not have them yet.
/// 4. Bump [currentSchemaVersion] and add a step to [schemaMigrations].
const int currentSchemaVersion = 1;

/// Releases before schema versioning wrote no version. Their boxes use the
/// schema that shipped in 2.1.1, which is version 1.
const int legacySchemaVersion = 1;

/// Key in `schema_db` that stores [currentSchemaVersion].
const String schemaVersionKey = 'schemaVersion';

/// Boxes a migration step may read and rewrite.
class SchemaBoxes {
  const SchemaBoxes({
    required this.notes,
    required this.folders,
    required this.settings,
  });

  final Box<Note> notes;
  final Box<Folder> folders;
  final Box<Settings> settings;
}

/// One ordered migration step. Step `n` upgrades schema `n` to `n + 1`.
typedef SchemaStep = Future<void> Function(SchemaBoxes boxes);

/// Ordered migrations keyed by the version they upgrade from.
///
/// Version 1 is the first versioned schema, so there is nothing to migrate yet.
const Map<int, SchemaStep> schemaMigrations = {};

/// Raised when the stored schema cannot be brought up to the current version.
class SchemaMigrationException implements Exception {
  const SchemaMigrationException(this.message);

  final String message;

  @override
  String toString() => 'SchemaMigrationException: $message';
}

/// Runs every migration from [from] up to [to] in order.
///
/// Throws [SchemaMigrationException] if the box was written by a newer app
/// version, or if a step is missing from the registry. Nothing is written
/// until every step succeeds, because the caller stores the version afterwards.
Future<void> runSchemaMigrations({
  required int from,
  required int to,
  required SchemaBoxes boxes,
  Map<int, SchemaStep>? migrations,
}) async {
  if (to < from) {
    throw SchemaMigrationException(
      'Database schema v$from is newer than this app supports (v$to). '
      'Update Fox to open your notes.',
    );
  }
  final registry = migrations ?? schemaMigrations;
  for (var version = from; version < to; version++) {
    final step = registry[version];
    if (step == null) {
      throw SchemaMigrationException(
        'No migration registered from v$version to v${version + 1}.',
      );
    }
    await step(boxes);
  }
}
