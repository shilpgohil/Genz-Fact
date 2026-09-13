import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/luma_tokens.dart';
import '../../models/media_album.dart';
import '../../services/library_controller.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/photo_tile.dart';
import '../collection/collection_screen.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final device = library.deviceAlbums.where((a) => !a.isAll).toList();
    final luma = [
      for (final collection in library.collections)
        collection.asAlbum(library.assets.map((a) => a.id).toList()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Albums'),
        actions: [
          IconButton(
            tooltip: 'New Luma collection',
            onPressed: () => _newCollection(context, library),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: device.isEmpty && luma.isEmpty
          ? const EmptyState(
              icon: Icons.photo_album_outlined,
              title: 'No albums',
              message: 'Device albums appear here when the system exposes them. You can also keep collections that exist only in Luma.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                if (luma.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text('In Luma'),
                  ),
                  for (final album in luma)
                    _AlbumTile(
                      album: album,
                      caption: 'Luma collection',
                      library: library,
                    ),
                ],
                if (device.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text('On this device'),
                  ),
                  for (final album in device)
                    _AlbumTile(
                      album: album,
                      caption: 'System album',
                      library: library,
                    ),
                ],
              ],
            ),
    );
  }

  Future<void> _newCollection(
    BuildContext context,
    LibraryController library,
  ) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Luma collection'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Name — stored in the app, not the camera roll',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    if (name == null || name.isEmpty) return;
    await library.createCollection(name, const []);
  }
}

class _AlbumTile extends StatelessWidget {
  const _AlbumTile({
    required this.album,
    required this.caption,
    required this.library,
  });

  final MediaAlbum album;
  final String caption;
  final LibraryController library;

  @override
  Widget build(BuildContext context) {
    final cover = album.coverId == null ? null : library.byId(album.coverId!);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: LumaTokens.space20,
        vertical: LumaTokens.space8,
      ),
      leading: SizedBox(
        width: 56,
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(LumaTokens.radiusTile),
          child: cover == null
              ? ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                  child: const Icon(Icons.photo_album_outlined),
                )
              : PhotoTile(
                  asset: cover,
                  image: library.thumb(cover.id, size: 160),
                ),
        ),
      ),
      title: Text(album.name),
      subtitle: Text('$caption · ${album.count}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => CollectionScreen(
              title: album.name,
              subtitle: caption,
              assets: library.assetsInAlbum(album),
            ),
          ),
        );
      },
    );
  }
}
