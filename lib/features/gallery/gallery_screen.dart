import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/luma_tokens.dart';
import '../../core/utilities/formatters.dart';
import '../../models/app_models.dart';
import '../../services/date_grouping.dart';
import '../../services/library_controller.dart';
import '../../services/media_actions.dart';
import '../../services/selection_controller.dart';
import '../../widgets/asset_grid.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/selection_toolbar.dart';
import '../collection/collection_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final selection = context.watch<SelectionController>();
    final assets = library.visibleAssets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          if (library.indexing)
            const Padding(
              padding: EdgeInsets.only(right: LumaTokens.space12),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Jump to month',
            onPressed: assets.isEmpty
                ? null
                : () => _jumpToMonth(context, library),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (library.phase == LibraryPhase.indexing && assets.isEmpty) {
            return const LoadingState();
          }
          if (assets.isEmpty) {
            return const EmptyState(
              title: 'Library is empty',
              message: 'Photos and videos on this device will appear here, grouped by day.',
            );
          }
          return Stack(
            children: [
              AssetGrid(
                assets: assets,
                heroPrefix: 'library',
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
                    onMore: () => _more(context, library, selection),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _jumpToMonth(
    BuildContext context,
    LibraryController library,
  ) async {
    final months = monthAnchors(library.visibleAssets);
    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView.builder(
          itemCount: months.length,
          itemBuilder: (context, i) {
            final month = months[i];
            return ListTile(
              title: Text(formatMonthYear(month)),
              onTap: () => Navigator.pop(context, month),
            );
          },
        );
      },
    );
    if (selected == null || !context.mounted) return;
    final subset = library.visibleAssets
        .where(
          (a) =>
              a.createdAt.year == selected.year &&
              a.createdAt.month == selected.month,
        )
        .toList();
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            CollectionScreen(title: formatMonthYear(selected), assets: subset),
      ),
    );
  }

  Future<void> _more(
    BuildContext context,
    LibraryController library,
    SelectionController selection,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.collections_bookmark_outlined),
                title: const Text('Add to Luma collection'),
                onTap: () => Navigator.pop(context, 'collection'),
              ),
              ListTile(
                leading: const Icon(Icons.select_all),
                title: const Text('Select all visible'),
                onTap: () => Navigator.pop(context, 'all'),
              ),
            ],
          ),
        );
      },
    );
    if (!context.mounted || action == null) return;
    if (action == 'all') {
      selection.addAll(library.visibleAssets.map((a) => a.id));
    } else if (action == 'collection') {
      final nameController = TextEditingController();
      final name = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('New collection'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Name (stays in Luma, not the system library)',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, nameController.text.trim()),
                child: const Text('Create'),
              ),
            ],
          );
        },
      );
      if (name == null || name.isEmpty) return;
      await library.createCollection(name, selection.ids.toList());
      selection.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Saved “$name” in Luma')));
      }
    }
  }
}
