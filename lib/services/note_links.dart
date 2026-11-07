import 'package:flutter/material.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

typedef LinkLauncher = Future<bool> Function(Uri uri);

Future<bool> _launchExternal(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// Opens a link from a note. Web links open directly; any other scheme asks
/// for confirmation first. No network request is made inside the app.
Future<void> openNoteLink({
  required BuildContext context,
  required String rawUrl,
  LinkLauncher? launcher,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final uri = Uri.tryParse(rawUrl.trim());
  if (uri == null || uri.scheme.isEmpty) {
    messenger?.showSnackBar(
      SnackBar(content: Text(l10n.invalidUrl)),
    );
    return;
  }

  final isWeb = uri.scheme == 'http' || uri.scheme == 'https';
  if (!isWeb) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.openLinkTitle),
        content: Text(l10n.openLinkConfirm(rawUrl)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.openLinkAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
  }

  try {
    await (launcher ?? _launchExternal)(uri);
  } catch (e) {
    messenger?.showSnackBar(
      SnackBar(content: Text(l10n.errorOpeningLink(e.toString()))),
    );
  }
}
