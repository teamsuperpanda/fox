import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/note_detail_page.dart';
import 'package:fox/providers/locale_provider.dart';
import 'package:fox/providers/theme_provider.dart';
import 'package:fox/services/constants.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:fox/services/settings_service.dart';
import 'package:fox/services/umami_service.dart';
import 'package:fox/widgets/dialogs.dart';
import 'package:fox/widgets/empty_state.dart';
import 'package:fox/widgets/folders_dialog.dart';
import 'package:fox/widgets/note_list.dart';
import 'package:fox/widgets/view_options_sheet.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {required this.controller, this.useGoogleFonts = true, super.key});
  final NotesController controller;
  final bool useGoogleFonts;

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
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UmamiService>().trackPageView('/home');
    });
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
      final term = _searchController.text;
      controller.setSearchTerm(term);
      _searchDebounce?.cancel();
      if (term.isNotEmpty) {
        _searchDebounce = Timer(const Duration(milliseconds: 500), () {
          context
              .read<UmamiService>()
              .track('search_perform', data: {'term': term});
        });
      }
    });
    // Kick off the FAB wiggle after the first frame so it doesn't block
    // pumpAndSettle in tests (a repeating animation never "settles").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && controller.fabAnimation) {
        unawaited(_fabController.repeat(reverse: true));
      }
    });
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    _animationController.dispose();
    _fabController.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      if (controller.fabAnimation) {
        if (!_fabController.isAnimating) {
          unawaited(_fabController.repeat(reverse: true));
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
        unawaited(_animationController.forward(from: 0));
      } else {
        unawaited(_animationController.reverse(from: 1));
      }
    });
  }

  Future<void> _addNote() async {
    final result = await Navigator.of(context).push<NoteDetailResult>(
      MaterialPageRoute(
        builder: (_) => NoteDetailPage(
          controller: controller,
        ),
      ),
    );
    if (!mounted) return;
    if (result != null && result.changed) {
      if (result.deleted) {
        showUndoDeleteSnackBar(context, controller);
      }
      setState(() {});
    }
  }

  Future<void> _showFoldersDialog() async {
    await showDialog(
      context: context,
      builder: (context) => FoldersDialog(controller: controller),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showViewOptions() async {
    final l10n = AppLocalizations.of(context);
    late final SettingsService settingsService;
    try {
      settingsService = SettingsService();
      settingsService.getSettings();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.startupError(e.toString()))),
        );
      }
      return;
    }

    context
        .read<UmamiService>()
        .track('view_option_change', data: {'action': 'open'});

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => ViewOptionsSheet(
        controller: controller,
        settingsService: settingsService,
        themeProvider: context.read<ThemeProvider>(),
        localeProvider: context.read<LocaleProvider>(),
        umamiService: context.read<UmamiService>(),
        accentColorOptions: accentColorOptions,
        useGoogleFonts: widget.useGoogleFonts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notes = controller.notes;
    final hasAnyNotes = controller.hasNotes;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Semantics(
                label: 'Search notes',
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    border: InputBorder.none,
                  ),
                ),
              )
            : MediaQuery.of(context).size.width <= 320
                ? null
                : Text(l10n.appTitle),
        centerTitle: true,
        leading: GestureDetector(
          onTap: _toggleRotation,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: RotationTransition(
              turns:
                  Tween<double>(begin: 0, end: 1).animate(_animationController),
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
            Semantics(
              label: 'Search',
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: !hasAnyNotes
                    ? null
                    : () {
                        context.read<UmamiService>().track('search_activation');
                        setState(() => _isSearching = true);
                      },
              ),
            ),
          Semantics(
            label: l10n.folders,
            child: IconButton(
              icon: const Icon(Icons.folder_outlined),
              onPressed: _showFoldersDialog,
              tooltip: l10n.folders,
            ),
          ),
          Semantics(
            label: l10n.viewOptions,
            child: IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showViewOptions,
              tooltip: l10n.viewOptions,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Semantics(
              label: l10n.toggleTheme,
              child: IconButton(
                icon: Icon(context.watch<ThemeProvider>().getThemeIcon()),
                onPressed: () {
                  context.read<UmamiService>().track('theme_change');
                  unawaited(context.read<ThemeProvider>().toggleTheme());
                },
                tooltip: l10n.toggleTheme,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: 'Add note',
        child: AnimatedBuilder(
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
      ),
      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Folder filter chip bar
                if (controller.selectedFolderId != null)
                  Semantics(
                    label: 'Folder filter',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            controller.selectedFolderId ==
                                    AppConstants.unfiledFolderId
                                ? l10n.unfiled
                                : controller.getFolderName(
                                      controller.selectedFolderId,
                                    ) ??
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
