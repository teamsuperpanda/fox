import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings.dart';
import '../models/settings_adapter.dart';
import '../models/note_adapter.dart';
import '../models/note.dart';

class StorageService {
  static bool _inited = false;

  /// Initialize Hive, register adapters, and open core boxes.
  static Future<void> init() async {
    if (_inited) return;
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(NoteAdapter());
    }
    
    // Open boxes
    await Hive.openBox<Settings>('settings_db');
    await Hive.openBox('migration_flags'); // For storing migration flags
    await Hive.openBox<Note>('notes_db'); // For storing notes
    
    _inited = true;
  }
}
