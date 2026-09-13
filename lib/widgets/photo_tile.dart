import 'package:flutter/material.dart';

import '../core/theme/luma_colors.dart';
import '../core/utilities/formatters.dart';
import '../models/media_asset.dart';

class PhotoTile extends StatelessWidget {
  const PhotoTile({
    super.key,
    required this.asset,
    this.image,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.selectionMode = false,
    this.heroTag,
  });

  final MediaAsset asset;
  final ImageProvider? image;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool selectionMode;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    Widget content = image == null
        ? ColoredBox(color: colors.tilePlaceholder)
        : Image(
            image: image!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            filterQuality: FilterQuality.low,
            errorBuilder: (_, _, _) =>
                ColoredBox(color: colors.tilePlaceholder),
          );

    if (heroTag != null) {
      content = Hero(tag: heroTag!, child: content);
    }

    return Semantics(
      button: true,
      image: true,
      selected: selected,
      child: Material(
        color: colors.tilePlaceholder,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            fit: StackFit.expand,
            children: [
              content,
              if (asset.isVideo)
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: _Badge(icon: Icons.play_arrow_rounded),
                  ),
                ),
              if (asset.isVideo)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      formatDuration(asset.duration),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        shadows: const [
                          Shadow(blurRadius: 8, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
              if (asset.isFavorite && !selectionMode)
                const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 14,
                      color: Color(0xFFE4C39A),
                    ),
                  ),
                ),
              if (selectionMode)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 22,
                      color: selected ? colors.accent : Colors.white70,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 16, color: Colors.white);
  }
}
