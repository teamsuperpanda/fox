import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/widgets/settings/settings_common.dart';
import 'package:provider/provider.dart';

/// Accent colour picker moved out of the old view options sheet.
class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({
    required this.accentColorOptions,
    super.key,
  });

  final List<Color> accentColorOptions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsSection(
      title: l10n.accentColor,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) =>
              _buildAccentColorPicker(context, themeProvider),
        ),
      ],
    );
  }

  Widget _buildAccentColorPicker(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final currentColor = themeProvider.accentColor;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: accentColorOptions.map((color) {
          final isSelected = color.toARGB32() == currentColor.toARGB32();
          return Semantics(
            button: true,
            label: l10n.accentColor,
            child: GestureDetector(
              onTap: () => themeProvider.setAccentColor(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 42 : 36,
                height: isSelected ? 42 : 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 2.5,
                        )
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 20,
                        color: ThemeData.estimateBrightnessForColor(color) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      )
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
