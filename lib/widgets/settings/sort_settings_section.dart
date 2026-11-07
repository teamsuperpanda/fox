import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/widgets/settings/settings_common.dart';

/// Sort order picker.
class SortSettingsSection extends StatelessWidget {
  const SortSettingsSection({
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
      title: l10n.sortBy,
      children: [
        _tile(l10n.dateNewestFirst, SortBy.dateDesc),
        settingsDivider(context),
        _tile(l10n.dateOldestFirst, SortBy.dateAsc),
        settingsDivider(context),
        _tile(l10n.titleAZ, SortBy.titleAsc),
        settingsDivider(context),
        _tile(l10n.titleZA, SortBy.titleDesc),
      ],
    );
  }

  Widget _tile(String title, SortBy value) {
    return SettingsRadioTile(
      title: title,
      isSelected: controller.sortBy == value,
      onTap: () => _select(value),
    );
  }

  Future<void> _select(SortBy value) async {
    controller.setSortBy(value);
    try {
      await settingsService.setSortBy(value.name);
    } catch (e) {
      debugPrint('SortSettingsSection: failed to persist sortBy: $e');
    }
  }
}
