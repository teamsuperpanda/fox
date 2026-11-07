import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';

/// Asks for a passphrase used to encrypt an export.
///
/// Returns the passphrase, or null when the user cancels.
class ExportPassphraseDialog extends StatefulWidget {
  const ExportPassphraseDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const ExportPassphraseDialog(),
    );
  }

  static const int minLength = 8;

  @override
  State<ExportPassphraseDialog> createState() => _ExportPassphraseDialogState();
}

class _ExportPassphraseDialogState extends State<ExportPassphraseDialog> {
  final _passphrase = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _passphrase.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final value = _passphrase.text;
    if (value.length < ExportPassphraseDialog.minLength) {
      setState(() => _error = l10n.passphraseTooShort);
      return;
    }
    if (value != _confirm.text) {
      setState(() => _error = l10n.passphraseMismatch);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.encryptExport),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.encryptExportWarning),
            const SizedBox(height: 16),
            TextField(
              controller: _passphrase,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.passphrase),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirm,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.confirmPassphrase),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.encrypt),
        ),
      ],
    );
  }
}
