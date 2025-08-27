import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/settings.dart';

Future<void> migratePrefsToHive() async {
  final settingsBox = Hive.box<Settings>('settings_db');
  final migrationBox = Hive.box('migration_flags');
  
  if (migrationBox.get('migrated_prefs_v1') == true) return;

  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString('themeMode') ?? 'system';
  final settings = Settings(themeMode: stored);
  await settingsBox.put('app_settings', settings);
  await migrationBox.put('migrated_prefs_v1', true);
}
