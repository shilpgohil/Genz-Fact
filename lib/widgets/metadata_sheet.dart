import 'package:flutter/material.dart';

import '../core/theme/luma_colors.dart';
import '../core/theme/luma_tokens.dart';
import '../core/utilities/formatters.dart';
import '../models/media_asset.dart';

Future<void> showMetadataSheet(BuildContext context, MediaAsset asset) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => MetadataSheet(asset: asset),
  );
}

class MetadataSheet extends StatelessWidget {
  const MetadataSheet({super.key, required this.asset});

  final MediaAsset asset;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    final rows = <(String, String)>[
      (
        'Type',
        asset.isVideo ? 'Video' : (asset.isScreenshot ? 'Screenshot' : 'Photo'),
      ),
      (
        'Captured',
        '${formatShortDate(asset.createdAt)} · ${formatTime(asset.createdAt)}',
      ),
      ('Dimensions', '${asset.width} × ${asset.height}'),
      ('Size', formatBytes(asset.fileSizeBytes)),
      if (asset.isVideo) ('Duration', formatDuration(asset.duration)),
      if (asset.title != null && asset.title!.isNotEmpty)
        ('Name', asset.title!),
      if (asset.mimeType != null) ('Format', asset.mimeType!),
      (
        'Location',
        asset.hasLocation ? 'Embedded coordinates on device' : 'Not available',
      ),
      ('Favorite', asset.isFavorite ? 'Yes' : 'No'),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          LumaTokens.space24,
          LumaTokens.space8,
          LumaTokens.space24,
          LumaTokens.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Info', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: LumaTokens.space16),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        row.$1,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: colors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: LumaTokens.space8),
            Text(
              'Coordinates are never sent anywhere. Luma does not look up place names.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
