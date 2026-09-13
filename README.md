# Luma

A premium, local-first smart photo gallery for Android and iOS.

Photos stay on the device. No account, no cloud database, no backend.

## What it does

- Reads the real camera roll (with system permission)
- Fast date-grouped library with thumbnails
- Immersive viewer (zoom, swipe, video, share, favorite, delete)
- Moments clustered from capture times
- Categories that can be computed locally (screenshots, videos, favorites, large files, …)
- Metadata search (`August`, `Yesterday`, `Videos`, `2025`, …)
- Duplicate and cleanup suggestions — never deletes unless you confirm

## Run

```bash
flutter pub get
flutter run
```

iOS: grant Photos access when asked. Android 13+: grant photos/videos (or selected photos).

## Quality

```bash
dart format .
flutter analyze
flutter test
```

## Docs

See `AGENTS.md` and `docs/` for architecture, design, progress, and decisions.

## License

MIT. The previous static “Genz Facts” experiment is stored in `archive/genz-facts/`.
