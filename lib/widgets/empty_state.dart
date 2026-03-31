import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EmptyState extends StatelessWidget {
  /// When `true`, the widget shows a "no results" message instead of the
  /// default "no notes yet" message.
  final bool isSearching;

  const EmptyState({super.key, this.isSearching = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        isSearching ? l10n.noNotesMatchSearch : l10n.noNotesYet,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
