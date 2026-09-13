# Luma

A premium, local-first smart photo gallery for Android, iOS, and the web.

Photos stay on the device (or in this browser tab). No account, no cloud database, no backend.

## Open in a browser (no login)

**Use this link on your phone:** [https://eu4wgtuvb4rz.htmldrop.app/](https://eu4wgtuvb4rz.htmldrop.app/)

Tap **Choose photos** and pick images. They stay in that tab and are never uploaded.

The Vercel preview is locked to the project’s Vercel team. If you see **Request Sent**, you are signed in as an account that is not on that team — that screen is expected. Use the public link above instead.

## What it does

- Reads the real camera roll on Android/iOS (with system permission)
- On web, organizes files you choose in this tab
- Fast date-grouped library with thumbnails
- Immersive viewer (zoom, swipe, video, share, favorite, delete)
- Moments clustered from capture times
- Categories that can be computed locally (screenshots, videos, favorites, large files, …)
- Metadata search (`August`, `Yesterday`, `Videos`, `2025`, …)
- Duplicate and cleanup suggestions — never deletes unless you confirm

## Install on a phone

**Android (direct APK):** download [`dist/luma-android.apk`](dist/luma-android.apk) on the phone, open the file, allow install from the browser, then open **Luma**.

**iPhone:** Apple does not allow installing an unsigned `.ipa` from a website. See [`docs/TESTFLIGHT.md`](docs/TESTFLIGHT.md).

## Run from a computer

```bash
flutter pub get
flutter run                 # Android / iOS
flutter run -d chrome       # web
```

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
