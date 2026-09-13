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

## Install on a phone

Luma is not on the App Store or Play Store. You cannot tap “Get” from this chat onto your device.

**Android (direct APK):** download [`dist/luma-android.apk`](dist/luma-android.apk) on the phone, open the file, allow install from the browser, then open **Luma**. Use the 64-bit APK (almost every phone from 2017 on). Grant Photos / Videos (or selected photos).

**iPhone:** Apple does not allow installing an unsigned `.ipa` from a website. You need a Mac, Xcode, and a cable. See the step-by-step in the pull request / agent notes: clone the `cursor/luma-smart-gallery-f0ce` branch, open `ios/Runner.xcworkspace`, set your Team under Signing, then `flutter run`.

## Run from a computer

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
