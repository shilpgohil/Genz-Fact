# Architecture

## Layers

1. **Widgets / features** — screens and reusable UI. They read `LibraryController` and `SettingsStore` via `provider`.
2. **Controllers** — `LibraryController` owns permission, indexing, derived collections, size backfill, duplicate scan progress. `SelectionController` owns multi-select.
3. **Engines** — pure functions on `List<MediaAsset>`. No plugins, no `BuildContext`.
4. **MediaLibrary** — async interface. `PhotoManagerLibrary` is the device adapter. Tests use `FakeMediaLibrary`.

## Indexing

Metadata for all visible assets is held in memory. A `MediaAsset` is a few hundred bytes; tens of thousands are acceptable. Pixel buffers are not kept. Thumbnails are requested per visible tile through `AssetEntityImageProvider`.

Paging: first page (~150) notifies immediately so Home/Library appear; remaining pages append.

File sizes are optional and filled in the background with limited concurrency. Storage totals that lack sizes must not be invented — show what is known.

## Derived data

On each completed index (and after deletes/favorites):

- Date sections for the library grid
- Moments via `clusterMoments`
- Category counts via `category_engine`
- Health snapshot via `health_engine`

Duplicate near-match hashes run only when the user starts a scan.

## Platform actions

`MediaActions` wraps share / delete / favorite / file lookup. Delete always goes through `PhotoManager.editor.deleteWithIds` so the OS can confirm.

## Settings

`SettingsStore` persists: theme mode, grid density, reduce motion, reduce glass, include videos in library.

## Navigation

`AppShell` is a four-tab `IndexedStack`: Home, Library, Search, Albums. Settings, Health, Viewer, Moment detail, Cleanup, Duplicates, collection lists are pushed routes.
