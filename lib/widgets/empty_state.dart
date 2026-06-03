import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.isSearching = false});

  /// When `true`, the widget shows a "no results" message instead of the
  /// default "no notes yet" message.
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.notes,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: isSearching ? l10n.noNotesMatchSearch : l10n.noNotesYet,
              child: Text(
                isSearching ? l10n.noNotesMatchSearch : l10n.noNotesYet,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
