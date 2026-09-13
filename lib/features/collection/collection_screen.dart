import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/media_asset.dart';
import '../../services/library_controller.dart';
import '../../services/media_actions.dart';
import '../../services/selection_controller.dart';
import '../../widgets/asset_grid.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/selection_toolbar.dart';
import '../viewer/viewer_screen.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({
    super.key,
    required this.title,
    required this.assets,
    this.subtitle,
    this.heroPrefix,
  });

  final String title;
  final String? subtitle;
  final List<MediaAsset> assets;
  final String? heroPrefix;

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<SelectionController>();
    final library = context.watch<LibraryController>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (subtitle != null)
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
      body: assets.isEmpty
          ? EmptyState(
              title: 'Nothing here yet',
              message: 'This collection is computed from photos currently on the device.',
            )
          : Stack(
              children: [
                AssetGrid(
                  assets: assets,
                  heroPrefix: heroPrefix ?? title,
                  onOpen: (asset) => openViewer(context, assets, asset.id),
                ),
                if (selection.isActive)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SelectionToolbar(
                      count: selection.count,
                      onClear: selection.clear,
                      onShare: () =>
                          MediaActions.share(context, library, selection.ids),
                      onFavorite: () =>
                          MediaActions.favoriteMany(library, selection.ids),
                      onDelete: () => MediaActions.delete(
                        context,
                        library,
                        selection,
                        selection.ids,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

void openViewer(BuildContext context, List<MediaAsset> assets, String id) {
  final index = assets.indexWhere((asset) => asset.id == id);
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondary) {
        return FadeTransition(
          opacity: animation,
          child: ViewerScreen(
            assets: assets,
            initialIndex: index < 0 ? 0 : index,
          ),
        );
      },
    ),
  );
}
