# Progress

Last updated: 2026-09-13

## Current state

Luma is a real Flutter app (Android, iOS, and web) with a working local-first vertical slice. On phones, photos come from the device library via `photo_manager`. On the web, the user chooses local files; they stay in the browser tab and are never uploaded.

## DONE

### Implemented
- Milestone 1: theme, tokens, glass chrome, empty/loading/permission states, four-tab shell
- Milestone 2: `MediaLibrary` + `PhotoManagerLibrary`, iOS/Android permissions (including limited access), paged metadata index, size backfill
- Milestone 3: date-grouped lazy library grid, selection, month jump
- Milestone 4: immersive viewer (swipe, pinch/double-tap zoom, video, share, favorite, delete/info)
- Milestone 5–7: smart Home, time-based Moments, conservative categories
- Milestone 8: metadata search (dates, types, albums, favorites, large)
- Milestone 9–10: exact duplicate groups, optional similar-photo scan, cleanup suggestions (no auto-delete)
- Milestone 11–15: device albums vs Luma collections, favorites, health, settings, privacy copy
- Web: `SessionMediaLibrary`, Flutter web build, static deploy via `web-dist/` + `vercel.json`

### Tested
- `dart format .`
- `flutter analyze` — no issues
- `flutter test` — 35 tests (including session library + web permission copy)
- `flutter build web --release`

### Remains
- Run on a physical iPhone/Android with a real photo library (this environment is Linux)
- TestFlight: owner must enroll in the Apple Developer Program and upload from a Mac (`docs/TESTFLIGHT.md`)
- Custom branded store icons (default Flutter launcher)
- Persist perceptual hashes across launches
- Optional future on-device ML (people/scenes) — not claimed

### Known limitations
See `docs/KNOWN_ISSUES.md`.

### Recommended next action
Open the web app, choose photos, and walk Home / Library / Search / Viewer.

## Not claimed
- Face/people albums, OCR, semantic “beach/dog” search
- Cloud sync, accounts, analytics
- Reverse-geocoded place names in moment titles
