# Customers

## Customers — `frontend/lib/screen/customer/customer_screen.dart`
- **Route:** `/customer`
- **Purpose:** Searches and manages customer records.
- **Navigation:** Manage; add/edit actions open the shared form (dialog at screen width >= 840, bottom sheet below). Sale customer selection is a separate sale-flow selector.
- **UI:** Redesigned on the unit/supplier template: responsive header (back button + headline on desktop, themed app bar on mobile), Refresh and Add Customer actions, bordered search with live count, centered max-1240 content; themed cards below 800px content width / table at or above (also falls back to cards at large text scale); distinct loading, error-with-retry, empty (with add button), and no-match states; pull-to-refresh. KPI grid and FAB removed.
- **State/data:** `CustomerController` (guarded loads/writes, 60-second shared cache, retryable `loadError`, search that survives refresh/writes), `CustomerBinding`, customer service. Records stay `Map<String, dynamic>`.
- **Custom widgets:** `customer_table_widget.dart` (`items`), `customer_card_widget.dart` (`item`), shared `customer_form_widget.dart`; shared view toggle/search/app bar. `customer_kpi_widget.dart` deleted (orphaned).
- **Status:** Redesign implemented; manual device/browser QA pending.

## Add customer — `frontend/lib/screen/customer/widget/add_customer_widget.dart`
- **Route:** None; thin wrapper over `CustomerFormWidget`, hosted as dialog (>= 840px) or non-dismissible bottom sheet.
- **Purpose:** Creates a customer record.
- **Navigation:** Customer list Add Customer / empty-state action; save/cancel returns to host.
- **UI:** Shared form: grouped "Customer details" section, inline validation (name required, exact English/Khmer copy), optional phone/address, Active checkbox, photo upload (`ImageUploadWidget`, bucket `customer`/folder `customers`) with the browser-unavailable message on web; duplicate-submission guard, dismissal blocked while saving or uploading, draft retention and safe error copy on failed writes.
- **State/data:** `CustomerController.onSaveCustomer`; payload `{photo, name, phone, address, is_active}` unchanged (trimmed, real bool).
- **Status:** Redesign implemented; manual device/browser QA pending.

## Edit customer — `frontend/lib/screen/customer/widget/edit_customer_widget.dart`
- **Route:** None; thin wrapper over `CustomerFormWidget` (`customerId`), same hosting as Add.
- **Purpose:** Updates a customer record.
- **Navigation:** Customer list row tap / edit action; save/cancel returns to host.
- **UI:** Same shared form, prefilled from `getCustomerById`; late fetches never open on another page; failed updates keep the draft.
- **State/data:** `CustomerController.onUpdateCustomer`; payload unchanged.
- **Status:** Redesign implemented; manual device/browser QA pending.

## Sale customer selector — `frontend/lib/screen/sale/widget/select_customer_card_widget.dart`
- **Route:** No named route; themed card in the current-sale screen opens a picker bottom sheet.
- **Purpose:** Chooses a customer for the active sale.
- **Navigation:** Sale flow customer action; selecting or dismissing returns to sale. Dismiss without selecting keeps the current customer.
- **UI:** Redesigned: localized card (name/phone or translated fallbacks) on the theme card surface; picker sheet with Close button, local search by name or phone, loading spinner, empty state with Retry (`loadCustomers`), themed selected check. `SaleController` contract untouched.
- **State/data:** `SaleController.customers`, `isCustomersLoading`, `selectedCustomer`, `selectCustomer`, `loadCustomers` (unchanged).
- **Status:** Redesign implemented; manual device/browser QA pending.

## Redesign notes

Implemented 2026-11-12 on branch `customers-redesign`, mirroring the Units group (the newest completed redesign) as the concrete template for the supplier reference in CLAUDE.md.

Scope: responsive list (cards/table switch at 800px content width with a large-text fallback, max-1240 centered content, distinct loading/error/empty/no-match states with retry banner and pull-to-refresh), one shared guarded Add/Edit form (inline validation, duplicate-submission guard, PopScope dismissal block while saving/uploading, draft retention on failed writes, shared upload preview cleared once on form entry, web image-unavailable message), and the localized searchable sale selector. Controller: guarded overlapping loads, revision-checked responses, 60-second shared cache, search query seeded from the global SearchController and preserved across refresh/writes, confirmed deletion with toasts. Unchanged contracts: `/customer` route + binding, payload keys `{photo, name, phone, address, is_active}`, `SaleController` surface, `AppCachedImage` photo rendering (external pravatar fallback removed).

Verified results:
- `flutter test`: 340 passed, 1 web-only test skipped, exit 0 (baseline before this work: 308 + 1; 32 new customer tests across localization, controller, list redesign, forms, and selector).
- `flutter analyze`: zero diagnostics in every changed file; 53 pre-existing issues in untouched files.
- `flutter build web`: exit 0.
- `dart format --set-exit-if-changed`: clean on all changed Dart files; the two locale maps were unformatted at baseline and excluded from the gate.

Pending manual checks: physical-device camera/gallery upload to Supabase, live-browser appearance of the web image fallback, TalkBack/VoiceOver spoken checks, live-API error paths (load/save/delete failures against the real backend), and an in-app walk of list → add → edit → delete and the sale selector under DesktopAppShell.