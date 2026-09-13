# Luma — Agent Memory

This file is the source of truth for coding agents. Read it before changing the project. Verify the repository; do not trust chat history.

## Project purpose

Luma is a premium, local-first smart photo gallery for Android, iOS, and the web. It organizes photos without accounts, backends, cloud databases, or uploading files. Intelligence is computed locally from real metadata. Never fake AI, fake photos, fake search, or fake storage stats.

Product principle: *Don't make me manage my photos. Make the gallery manage itself.*

## Technology stack

- Flutter 3.47 (Dart 3.13), Material 3 used only as a substrate — visual language is custom Luma, not generic Material.
- State: `provider` + `ChangeNotifier` (`LibraryController`, `SelectionController`, `SettingsStore`).
- Photo library: `photo_manager` + `photo_manager_image_provider` on Android/iOS. On web, `SessionMediaLibrary` + a local file picker (files never leave the tab).
- Local settings: `shared_preferences`.
- Share: `share_plus`.
- Video playback: `video_player`.
- Dates: `intl`.

Do not add Firebase, networking clients, analytics, or account SDKs.

## Architecture rules

- UI, engines, and platform access stay separated.
- Pure Dart engines (`moment_engine`, `search_engine`, `duplicate_engine`, `category_engine`, `date_grouping`, `health_engine`) must stay testable without plugins.
- `MediaLibrary` is the only photo-platform boundary. App code uses `MediaAsset` ids, never raw `AssetEntity` except inside `PhotoManagerLibrary` and thumbnail widgets. Web uses `SessionMediaLibrary` via `createMediaLibrary()`.
- Do not load full-resolution images in grids. Thumbnails only.
- Do not copy the user's library into app storage.
- Never delete media automatically. Confirm destructive actions. Prefer native delete APIs.
- Device albums and Luma collections are different. Do not pretend they are the same.
- Prefer incremental changes. Do not rewrite working features.

## Layout

```
lib/
  app/            # bootstrap + root widget
  core/           # theme, tokens, formatters
  models/         # immutable data
  services/       # controllers + engines + platform adapters
  widgets/        # reusable UI
  features/       # screens
docs/             # product + engineering memory
```

## Important commands

```
export PATH="$PATH:$HOME/flutter/bin"   # if Flutter is not on PATH
flutter pub get
dart format .
flutter analyze
flutter test
```

Android/iOS device builds require the respective SDKs. Linux CI can still format, analyze, and test.

## Package decisions

Add a package only when it solves a real problem. Current reasons:

| Package | Why |
| --- | --- |
| photo_manager | Device photo library, permissions, albums, delete, favorite (Android/iOS) |
| photo_manager_image_provider | Efficient thumbnail `ImageProvider` |
| provider | Consistent, simple DI/state |
| shared_preferences | Theme/grid/motion settings |
| share_plus | Native share sheet |
| video_player | In-viewer video |
| intl | Date labels |

## Coding conventions

- Null safety, strong typing, small files, clear names.
- No magic numbers in widgets — use `LumaTokens`.
- No `print` of paths, GPS, titles, or other personal data.
- No placeholder screens that pretend to work.
- Screens should handle empty, loading, permission, and error states.

## UI rules

- Premium, calm, warm light. Champagne accent. Liquid glass used sparingly.
- Performance over blur. Reduce backdrop blur on Android by default.
- Touch targets ≥ 44px. Readable contrast in light and dark.
- Motion is short and purposeful. Honor reduce-motion.

## Testing rules

Business logic must have unit tests: date grouping, moments, search, duplicates, categories, health, selection. Widget tests cover empty/permission/search field. Do not claim a milestone is done if tests were not run.

## Current priorities

Device QA on a real photo library. Then: persist similar-photo hashes, branded icons, thumbnail size tuning.

The first vertical slice (access → gallery → viewer → moments → search → cleanup → settings) is in place.

## Never change casually

- Privacy: no uploads, no accounts, no tracking.
- `MediaLibrary` abstraction and pure engines.
- Native deletion confirmation path.
- Demo/hardcoded network photos as the primary library.
- Documentation in `/docs` and this file — update them when behavior changes.

## Memory files

Before substantial work: `AGENTS.md`, `docs/PROGRESS.md`, `docs/KNOWN_ISSUES.md`, relevant spec, then the code.

After a milestone: update `PROGRESS.md`, `DECISIONS.md` if needed, `KNOWN_ISSUES.md`, `IMPLEMENTATION_PLAN.md`.
