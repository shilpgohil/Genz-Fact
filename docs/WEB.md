# Web app

Luma on the web is the same Flutter app, compiled to a static site.

Browsers cannot read the camera roll. On web, **Choose photos** opens a local file picker. Selected files stay in this tab as blob URLs / in-memory bytes. Nothing is uploaded. Closing the tab clears the session.

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

## Production build

```bash
flutter build web --release
rm -rf web-dist
cp -R build/web web-dist
```

`web-dist/` is the deployable static output (Vercel `outputDirectory`, GitHub Pages, or any static host).

## Live URL

This repo is connected to Vercel (`genzfacts`). The current preview:

https://genzfacts-cqfjo7g2t-thesis-strength-analysers-projects.vercel.app

PR alias:

https://genzfacts-git-cursor-c10039-thesis-strength-analysers-projects.vercel.app

If the page asks for Vercel/GitHub login, that is Deployment Protection on the project — sign in with the repo owner account. To make it public, turn off Deployment Protection in the Vercel project settings.

