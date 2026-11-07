import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/widgets/settings/settings_common.dart';

/// App identity and open-source licence entry point.
class AboutSettingsSection extends StatelessWidget {
  const AboutSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final materialL10n = MaterialLocalizations.of(context);
    return SettingsSection(
      title: l10n.appTitle,
      children: [
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(materialL10n.licensesPageTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(
            context: context,
            applicationName: l10n.appTitle,
          ),
        ),
      ],
    );
  }
}
