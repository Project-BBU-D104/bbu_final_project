# Suppliers

Implementation covers all five screens. The desktop list uses one page header, a full-width table and grouped row actions. Add/Edit use centered dialogs on wide screens and bottom sheets on narrow screens. Physical-device, screen-reader and live-backend checks are still pending.

## Suppliers — `frontend/lib/screen/supplier/supplier_screen.dart`
- **Route:** `/supplier`, registered with `SupplierBinding`.
- **Presentation:** Searchable lazy cards below 800 usable pixels or above 130% text scaling; otherwise a table that fills its panel with horizontal scrolling when needed. Content is bounded to 1240 pixels with Home gutters. Desktop shows one title, right-aligned actions, a bounded search field and result count.
- **Actions:** One labeled Add Supplier action, refresh, details, and available phone/email/location actions.
- **States:** First-load progress/error with Retry, empty inventory, no matches, retained records during refresh, and a refresh-error banner.
- **Data:** `SupplierController` keeps the trimmed name query across cache reads, refresh and writes. Its unfiltered `suppliers` list remains available to purchase selectors.

## Add supplier — `frontend/lib/screen/supplier/widgets/supplier_add_widget.dart`
- **Host:** Opened by `SupplierController.addSupplier`; a centered dialog at 840 or more content pixels and a bottom sheet below that width. No separate route.
- **Form:** Shared `SupplierFormWidget`, with required name, phone and email; optional map/address. New records default to active.
- **Behavior:** Inline validation/error feedback, duplicate-save guard, preserved failed drafts, explicit Cancel/Close and safe keyboard scrolling. Saving disables edits and dismissal. Success updates local/cache data and closes only the submitting sheet.

## Edit supplier — `frontend/lib/screen/supplier/widgets/supplier_edit_widget.dart`
- **Host:** The same responsive dialog/sheet, opened after fetching the integer supplier ID; no separate route.
- **Form:** Grouped contact/location fields and an Active switch. Name spans the form width; phone/email sit side by side when space permits.
- **Behavior:** Duplicate edit-fetch/update guards, current-route checks after awaits, retained failed drafts and status, and immediate detail updates after success. A failed follow-up refresh does not convert a committed update into a retryable save.

## Supplier detail — `frontend/lib/screen/supplier/widgets/supplier_detail_card_widget.dart`
- **Route:** `/supplier-detail`, receiving the existing typed `SupplierModel` argument.
- **Presentation:** The supplier name heads the page, with desktop Edit/Delete actions in the header. Contact and location cards stack on narrow screens and sit side by side at 900 usable pixels. Complete values wrap; absent dates/optional values use `-`. Empty names and missing IDs are safe.
- **Behavior:** Retains its original supplier while a sheet is open; observes the matching current controller record. Missing contact data disables the corresponding action. Confirmed deletion removes the local/cache record and returns to the existing list once; cancellation/failure keeps detail intact.

## Supplier location picker — `frontend/lib/screen/supplier/location_picker_page.dart`
- **Host:** A `Navigator` page opened by `openSupplierMap` in `frontend/lib/global.dart`; returns `LatLng?`.
- **Presentation:** Map/marker and a coordinate panel sit side by side on wide screens; narrow screens retain controls below the map. OpenStreetMap attribution wraps, and Save/Cancel remain available. Typed coordinates and map taps stay synchronized; coordinate entry remains available without tiles.
- **Behavior:** Validates coordinate bounds with existing utilities. Saved coordinates precede device-location requests; denied/disabled/timed-out location falls back to Phnom Penh. Save retains six-decimal storage through the helper, and cancellation preserves the previous draft. Late results cannot alter an unmounted form.
- **Contact helpers:** Phone/email/map use the existing launcher, handle false results/exceptions and reject unsupported map schemes. The phone helper no longer reads `dart:io Platform` in a browser.

## Verification

The current full `flutter test --no-pub` suite passes 229 tests, and the standard application web build passes. Supplier code, the shared heading change and focused tests have no analysis findings. Controller/widget coverage includes required-field validation, duplicate writes, failed writes and refreshes, delayed results, stale refresh protection, dialog/sheet preservation, supplier names that match translation keys, keyboard activation, 48-pixel tap targets, both themes, Khmer, 200% scaling, coordinate validation and permission fallbacks. Supplier text/status contrast is checked against the 4.5:1 minimum.

Chrome screenshots of the actual supplier widgets with sample data are retained in the ignored `.superpowers/supplier-web-redesign/screenshots/` directory. They cover desktop/mobile lists, Add/Edit, required-field validation, detail, Khmer, dark mode and the picker.

Chrome interaction checks verify opening Add from the list, required validation after Save, and opening Edit from detail, with no uncaught browser exceptions. The sample-data preview bundles rendering resources locally. These browser checks do not replace live API or external-handler QA.

### Pending manual QA

- Physical phone/tablet portrait and landscape, actual keyboard and system-back behavior.
- Spoken screen-reader reading order, focus announcements and translated field errors.
- Live-browser phone/email/map launches and real handlers, permissions and blocked popups.
- Real location permissions/device services, unavailable live tiles, and a picked-location round trip.
- Live API create/edit/delete, duplicate-contact errors and network interruption.
