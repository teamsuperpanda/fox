import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/widgets/settings/settings_common.dart';

/// List display preferences (tags, previews, alternating rows, FAB animation).
class ViewSettingsSection extends StatelessWidget {
  const ViewSettingsSection({
    required this.controller,
    required this.settingsService,
    super.key,
  });

  final NotesController controller;
  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsSection(
      title: l10n.viewOptions,
      children: [
        SettingsSwitchTile(
          title: l10n.showTags,
          value: controller.showTags,
          onChanged: (val) => _persist(
            () => controller.setShowTags(val),
            () => settingsService.setShowTags(val),
          ),
        ),
        settingsDivider(context),
        SettingsSwitchTile(
          title: l10n.showNotePreviews,
          value: controller.showContent,
          onChanged: (val) => _persist(
            () => controller.setShowContent(val),
            () => settingsService.setShowContent(val),
          ),
        ),
        settingsDivider(context),
        SettingsSwitchTile(
          title: l10n.alternatingRowColors,
          value: controller.alternatingColors,
          onChanged: (val) => _persist(
            () => controller.setAlternatingColors(val),
            () => settingsService.setAlternatingColors(val),
          ),
        ),
        settingsDivider(context),
        SettingsSwitchTile(
          title: l10n.animateAddButton,
          value: controller.fabAnimation,
          onChanged: (val) => _persist(
            () => controller.setFabAnimation(val),
            () => settingsService.setFabAnimation(val),
          ),
        ),
      ],
    );
  }

  Future<void> _persist(
    void Function() apply,
    Future<void> Function() save,
  ) async {
    apply();
    try {
      await save();
    } catch (e) {
      debugPrint('ViewSettingsSection: failed to persist preference: $e');
    }
  }
}
