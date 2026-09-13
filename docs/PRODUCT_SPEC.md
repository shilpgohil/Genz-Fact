# Product spec — Luma

Luma is a local-first smart gallery. It reads the device photo library, organizes it, and helps people find, enjoy, and clean up photos without leaving the phone.

## Goals

- Faster finding than a plain grid.
- Honest on-device intelligence (dates, types, duplicates, moments).
- Beautiful viewing and calm chrome.
- Usable with zero network, zero account.

## Non-goals

- Cloud sync, social sharing networks, accounts.
- On-device ML scene/face recognition until it is stable and local.
- Pretending to know place names without geocoding data on device.

## Primary surfaces

| Surface | Role |
| --- | --- |
| Home | Smart landing: recent, moments, categories that actually have items |
| Library | Date-grouped thumbnail grid, selection, month jump |
| Viewer | Immersive photo/video, zoom, actions |
| Search | Metadata queries (dates, types, favorites, albums) |
| Albums | Device albums + optional Luma collections |
| Cleanup | Duplicates, large files, screenshots — user confirms deletes |
| Health | Library composition, not an admin dashboard |
| Settings | Appearance, grid, motion, permissions, privacy |

## Intelligence that is allowed

Computed from local metadata only:

- Date/time grouping and relative labels
- Moments (time clustering; titles from weekday/time-of-day/date span/album name)
- Screenshots (path, title, iOS subtype bit)
- Videos, favorites, recent, large files, burst-like sequences
- Exact duplicates (size + dimensions) and near duplicates (perceptual hash after an explicit scan)
- Portrait-like (iOS depth/portrait subtype only)

Not claimed: people/selfies, OCR, semantic “beach/dog” search, invented event names (“Birthday Night” without evidence).

## Privacy copy (must remain true)

- Photos stay on the device.
- No account.
- No backend.
- No upload required.
