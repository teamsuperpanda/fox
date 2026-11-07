import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/models/note_colors.dart';
import 'package:fox/models/search_filters.dart';
import 'package:fox/services/notes_controller.dart';
import 'package:intl/intl.dart';

/// Row of search scope and filter chips plus the current result count.
///
/// The folder scope chip only appears when a folder filter is active, because
/// browsing without a folder already sees every note.
class SearchFiltersBar extends StatelessWidget {
  const SearchFiltersBar({required this.controller, super.key});

  final NotesController controller;

  static final DateFormat _dateFormat = DateFormat.yMMMd();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _buildBar(context),
    );
  }

  Widget _buildBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = controller.filters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (controller.selectedFolderId != null) ...[
                _scopeChip(l10n),
                const SizedBox(width: 8),
              ],
              _pinnedChip(l10n, filters),
              const SizedBox(width: 8),
              _tagChip(l10n, filters),
              const SizedBox(width: 8),
              _colorChip(context, l10n, filters),
              const SizedBox(width: 8),
              _dateChip(context, l10n, filters),
              if (filters.isActive) ...[
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.filter_alt_off_outlined, size: 16),
                  label: Text(l10n.clearFilters),
                  onPressed: controller.clearFilters,
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
          child: Text(
            l10n.searchResultCount(controller.notes.length),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  Widget _scopeChip(AppLocalizations l10n) {
    final inFolder = controller.searchScope == SearchScope.folder;
    return FilterChip(
      avatar: Icon(inFolder ? Icons.folder_outlined : Icons.public, size: 16),
      label: Text(inFolder ? l10n.searchScopeFolder : l10n.searchScopeAll),
      selected: inFolder,
      onSelected: (selected) => controller.setSearchScope(
        selected ? SearchScope.folder : SearchScope.all,
      ),
    );
  }

  Widget _pinnedChip(AppLocalizations l10n, SearchFilters filters) {
    return FilterChip(
      avatar: const Icon(Icons.push_pin_outlined, size: 16),
      label: Text(l10n.filterPinned),
      selected: filters.pinnedOnly,
      onSelected: (selected) =>
          controller.setFilters(filters.copyWith(pinnedOnly: selected)),
    );
  }

  Widget _tagChip(
    AppLocalizations l10n,
    SearchFilters filters,
  ) {
    final tag = filters.tag;
    if (tag != null) {
      return InputChip(
        avatar: const Icon(Icons.sell_outlined, size: 16),
        label: Text(tag),
        deleteButtonTooltipMessage: l10n.clearFilters,
        onDeleted: () =>
            controller.setFilters(filters.copyWith(clearTag: true)),
      );
    }
    final tags = controller.allTags;
    return PopupMenuButton<String>(
      enabled: tags.isNotEmpty,
      tooltip: l10n.filterTag,
      onSelected: (value) =>
          controller.setFilters(filters.copyWith(tag: value)),
      itemBuilder: (context) => [
        for (final value in tags)
          PopupMenuItem<String>(value: value, child: Text(value)),
      ],
      child: Chip(
        avatar: const Icon(Icons.sell_outlined, size: 16),
        label: Text(l10n.filterTag),
      ),
    );
  }

  Widget _colorChip(
    BuildContext context,
    AppLocalizations l10n,
    SearchFilters filters,
  ) {
    final color = filters.color;
    if (color != null) {
      return InputChip(
        avatar: _ColorDot(hex: color),
        label: Text(l10n.filterColor),
        deleteButtonTooltipMessage: l10n.clearFilters,
        onDeleted: () =>
            controller.setFilters(filters.copyWith(clearColor: true)),
      );
    }
    return ActionChip(
      avatar: const Icon(Icons.palette_outlined, size: 16),
      label: Text(l10n.filterColor),
      onPressed: () => _pickColor(context, l10n),
    );
  }

  Widget _dateChip(
    BuildContext context,
    AppLocalizations l10n,
    SearchFilters filters,
  ) {
    final from = filters.from;
    final to = filters.to;
    if (from != null || to != null) {
      final start = from == null ? '' : _dateFormat.format(from);
      final end = to == null ? '' : _dateFormat.format(to);
      return InputChip(
        avatar: const Icon(Icons.date_range, size: 16),
        label: Text('$start - $end'),
        deleteButtonTooltipMessage: l10n.clearFilters,
        onDeleted: () =>
            controller.setFilters(filters.copyWith(clearDates: true)),
      );
    }
    return ActionChip(
      avatar: const Icon(Icons.date_range, size: 16),
      label: Text(l10n.filterDateRange),
      onPressed: () => _pickDateRange(context, l10n),
    );
  }

  Future<void> _pickColor(BuildContext context, AppLocalizations l10n) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.filterColor),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final hex
                    in noteColorOptions.where((color) => color.isNotEmpty))
                  InkWell(
                    onTap: () => Navigator.of(context).pop(hex),
                    customBorder: const CircleBorder(),
                    child: Semantics(
                      button: true,
                      label: l10n.filterColor,
                      child: _ColorDot(hex: hex, size: 32),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected == null || !context.mounted) return;
    controller.setFilters(controller.filters.copyWith(color: selected));
  }

  Future<void> _pickDateRange(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: l10n.filterDateRange,
    );
    if (range == null || !context.mounted) return;
    controller.setFilters(
      controller.filters.copyWith(
        from: DateTime(range.start.year, range.start.month, range.start.day),
        to: DateTime(
          range.end.year,
          range.end.month,
          range.end.day,
          23,
          59,
          59,
          999,
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.hex, this.size = 16});

  final String hex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(hex) ?? Theme.of(context).colorScheme.outline;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
