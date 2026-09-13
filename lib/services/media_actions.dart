import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/errors/luma_exception.dart';
import '../services/library_controller.dart';
import '../services/selection_controller.dart';

class MediaActions {
  static Future<void> share(
    BuildContext context,
    LibraryController library,
    Iterable<String> ids,
  ) async {
    final files = <XFile>[];
    for (final id in ids) {
      final path = await library.library.filePath(id);
      if (path != null) files.add(XFile(path));
    }
    if (!context.mounted) return;
    if (files.isEmpty) {
      _toast(context, 'Nothing available to share.');
      return;
    }
    try {
      await SharePlus.instance.share(ShareParams(files: files));
    } catch (_) {
      if (context.mounted) {
        _toast(context, 'Sharing could not be completed.');
      }
    }
  }

  static Future<bool> confirmDelete(BuildContext context, int count) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete from device?'),
          content: Text(
            count == 1
                ? 'This uses the system photo library. You can still cancel in the next system prompt if one appears.'
                : 'Delete $count items from the photo library? The system may ask you to confirm.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static Future<void> delete(
    BuildContext context,
    LibraryController library,
    SelectionController selection,
    Iterable<String> ids,
  ) async {
    final list = ids.toList();
    if (list.isEmpty) return;
    final ok = await confirmDelete(context, list.length);
    if (!ok || !context.mounted) return;
    try {
      final deleted = await library.delete(list);
      selection.clear();
      if (context.mounted) {
        _toast(
          context,
          deleted.isEmpty
              ? 'No items were deleted.'
              : 'Removed ${deleted.length} from the library.',
        );
      }
    } on LumaException catch (error) {
      if (context.mounted) _toast(context, error.message);
    }
  }

  static Future<void> favoriteMany(
    LibraryController library,
    Iterable<String> ids,
  ) async {
    for (final id in ids) {
      final asset = library.byId(id);
      if (asset == null || asset.isFavorite) continue;
      try {
        await library.toggleFavorite(id);
      } catch (_) {}
    }
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
