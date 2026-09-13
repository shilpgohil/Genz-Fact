# Decisions

## State management: provider + ChangeNotifier

Simple, explicit, enough for one library controller. Riverpod/Bloc would add indirection without a second team.

## photo_manager over photo_gallery / method channels

Mature permission handling (limited access, Android 13/14), albums, delete, favorite, thumbnails.

## Grid of date-rows, not masonry, for the main library

Masonry is prettier and worse for recycling thousands of tiles. Home and moments can be richer. Main library optimizes scroll.

## In-memory metadata, not SQLite (v1)

Asset structs are small. SQLite can wait until indexes or incremental updates need persistence. Perceptual hashes currently live in memory for the session after a similar-photo scan.

## No reverse geocoding

Place names would need a database or network. Moments never invent cities.

## No `MANAGE_MEDIA` permission

Keeps deletes behind the system confirmation UI. Safer and better aligned with “never surprise-delete.”

## Glass reduced on Android by default

`BackdropFilter` is expensive on low-end GPUs. Users can enable full glass in Settings.

## Luma collections vs device albums

Device albums come from the OS. Luma collections are local id lists. UI labels them separately.

## Web session library

Browsers have no camera-roll API equivalent to `photo_manager`. The web build uses `SessionMediaLibrary`: the user picks local files, Luma organizes them in this tab, and closing the tab clears the session. Files are not uploaded.

## TestFlight is owner-side

This environment cannot upload to TestFlight. Distribution uses the owner’s paid Apple Developer Program team and a Mac (see `docs/TESTFLIGHT.md`).

## Export compliance

`ITSAppUsesNonExemptEncryption` is `false`. Luma does not implement custom non-exempt cryptography; standard TLS and hashing used by dependencies are treated as exempt. Revisit this if you add your own crypto.

This GitHub repo originally held a static “Genz Facts” page. It is preserved under `archive/genz-facts/` and is not part of the app.
