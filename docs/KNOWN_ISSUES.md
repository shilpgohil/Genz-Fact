# Known issues

## Environment

- This agent runs on Linux. `flutter test` / `flutter analyze` are the verification path. iOS Simulator and a physical photo library are not available here.
- `photo_manager` is a no-op/error on desktop; the app is intended for Android/iOS devices.

## Platform limits

- iOS location on assets may be missing without extra location plugins; Luma does not add those.
- Android favorites require API 30+.
- File size queries can be slow or trigger iCloud download in edge cases — sizes are optional and backfilled; storage UI must not fabricate totals.
- Creating OS albums is reliable on iOS; Android folder creation is limited. Luma collections cover cross-platform user grouping.
- Screenshot detection is heuristic (path/title/subtype), not CV.
- Portrait-like is iOS depth subtype only.
- Limited photo access: the app sees only what the OS grants.

## Product limits

- No people/selfies album until a local model exists.
- Moment titles never include guessed event names or city names.
- Near-duplicate scan is user-initiated (CPU/battery). Hashes are not yet persisted across launches.
