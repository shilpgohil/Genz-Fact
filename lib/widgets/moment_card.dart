import 'package:flutter/material.dart';

import '../core/theme/luma_colors.dart';
import '../core/theme/luma_tokens.dart';
import '../models/media_moment.dart';
import 'photo_tile.dart';

class MomentCard extends StatelessWidget {
  const MomentCard({
    super.key,
    required this.moment,
    required this.imageFor,
    this.onTap,
  });

  final MediaMoment moment;
  final ImageProvider? Function(String id) imageFor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    final extras = moment.assets.skip(1).take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LumaTokens.space20,
        LumaTokens.space8,
        LumaTokens.space20,
        LumaTokens.space12,
      ),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(LumaTokens.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: moment.hero == null
                    ? ColoredBox(color: colors.tilePlaceholder)
                    : PhotoTile(
                        asset: moment.hero!,
                        image: imageFor(moment.hero!.id),
                        heroTag: 'moment-${moment.id}',
                      ),
              ),
              if (extras.isNotEmpty)
                SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      for (final asset in extras)
                        Expanded(
                          child: PhotoTile(
                            asset: asset,
                            image: imageFor(asset.id),
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moment.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (moment.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        moment.subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
