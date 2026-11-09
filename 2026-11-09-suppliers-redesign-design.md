# Suppliers Redesign Design

**Status:** Implemented on the isolated `suppliers-redesign` branch; final review and manual-QA limits are recorded in the validation document.
**Request:** Full Suppliers group redesign matching Home, confirmed on 2026-11-09.
**Inventory:** [SCREENS_INDEX.md](SCREENS_INDEX.md), [screen/SCREENS_SUPPLIERS.md](screen/SCREENS_SUPPLIERS.md).

## Intent and scope

Make all five Suppliers screens consistent with Home: supplier list, Add sheet, Edit sheet, detail, and location picker. Preserve the existing supplier workflow while making search, submission, contact actions, and navigation reliable. The concrete layout and behavior choices below are proposals, not previously approved requirements.

## Existing behavior and constraints

- `/supplier` uses `SupplierBinding`; `/supplier-detail` receives a `SupplierModel`. Add/Edit are modal bottom sheets opened by `SupplierController`, not named routes. The location picker is pushed with `Navigator` and returns `LatLng?`.
- Home provides theme-aware cards, maximum content width 1240, and padding 16 below width 600 / 32 otherwise. `DesktopAppShell` surrounds the navigator and reduces the content width; feature screens must use their actual constraints.
- `SupplierController` also supplies the unfiltered `suppliers` list to purchase forms and is registered by several feature bindings. Its default constructor and public list must remain compatible.
- Refresh currently resets `searchSuppliers` regardless of the keyword. Errors are toast-only; update errors are swallowed. Saves have no duplicate-request guard. Edit success calls `Get.offNamed`, even though Edit is a sheet. Detail reads a snapshot argument and indexes an empty name unsafely.
- The create API requires nonempty name, phone, and email. Existing Add/Edit validators require the same. Map/address are optional; Edit exposes status and Add defaults to active. Preserve these rules without inventing phone/email-format restrictions.
- Existing location helpers provide six-decimal coordinates, saved-position precedence, permission fallback to Phnom Penh (`11.5564,104.9282`), and cancellation preserving the field. Existing tests cover coordinate utilities and map selection.
- `callPhone` accesses `dart:io Platform`, which is unsuitable for browser execution. Contact launch failure must give usable feedback; map launch must accept coordinates and HTTP(S) URLs while rejecting other schemes.

## Approaches

1. **List-only restyle:** smaller, but leaves four screens and the broken save/navigation states untouched; does not meet the confirmed scope.
2. **Complete feature redesign using existing layers:** recommended. Keep routes/services, share the duplicated form, reuse Home surfaces and location helpers, and fix only behavior required by these screens.
3. **Generic CRUD framework or new map service:** introduces infrastructure and cross-feature changes this request does not need; defer.

The user selected the complete Suppliers scope. Option 2 is the proposed implementation approach for review.

## Global constraints

- Plans and design documents live in the repository root only.
- Never push code to GitHub or similar without asking the user.
- Never add Co-Authored-By trailers to commit messages.
- Keep Dart SDK constraint `>=3.11.4 <4.0.0`; add no dependencies.
- Preserve `/supplier`, `/supplier-detail`, `SupplierModel` route arguments, Add/Edit sheet hosting, and the `LatLng?` picker result.
- Preserve supplier endpoint `supplier` and payload keys `name`, `phone`, `email`, `map`, `address`, `status`; no backend, migration, environment, generated-platform, or permissions changes.
- Reuse the existing themes, fonts, English/Khmer localization, confirmation dialog, bottom-sheet helper, and location utilities.
- Keep `suppliers` unfiltered for purchase selectors and retain the 60-second cache.

## List and detail

Center list/detail content at maximum width 1240, with Home gutters and card treatment. Reuse `HomeSectionCard` for detail sections; do not put a lazy list inside the scrolling `HomeTabLayout`. Keep `CustomAppBar` and the persistent desktop sidebar.

The list has a short introduction, existing name search, Refresh, and one labeled Add Supplier action. No new filters, KPIs, sorting, pagination, or view toggle. Use lazy cards below 1000 usable pixels or above text scale 1.3; otherwise retain the existing table. Contain table horizontal scrolling inside its card, with minimum table width 1000. Supplier values may truncate in the list with full-value tooltips/semantics; detail wraps complete values.

Separate first-load progress, first-load error with Retry, empty inventory, and no search matches. A refresh keeps existing records visible, marks progress, and shows a retry banner on failure. Reapply the current trimmed, case-insensitive name query on cache load, refresh, and every write; clearing it restores all suppliers.

Detail uses an identity/status header, contact actions, and information sections. At content width 900 and above, identity/contact and information sit side by side; otherwise stack. Use a business icon when the name is empty, `-` for absent optional values/dates, and safe handling for missing arguments/ID. Edit/Delete require an ID. Show status as text with an explicit theme-derived color so translation cannot change color selection.

Keep `/supplier-detail` arguments unchanged, but observe the matching current record in `controller.suppliers`, falling back to the route argument. A successful edit updates that record and closes only its sheet, so detail immediately shows the response. Confirmed successful deletion removes the local/cache record, closes detail once, and refreshes the existing list; a failed delete leaves detail and data intact. The confirmation helper already closes its dialog before calling the operation.

## Shared Add/Edit form

Extract one feature-local `SupplierFormWidget`; keep existing Add/Edit constructors as thin adapters. Use one column below 640 usable pixels and two columns above it for short fields, with address spanning the width. Bound the sheet content to width 760; use safe-area/keyboard insets and vertical scrolling. Keep visible field labels, multiline address, read-only map field with labeled picker control, explicit Cancel/Close, and one Save action. Add defaults to active without a new status control; Edit keeps the active control.

Validate trimmed name, phone, and email in both the form and controller; map/address remain optional. Do not erase an existing map URL merely because it cannot seed coordinates. New picker coordinates retain the established six-decimal storage format.

Add `isSaving`, `isOpeningEdit`, and `formError` controller state. Prevent duplicate writes/edit fetches and overlapping forms. Disable field changes, picker, close, and back during a write; disable barrier/drag dismissal for supplier sheets and provide explicit cancellation. Give the shared sheet helper optional dismissal flags with defaults preserving its other callers.

Failures leave drafts and sheets open with localized inline feedback. A successful POST/PUT is committed success: update `suppliers`, search results, and cache from its response, then close only the submitting sheet. A follow-up GET failure is a list refresh error, not a failed save or a reason to resubmit. Check context/controller lifecycle after awaits; a late result must not pop an unrelated route or write to disposed text controllers. Return `Future<void>` from save so tests/callers can await it.

## Location and contact actions

Keep OpenStreetMap, attribution, existing initial position/permission fallback, tile-provider test seam, and the Save result. Theme the picker controls and add a labeled editable `latitude,longitude` field synchronized with map taps; it supplies keyboard access and remains usable when tiles fail. Validate with `parseCoordinates`; invalid values show an inline error and cannot save. Save uses `formatCoordinates`/existing return semantics; Cancel/back returns null. A tile error must not hide the form, marker controls, attribution, or Save.

Guard repeated picker opens in the shared form. Preserve saved coordinates before attempting device location. Keep the helper's mounted check after permission waits and add the corresponding check after picker return before changing a draft.

Use the existing URL launcher for `tel:`, `mailto:`, coordinates converted to a Google Maps HTTPS URL, and saved HTTP(S) map URLs. Remove the supplier phone helper's platform-only branch. Handle empty data, false launch results, and exceptions with localized feedback; absent contact/location actions are disabled. Reject unsupported map URI schemes rather than launching arbitrary content. Do not redesign global storage/auth helpers.

## Accessibility and localization

Use semantic theme colors in both modes, visible keyboard focus and Material controls, translated labels/tooltips, and at least 48 logical-pixel action targets. Keep normal text contrast at least 4.5:1. Test long English/Khmer names, emails, and addresses at 200% text scale and with the desktop sidebar. Actions wrap/stack and the keyboard cannot obscure Save. Retain normal system back behavior except while a write is committing. Do not add decorative animation or external imagery.

## Validation and exclusions

Use focused controller/widget tests with fake supplier services, in-memory tiles, mocked location/launcher behavior, and existing Home theme/locale setup. Then run the full Flutter suite, static analysis, and standard web build. Review live mobile/desktop flows, both themes/locales, keyboard navigation, denied permission, and unavailable tiles; explicitly report any manual checks not performed.

No backend/API redesign, new dependencies, batch operations, import/export, supplier photos, purchase-form redesign, or application-wide search rewrite. The Products design/plan already in the root remains independent. Product implementation may also touch shared search styling: inspect the current file at execution time and keep one compatible change.
