# Testing

## Unit (required)

| Area | File |
| --- | --- |
| Date grouping | `test/date_grouping_test.dart` |
| Moments | `test/moment_engine_test.dart` |
| Search | `test/search_engine_test.dart` |
| Duplicates | `test/duplicate_engine_test.dart` |
| Categories | `test/category_engine_test.dart` |
| Health | `test/health_engine_test.dart` |
| Selection | `test/selection_controller_test.dart` |
| Session / web library | `test/session_media_library_test.dart` |

Fixtures live in `test/helpers/media_fixtures.dart`. They must not use network images.

## Widget

Empty state, permission panel, search field, app smoke test with `FakeMediaLibrary`.

## Commands

```
dart format .
flutter analyze
flutter test
```

## Device QA (when a phone is available)

- Deny / limited / full permission
- Empty library
- Large library scroll
- Viewer zoom + swipe
- Delete cancel vs confirm
- Airplane mode
- Light and dark
