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

**Public (no Vercel login):** https://eu4wgtuvb4rz.htmldrop.app/

The Vercel Git preview is behind Deployment Protection. Accounts that are not on the `genzfacts` Vercel team (for example `28sgphotos@gmail.com`) see “Request Sent” and cannot open it until a team owner approves. Use the public link above instead.

Vercel preview (team only):

https://genzfacts-git-cursor-c10039-thesis-strength-analysers-projects.vercel.app

