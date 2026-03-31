import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'note_detail_page.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notes_controller.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';
import 'widgets/dialogs.dart';
import 'widgets/empty_state.dart';
import 'widgets/folders_dialog.dart';
import 'widgets/note_list.dart';

class HomePage extends StatefulWidget {
  final NotesController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  NotesController get controller => widget.controller;
  late AnimationController _animationController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  bool _isRotated = false;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // subtle slow wiggle for the FAB
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fabAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );

    _searchController.addListener(() {
      controller.setSearchTerm(_searchController.text);
    });
    // Kick off the FAB wiggle after the first frame so it doesn't block
    // pumpAndSettle in tests (a repeating animation never "settles").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && controller.fabAnimation) {
        _fabController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    _animationController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      if (controller.fabAnimation) {
        if (!_fabController.isAnimating) {
          _fabController.repeat(reverse: true);
        }
      } else {
        if (_fabController.isAnimating) {
          _fabController.stop();
        }
        // Force neutral position (0 degrees). Tween is -0.05 to 0.05. Neutral is 0.0, which is t=0.5
        _fabController.value = 0.5;
      }
      setState(() {});
    }
  }

  void _toggleRotation() {
    setState(() {
      _isRotated = !_isRotated;
      if (_isRotated) {
        _animationController.forward(from: 0.0);
      } else {
        _animationController.reverse(from: 1.0);
      }
    });
  }

  Future<void> _addNote() async {
    final result =
        await Navigator.of(context).push<NoteDetailResult>(MaterialPageRoute(
      builder: (_) => NoteDetailPage(
        controller: controller,
      ),
    ));
    if (!mounted) return;
    if (result != null && result.changed) {
      if (result.deleted) {
        showUndoDeleteSnackBar(context, controller);
      }
      setState(() {});
    }
  }

  void _showFoldersDialog() async {
    await showDialog(
      context: context,
      builder: (context) => FoldersDialog(controller: controller),
    );
    if (!mounted) return;
    setState(() {});
  }

  void _showViewOptions() async {
    SettingsService? settingsService;
    try {
      settingsService = SettingsService();
      // Access box to verify it's open
      settingsService.getSettings();
    } catch (_) {
      settingsService = null;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return Consumer<ThemeProvider>(
              builder: (consumerContext, themeProvider, child) {
                final brightness =
                    MediaQuery.platformBrightnessOf(consumerContext);
                final isDark =
                    themeProvider.themeMode == ThemeMode.dark ||
                    (themeProvider.themeMode == ThemeMode.system &&
                        brightness == Brightness.dark);
                final activeTheme = isDark
                    ? AppTheme.dark(themeProvider.accentColor)
                    : AppTheme.light(themeProvider.accentColor);

                return Theme(
                  data: activeTheme,
                  child: Builder(
                    builder: (context) {
                      // context now sits BELOW AnimatedTheme, so
                      // Theme.of(context) always reflects the latest accent.
                      final l10n = AppLocalizations.of(context);
                      final localeProvider = context.read<LocaleProvider>();
                      final colorScheme = Theme.of(context).colorScheme;

                      return Material(
                        color: colorScheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.viewOptions,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(context, l10n.sortBy),
                            _buildCardGroup(context, [
                              _buildRadioTile(
                                context: context,
                                title: l10n.dateNewestFirst,
                                value: SortBy.dateDesc,
                                groupValue: controller.sortBy,
                                onChanged: (val) async {
                                  controller.setSortBy(val);
                                  await settingsService?.setSortBy(val.name);
                                  setDialogState(() {});
                                },
                              ),
                              _buildDivider(context),
                              _buildRadioTile(
                                context: context,
                                title: l10n.dateOldestFirst,
                                value: SortBy.dateAsc,
                                groupValue: controller.sortBy,
                                onChanged: (val) async {
                                  controller.setSortBy(val);
                                  await settingsService?.setSortBy(val.name);
                                  setDialogState(() {});
                                },
                              ),
                              _buildDivider(context),
                              _buildRadioTile(
                                context: context,
                                title: l10n.titleAZ,
                                value: SortBy.titleAsc,
                                groupValue: controller.sortBy,
                                onChanged: (val) async {
                                  controller.setSortBy(val);
                                  await settingsService?.setSortBy(val.name);
                                  setDialogState(() {});
                                },
                              ),
                              _buildDivider(context),
                              _buildRadioTile(
                                context: context,
                                title: l10n.titleZA,
                                value: SortBy.titleDesc,
                                groupValue: controller.sortBy,
                                onChanged: (val) async {
                                  controller.setSortBy(val);
                                  await settingsService?.setSortBy(val.name);
                                  setDialogState(() {});
                                },
                              ),
                            ]),
                            const SizedBox(height: 24),
                            _buildSectionHeader(context, l10n.viewOptions),
                            _buildCardGroup(context, [
                              _buildSwitchTile(
                                context: context,
                                title: l10n.showTags,
                                value: controller.showTags,
                                onChanged: (val) async {
                                  controller.setShowTags(val);
                                  await settingsService?.setShowTags(val);
                                  setDialogState(() {});
                                },
                              ),
                              _buildDivider(context),
                              _buildSwitchTile(
                                context: context,
                                title: l10n.showNotePreviews,
                                value: controller.showContent,
                                onChanged: (val) async {
                                  controller.setShowContent(val);
                                  await settingsService?.setShowContent(val);
                                  setDialogState(() {});
                                },
                              ),
                              _buildDivider(context),
                              _buildSwitchTile(
                                context: context,
                                title: l10n.alternatingRowColors,
                                value: controller.alternatingColors,
                                onChanged: (val) async {
                                  controller.setAlternatingColors(val);
                                  await settingsService
                                      ?.setAlternatingColors(val);
                                  setDialogState(() {});
                                },
                              ),
                              _buildDivider(context),
                              _buildSwitchTile(
                                context: context,
                                title: l10n.animateAddButton,
                                value: controller.fabAnimation,
                                onChanged: (val) async {
                                  controller.setFabAnimation(val);
                                  await settingsService?.setFabAnimation(val);
                                  setDialogState(() {});
                                },
                              ),
                            ]),
                            const SizedBox(height: 24),
                            _buildSectionHeader(context, l10n.accentColor),
                            _buildAccentColorPicker(context, setDialogState),
                            const SizedBox(height: 24),
                            _buildSectionHeader(context, l10n.language),
                            _buildLanguageSelector(
                                context, l10n, localeProvider, setDialogState),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
                      );  // Material
                    },
                  ),  // Builder
                );  // Theme
              },
            );  // Consumer
          },
        );  // StatefulBuilder
      },
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
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.3),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
            Expanded(
              child: Text(title),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  /// Mapping from locale to its native display name for the language picker.
  static const _localeDisplayNames = <String, String>{
    'en': 'English',
    'es': 'Español',
    'es_419': 'Español (Latinoamérica)',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português (Brasil)',
    'pt_PT': 'Português (Portugal)',
    'it': 'Italiano',
    'ja': '日本語',
    'ko': '한국어',
    'zh': '中文（简体）',
    'zh_TW': '中文（繁體）',
    'ru': 'Русский',
    'tr': 'Türkçe',
    'nl': 'Nederlands',
    'sv': 'Svenska',
    'pl': 'Polski',
    'ar': 'العربية',
    'hi': 'हिन्दी',
    'id': 'Bahasa Indonesia',
    'vi': 'Tiếng Việt',
    'th': 'ภาษาไทย',
    'uk': 'Українська',
    'ro': 'Română',
    'cs': 'Čeština',
    'da': 'Dansk',
    'fi': 'Suomi',
    'ms': 'Bahasa Melayu',
    'bn': 'বাংলা',
    'el': 'Ελληνικά',
    'he': 'עברית',
  };

  static String _localeTag(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
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
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: accentColorOptions.map((color) {
          final isSelected = color.toARGB32() == currentColor.toARGB32();
          return GestureDetector(
            onTap: () {
              themeProvider.setAccentColor(color);
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
                        )
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
    final currentTag = currentLocale != null ? _localeTag(currentLocale) : null;
    final displayText = currentTag != null
        ? (_localeDisplayNames[currentTag] ?? currentTag)
        : l10n.systemDefault;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final selected = await showDialog<Locale?>(
            context: context,
            builder: (_) => _LanguagePickerDialog(
              currentTag: currentTag,
              localeDisplayNames: _localeDisplayNames,
              systemDefaultLabel: l10n.systemDefault,
              searchHintLabel: l10n.search,
            ),
          );
          if (selected == _sentinelSystemDefault) {
            localeProvider.setLocale(null);
            setDialogState(() {});
          } else if (selected != null) {
            localeProvider.setLocale(selected);
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
    );
  }

  /// Sentinel locale returned by the picker to indicate "System Default".
  static final _sentinelSystemDefault = Locale('__system__');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notes = controller.notes;
    final hasAnyNotes = controller.hasNotes;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  border: InputBorder.none,
                ),
              )
            : Text(l10n.appTitle),
        centerTitle: true,
        leading: GestureDetector(
          onTap: _toggleRotation,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
              alignment: Alignment.center,
              child: Image.asset('assets/images/icon/icon.png'),
            ),
          ),
        ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                controller.setSearchTerm('');
                setState(() => _isSearching = false);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: !hasAnyNotes
                  ? null
                  : () => setState(() => _isSearching = true),
            ),
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            onPressed: _showFoldersDialog,
            tooltip: l10n.folders,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showViewOptions,
            tooltip: l10n.viewOptions,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(context.watch<ThemeProvider>().getThemeIcon()),
              onPressed: () => context.read<ThemeProvider>().toggleTheme(),
              tooltip: l10n.toggleTheme,
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) => Transform.rotate(
          angle: _fabAnimation.value,
          child: child,
        ),
        child: FloatingActionButton(
          onPressed: _addNote,
          child: const Icon(Icons.add),
        ),
      ),
      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Folder filter chip bar
                if (controller.selectedFolderId != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.folder,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          controller.selectedFolderId ==
                                  NotesController.unfiledFolderId
                              ? l10n.unfiled
                              : controller.getFolderName(
                                      controller.selectedFolderId) ??
                                  l10n.unknown,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () => controller.setSelectedFolder(null),
                          icon: Icon(
                            Icons.close,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: l10n.clearFolderFilter,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: notes.isEmpty
                      ? EmptyState(
                          isSearching:
                              _isSearching || controller.searchTerm.isNotEmpty,
                        )
                      : NoteList(
                          controller: controller,
                          notes: notes,
                          showTags: controller.showTags,
                          showContent: controller.showContent,
                        ),
                ),
              ],
            ),
    );
  }
}

/// A dialog with a search box that lets the user pick a language.
class _LanguagePickerDialog extends StatefulWidget {
  final String? currentTag;
  final Map<String, String> localeDisplayNames;
  final String systemDefaultLabel;
  final String searchHintLabel;

  const _LanguagePickerDialog({
    required this.currentTag,
    required this.localeDisplayNames,
    required this.systemDefaultLabel,
    required this.searchHintLabel,
  });

  @override
  State<_LanguagePickerDialog> createState() => _LanguagePickerDialogState();
}

class _LanguagePickerDialogState extends State<_LanguagePickerDialog> {
  final _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _filter = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build filtered list of locales
    final allLocales = AppLocalizations.supportedLocales;
    final filtered = _filter.isEmpty
        ? allLocales
        : allLocales.where((locale) {
            final tag = _HomePageState._localeTag(locale);
            final name = (widget.localeDisplayNames[tag] ?? tag).toLowerCase();
            return name.contains(_filter) ||
                tag.toLowerCase().contains(_filter);
          }).toList();

    final showSystemDefault = _filter.isEmpty ||
        widget.systemDefaultLabel.toLowerCase().contains(_filter);

    return AlertDialog(
      title: TextField(
        controller: _searchCtrl,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.searchHintLabel,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (showSystemDefault)
              _buildTile(
                label: widget.systemDefaultLabel,
                isSelected: widget.currentTag == null,
                onTap: () => Navigator.of(context)
                    .pop(_HomePageState._sentinelSystemDefault),
              ),
            ...filtered.map((locale) {
              final tag = _HomePageState._localeTag(locale);
              return _buildTile(
                label: widget.localeDisplayNames[tag] ?? tag,
                isSelected: tag == widget.currentTag,
                onTap: () => Navigator.of(context).pop(locale),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(label),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      onTap: onTap,
    );
  }
}
