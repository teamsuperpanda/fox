import 'package:flutter/material.dart';

/// Single place for transient user feedback so every snackbar shares the same
/// duration, placement and error styling.
class FeedbackService {
  const FeedbackService();

  static const Duration duration = Duration(seconds: 5);

  /// Neutral confirmation. Only call this after the write actually succeeded.
  void success(BuildContext context, String message) {
    _show(
      context,
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  /// Error with an optional retry action.
  void error(
    BuildContext context,
    String message, {
    String? retryLabel,
    VoidCallback? onRetry,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    _show(
      context,
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: colorScheme.error,
        action: retryLabel != null && onRetry != null
            ? SnackBarAction(
                label: retryLabel,
                textColor: colorScheme.onError,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Undo affordance for a just-performed action.
  ///
  /// The snackbar is replaced rather than stacked, so two deletes can never
  /// leave an older "Undo" pointing at the newest removed note. It is hidden
  /// as soon as the undo runs, whether or not the note was still restorable.
  void undo(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required Future<bool> Function() onUndo,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: SnackBarAction(
            label: actionLabel,
            onPressed: () async {
              await onUndo();
              messenger.hideCurrentSnackBar();
            },
          ),
        ),
      );
  }

  void _show(BuildContext context, SnackBar snackBar) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(snackBar);
  }
}
