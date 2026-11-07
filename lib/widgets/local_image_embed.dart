import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:fox/l10n/app_localizations.dart';
import 'package:fox/services/image_store.dart';

/// Renders `image` embeds from files the app copied into its documents
/// directory. The Delta stores a relative path, resolved here.
class LocalImageEmbedBuilder extends EmbedBuilder {
  const LocalImageEmbedBuilder(this.store);

  final ImageStore store;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final data = embedContext.node.value.data;
    final provider = data is String ? store.imageProvider(data) : null;
    final maxWidth = MediaQuery.sizeOf(context).width;

    if (provider == null) {
      return _MissingImage(embedContext.textStyle);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Image(
          image: provider,
          fit: BoxFit.contain,
          errorBuilder: (context, _, __) => _MissingImage(
            embedContext.textStyle,
          ),
        ),
      ),
    );
  }
}

class _MissingImage extends StatelessWidget {
  const _MissingImage(this.textStyle);
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: textStyle.fontSize ?? 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.imageUnavailable,
            style: textStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
