import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/widgets/settings/about_settings_section.dart';
import 'package:fox/widgets/settings/appearance_settings_section.dart';
import 'package:fox/widgets/settings/language_settings_section.dart';
import 'package:fox/widgets/settings/sort_settings_section.dart';
import 'package:fox/widgets/settings/view_settings_section.dart';

/// Full-screen settings, organised around tasks instead of one long sheet.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.controller,
    required this.settingsService,
    super.key,
  });

  final NotesController controller;
  final SettingsService settingsService;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.viewOptions),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          AppearanceSettingsSection(
            accentColorOptions: accentColorOptions,
          ),
          ViewSettingsSection(
            controller: widget.controller,
            settingsService: widget.settingsService,
          ),
          SortSettingsSection(
            controller: widget.controller,
            settingsService: widget.settingsService,
          ),
          LanguageSettingsSection(
            onLocaleChanged: () => setState(() {}),
          ),
          const AboutSettingsSection(),
        ],
      ),
    );
  }
}
