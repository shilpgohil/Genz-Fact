import 'package:flutter/material.dart';

import '../core/theme/luma_colors.dart';
import '../core/theme/luma_tokens.dart';
import 'glass_surface.dart';

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    final textColor = filled
        ? (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1916)
              : colors.surface)
        : (destructive ? colors.danger : colors.textPrimary);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: LumaTokens.iconSm, color: textColor),
          const SizedBox(width: LumaTokens.space8),
        ],
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: textColor),
        ),
      ],
    );

    if (filled) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: LumaTokens.tapMin),
        child: Material(
          color: destructive ? colors.danger : colors.accent,
          borderRadius: BorderRadius.circular(LumaTokens.radiusPill),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(LumaTokens.radiusPill),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LumaTokens.space20,
                vertical: LumaTokens.space12,
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    return LumaGlass(
      borderRadius: BorderRadius.circular(LumaTokens.radiusPill),
      padding: const EdgeInsets.symmetric(
        horizontal: LumaTokens.space16,
        vertical: LumaTokens.space10,
      ),
      child: InkWell(onTap: onPressed, child: child),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: LumaTokens.tapMin,
      height: LumaTokens.tapMin,
      child: LumaGlass(
        borderRadius: BorderRadius.circular(LumaTokens.radiusPill),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: LumaTokens.iconMd),
          tooltip: tooltip,
        ),
      ),
    );
    return button;
  }
}
