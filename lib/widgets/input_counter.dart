import 'package:flutter/material.dart';

/// Counter for a length-limited field. Returns null until the field is close
/// to its limit, so the counter only appears when it is useful.
Widget? inputCounter(
  BuildContext context, {
  required int currentLength,
  required bool isFocused,
  required int? maxLength,
}) {
  final limit = maxLength;
  if (limit == null || currentLength <= limit * 0.8) return null;
  final over = currentLength > limit;
  return Text(
    '$currentLength/$limit',
    style: over
        ? TextStyle(color: Theme.of(context).colorScheme.error)
        : Theme.of(context).textTheme.bodySmall,
  );
}
