import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/data_export.dart';

/// Shown when startup fails, for example because a migration could not run.
///
/// It always offers a retry and a way to copy whatever data is still readable
/// to the clipboard, so the user is never stuck on a blank screen with no way
/// to recover their notes.
class StartupFailureScreen extends StatefulWidget {
  const StartupFailureScreen({
    required this.error,
    required this.onRetry,
    super.key,
  });

  final Object error;
  final Future<void> Function() onRetry;

  @override
  State<StartupFailureScreen> createState() => _StartupFailureScreenState();
}

class _StartupFailureScreenState extends State<StartupFailureScreen> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      await widget.onRetry();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  Future<void> _copyBackup() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await Clipboard.setData(ClipboardData(text: DataExport.buildBackup()));
      messenger?.showSnackBar(SnackBar(content: Text(l10n.backupCopied)));
    } catch (e) {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.backupFailed('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.startupError(widget.error.toString()),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _retrying ? null : _retry,
                  icon: _retrying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _copyBackup,
                  icon: const Icon(Icons.copy_all),
                  label: Text(l10n.copyBackup),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
