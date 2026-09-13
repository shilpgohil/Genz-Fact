import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/luma_tokens.dart';
import '../../core/utilities/formatters.dart';
import '../../models/media_asset.dart';
import '../../services/category_engine.dart';
import '../../services/library_controller.dart';
import '../collection/collection_screen.dart';
import '../duplicates/duplicates_screen.dart';

class CleanupScreen extends StatelessWidget {
  const CleanupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final assets = library.visibleAssets;
    final screenshots = screenshotAssets(assets);
    final large = largeAssets(assets);
    final duplicates = library.duplicateGroups;
    final duplicateCount = duplicates.fold<int>(
      0,
      (sum, g) => sum + g.items.length,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cleanup')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            'Luma never deletes on its own. These are suggestions based on metadata already on the device.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: LumaTokens.space20),
          _Row(
            title: 'Duplicates',
            detail: duplicateCount == 0
                ? 'None found yet'
                : formatCount(duplicateCount, 'candidate'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const DuplicatesScreen()),
            ),
          ),
          _Row(
            title: 'Screenshots',
            detail: screenshots.isEmpty
                ? 'None detected'
                : '${formatCount(screenshots.length, 'item')} · ${formatBytes(_sum(screenshots))}',
            onTap: screenshots.isEmpty
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CollectionScreen(
                        title: 'Screenshots',
                        assets: screenshots,
                      ),
                    ),
                  ),
          ),
          _Row(
            title: 'Large files',
            detail: large.isEmpty
                ? library.sizing
                      ? 'Still measuring sizes…'
                      : 'None above the size threshold'
                : '${formatCount(large.length, 'item')} · ${formatBytes(_sum(large))}',
            onTap: large.isEmpty
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CollectionScreen(title: 'Large files', assets: large),
                    ),
                  ),
          ),
          _Row(
            title: 'Videos',
            detail: formatCount(videoAssets(assets).length, 'video'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => CollectionScreen(
                  title: 'Videos',
                  assets: videoAssets(assets),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? _sum(List<MediaAsset> items) {
    var total = 0;
    var any = false;
    for (final item in items) {
      final size = item.fileSizeBytes;
      if (size != null) {
        any = true;
        total += size;
      }
    }
    return any ? total : null;
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.detail, this.onTap});

  final String title;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(detail),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
