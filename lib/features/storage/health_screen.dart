import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/luma_colors.dart';
import '../../core/theme/luma_tokens.dart';
import '../../core/utilities/formatters.dart';
import '../../services/library_controller.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final health = library.health;
    final colors = context.luma;

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery health')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            'A quiet reading of this library — not an analytics dashboard.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: LumaTokens.space24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Stat(label: 'Photos', value: '${health.photoCount}'),
              _Stat(label: 'Videos', value: '${health.videoCount}'),
              _Stat(label: 'Favorites', value: '${health.favoriteCount}'),
              _Stat(label: 'Screenshots', value: '${health.screenshotCount}'),
              _Stat(label: 'Recent', value: '${health.recentCount}'),
              _Stat(
                label: 'Duplicate candidates',
                value: '${health.duplicateCandidateCount}',
              ),
              _Stat(label: 'Large items', value: '${health.largeCount}'),
              _Stat(
                label: health.sizesComplete ? 'Storage' : 'Storage (known)',
                value: formatBytes(health.knownBytes),
              ),
            ],
          ),
          const SizedBox(height: LumaTokens.space24),
          if (!health.sizesComplete)
            Text(
              library.sizing
                  ? 'Measuring remaining file sizes in the background…'
                  : 'Some items have no size yet, so the storage total is incomplete — not estimated.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    return SizedBox(
      width: 156,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(LumaTokens.radiusCard),
        ),
        child: Padding(
          padding: const EdgeInsets.all(LumaTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
