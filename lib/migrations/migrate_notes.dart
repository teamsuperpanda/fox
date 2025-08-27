import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:hive/hive.dart';

import '../services/repository_sqlite.dart';
import '../services/repository_idb_web.dart';
import '../services/repository_hive.dart';

Future<void> migrateNotesToHive() async {
  final migrationBox = Hive.box('migration_flags');
  
  // Check if migration already completed
  if (migrationBox.get('migrated_notes_v1') == true) return;

  try {
    // Create the old repository based on platform
    final oldRepo = kIsWeb
        ? await WebIdbNoteRepository.create()
        : await SqliteNoteRepository.create();

    // Get all existing notes
    final existingNotes = await oldRepo.getAll();
    
    // Get the new Hive repository
    final newRepo = await HiveNoteRepository.create();
    
    // Migrate each note
    for (final note in existingNotes) {
      await newRepo.upsert(note);
    }
    
    // Mark migration as complete
    await migrationBox.put('migrated_notes_v1', true);
    
    debugPrint('Notes migration completed: ${existingNotes.length} notes migrated to Hive');
  } catch (e) {
    debugPrint('Notes migration failed: $e');
    // Don't mark as completed so it can retry next time
    rethrow;
  }
}
