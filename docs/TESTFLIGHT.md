# Put Luma on TestFlight

TestFlight is the supported way to install Luma on an iPhone without a cable. It is **not** the App Store, and it is **not** something this cloud environment can publish for you.

Apple requires:

- A **paid** [Apple Developer Program](https://developer.apple.com/programs/) membership (about US$99 / year). A free Apple ID is not enough.
- A **Mac** with Xcode (current TestFlight uploads need a recent Xcode / iOS SDK).
- An app record in [App Store Connect](https://appstoreconnect.apple.com/).

This Linux agent cannot sign or upload an iOS build. You upload from your Mac, signed as **your** team.

## What testers get

- Install from the **TestFlight** app (free on the App Store).
- Internal testers (people on your App Store Connect team): up to 100, no Beta App Review.
- External testers: email or public link, after Apple’s Beta App Review.
- Each **build expires after 90 days**. Upload a new build to keep testing. That is how you “keep it on TestFlight.”

## One-time Apple setup

1. Enroll at https://developer.apple.com/programs/ and wait until the account is active.
2. Open https://appstoreconnect.apple.com/ → **Apps** → **+** → **New App**.
   - Platforms: iOS
   - Name: Luma (or another available name)
   - Primary language: English
   - Bundle ID: register `com.luma.luma` in [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) if it is free, otherwise pick a unique id like `com.yourname.luma` and change it in Xcode to match
   - SKU: `luma` (any internal string)
   - User Access: Full Access
3. In Xcode → **Settings → Accounts**, add the same Apple ID. Download manual profiles if Xcode asks.

## Upload the first build (on your Mac)

```bash
git clone https://github.com/shilpgohil/Genz-Fact.git
cd Genz-Fact
git checkout cursor/luma-smart-gallery-f0ce
flutter pub get
open ios/Runner.xcworkspace
```

1. Select the **Runner** target → **Signing & Capabilities**.
2. Enable **Automatically manage signing**.
3. Set **Team** to your **paid** Developer Program team (not “Personal Team”).
4. Confirm the bundle id matches App Store Connect.
5. At the top of Xcode, choose **Any iOS Device (arm64)**, not a simulator.
6. Menu **Product → Archive**. Wait until Organizer opens.
7. **Distribute App → App Store Connect → Upload**.
8. Let Xcode manage signing. Upload.

Export compliance: `ITSAppUsesNonExemptEncryption` is already `false` in `Info.plist` because Luma does not use custom non-exempt cryptography. Confirm that in App Store Connect if asked.

Bump the build number for every new upload. In `pubspec.yaml`, `1.0.0+1` the `+1` is the iOS build (`CFBundleVersion`). Next upload: `1.0.0+2`, then `+3`, and so on.

Or from the repo root:

```bash
flutter build ipa
```

Then upload `build/ios/ipa/*.ipa` with **Transporter** or Xcode Organizer.

## Invite yourself or testers

1. App Store Connect → your app → **TestFlight**.
2. Wait until the build shows **Ready to Test** (processing can take 10–30 minutes).
3. **Internal Testing**: add yourself as an App Store Connect user, add the build to an internal group.
4. On the iPhone: install **TestFlight** from the App Store, accept the email/public-link invite, install **Luma**.
5. Grant Photos access when Luma asks.

## What this does not do

- It does not list Luma on the public App Store.
- It does not replace Android sideload (`dist/luma-android.apk`).
- Builds are not permanent; refresh before the 90-day expiry.
- Do not send Apple ID passwords or API keys to an agent. Keep signing on your Mac.
