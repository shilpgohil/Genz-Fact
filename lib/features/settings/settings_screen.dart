import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/luma_tokens.dart';
import '../../models/app_models.dart';
import '../../services/library_controller.dart';
import '../../services/settings_store.dart';
import '../../widgets/glass_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final store = context.watch<SettingsStore>();
    final settings = store.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          const _Heading('Appearance'),
          _Choice(
            label: 'Theme',
            value: settings.theme.name,
            options: ThemePreference.values.map((e) => e.name).toList(),
            onSelected: (name) {
              final theme = ThemePreference.values.firstWhere(
                (e) => e.name == name,
              );
              store.update(settings.copyWith(theme: theme));
            },
          ),
          _Choice(
            label: 'Grid',
            value: settings.grid.name,
            options: GridDensity.values.map((e) => e.name).toList(),
            onSelected: (name) {
              final grid = GridDensity.values.firstWhere((e) => e.name == name);
              store.update(settings.copyWith(grid: grid));
            },
          ),
          _Choice(
            label: 'Glass',
            value: settings.glass.name,
            options: GlassLevel.values.map((e) => e.name).toList(),
            onSelected: (name) {
              final glass = GlassLevel.values.firstWhere((e) => e.name == name);
              store.update(settings.copyWith(glass: glass));
            },
          ),
          SwitchListTile(
            title: const Text('Reduce motion'),
            value: settings.reduceMotion,
            onChanged: (value) =>
                store.update(settings.copyWith(reduceMotion: value)),
          ),
          SwitchListTile(
            title: const Text('Include videos in Library'),
            value: settings.includeVideos,
            onChanged: (value) =>
                store.update(settings.copyWith(includeVideos: value)),
          ),
          const _Heading('Library'),
          ListTile(
            title: const Text('Permission'),
            subtitle: Text(
              library.isSessionLibrary
                  ? 'Browser session — photos stay in this tab'
                  : _permissionLabel(library.permission),
            ),
            trailing: library.isSessionLibrary
                ? TextButton(
                    onPressed: library.manageLimitedAccess,
                    child: const Text('Add'),
                  )
                : library.permission == LumaPermission.limited
                ? TextButton(
                    onPressed: library.manageLimitedAccess,
                    child: const Text('Manage'),
                  )
                : TextButton(
                    onPressed: library.openSettings,
                    child: const Text('System'),
                  ),
          ),
          ListTile(
            title: const Text('Refresh library'),
            subtitle: Text(
              library.indexing
                  ? 'Indexing ${library.indexedCount}…'
                  : '${library.assets.length} items indexed',
            ),
            onTap: library.loadLibrary,
          ),
          const _Heading('Privacy'),
          ListTile(
            title: Text(
              library.isSessionLibrary
                  ? 'Photos stay in this browser tab'
                  : 'Photos stay on this device',
            ),
            subtitle: Text(
              library.isSessionLibrary
                  ? 'Luma does not create an account or upload your library. Search and moments use metadata from the files you chose in this tab.'
                  : 'Luma does not create an account, upload your library, or talk to a Luma server. Search and moments use metadata already on the phone.',
            ),
          ),
          const _Heading('About'),
          ListTile(
            title: const Text('Luma'),
            subtitle: Text(
              library.isSessionLibrary
                  ? '1.0.0 · Local-first gallery · Web'
                  : '1.0.0 · Local-first gallery',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(LumaTokens.space20),
            child: GlassButton(
              label: library.isSessionLibrary
                  ? 'Choose photos'
                  : 'Request photo access',
              onPressed: library.isSessionLibrary
                  ? library.manageLimitedAccess
                  : library.requestAccess,
            ),
          ),
        ],
      ),
    );
  }

  String _permissionLabel(LumaPermission permission) {
    return switch (permission) {
      LumaPermission.authorized => 'Full access',
      LumaPermission.limited => 'Limited access',
      LumaPermission.denied => 'Denied',
      LumaPermission.restricted => 'Restricted',
      LumaPermission.notDetermined => 'Not determined',
      LumaPermission.unknown => 'Unknown',
    };
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          showDragHandle: true,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final option in options)
                    ListTile(
                      title: Text(option),
                      selected: option == value,
                      onTap: () => Navigator.pop(context, option),
                    ),
                ],
              ),
            );
          },
        );
        if (selected != null) onSelected(selected);
      },
    );
  }
}
