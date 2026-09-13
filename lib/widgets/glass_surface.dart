import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/luma_colors.dart';
import '../core/theme/luma_tokens.dart';
import '../models/app_models.dart';
import '../services/settings_store.dart';

class LumaGlass extends StatelessWidget {
  const LumaGlass({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    var level = GlassLevel.reduced;
    try {
      level = context.watch<SettingsStore>().settings.glass;
    } catch (_) {}

    final radius = borderRadius ?? BorderRadius.circular(LumaTokens.radiusCard);
    final blur = switch (level) {
      GlassLevel.off => 0.0,
      GlassLevel.reduced => LumaTokens.blurReduced,
      GlassLevel.full => LumaTokens.blurFull,
    };

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: blur == 0
            ? colors.surface.withValues(alpha: 0.96)
            : colors.glassFill,
        borderRadius: radius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );

    if (blur == 0) return ClipRRect(borderRadius: radius, child: decorated);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: decorated,
      ),
    );
  }
}

class SettingsStoreProvider extends InheritedWidget {
  const SettingsStoreProvider({
    super.key,
    required this.store,
    required super.child,
  });

  final SettingsStore store;

  static SettingsStore? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SettingsStoreProvider>()
        ?.store;
  }

  @override
  bool updateShouldNotify(SettingsStoreProvider oldWidget) =>
      oldWidget.store != store;
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LumaGlass(
      padding: padding ?? const EdgeInsets.all(LumaTokens.space16),
      child: child,
    );
  }
}
