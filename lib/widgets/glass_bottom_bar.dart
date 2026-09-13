import 'package:flutter/material.dart';

import '../core/theme/luma_colors.dart';
import '../core/theme/luma_tokens.dart';
import 'glass_surface.dart';

class GlassBottomBarItem {
  const GlassBottomBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class GlassBottomBar extends StatelessWidget {
  const GlassBottomBar({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
  });

  final List<GlassBottomBarItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        LumaTokens.space16,
        0,
        LumaTokens.space16,
        LumaTokens.space12,
      ),
      child: LumaGlass(
        borderRadius: BorderRadius.circular(LumaTokens.radiusSheet),
        padding: const EdgeInsets.symmetric(
          horizontal: LumaTokens.space8,
          vertical: LumaTokens.space8,
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _Item(
                  item: items[i],
                  selected: i == index,
                  accent: colors.accent,
                  muted: colors.textTertiary,
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.item,
    required this.selected,
    required this.accent,
    required this.muted,
    required this.onTap,
  });

  final GlassBottomBarItem item;
  final bool selected;
  final Color accent;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? accent : muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LumaTokens.radiusCard),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LumaTokens.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              color: color,
              size: LumaTokens.iconMd,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
