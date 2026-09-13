import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/luma_colors.dart';
import '../../core/theme/luma_tokens.dart';
import '../../core/utilities/formatters.dart';
import '../../models/duplicate_group.dart';
import '../../services/library_controller.dart';
import '../../services/media_actions.dart';
import '../../services/selection_controller.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/photo_tile.dart';
import '../collection/collection_screen.dart';

class DuplicatesScreen extends StatelessWidget {
  const DuplicatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final groups = library.duplicateGroups;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplicates'),
        actions: [
          TextButton(
            onPressed: library.scanningSimilar ? null : library.scanSimilar,
            child: Text(library.scanningSimilar ? 'Scanning…' : 'Scan similar'),
          ),
        ],
      ),
      body: groups.isEmpty
          ? EmptyState(
              icon: Icons.copy_all_outlined,
              title: 'No duplicate groups',
              message: 'Exact matches use file size and dimensions. Scan similar photos to look for near-duplicates from thumbnails. Nothing is deleted automatically.',
              actionLabel: library.scanningSimilar ? null : 'Scan similar',
              onAction: library.scanSimilar,
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: groups.length,
              itemBuilder: (context, i) => _GroupCard(group: groups[i]),
            ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});
  final DuplicateGroup group;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final colors = context.luma;
    final keep = group.recommendedKeep;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LumaTokens.space20,
        LumaTokens.space8,
        LumaTokens.space20,
        LumaTokens.space12,
      ),
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
              Text(
                group.kind == DuplicateKind.exact
                    ? 'Exact match'
                    : 'Similar photos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${group.items.length} items · recoverable ${formatBytes(group.reclaimableBytes)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: LumaTokens.space12),
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: group.items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final asset = group.items[i];
                    return SizedBox(
                      width: 72,
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: PhotoTile(
                                asset: asset,
                                image: library.thumb(asset.id, size: 160),
                                onTap: () =>
                                    openViewer(context, group.items, asset.id),
                              ),
                            ),
                          ),
                          Text(
                            asset.id == keep.id
                                ? 'Keep'
                                : formatBytes(asset.fileSizeBytes),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final extras = group.items
                        .where((a) => a.id != keep.id)
                        .map((a) => a.id);
                    await MediaActions.delete(
                      context,
                      library,
                      context.read<SelectionController>(),
                      extras,
                    );
                  },
                  child: Text(
                    'Review extras for delete',
                    style: TextStyle(color: colors.danger),
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
