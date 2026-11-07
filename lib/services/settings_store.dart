import 'package:fox/models/settings.dart';

/// Persistence port for the single stored [Settings] value.
///
/// Implementations live with the storage adapters (`repository_hive.dart`);
/// `SettingsService` itself does not touch Hive.
abstract class SettingsStore {
  Settings? read();

  Future<void> write(Settings settings);
}
