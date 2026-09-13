import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:luma/models/app_models.dart';
import 'package:luma/models/media_asset.dart';
import 'package:luma/services/session_media_library.dart';

/// 1×1 transparent PNG.
final Uint8List kTinyPng = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  test('starts without access and an empty session', () async {
    final library = SessionMediaLibrary();
    expect(library.accessMode, LibraryAccessMode.session);
    expect(await library.currentPermission(), LumaPermission.notDetermined);
    expect(await library.pagedAllAssets().toList(), [<MediaAsset>[]]);
  });

  test('cancelled picker leaves permission undetermined', () async {
    final library = SessionMediaLibrary(pickFiles: () async => const []);
    expect(await library.requestPermission(), LumaPermission.notDetermined);
  });

  test('ingesting files authorizes and lists newest first', () async {
    final library = SessionMediaLibrary(
      pickFiles: () async => [
        SessionFile(
          name: 'older.jpg',
          bytes: kTinyPng,
          lastModified: DateTime(2024, 1, 1),
          mimeType: 'image/png',
          width: 1,
          height: 1,
        ),
        SessionFile(
          name: 'newer.jpg',
          bytes: kTinyPng,
          lastModified: DateTime(2025, 6, 2),
          mimeType: 'image/png',
          width: 1,
          height: 1,
        ),
      ],
    );

    expect(await library.requestPermission(), LumaPermission.authorized);
    final pages = await library.pagedAllAssets().toList();
    final assets = pages.expand((page) => page).toList();
    expect(assets.map((a) => a.title), ['newer.jpg', 'older.jpg']);
    expect(assets.first.kind, MediaKind.image);
    expect(assets.first.fileSizeBytes, kTinyPng.length);
  });

  test('folders from relative paths become session albums', () async {
    final library = SessionMediaLibrary();
    await library.ingest([
      SessionFile(
        name: 'a.jpg',
        bytes: kTinyPng,
        lastModified: DateTime(2025, 1, 1),
        mimeType: 'image/png',
        relativePath: 'Trip/a.jpg',
        width: 1,
        height: 1,
      ),
      SessionFile(
        name: 'b.jpg',
        bytes: kTinyPng,
        lastModified: DateTime(2025, 1, 2),
        mimeType: 'image/png',
        relativePath: 'Trip/b.jpg',
        width: 1,
        height: 1,
      ),
      SessionFile(
        name: 'c.jpg',
        bytes: kTinyPng,
        lastModified: DateTime(2025, 1, 3),
        mimeType: 'image/png',
        relativePath: 'Home/c.jpg',
        width: 1,
        height: 1,
      ),
    ]);

    final albums = await library.listAlbums();
    expect(albums.first.isAll, isTrue);
    expect(albums.first.count, 3);
    expect(albums.where((a) => !a.isAll).map((a) => a.name).toList(), [
      'Home',
      'Trip',
    ]);
    final trip = albums.firstWhere((a) => a.name == 'Trip');
    expect(await library.assetIdsForAlbum(trip.id), hasLength(2));
  });

  test(
    'delete and favorite only change the session, not disk semantics',
    () async {
      final library = SessionMediaLibrary();
      await library.ingest([
        SessionFile(
          name: 'keep.png',
          bytes: kTinyPng,
          lastModified: DateTime(2025, 3, 1),
          mimeType: 'image/png',
          width: 1,
          height: 1,
        ),
        SessionFile(
          name: 'drop.png',
          bytes: kTinyPng,
          lastModified: DateTime(2025, 3, 2),
          mimeType: 'image/png',
          width: 1,
          height: 1,
        ),
      ]);
      final ids = (await library.pagedAllAssets().first)
          .map((a) => a.id)
          .toList();
      final drop = ids.first;
      final keep = ids.last;

      await library.favorite(keep, true);
      final deleted = await library.deleteIds([drop]);
      expect(deleted, [drop]);

      final remaining = await library.pagedAllAssets().first;
      expect(remaining, hasLength(1));
      expect(remaining.single.id, keep);
      expect(remaining.single.isFavorite, isTrue);
      expect(library.thumbnailProvider(keep, size: 64), isNotNull);
      expect(library.previewProvider(keep), isNotNull);
    },
  );

  test('adding more files merges into the existing session', () async {
    var round = 0;
    final library = SessionMediaLibrary(
      pickFiles: () async {
        round++;
        return [
          SessionFile(
            name: 'round$round.png',
            bytes: kTinyPng,
            lastModified: DateTime(2025, 1, round),
            mimeType: 'image/png',
            width: 1,
            height: 1,
          ),
        ];
      },
    );
    await library.requestPermission();
    await library.presentLimitedPicker();
    final assets = await library.pagedAllAssets().first;
    expect(assets.map((a) => a.title), ['round2.png', 'round1.png']);
  });
}
