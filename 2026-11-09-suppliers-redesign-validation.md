# Suppliers Redesign Validation

Date: 2026-11-09 (Asia/Bangkok). Branch: `suppliers-redesign`, isolated worktree `.superpowers/worktrees/suppliers-redesign`. No push or merge performed.

**Environment:** Installed Flutter 3.44.0 / Dart 3.12.0 and cached dependencies. SDK-generated registrants and lockfile resolution changes are excluded from the final diff.

## Automated results

- Baseline `flutter test`: **180 passed**.
- Final `flutter test`: **223 passed**.
- `flutter analyze`: **70 existing diagnostics**, down from the 72-issue baseline; comparison by diagnostic message/path found **no new diagnostics**.
- Standard `flutter build web`: **passed**. Existing dependency wasm dry-run warnings remain; this is a successful standard JavaScript web build, not a claim of wasm support.
- Focused controller/widget suites passed, including supplier search/cache/refresh, malformed responses, stale-refresh protection, validated/guarded writes, preserved drafts, route and sheet behavior, lifecycle checks, map coordinates, permission fallbacks, launcher failures and unsupported URI rejection.
- Accessibility checks include keyboard card activation, labeled targets, Android-sized touch targets, both themes, long Khmer text and 200% text scaling. Supplier text and badge contrast tests meet **4.5:1**.
- A regression reproduced the detail page disappearing behind Edit; it passes after capturing the original supplier argument. A separate regression caught missing Khmer status/validation copy.
- Fixture screenshot render passed for desktop/mobile list, detail, Edit, Add, dark Khmer and picker. Previews are in ignored `.superpowers/supplier-preview/` inside this worktree. Picker screenshots use in-memory tiles.

## Browser and manual limits

`flutter test --platform chrome test/supplier_location_flow_test.dart` could not start its suite. Inspection of Chrome's local test page showed failed loading of the Flutter test server's CanvasKit JS/WASM resources (HTTP status not OK / dynamic-import failure). The runner was stopped after diagnosis. **No Chrome test pass is claimed.**

Physical devices, live-browser contact handlers/popups, spoken screen readers, actual geolocation prompts/tiles and a live API were not tested. These checks remain listed in `screen/SCREENS_SUPPLIERS.md`. The normal web build and mocked launcher/location tests do not replace them.

## Decisions made during execution

1. Added optional `useTheme=false` to the existing CustomAppBar and enabled it only for Suppliers because the shared widget hardcoded white/black. Other callers retain their defaults. If wrong: supplier-header appearance changes.
2. Added optional sheet constraints to the existing helper because Material's default 640-pixel cap prevented the specified 760-pixel supplier form. Other callers retain their defaults. If wrong: supplier desktop form width changes.

## Scope

No backend, endpoint/payload, migration, environment, permission, dependency or generated-platform changes are included. Routes and typed supplier arguments remain compatible; purchase dropdowns retain the unfiltered supplier list. Existing Products planning documents in the main checkout are untouched.

## Independent review

A fresh-context reviewer inspected the complete branch and connected routing/services. Review found a location-lookup race during sheet dismissal, four accidentally corrupted existing Unicode entries, and missing Khmer map-launch failure copy. All three were treated as required corrections and fixed in one pass, with each regression observed failing before the fix and passing afterward. The complete suite then passed all 223 tests. No review findings remain deferred.

The location helper now captures its originating route and checks that it remains current both before pushing the picker and before applying its result. The Unicode entries are restored exactly from the base revision, and map-launch feedback has matching locale entries.
