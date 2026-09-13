import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/luma_colors.dart';
import '../core/theme/luma_theme.dart';
import '../core/theme/luma_tokens.dart';
import '../features/shell/app_shell.dart';
import '../models/app_models.dart';
import '../services/library_controller.dart';
import '../services/settings_store.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_surface.dart';
import '../widgets/loading_state.dart';
import '../widgets/permission_panel.dart';

class LumaApp extends StatelessWidget {
  const LumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>().settings;
    final themeMode = switch (settings.theme) {
      ThemePreference.system => ThemeMode.system,
      ThemePreference.light => ThemeMode.light,
      ThemePreference.dark => ThemeMode.dark,
    };

    return SettingsStoreProvider(
      store: context.read<SettingsStore>(),
      child: MaterialApp(
        title: 'Luma',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: lumaTheme(brightness: Brightness.light),
        darkTheme: lumaTheme(brightness: Brightness.dark),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    return switch (library.phase) {
      LibraryPhase.booting => const _Launch(),
      LibraryPhase.needsPermission => Scaffold(
        body: PermissionPanel(
          permission: library.permission,
          accessMode: library.library.accessMode,
          onAllow: library.permission == LumaPermission.limited
              ? () {
                  // Limited users can enter the app with the current selection.
                  library.loadLibrary();
                }
              : library.requestAccess,
          onOpenSettings: library.openSettings,
          onManageLimited: library.manageLimitedAccess,
        ),
      ),
      LibraryPhase.error => Scaffold(
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Library unavailable',
          message:
              library.errorMessage ??
              'Something went wrong while reading photos.',
          actionLabel: 'Try again',
          onAction: library.requestAccess,
        ),
      ),
      LibraryPhase.indexing ||
      LibraryPhase.ready ||
      LibraryPhase.empty => const AppShell(),
    };
  }
}

class _Launch extends StatelessWidget {
  const _Launch();

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    return Scaffold(
      backgroundColor: colors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Luma', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: LumaTokens.space12),
            Text(
              'A quieter gallery',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: LumaTokens.space32),
            const LoadingState(label: ''),
          ],
        ),
      ),
    );
  }
}
