import 'package:flutter/material.dart';

import '../core/theme/luma_colors.dart';
import '../core/theme/luma_tokens.dart';
import 'glass_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.photo_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LumaTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: colors.accent),
            const SizedBox(height: LumaTokens.space16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: LumaTokens.space8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: LumaTokens.space20),
              GlassButton(
                label: actionLabel!,
                filled: true,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
