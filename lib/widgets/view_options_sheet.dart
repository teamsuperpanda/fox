import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fox/data/locale_display_names.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/services/umami_service.dart';
import 'package:fox/theme/app_theme.dart';
import 'package:fox/widgets/language_picker_dialog.dart';
import 'package:provider/provider.dart';

class ViewOptionsSheet extends StatefulWidget {
  const ViewOptionsSheet({
    required this.controller,
    required this.settingsService,
    required this.themeProvider,
    required this.localeProvider,
    required this.umamiService,
    required this.accentColorOptions,
    this.useGoogleFonts = true,
    super.key,
  });

  final NotesController controller;
  final SettingsService settingsService;
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;
  final UmamiService umamiService;
  final List<Color> accentColorOptions;
  final bool useGoogleFonts;

  @override
  State<ViewOptionsSheet> createState() => _ViewOptionsSheetState();
}

class _ViewOptionsSheetState extends State<ViewOptionsSheet> {
  Map<String, String> _localeNames = const {};

  @override
  void initState() {
    super.initState();
    unawaited(LocaleDisplayNames.load().then((names) {
      if (mounted) setState(() => _localeNames = names);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Consumer<ThemeProvider>(
          builder: (consumerContext, themeProvider, child) {
            final brightness = MediaQuery.platformBrightnessOf(consumerContext);
            final isDark = themeProvider.themeMode == ThemeMode.dark ||
                (themeProvider.themeMode == ThemeMode.system &&
                    brightness == Brightness.dark);
            final activeTheme = isDark
                ? AppTheme.dark(themeProvider.accentColor,
                    useGoogleFonts: widget.useGoogleFonts)
                : AppTheme.light(themeProvider.accentColor,
                    useGoogleFonts: widget.useGoogleFonts);

            return Theme(
              data: activeTheme,
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  final localeProvider = context.read<LocaleProvider>();
                  final colorScheme = Theme.of(context).colorScheme;

                  return Material(
                    color: colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            _buildHandle(colorScheme),
                            _buildHeader(context, l10n, colorScheme),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader(context, l10n.sortBy),
                                    _buildCardGroup(context, [
                                      _buildRadioTile(
                                        context: context,
                                        title: l10n.dateNewestFirst,
                                        value: SortBy.dateDesc,
                                        groupValue: widget.controller.sortBy,
                                        onChanged: (val) async {
                                          widget.controller.setSortBy(val);
                                          try {
                                            await widget.settingsService
                                                .setSortBy(val.name);
                                          } catch (e) {
                                            debugPrint(
                                                'ViewOptionsSheet: failed to persist sortBy: $e');
                                          }
                                          setDialogState(() {});
                                        },
                                      ),
                                      _buildDivider(context),
                                      _buildRadioTile(
                                        context: context,
                                        title: l10n.dateOldestFirst,
                                        value: SortBy.dateAsc,
                                        groupValue: widget.controller.sortBy,
                                        onChanged: (val) async {
                                          widget.controller.setSortBy(val);
                                          try {
                                            await widget.settingsService
                                                .setSortBy(val.name);
                                          } catch (e) {
                                            debugPrint(
                                                'ViewOptionsSheet: failed to persist sortBy: $e');
                                          }
                                          setDialogState(() {});
                                        },
                                      ),
                                      _buildDivider(context),
                                      _buildRadioTile(
                                        context: context,
                                        title: l10n.titleAZ,
                                        value: SortBy.titleAsc,
                                        groupValue: widget.controller.sortBy,
                                        onChanged: (val) async {
                                          widget.controller.setSortBy(val);
                                          try {
                                            await widget.settingsService
                                                .setSortBy(val.name);
                                          } catch (e) {
                                            debugPrint(
                                                'ViewOptionsSheet: failed to persist sortBy: $e');
                                          }
                                          setDialogState(() {});
                                        },
                                      ),
                                      _buildDivider(context),
                                      _buildRadioTile(
                                        context: context,
                                        title: l10n.titleZA,
                                        value: SortBy.titleDesc,
                                        groupValue: widget.controller.sortBy,
                                        onChanged: (val) async {
                                          widget.controller.setSortBy(val);
                                          try {
                                            await widget.settingsService
                                                .setSortBy(val.name);
                                          } catch (e) {
                                            debugPrint(
                                                'ViewOptionsSheet: failed to persist sortBy: $e');
                                          }
                                          setDialogState(() {});
                                        },
                                      ),
                                    ]),
                                    const SizedBox(height: 24),
                                    _buildSectionHeader(
                                        context, l10n.viewOptions),
                                    _buildCardGroup(context, [
                                      _buildSwitchTile(
                                        context: context,
                                        title: l10n.showTags,
                                        value: widget.controller.showTags,
                                        onChanged: (val) async {
                                          widget.controller.setShowTags(val);
                                          try {
                                            await widget.settingsService
                                                .setShowTags(val);
                                          } catch (e) {
                                            debugPrint(
                                                'ViewOptionsSheet: failed to persist showTags: $e');
                                          }
                                          setDialogState(() {});
                                        },
                                      ),
                                      _buildDivider(context),
                                      _buildSwitchTile(
                                        context: context,
                                        title: l10n.showNotePreviews,
                                        value: widget.controller.showContent,
                                        onChanged: (val) async {
                                          widget.controller.setShowContent(val);
                                          try {
                                            await widget.settingsService
                                                .setShowContent(val);
                                          } catch (e) {
                                            debugPrint(
                                                'ViewOptionsSheet: failed to persist showContent: $e');
                                          }
                                          setDialogState(() {});
                                        },
                                      ),
                                      _buildDivider(context),
                                      _buildSwitchTile(
                                        context: context,
                                        title: l10n.alternatingRowColors,
                                        value:
                                            widget.controller.alternatingColors,
                                        onChanged: (val) async {
                                          widget.controller
                                              .setAlternatingColors(val);
                                          try {
                                            await widget.settingsService
                                                .setAlternatingColors(val);
                                          } catch (e) {
                                            debugPrint(
                                                'ViewOptionsSheet: failed to persist alternatingColors: $e');
                                          }
                                          setDialogState(() {});
                                        },
                                      ),
                                      _buildDivider(context),
                                      _buildSwitchTile(
                                        context: context,
                                        title: l10n.animateAddButton,
                                        value: widget.controller.fabAnimation,
                                        onChanged: (val) async {
                                          widget.controller
                                              .setFabAnimation(val);
                                          try {
                                            await widget.settingsService
                                                .setFabAnimation(val);
                                          } catch (e) {
                                            debugPrint(
                                                'ViewOptionsSheet: failed to persist fabAnimation: $e');
                                          }
                                          setDialogState(() {});
                                        },
                                      ),
                                    ]),
                                    const SizedBox(height: 24),
                                    _buildSectionHeader(
                                        context, l10n.accentColor),
                                    _buildAccentColorPicker(
                                        context, setDialogState),
                                    const SizedBox(height: 24),
                                    _buildSectionHeader(context, l10n.language),
                                    _buildLanguageSelector(
                                      context,
                                      l10n,
                                      localeProvider,
                                      setDialogState,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildSectionHeader(
                                        context, l10n.analytics),
                                    _buildCardGroup(context, [
                                      _buildSwitchTile(
                                        context: context,
                                        title: l10n.analytics,
                                        value: widget.settingsService
                                            .getAnalyticsEnabled(),
                                        onChanged: (val) async {
                                          widget.umamiService.enabled = val;
                                          try {
                                            await widget.settingsService
                                                .setAnalyticsEnabled(val);
                                          } catch (e) {
                                            debugPrint(
                                                'ViewOptionsSheet: failed to persist analyticsEnabled: $e');
                                          }
                                          widget.umamiService.track(
                                              'analytics_change',
                                              data: {'analytics': val});
                                          setDialogState(() {});
                                        },
                                      ),
                                    ]),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHandle(ColorScheme colorScheme) {
    return Container(
      width: 48,
      height: 5,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              l10n.viewOptions,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildCardGroup(BuildContext context, List<Widget> children) {
    return Card(
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
    );
  }

  Widget _buildDivider(BuildContext context) {
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

  Widget _buildRadioTile({
    required BuildContext context,
    required String title,
    required SortBy value,
    required SortBy groupValue,
    required Function(SortBy) onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
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

  Widget _buildAccentColorPicker(
    BuildContext context,
    StateSetter setDialogState,
  ) {
    final themeProvider = context.read<ThemeProvider>();
    final currentColor = themeProvider.accentColor;

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
        children: widget.accentColorOptions.map((color) {
          final isSelected = color.toARGB32() == currentColor.toARGB32();
          return Semantics(
            button: true,
            label: 'Accent color',
            child: GestureDetector(
              onTap: () {
                themeProvider.setAccentColor(color);
                widget.umamiService.track('accent_color_change');
                setDialogState(() {});
              },
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

  Widget _buildLanguageSelector(
    BuildContext context,
    AppLocalizations l10n,
    LocaleProvider localeProvider,
    StateSetter setDialogState,
  ) {
    final currentLocale = localeProvider.locale;
    final currentTag =
        currentLocale != null ? localeToTag(currentLocale) : null;
    final displayText = currentTag != null
        ? (_localeNames[currentTag] ?? currentTag)
        : l10n.systemDefault;

    return Semantics(
      button: true,
      label: 'Language selector',
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
          onTap: () async {
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
              widget.umamiService
                  .track('locale_change', data: {'locale': 'system'});
              setDialogState(() {});
            } else if (selected != null) {
              await localeProvider.setLocale(selected);
              widget.umamiService.track('locale_change',
                  data: {'locale': selected.toLanguageTag()});
              setDialogState(() {});
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.language,
                    size: 22, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayText,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
