import 'package:flutter/material.dart';

import '../core/theme/luma_colors.dart';
import '../core/theme/luma_tokens.dart';
import '../core/utilities/formatters.dart';
import 'glass_surface.dart';

class SelectionToolbar extends StatelessWidget {
  const SelectionToolbar({
    super.key,
    required this.count,
    required this.onClear,
    this.onShare,
    this.onFavorite,
    this.onDelete,
    this.onMore,
  });

  final int count;
  final VoidCallback onClear;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          LumaTokens.space16,
          0,
          LumaTokens.space16,
          LumaTokens.space12,
        ),
        child: LumaGlass(
          borderRadius: BorderRadius.circular(LumaTokens.radiusSheet),
          padding: const EdgeInsets.symmetric(
            horizontal: LumaTokens.space8,
            vertical: LumaTokens.space4,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Cancel',
              ),
              Expanded(
                child: Text(
                  formatCount(count, 'selected', 'selected'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: onShare,
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: 'Share',
              ),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(Icons.favorite_border_rounded, color: colors.accent),
                tooltip: 'Favorite',
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, color: colors.danger),
                tooltip: 'Delete',
              ),
              if (onMore != null)
                IconButton(
                  onPressed: onMore,
                  icon: const Icon(Icons.more_horiz_rounded),
                  tooltip: 'More',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
