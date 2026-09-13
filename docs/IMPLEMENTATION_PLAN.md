# Implementation plan

Work in milestones. After each: format, analyze, test, update PROGRESS.md.

## Milestone 1 — Foundation — done

Theme, tokens, shell, reusable widgets, empty/loading/error/permission states.

## Milestone 2 — Real library — done

`MediaLibrary` + `PhotoManagerLibrary`. iOS/Android permissions. Paged metadata index.

## Milestone 3 — Main gallery — done

Date-grouped rows, lazy tiles, thumbnails, video/favorite badges, selection, month jump.

## Milestone 4 — Viewer — done

PageView, pinch/double-tap zoom, videos, favorite/share/delete/metadata.

## Milestone 5–7 — Smart home, moments, categories — done

Home sections only when data exists. Time-based moments. Conservative categories.

## Milestone 8 — Search — done

Local metadata parser + filter. Extensible for future on-device intelligence.

## Milestone 9–10 — Duplicates and cleanup — done

Exact groups from size+dimensions. Optional perceptual scan. No auto-delete.

## Milestone 11–15 — Albums, favorites, actions, health, settings — done

Device albums vs Luma collections. Native favorites when the OS supports them.

## Next iteration (device QA)

- Profile scrolling on a 10k+ library
- Tune thumbnail sizes per device pixel ratio
- Persist similar-photo hashes
- Branded launcher icons
