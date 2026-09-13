# Design system

## Personality

Intelligent, calm, premium, private. Warm paper in light mode, near-black graphite in dark mode, champagne highlight. Not neon, not generic Material cards.

## Tokens (`lib/core/theme/luma_tokens.dart`)

- Spacing: 4, 8, 12, 16, 20, 24, 32, 48
- Radius: 12 tile, 18 card, 28 sheet, 999 pill
- Blur: 18 (full), 8 (reduced), 0 (off)
- Glass opacity: 0.08 dark / 0.55 light fill; hairline border
- Motion: 180 / 280 / 420 ms, curve `cubic-bezier(0.22, 1, 0.36, 1)`
- Grid: comfortable 2, regular 3, compact 4 (landscape +1 cap 5)
- Icon sizes: 18, 22, 28
- Min tap: 44

## Type

- Wordmark / large titles: serif (`Georgia` / `New York` fallback) for “Luma”
- UI: platform SF/Roboto with a custom scale (title, body, caption, overline)

## Components

`GlassCard`, `GlassButton`, `GlassBottomBar`, `SectionHeader`, `PhotoTile`, `MomentCard`, `EmptyState`, `LoadingState`, `PermissionPanel`, `LumaSearchField`, `SelectionToolbar`, `MetadataSheet`.

## Glass policy

Backdrop blur only on chrome (top bar, bottom bar, sheets). Tiles are opaque images. If scroll jank appears, drop blur before dropping layout quality.

## Color

Dark background `#070708`, surface `#141416`, text `#F4F1EA`, muted `#A39E94`, accent `#E4C39A`, danger `#E85D4C`.
Light background `#F3EFE8`, surface `#FFFCF7`, text `#1A1916`, accent `#7A5428`.
