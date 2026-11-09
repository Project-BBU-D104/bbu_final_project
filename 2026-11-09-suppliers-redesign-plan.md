# Suppliers Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Execution:** Native implementation complete; automated results and manual limits are recorded in [validation](2026-11-09-suppliers-redesign-validation.md). Independent final review pending.

**Goal:** Redesign all five Suppliers screens to match Home while preserving supplier CRUD, purchase lookup data, and location selection.

**Architecture:** Keep GetX routes/controllers and the existing SupplierService API. Reuse Home surfaces, share the two supplier forms, and add narrowly scoped request state and local/cache reconciliation. Keep map/launcher behavior in the existing helpers.

**Tech Stack:** Flutter/Dart, GetX, existing Material themes/localization, flutter_map, latlong2, geolocator, url_launcher; FastAPI unchanged.

**Spec:** [2026-11-09-suppliers-redesign-design.md](2026-11-09-suppliers-redesign-design.md), based on [SCREENS_INDEX.md](SCREENS_INDEX.md) and [screen/SCREENS_SUPPLIERS.md](screen/SCREENS_SUPPLIERS.md). Proposed design and plan; review before implementation.

## Global Constraints

- Plans and design documents live in the repository root only.
- Never push code to GitHub or similar without asking the user.
- Never add Co-Authored-By trailers to commit messages.
- Keep Dart SDK constraint `>=3.11.4 <4.0.0`; add no dependencies.
- Preserve `/supplier`, `/supplier-detail`, `SupplierModel` route arguments, Add/Edit sheet hosting, and the `LatLng?` picker result.
- Preserve supplier endpoint `supplier` and payload keys `name`, `phone`, `email`, `map`, `address`, `status`; no backend, migration, environment, generated-platform, or permissions changes.
- Reuse the existing themes, fonts, English/Khmer localization, confirmation dialog, bottom-sheet helper, and location utilities.
- Keep `suppliers` unfiltered for purchase selectors and retain the 60-second cache.

## Review Focus

1. A query survives cache loading, refresh, and writes without filtering purchase dropdown data. Test in Tasks 1 and 3.
2. A committed write followed by failed refresh must not invite a duplicate submission; failed writes preserve drafts. Test in Task 3.
3. Sheet/map cancellation or leaving during async work must not pop a different page or mutate disposed controllers. Test in Tasks 3 and 4.
4. Missing IDs/optional fields and long Khmer text at 200% scale must leave detail and actions safe and operable. Test in Tasks 1-3.
5. Denied location permission, missing tiles, browser phone launch, and unsupported map URLs must preserve a usable selection/contact flow. Test in Task 4.

---

## File structure and impact

| File | Responsibility |
|---|---|
| `frontend/lib/controllers/supplier_controller.dart` | Injectable service, search/load state, guarded writes, sheet lifecycle, local/cache reconciliation. |
| `frontend/lib/models/supplier_model.dart` | Parse optional dates safely without weakening required name/phone types. |
| `frontend/lib/screen/supplier/supplier_screen.dart` | Responsive list toolbar, cards/table, loading/error/empty states. |
| `frontend/lib/screen/supplier/widgets/supplier_card_widget.dart` | Themed accessible card and contact actions; remove local `iconBox` if unused. |
| `frontend/lib/screen/supplier/widgets/supplier_table_widget.dart` | Themed table, contained scrolling, translated labels/actions. |
| `frontend/lib/screen/supplier/widgets/supplier_detail_card_widget.dart` | Responsive reactive detail, safe identity, existing edit/delete workflow. |
| `frontend/lib/screen/supplier/widgets/supplier_form_widget.dart` (new) | Shared form, validation, keyboard/inset layout, pending/error controls. |
| `frontend/lib/screen/supplier/widgets/supplier_add_widget.dart` | Preserve constructor; adapt shared form to create. |
| `frontend/lib/screen/supplier/widgets/supplier_edit_widget.dart` | Preserve required integer supplierId; adapt shared form to update. |
| `frontend/lib/screen/supplier/location_picker_page.dart` | Themed picker, synchronized coordinate entry, validation and result. |
| `frontend/lib/global.dart` | Preserve supplier map flow; mounted guards and portable safe contact launching. |
| `frontend/lib/widget/bottom_sheets.dart` | Optional dismissal flags, defaults unchanged for all other features. |
| `frontend/lib/widget/search_widget.dart` | Theme surface and clear-action label only, if still needed. |
| `frontend/lib/localization/en_us.dart`, `frontend/lib/localization/km_kh.dart` | Matching keys for new supplier copy, introduced in owning tasks. |
| `frontend/test/supplier_test_support.dart` (new) | Shared fake service, fixtures and themed test host. |
| `frontend/test/supplier_controller_test.dart` (new) | Search/load/cache/model regression tests. |
| `frontend/test/supplier_redesign_test.dart` (new) | List/detail layouts, routes, actions and accessibility. |
| `frontend/test/supplier_form_test.dart` (new) | Validation, request races, sheet lifecycle and draft tests. |
| `frontend/test/supplier_location_flow_test.dart` (new) | Permission fallback, picker cancellation, safe contact launching. |
| `frontend/test/location_picker_page_test.dart`, `frontend/test/search_widget_test.dart` | Extend existing picker/search regressions. |
| `SCREENS_INDEX.md`, `screen/SCREENS_SUPPLIERS.md` | Record actual presentation, verified scope, remaining manual checks. |

Read-only dependencies: `routes/app_pages.dart`, `routes/app_routes.dart`, supplier/product/purchase/stock bindings, purchase Add/Edit supplier selectors, `screen/home/desktop_app_shell.dart`, `screen/home/widget/home_tab_layout.dart`, `utils/location_utils.dart`, `utils/date_formatter.dart`, `helper/confirm_dialog_helper.dart`, `services/main_service/supplier_service.dart`, backend supplier routes/schemas. No exports or dependency/config changes are needed.

## Execution conventions

Run Flutter commands from `frontend/`, git commands from the root. Record baseline `git status --short`, `flutter test`, and `flutter analyze`; preserve unrelated work, including the Products documents. Use an isolated workspace at execution time if needed, following using-git-worktrees. No implementation or commits are performed by this planning task.

Use `Get.testMode`, a local test API URL, fake storage/locale setup following `home_group_redesign_test.dart`, and no live API/tiles. Inject the service rather than replacing controller logic. Initialize static cache deterministically with a fake successful fetch before each scenario; do not add a public cache-reset API just for tests. Reset GetX, locator, viewport, and mocked channels after each test. Complete delayed requests in teardown. Red failures must be behavioral assertions after the planned interface compiles, not unresolved imports/methods.

For each task, explicitly stage only its mapped files and commit after passing its checks, using the listed subject. Include any localization/test-support changes used by that task. Never add trailers or push. Re-read shared files at execution time: the independent Products plan also proposes a theme fix to SearchWidget.

### Task 1: Preserve supplier search through loading and refresh

**Files:** Modify supplier_controller.dart, supplier_model.dart and both locale maps; create supplier_controller_test.dart and supplier_test_support.dart.

**Interfaces:** Add `SupplierController({SupplierService? service})`, defaulting to the existing service. Keep `suppliers`, `searchSuppliers`, and `void searchSupplier(String keyword)`. Add `final loadError = ''.obs`; change `onRefresh()` to `Future<void> onRefresh()`. Keep `Future<void> getSuppliers()`. Store/dispose the keyword Worker and immediately apply the current shared keyword on initialization.

Support defines `Map<String, dynamic> supplierJson(int id, String name, {bool status = true})` with phone `012345678`, email `supplier@example.com`, nullable map/address/dates; `FakeSupplierService implements SupplierService` with mutable `List<Map<String, dynamic>> items`, nullable `Map<String, dynamic>? lastCreatedData` / `lastUpdatedData`, integer counters `getCalls`, `getByIdCalls`, `createCalls`, `updateCalls`, `deleteCalls`, and async overrides matching the existing service. Default create/update return a complete record, and mutate items; use scenario subclasses with Completers/errors. Add a themed `Future<void> pumpSupplierHost(WidgetTester tester, {required Widget home, Size size = const Size(390, 844), bool dark = false, Locale locale = const Locale('en', 'US'), double textScale = 1})` using existing app themes/translations and DesktopAppShell in its navigator builder.

- [x] **Step 1: Write failing tests** `refresh keeps the current name query`, `initial shared query applies to cached records`, `failed refresh retains records and exposes retry state`, and `optional dates tolerate invalid input`. Seed IDs 1/2 named Alpha/Beta, query ` ALP `, fetch again, and assert:

  ```dart
  expect(controller.searchSuppliers.map((s) => s.id), [1]);
  expect(controller.suppliers.map((s) => s.id), [1, 2]);
  controller.searchSupplier('');
  expect(controller.searchSuppliers.length, 2);
  expect(SupplierModel.fromJson({...supplierJson(1, 'Alpha'),
    'created_at': 'invalid'}).createdAt, isNull);
  ```

  On a thrown refresh assert `loadError` is nonempty, `isLoading` is false, and both original unfiltered records remain. A subsequent success clears the error. Repeat for a non-list GET response. Also test empty/missing optional dates and controller disposal followed by keyword changes without stale callbacks.
- [x] **Step 2: Run** `flutter test test/supplier_controller_test.dart`; expect the search/date/state assertions to fail on the current implementation. Introduce only the injectable constructor/declared state needed to compile the tests before recording red.
- [x] **Step 3: Implement** the constructor and existing load/search methods with one private normalized query, reapplying it after cache/network loads. Set/clear `Unable to load suppliers. Please try again.` using both locale maps and retain data on failure; treat a non-list GET response as load failure. Use `DateTime.tryParse` for nullable date strings. Dispose the Worker in onClose; preserve the 60-second cache and raw list for selectors.
- [x] **Step 4: Run** `flutter test test/supplier_controller_test.dart test/customer_controller_test.dart test/product_controller_search_test.dart`; expect PASS. Run `flutter analyze lib/controllers/supplier_controller.dart lib/models/supplier_model.dart`; expect no new issues.
- [x] **Step 5: Commit** with subject `frontend: preserve supplier search and refresh state`.

### Task 2: Redesign supplier browsing and detail

**Files:** Modify supplier_screen.dart, supplier_card_widget.dart, supplier_table_widget.dart, supplier_detail_card_widget.dart, both locale maps, and shared search_widget.dart only if needed. Create supplier_redesign_test.dart; extend search_widget_test.dart.

**Interfaces:** Consume Task 1 lists/loadError and test support. Preserve `SupplierCardWidget({super.key, required SupplierModel item})`, `SupplierTableWidget({super.key, required List<SupplierModel> items})`, SupplierScreen/SupplierDetailCardWidget constructors, `gotoSupplierDetail(SupplierModel)`, `/supplier-detail` arguments and existing write methods. Detail resolves its ID from the typed argument and observes a matching current list record.

- [x] **Step 1: Write failing tests** `supplier list adapts to usable width and text scale`, `loading error empty and no matches have distinct actions`, `detail handles empty name optional fields and absent id`, `detail uses current controller record`, and `supplier actions preserve routes and keyboard access`. Assert cards at content widths 999 and scale 2; table at width 1000 and scale 1. Assert no exception with long Khmer fields, 390x844, 844x390 and 1440x900 with sidebar, dark mode and scale 2. Navigate by keyboard activation and assert:

  ```dart
  expect(Get.currentRoute, '/supplier-detail');
  expect(Get.arguments, same(supplier));
  expect(Get.find<SupplierController>(), same(controller));
  expect(tester.takeException(), isNull);
  ```

  Replace the matching controller record and assert detail shows its changed name. Null argument gives a back-capable empty state; null ID disables edit/delete. Missing dates/email/address/map render `-` and disable unavailable actions. Assert retry invokes one GET, refresh failure leaves Alpha visible, and translated status does not control its color.
- [x] **Step 2: Run** `flutter test test/supplier_redesign_test.dart test/search_widget_test.dart`; expect layout/theme/action assertions to fail on current widgets.
- [x] **Step 3: Implement** the list/detail layouts specified in the design: maximum width 1240, gutters 16/32, list table threshold 1000 and scale ceiling 1.3, detail columns at width 900, lazy mobile cards and a single contained table horizontal scroll. Use themed Material controls, HomeSectionCard for detail, and one labeled Add action. Keep data visible during refresh; render localized Retry, empty and no-match messages. Make row/card activation keyboard-operable; full text remains available when truncated. Use business-icon and `-` fallbacks without changing global DateFormatter.
- [x] **Step 4: Finish accessibility/localization** in those widgets: label every icon, wrap footer actions, use 48-pixel targets, theme-derived status color with translated text, and call/email/map disable states. Change only shared search surface/clear tooltip if absent; preserve SearchWidget constructor, controller ownership, scanner and debounce behavior. Add every new static key to both locale maps. Add assertions for actual themed surface/foreground values and run Flutter labeled-target/tap-target guidelines on the phone fixture.
- [x] **Step 5: Run** `flutter test test/supplier_redesign_test.dart test/supplier_controller_test.dart test/search_widget_test.dart test/desktop_app_shell_test.dart test/dark_mode_surfaces_test.dart`; expect PASS, no layout exceptions, unchanged route argument type and sidebar behavior.
- [x] **Step 6: Commit** with subject `frontend: redesign supplier browsing and details`.

### Task 3: Share supplier forms and make writes reliable

**Files:** Create supplier_form_widget.dart and supplier_form_test.dart. Modify supplier_controller.dart, Add/Edit adapters, supplier_detail_card_widget.dart if required for pending actions, bottom_sheets.dart, both locale maps, and supplier_test_support.dart.

**Interfaces:** Create `SupplierFormWidget({super.key, required SupplierController controller, required String title, required Future<void> Function(BuildContext) onSubmit, bool showStatus = false})` as a StatefulWidget. Preserve SupplierAddWidget and `SupplierEditWidget({super.key, required int supplierId})`. Add controller `final isSaving = false.obs`, `final isOpeningEdit = false.obs`, `final formError = ''.obs`; preserve update/edit/delete parameters and make `saveSupplier(BuildContext context)` return `Future<void>`. Add optional named `bool isDismissible = true, bool enableDrag = true` to `AppBottomSheets.show<T>` and pass them through to showModalBottomSheet. Supplier sheets pass false for both; every other caller keeps defaults.

- [x] **Step 1: Write failing form tests** `blank required fields never write`, `optional fields and trimmed payload retain contract`, `repeated save and edit taps send one request`, `write failure preserves draft and shows error`, and `refresh failure after committed save does not offer resubmission`. Compile against the minimal declared state/interfaces, then submit each whitespace-only required field and assert zero calls plus its existing translated required message. Successful create with name ` Alpha `, phone ` 012345678 `, email ` supplier@example.com ` asserts:

  ```dart
  expect(service.lastCreatedData, {
    'name': 'Alpha', 'phone': '012345678',
    'email': 'supplier@example.com', 'map': '', 'address': '', 'status': true,
  });
  expect(service.createCalls, 1);
  ```

  Call save/update directly with invalid fields to pin controller validation too. Use delayed futures to assert two taps invoke one service call, controls stay disabled, and back/close/barrier/drag cannot dismiss while saving. Failed create/update keeps text, status, sheet, and a localized error. Existing supplier email/phone are not rejected by new format rules.
- [x] **Step 2: Write navigation/data tests** `edit closes only its sheet and updates detail`, `late edit fetch never opens on another page`, `delete cancel failure and success preserve stack`, and `purchase lookup remains unfiltered after writes`. Mount Home -> supplier -> detail -> sheet. On success assert one existing supplier route, updated detail name/status, refreshed cache on a new controller, and the same supplier controller. On failed follow-up GET assert one write, closed sheet, updated local record and list error. Delete Cancel/failed DELETE retain detail/data; successful DELETE returns to the existing list, removes its record/cache even if GET fails, and reapplies the query. Leaving during edit fetch opens no sheet; close the controller during a pending write and assert no unrelated pop/disposed-controller exception.
- [x] **Step 3: Run** `flutter test test/supplier_form_test.dart`; expect failures demonstrating duplicate writes, silent errors or incorrect sheet navigation.
- [x] **Step 4: Implement** the shared form with the design's width 760, field breakpoint 640, visible labels, keyboard inset scrolling, editable status only for Edit, guarded map opens, and PopScope/disabled controls during writes. Keep controller-owned text fields/form key; only one supplier form may mount at a time. Use thin existing Add/Edit adapters and explicit localized Close/Cancel/Save controls. Validate required trimmed fields at the controller boundary before writes; no new validators for optional address/map.
- [x] **Step 5: Implement** guarded save/update/edit/delete in the controller, with try/finally resetting pending state, localized inline write errors, and context/lifecycle checks after awaits. Upsert POST/PUT response into the unfiltered list and cache, reapply query, and close the sheet with its own Navigator only after success. A follow-up list refresh uses loadError independently. Prevent overlapping edit fetches/forms and writes. On confirmed delete, remove the committed ID locally/cache and pop detail once; preserve the existing dialog helper, which already closes confirmation. Keep a visible failure message and do not navigate on failed DELETE.
- [x] **Step 6: Add form layout tests** `supplier form survives keyboard Khmer and large text` at 390x844, keyboard inset 300, scale 2, and a desktop sheet; assert focused errors and Save/Cancel can be scrolled into view without overflow. Verify checkbox status is preserved across failure and picker cancellation. Assert other features' sheet-helper default dismissal behavior is unchanged.
- [x] **Step 7: Run** `flutter test test/supplier_form_test.dart test/supplier_redesign_test.dart test/supplier_controller_test.dart test/purchase_payment_crud_test.dart test/payment_crud_test.dart`; expect PASS. Run targeted analysis on the changed controller/form/helper files; expect no new issues.
- [x] **Step 8: Commit** with subject `frontend: share supplier forms and guard supplier writes`.

### Task 4: Finish location selection and portable contact actions

**Files:** Modify location_picker_page.dart, global.dart, the shared supplier form if needed for picker pending state, and both locale maps. Extend location_picker_page_test.dart; create supplier_location_flow_test.dart. Keep location_utils.dart unchanged unless a failing regression proves a correction necessary.

**Interfaces:** Preserve `LocationPickerPage({super.key, required LatLng initialPosition, TileProvider? tileProvider})`, `Future<void> openSupplierMap(BuildContext, TextEditingController)`, `Future<void> callPhone(String)`, `Future<void> openEmail(String)`, and `Future<void> openGoogleMap(String)`. Consume existing `parseCoordinates(String) -> LatLng?`, `formatCoordinates(LatLng) -> String`, `applyPickedLocation`, and `defaultMapLocation`.

- [x] **Step 1: Write failing picker tests** `typed coordinates save and map taps synchronize the field`, `invalid coordinates cannot save`, `cancel preserves the supplier draft`, and `picker remains operable without tiles`. Reuse the existing in-memory tile provider and add a failing provider. Enter `-33.8688,151.2093`; assert returned latitude/longitude equal those numbers. Enter `91,0`, `0,181`, empty and `abc,def`; assert inline validation and no popped route. Tap the map and assert the field equals formatCoordinates(selected). Back/Cancel returns null; in both themes/Khmer/scale 2 assert coordinate field, attribution and Save remain reachable even with failed tiles.
- [x] **Step 2: Write helper tests** `saved coordinates skip permission requests`, `denied disabled timed out location uses default center`, `picker cancellation or unmounted host never changes draft`, and `contact launch handles supported and rejected values`. Mock existing platform channels/platform interfaces without adding dependencies. Exercise openSupplierMap through a real host Navigator; assert default center is `LatLng(11.5564,104.9282)`, saved map URLs remain unchanged on cancellation, and repeated location taps open one picker. After host/controller disposal, complete a pending location/picker result and assert no disposed-text-controller exception.

  For launch tests capture Uri/mode: phone creates `tel:012345678`, email uses `mailto:`, and `11.5564,104.9282` maps to `https://www.google.com/maps/search/?api=1&query=11.5564,104.9282`. Preserve saved HTTPS map URLs; reject empty input and `javascript:alert(1)`/`file:///tmp/example` without a launch. False launcher results and exceptions show localized feedback. Add a browser test path for callPhone to prove no `Platform.is*` access; run it with Chrome in Step 5.
- [x] **Step 3: Run** `flutter test test/location_picker_page_test.dart test/supplier_location_flow_test.dart`; expect new coordinate-entry/launch/lifecycle assertions to fail while existing map-tap/Save tests continue passing.
- [x] **Step 4: Implement** synchronized picker coordinate entry with parseCoordinates validation, safe-area controls, localized Save/Cancel and theme-derived control/marker colors. Keep existing initial position and return semantics; dispose any new text controller. Keep OSM attribution visible. In global.dart, guard after returning from the picker before applying a value; remove the supplier phone helper's platform-only branch and use the installed launcher for all supported platforms. Check trimmed data, acceptable map URI scheme/host, false results and exceptions. Preserve existing geolocation timeout/fallback and email subject/body. Localize only touched feedback; do not refactor unrelated helpers.
- [x] **Step 5: Run** `flutter test test/location_utils_test.dart test/location_picker_page_test.dart test/supplier_location_flow_test.dart test/supplier_form_test.dart` and `flutter test --platform chrome test/supplier_location_flow_test.dart`; expect PASS. If Chrome/platform tooling is unavailable, record that specific unverified path instead of claiming browser launch coverage.
- [x] **Step 6: Commit** with subject `frontend: improve supplier location and contact actions`.

### Task 5: Verify the complete group and update its inventory

**Files:** Modify `SCREENS_INDEX.md` and `screen/SCREENS_SUPPLIERS.md`; product files only if a failure is traced to this plan's shared-widget edits.

**Interfaces:** Consume Tasks 1-4 with their existing public routes, sheet adapters, service signatures and test suites; introduce no new production interfaces.

- [x] **Step 1: Run** `flutter test`; expect the complete suite to pass, including search lifecycle, purchases, desktop shell, and existing location tests. Record the actual test count. Fix any regression in its owning changed file and repeat its focused test before repeating the full suite.
- [x] **Step 2: Run** `flutter analyze`; expect no newly introduced diagnostics, recording pre-existing diagnostics separately. Run `flutter build web`; expect exit code 0 and the standard build artifact. Do not substitute a special build mode or claim a browser build proves launcher/device behavior.
- [ ] **Step 3: Inspect the flows manually** at phone portrait/landscape and desktop with sidebar, light/dark, English/Khmer, and 200% text: search/refresh/retry, create, edit/status, delete cancel/confirm, map save/cancel, denied permission, unavailable tiles, keyboard-only actions, and actual phone/email/map launching. Verify normal text contrast at least 4.5:1. Capture list/form/detail/picker screenshots for review. Record device, screen-reader or live-backend checks that cannot be performed as pending; do not mark them passed.
- [x] **Step 4: Update inventory** with confirmed bottom-sheet hosting, all five redesigned screens, test/build evidence, and the exact manual-QA limits. Mark the group complete only when the implementation and automated verification support it; distinguish pending manual QA. Avoid changing other groups' status.
- [x] **Step 5: Review** `git diff --check` and `git diff --stat`; expect no whitespace errors, unrelated modifications, credentials, or generated/dependency changes. Commit the documentation with subject `docs: record supplier redesign verification`.

## Handoff

Review the proposed design and plan before implementation. Recommended execution: **Native**, because five tasks share one controller, route stack and form lifecycle; keeping their context together minimizes coordination. Subagent-driven execution remains available if independent review of each task is preferred. No code is pushed without separate user permission.
