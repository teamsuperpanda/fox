import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fox/data/locale_display_names.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/constants.dart';

class LanguagePickerDialog extends StatefulWidget {
  const LanguagePickerDialog({
    required this.currentTag,
    required this.systemDefaultLabel,
    required this.searchHintLabel,
    super.key,
  });

  static const sentinelSystemDefault = Locale('__system__');

  final String? currentTag;
  final String systemDefaultLabel;
  final String searchHintLabel;

  @override
  State<LanguagePickerDialog> createState() => _LanguagePickerDialogState();
}

class _LanguagePickerDialogState extends State<LanguagePickerDialog> {
  final _searchCtrl = TextEditingController();
  String _filter = '';
  Map<String, String> _displayNames = const {};

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _filter = _searchCtrl.text.toLowerCase());
    });
    unawaited(_loadNames());
  }

  Future<void> _loadNames() async {
    final names = await LocaleDisplayNames.load();
    if (mounted) setState(() => _displayNames = names);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const allLocales = AppLocalizations.supportedLocales;
    final filtered = _filter.isEmpty
        ? allLocales
        : allLocales.where((locale) {
            final tag = localeToTag(locale);
            final name = (_displayNames[tag] ?? tag).toLowerCase();
            return name.contains(_filter) ||
                tag.toLowerCase().contains(_filter);
          }).toList();

    final showSystemDefault = _filter.isEmpty ||
        widget.systemDefaultLabel.toLowerCase().contains(_filter);

    return AlertDialog(
      title: Semantics(
        label: 'Search languages',
        child: TextField(
          controller: _searchCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: widget.searchHintLabel,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
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
                    .pop(LanguagePickerDialog.sentinelSystemDefault),
              ),
            ...filtered.map((locale) {
              final tag = localeToTag(locale);
              return _buildTile(
                label: _displayNames[tag] ?? tag,
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
