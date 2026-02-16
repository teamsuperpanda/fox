import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'note_detail_page.dart';
import 'providers/theme_provider.dart';
import 'services/notes_controller.dart';
import 'services/settings_service.dart';
import 'widgets/empty_state.dart';
import 'widgets/note_list.dart';

class HomePage extends StatefulWidget {
  final NotesController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
  with TickerProviderStateMixin {
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
    
    // In tests the binding is AutomatedTestWidgetsFlutterBinding which schedules
    // continuous frames; avoid starting a repeating ticker there so tests can
    // settle. Start looping only in normal app runs.
    /*
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    if (!bindingName.contains('AutomatedTestWidgetsFlutterBinding')) {
      _fabController.repeat(reverse: true);
    }
    */
    // Performance improvement: Removed continuous animation loop to save battery
    // _fabController.forward(); // Moved to _onChanged to respect initial settings
    _searchController.addListener(() {
      controller.setSearchTerm(_searchController.text);
    });
    // Load settings after animation controllers are initialized
    _loadSettings();
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

  void _loadSettings() {
    try {
      final settingsService = SettingsService();
      controller.setShowTags(settingsService.getShowTags());
      controller.setShowContent(settingsService.getShowContent());
      controller.setAlternatingColors(settingsService.getAlternatingColors());
      controller.setFabAnimation(settingsService.getFabAnimation());
    } catch (e) {
      // Settings box may not be initialized in tests
      controller.setShowTags(true);
      controller.setShowContent(true);
      controller.setAlternatingColors(false);
      controller.setFabAnimation(false);
    }
    // Start animation if fabAnimation is enabled after loading settings
    if (controller.fabAnimation && !_fabController.isAnimating) {
      _fabController.repeat(reverse: true);
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
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => NoteDetailPage(
        controller: controller,
      ),
    ));
    if (changed == true) setState(() {});
  }

  void _showViewOptions() async {
    final settingsService = SettingsService();
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('View Options'),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sort By', style: Theme.of(context).textTheme.titleSmall),
                    ListTile(
                      title: const Text('Date (Newest First)'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(
                      controller.sortBy == SortBy.dateDesc
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: controller.sortBy == SortBy.dateDesc
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onTap: () {
                      controller.setSortBy(SortBy.dateDesc);
                      setDialogState(() {});
                    },
                  ),
                  ListTile(
                    title: const Text('Date (Oldest First)'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(
                      controller.sortBy == SortBy.dateAsc
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: controller.sortBy == SortBy.dateAsc
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onTap: () {
                      controller.setSortBy(SortBy.dateAsc);
                      setDialogState(() {});
                    },
                  ),
                  ListTile(
                    title: const Text('Title (A-Z)'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(
                      controller.sortBy == SortBy.titleAsc
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: controller.sortBy == SortBy.titleAsc
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onTap: () {
                      controller.setSortBy(SortBy.titleAsc);
                      setDialogState(() {});
                    },
                  ),
                  ListTile(
                    title: const Text('Title (Z-A)'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(
                      controller.sortBy == SortBy.titleDesc
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: controller.sortBy == SortBy.titleDesc
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onTap: () {
                      controller.setSortBy(SortBy.titleDesc);
                      setDialogState(() {});
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Show Tags'),
                    value: controller.showTags,
                    onChanged: (value) async {
                      controller.setShowTags(value);
                      await settingsService.setShowTags(value);
                      setDialogState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show Note Previews'),
                    value: controller.showContent,
                    onChanged: (value) async {
                      controller.setShowContent(value);
                      await settingsService.setShowContent(value);
                      setDialogState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Alternating Row Colors'),
                    value: controller.alternatingColors,
                    onChanged: (value) async {
                      controller.setAlternatingColors(value);
                      await settingsService.setAlternatingColors(value);
                      setDialogState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Animate Add Button'),
                    value: controller.fabAnimation,
                    onChanged: (value) async {
                      controller.setFabAnimation(value);
                      await settingsService.setFabAnimation(value);
                      setDialogState(() {});
                    },
                  ),
                ],
              ),
            ),
            ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = controller.notes;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              )
            : const Text('Fox'),
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
                  setState(() => _isSearching = false);
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: notes.isEmpty
                    ? null
                    : () => setState(() => _isSearching = true),
              ),
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: notes.isEmpty ? null : _showViewOptions,
              tooltip: 'View options',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(context.watch<ThemeProvider>().getThemeIcon()),
                onPressed: () => context.read<ThemeProvider>().toggleTheme(),
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
          : notes.isEmpty
              ? const EmptyState()
              : NoteList(
                  controller: controller,
                  notes: notes,
                  showTags: controller.showTags,
                  showContent: controller.showContent,
                ),
    );
  }
}

