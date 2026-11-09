# Suppliers

Implementation covers all five screens. The list and detail retain the desktop sidebar and now use Home's responsive, theme-aware surfaces. Add/Edit remain modal bottom sheets. Physical-device, live-browser, screen-reader and live-backend checks are still pending.

## Suppliers — `frontend/lib/screen/supplier/supplier_screen.dart`
- **Route:** `/supplier`, registered with `SupplierBinding`.
- **Presentation:** Searchable lazy cards below 1000 usable pixels or above 130% text scaling; otherwise a horizontally contained table. Content is bounded to 1240 pixels with Home gutters.
- **Actions:** One labeled Add Supplier action, refresh, details, and available phone/email/location actions.
- **States:** First-load progress/error with Retry, empty inventory, no matches, retained records during refresh, and a refresh-error banner.
- **Data:** `SupplierController` keeps the trimmed name query across cache reads, refresh and writes. Its unfiltered `suppliers` list remains available to purchase selectors.

## Add supplier — `frontend/lib/screen/supplier/widgets/supplier_add_widget.dart`
- **Host:** Modal bottom sheet opened by `SupplierController.addSupplier`; no separate route.
- **Form:** Shared `SupplierFormWidget`, with required name, phone and email; optional map/address. New records default to active.
- **Behavior:** Inline validation/error feedback, duplicate-save guard, preserved failed drafts, explicit Cancel/Close and safe keyboard scrolling. Saving disables edits and dismissal. Success updates local/cache data and closes only the submitting sheet.

## Edit supplier — `frontend/lib/screen/supplier/widgets/supplier_edit_widget.dart`
- **Host:** The same modal sheet, opened after fetching the integer supplier ID; no separate route.
- **Form:** Shared fields plus the existing Active checkbox; desktop sheets support two columns.
- **Behavior:** Duplicate edit-fetch/update guards, current-route checks after awaits, retained failed drafts and status, and immediate detail updates after success. A failed follow-up refresh does not convert a committed update into a retryable save.

## Supplier detail — `frontend/lib/screen/supplier/widgets/supplier_detail_card_widget.dart`
- **Route:** `/supplier-detail`, receiving the existing typed `SupplierModel` argument.
- **Presentation:** Identity/contact and information cards stack on narrow screens and sit side by side at 900 usable pixels. Complete values wrap; absent dates/optional values use `-`. Empty names and missing IDs are safe.
- **Behavior:** Retains its original supplier while a sheet is open; observes the matching current controller record. Missing contact data disables the corresponding action. Confirmed deletion removes the local/cache record and returns to the existing list once; cancellation/failure keeps detail intact.

## Supplier location picker — `frontend/lib/screen/supplier/location_picker_page.dart`
- **Host:** A `Navigator` page opened by `openSupplierMap` in `frontend/lib/global.dart`; returns `LatLng?`.
- **Presentation:** Map/marker, wrapping OpenStreetMap attribution, labeled coordinate entry and Save/Cancel. Typed coordinates and map taps stay synchronized; coordinate entry remains available without tiles.
- **Behavior:** Validates coordinate bounds with existing utilities. Saved coordinates precede device-location requests; denied/disabled/timed-out location falls back to Phnom Penh. Save retains six-decimal storage through the helper, and cancellation preserves the previous draft. Late results cannot alter an unmounted form.
- **Contact helpers:** Phone/email/map use the existing launcher, handle false results/exceptions and reject unsupported map schemes. The phone helper no longer reads `dart:io Platform` in a browser.

## Verification

Final automated counts and limits are recorded in [the validation record](../2026-11-09-suppliers-redesign-validation.md). Controller/widget coverage includes required-field validation, duplicate writes, failed writes and refreshes, delayed results, stale refresh protection, route/sheet preservation, keyboard activation, 48-pixel tap targets, both themes, Khmer, 200% scaling, coordinate validation and permission fallbacks. Supplier text/status contrast is checked against the 4.5:1 minimum.

Fixture screenshots of desktop/mobile lists, Add/Edit, detail, dark Khmer and the picker are retained in the worktree's ignored `.superpowers/supplier-preview/` directory. Picker previews use in-memory tiles; they do not demonstrate live map availability.

The Chrome test suite could not start because the Flutter test server failed to load its local CanvasKit JS/WASM resources. No browser test pass is claimed. The standard web build is verified separately.

### Pending manual QA

- Physical phone/tablet portrait and landscape, actual keyboard and system-back behavior.
- Spoken screen-reader reading order, focus announcements and translated field errors.
- Live-browser phone/email/map launches and real handlers, permissions and blocked popups.
- Real location permissions/device services, unavailable live tiles, and a picked-location round trip.
- Live API create/edit/delete, duplicate-contact errors and network interruption.
