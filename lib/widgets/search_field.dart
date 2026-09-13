import 'package:flutter/material.dart';

import '../core/theme/luma_colors.dart';
import '../core/theme/luma_tokens.dart';

class LumaSearchField extends StatelessWidget {
  const LumaSearchField({
    super.key,
    required this.controller,
    this.onChanged,
    this.hint = 'August, videos, yesterday…',
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge,
      cursorColor: colors.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyMedium,
        prefixIcon: Icon(Icons.search_rounded, color: colors.textTertiary),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LumaTokens.radiusPill),
          borderSide: BorderSide(color: colors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LumaTokens.radiusPill),
          borderSide: BorderSide(color: colors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LumaTokens.radiusPill),
          borderSide: BorderSide(color: colors.accent.withValues(alpha: 0.6)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LumaTokens.space16,
          vertical: LumaTokens.space12,
        ),
      ),
    );
  }
}
