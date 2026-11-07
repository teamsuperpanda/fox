import 'package:flutter/material.dart';

/// Titled card group used by every settings section.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.5),
              ),
            ),
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

/// Divider used between rows inside a [SettingsSection].
Widget settingsDivider(BuildContext context) {
  return ExcludeSemantics(
    child: Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color:
          Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    ),
  );
}

/// A switch row with the same shape as the old view options sheet.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// A radio row rendered with the app's custom selection icon.
class SettingsRadioTile extends StatelessWidget {
  const SettingsRadioTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
