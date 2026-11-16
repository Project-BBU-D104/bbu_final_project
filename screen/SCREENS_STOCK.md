# Stock

Integration verification: 2026-11-16. All 15 screens are implemented and verified by focused automated tests. Manual QA remains pending; this is not a production sign-off. The full suite retains one unrelated baseline failure.

## Screens

| Screen | File | Route / host | Status |
|---|---|---|---|
| Warehouses: List | [Source](../frontend/lib/screen/stock/warehouse/warehouse_screen.dart) | `/warehouse` | Implemented; automated checks passed |
| Warehouses: Add | [Source](../frontend/lib/screen/stock/warehouse/widget/add_warehouse_widget.dart) | Adaptive form | Implemented; automated checks passed |
| Warehouses: Edit | [Source](../frontend/lib/screen/stock/warehouse/widget/edit_warehouse_widget.dart) | Adaptive form | Implemented; automated checks passed |
| Warehouses: Detail | [Source](../frontend/lib/screen/stock/warehouse/widget/ware_house_detail_widget.dart) | `/warehouse-detail` | Implemented; automated checks passed |
| Warehouse stock: List | [Source](../frontend/lib/screen/stock/warehouse_stock/warehouse_stock_screen.dart) | `/warehouse-stock` | Implemented; automated checks passed |
| Warehouse stock: Add | [Source](../frontend/lib/screen/stock/warehouse_stock/widget/add_warehouse_stock_widget.dart) | Adaptive form; multiple rows | Implemented; automated checks passed |
| Warehouse stock: Edit | [Source](../frontend/lib/screen/stock/warehouse_stock/widget/edit_warehouse_stock_widget.dart) | Adaptive form; exactly one row | Implemented; automated checks passed |
| Adjustments: List | [Source](../frontend/lib/screen/stock/stock_adjustment/stock_adjustment_screen.dart) | `/stock-adjustment` | Implemented; automated checks passed |
| Adjustments: Add | [Source](../frontend/lib/screen/stock/stock_adjustment/widget/add_stock_adjustment_widget.dart) | Adaptive form | Implemented; automated checks passed |
| Adjustments: Edit | [Source](../frontend/lib/screen/stock/stock_adjustment/widget/edit_stock_adjustment_type_widget.dart) | Adaptive form; live reversal preview | Implemented; automated checks passed |
| Adjustments: Detail | [Source](../frontend/lib/screen/stock/stock_adjustment/widget/stock_adjustment_detail_widget.dart) | `/stock-adjustment-detail` | Implemented; automated checks passed |
| Transfers: List | [Source](../frontend/lib/screen/stock/stock_transfer/stock_transfer_screen.dart) | `/stock-transfer` | Implemented; automated checks passed |
| Transfers: Add | [Source](../frontend/lib/screen/stock/stock_transfer/widget/add_stock_transfer_widget.dart) | Adaptive form; fresh stock preflight | Implemented; automated checks passed |
| Transfers: Edit | [Source](../frontend/lib/screen/stock/stock_transfer/widget/edit_stock_transfer_widget.dart) | Adaptive form; original-source addback | Implemented; automated checks passed |
| Transfers: Detail | [Source](../frontend/lib/screen/stock/stock_transfer/widget/stock_transfer_detail_card_widget.dart) | `/stock-transfer-detail` | Implemented; automated checks passed |

## Layout and navigation

All four lists preserve `DesktopAppShell`, use the shared UI kit and `AppTokens`/`AppSpacing`, and choose cards or tables from available content width (799/800 boundary). Large text falls back to cards. Lists have persistent shared search, counts, lazy scrolling, pull-to-refresh, and distinct loading, failed-load, empty, no-match, and retained-record refresh-error states.

Each feature shares Add/Edit form content behind its existing adapters. `AppFormShell.show` opens a dialog at the desktop breakpoint and a bottom sheet below it. Forms validate inline, focus invalid fields, preserve rejected drafts, and guard writes and dismissal while saving. Warehouse stock form lookups stay local and cannot overwrite another controller's active warehouse search.

Warehouse list/card/table selection calls `WarehouseController.gotoWarehouseDetail` with the existing map argument. Adjustment and transfer controllers retain their existing detail route/map contracts. Detail screens reuse bound controllers and the newest matching records, provide safe unavailable states and Back actions, and expose no write controls for unavailable arguments. Compact detail actions wrap in safe footers; desktop actions use page headers. Successful deletes leave list routes intact and close only their originating current detail routes.

## Stock correctness and integration fixes

- Warehouse stock Add serializes multiple unique product rows, including zero quantities. Edit permits exactly one row in both UI and controller. Successful edits retain the committed quantity even if list readback fails; a dismissing form cannot submit its movement again.
- Adjustment Edit reverses the original movement from live stock before applying the draft. A changed pair uses that pair's live stock. Unknown lookup results block saving, stale responses cannot overwrite current selections, and derived previous/new quantities remain server-owned.
- Transfers merge duplicate products, retain rows on source changes, and add original quantities back exactly once only for the original source. Submission fetches fresh source stock and guards the whole preflight/write. Late Add/Edit/detail responses and completed-save readbacks cannot open over, write from, or pop another route.
- `frontend/lib/utils/stock_refresh.dart` provides `Future<void> refreshStockReadModels()`. It refreshes existing Warehouse/Product instances independently, skips uninstantiated lazy bindings, and uses `getProducts(showLoading: false)`. All three stock-mutation features call it; existing feature-specific warehouse-stock list refreshes are retained.
- Readback failures never become retryable save failures. The API client also treats malformed successful response bodies as committed for the four Stock endpoints on POST/PUT/DELETE only; GETs, rejected writes, other endpoints, and backend behavior retain their contracts.
- Repeated warehouse-stock/transfer delete actions open one confirmation. Existing feature test support files remain separate. Shared threshold tokens are declared once; all source locale keys are retained, duplicate keys are absent, two differing Khmer phrasings are reconciled, and five missing form/search/confirmation labels now have English/Khmer copy.

## Verification results

All commands ran from the isolated integration worktree, using fake services and the public example environment file. No live credentials or API mutations were used.

| Check | Actual result |
|---|---|
| Focused Stock/controller/form/list/detail/localization/refresh/API-response tests | 248 passed, 0 failures |
| Affected purchase, purchase-request, purchase-payment, and API-authentication tests | 100 passed, 0 failures |
| Full Flutter suite | 843 passed, 1 skipped, 1 pre-existing failure |
| Baseline full Flutter suite before integration | 595 passed, 1 skipped, 1 failure |
| `flutter analyze --no-pub` | 17 existing diagnostics; 0 added; baseline 37 |
| `flutter build web --no-pub` | Passed |
| Changed Dart formatting | All 60 files formatted; format gate passed |
| `git diff --check` | Passed |
| Source/main preservation | HEAD, staged diff, Git status, tracked/untracked implementation and document hashes unchanged |

The unchanged full-suite failure is `product_redesign_test.dart`: **category sheet and search use dark surfaces** (`Bad state: No element`, original assertion at line 296). It reproduced before integration. It is outside Stock scope and remains a blocker to an entirely green repository suite. The web-only skip is retained. Analyzer diagnostics are compared by message/severity/path with line/column offsets ignored; no new diagnostics remain. Dependency Wasm dry-run warnings do not prevent the standard web build.

Automated coverage includes real-shell width probes at 390/840/1024/1440, isolated 799/800 content boundaries, English/Khmer and light/dark cases, large text, keyboard insets, focus/keyboard activation, safe invalid arguments, missing relations/dates, retained drafts, duplicate-save guards, stale requests, and committed-write/readback separation. These tests do not establish real-device or backend concurrency behavior.

## Pending manual QA

- Complete a live create/edit/delete journey for each feature, including multi-row stock Add and one-row Edit.
- Verify Warehouse → warehouse stock → adjustment → transfer quantities against a live API, concurrent stock depletion/replenishment, and real failed-readback recovery without repeating mutations.
- Capture browser screenshots and exercise resizing, long Khmer labels, light/dark themes, physical keyboard focus, mobile keyboards, and large-text layouts.
- Check TalkBack/VoiceOver and browser screen-reader announcements, focus order, and control labels on actual devices.
- Resolve the unrelated baseline Product test before requiring a completely green full suite.

## Integration provenance

Common baseline: `cb5dd7f3e496cb7fa8451100f723e1bb567dc8f1`. Integration workspace: `.superpowers/worktrees/stock-integration`, branch `stock/integration`; the Stock changes are recorded separately for local integration into `main`, with all source worktrees retained. Sources were read-only and integrated in the order below. All implementation changes happened to be committed; untracked source files were plans/designs or handoff notes and were excluded. No generated plans/designs, environments, secrets, caches, build outputs, or backend changes are part of the implementation diff.

| Order | Feature | Source folder under `.superpowers/worktrees/` | Source HEAD | Screens |
|---|---|---|---|---:|
| 1 | Warehouses | `warehouses` | `531243e` | 4 |
| 2 | Warehouse stock | `warehouse-stock` | `5561bea` | 3 |
| 3 | Adjustments | `adjustments` | `bcb160e` | 4 |
| 4 | Transfers | `transfers` | `ab90e12` | 4 |

The pre-existing main-workspace `SCREENS_INDEX.md` and Catalog inventory edits are preserved separately as uncommitted changes and excluded from the Stock integration commit. Final review was performed inline by the integrating agent, honoring the request to execute the integration itself; no independent reviewer or live QA sign-off is claimed. Detailed execution logs, source manifests, normalized diagnostics, and preservation snapshots are in the ignored `.superpowers/` folder inside the integration worktree.
