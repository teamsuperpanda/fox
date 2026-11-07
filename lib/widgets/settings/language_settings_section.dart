import 'package:flutter/material.dart';
import 'package:fox/data/locale_display_names.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/widgets/language_picker_dialog.dart';
import 'package:fox/widgets/settings/settings_common.dart';
import 'package:provider/provider.dart';

/// Language override picker.
class LanguageSettingsSection extends StatelessWidget {
  const LanguageSettingsSection({
    required this.onLocaleChanged,
    super.key,
  });

  /// Called after the locale has been persisted so the section can rebuild.
  final VoidCallback onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsSection(
      title: l10n.language,
      children: [_buildLanguageSelector(context, l10n)],
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale;
    final currentTag =
        currentLocale != null ? localeToTag(currentLocale) : null;
    final displayText = currentTag != null
        ? (LocaleDisplayNames.names[currentTag] ?? currentTag)
        : l10n.systemDefault;

    return Semantics(
      button: true,
      label: l10n.language,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _pickLocale(context, l10n, localeProvider, currentTag),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayText,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickLocale(
    BuildContext context,
    AppLocalizations l10n,
    LocaleProvider localeProvider,
    String? currentTag,
  ) async {
    final selected = await showDialog<Locale?>(
      context: context,
      builder: (_) => LanguagePickerDialog(
        currentTag: currentTag,
        systemDefaultLabel: l10n.systemDefault,
        searchHintLabel: l10n.search,
      ),
    );
    if (selected == LanguagePickerDialog.sentinelSystemDefault) {
      await localeProvider.setLocale(null);
      onLocaleChanged();
    } else if (selected != null) {
      await localeProvider.setLocale(selected);
      onLocaleChanged();
    }
  }
}
