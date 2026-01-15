import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'note_detail_page.dart';
import 'providers/theme_provider.dart';
import 'services/notes_controller.dart';
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
    _fabController.forward();
    _searchController.addListener(() {
      controller.setSearchTerm(_searchController.text);
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
    if (mounted) setState(() {});
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
            if (notes.isNotEmpty) ...[
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
                  onPressed: () => setState(() => _isSearching = true),
                ),
              PopupMenuButton<SortBy>(
                icon: const Icon(Icons.sort),
                onSelected: (sortBy) => controller.setSortBy(sortBy),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: SortBy.dateDesc,
                    child: Text('Date (Newest First)'),
                  ),
                  PopupMenuItem(
                    value: SortBy.dateAsc,
                    child: Text('Date (Oldest First)'),
                  ),
                  PopupMenuItem(
                    value: SortBy.titleAsc,
                    child: Text('Title (A-Z)'),
                  ),
                  PopupMenuItem(
                    value: SortBy.titleDesc,
                    child: Text('Title (Z-A)'),
                  ),
                ],
              ),
            ],
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
              : NoteList(controller: controller, notes: notes),
    );
  }
}

