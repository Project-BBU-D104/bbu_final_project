# Catalog

## Categories — `frontend/lib/screen/category/category_screen.dart`
- **Route:** `/category`
- **Purpose:** Browses and manages product categories.
- **Navigation:** Manage feature card; add/edit forms are reached from list actions. Next: return to Manage or open another feature.
- **UI:** Redesigned 2026-11: app bar with labeled refresh, themed search, wrapping header actions, lazy card list below 800px of available width / table at or above, content centered at max 1240px with 16/32px outer padding, distinct loading/error/empty/no-match states with retry and add actions. Keyboard-activatable rows.
- **State/data:** `CategoryController` (guarded `isLoading`/`isSaving`/`isOpeningEdit`, `loadError`/`formError`, 60s shared cache), `CategoryBinding`, category service. `categoryList`/`searchCategoryList` stay map-shaped for the product form and category filter.
- **Custom widgets:** `screen/category/widget/table_category_widget.dart`, `card_category_widget.dart`, thin `add_category_widget.dart`/`edit_category_widget.dart` adapters over shared `category_form_widget.dart`; shared `custom_app_bar.dart`, `search_widget.dart`.
- **Current design issues:** None known after the 2026-11 redesign; manual device/browser and screen-reader checks remain pending.

## Add category — `frontend/lib/screen/category/widget/add_category_widget.dart`
- **Route:** No route; shown as a dialog at/above 840px, otherwise a bottom sheet.
- **Purpose:** Enters and saves a category.
- **Navigation:** Opened from category list actions; save/cancel returns to its host. Dismissal is blocked while a write is pending.
- **UI:** Thin adapter over shared `category_form_widget.dart`: icon and title header, Category details section, visible labels, required-name validation with focus to the first invalid field, inline error text, persistent Cancel/Save footer with a saving state.
- **State/data:** `CategoryController` (`isSaving`/`formError`); sends trimmed `name` and `description`. Duplicate submissions are ignored and failed saves retain the draft.
- **Custom widgets:** `category_form_widget.dart`.
- **Current design issues:** None known after the 2026-11 redesign; manual checks remain pending.

## Edit category — `frontend/lib/screen/category/widget/edit_category_widget.dart`
- **Route:** No route; shown as a dialog at/above 840px, otherwise a bottom sheet.
- **Purpose:** Updates a selected category.
- **Navigation:** Opened from category list/card action; save/cancel returns to host. A late fetch never opens the form over another route.
- **UI:** Same shared `category_form_widget.dart` as Add category, prefilled from the fetched record.
- **State/data:** `CategoryController` (`isSaving`/`isOpeningEdit`/`formError`), selected category ID; sends trimmed `name` and `description`.
- **Custom widgets:** `category_form_widget.dart`.
- **Current design issues:** None known after the 2026-11 redesign; manual checks remain pending.

## Products — `frontend/lib/screen/product/product_screen.dart`
- **Route:** `/product`
- **Purpose:** Searches, browses and manages products.
- **Navigation:** Manage/Home quick action; add, edit, detail actions. Next: product form/detail or scanner from forms.
- **UI:** Redesigned 2026-11: app bar with labeled refresh, themed search with labeled scan/clear actions, wrapping category filter, lazy card list below 760px of available width and table at/above 760px, content centered at max 1240px with 16/32px outer padding, distinct loading/empty/no-match/failure states with retry banner, labeled FAB add action. Keyboard-activatable rows.
- **State/data:** `ProductController`, `ProductBinding`, product service/model. Search query and category filter compose in `filteredItems`.
- **Custom widgets:** `screen/product/widget/product_table_widget.dart`, `product_card_widget.dart`, `filter_widget.dart`; shared search widget.
- **Current design issues:** None known after the 2026-11 redesign; live-device, camera, and spoken screen-reader checks remain pending.

## Add product — `frontend/lib/screen/product/widget/add_product_widget.dart`
- **Route:** `/add-product`
- **Purpose:** Creates a product with identifying, price, stock and image information.
- **Navigation:** Product list add action; barcode action pushes scanner page. Save/Cancel returns to caller/list.
- **UI:** Redesigned 2026-11 as a thin adapter around shared `product_form_widget.dart`: grouped HomeSectionCard sections (Product information / Pricing / Image and description), one column below 900px and two at/above capped at 1000px, visible labels with required indicators, inline validation copy, focus to first invalid field, persistent footer above the onscreen keyboard, native image upload, web shows preview plus an unavailable-upload message.
- **State/data:** `ProductController` (`isSaving`/`formError`), product model/service, image upload controller/service. Duplicate submissions are ignored while pending; failed saves retain the draft and show a safe error.
- **Custom widgets:** `frontend/lib/screen/product/widget/product_form_widget.dart`, `frontend/lib/widget/image_upload_widget.dart`, scanner page below.
- **Current design issues:** Browser image upload remains unavailable (explicit follow-up).

## Edit product — `frontend/lib/screen/product/widget/edit_product_widget.dart`
- **Route:** `/edit-product`, product ID in GetX arguments.
- **Purpose:** Updates an existing product.
- **Navigation:** Product detail/list action; barcode action pushes scanner. Update/Cancel returns to list/detail context.
- **UI:** Redesigned 2026-11 as a thin adapter around shared `product_form_widget.dart` (same layout/validation as Add product), prefilled by the controller; existing photo preview preserved.
- **State/data:** `ProductController`, product ID/model/service. Prices are sent as validated trimmed text (no invalid-to-zero fallback); failed fetches stay on detail with a safe toast and `isOpeningEdit` guards repeated taps.
- **Custom widgets:** `frontend/lib/screen/product/widget/product_form_widget.dart`, `frontend/lib/widget/image_upload_widget.dart`, scanner page.
- **Current design issues:** Browser image upload remains unavailable (explicit follow-up).

## Product detail — `frontend/lib/screen/product/widget/product_card_detail_widget.dart`
- **Route:** `/product-card-detail`, product object argument.
- **Purpose:** Reviews a selected product.
- **Navigation:** Product card/row action (tap or keyboard Enter); back returns to products.
- **UI:** Redesigned 2026-11: themed scaffold, image above information below 900px of available width and beside it at/above, wrapping information rows in HomeSectionCards (no fixed-aspect tiles), safe fallbacks for absent optional fields, SafeArea footer with wrapping Delete/Edit actions; Edit disabled while opening.
- **State/data:** Product argument map; shared `ProductController` resolved via `Get.find` (no second controller). Confirmed deletion retained.
- **Custom widgets:** Product card/detail widgets in the same folder; shared HomeSectionCard.
- **Current design issues:** Detail shows its route snapshot after edit until reopened (documented `shortcut:` comment); live detail refresh is an explicit follow-up.

## Product scanner — `frontend/lib/widget/test_product_scanner_page.dart`
- **Route:** None; `Navigator.push(MaterialPageRoute)` from add/edit product forms.
- **Purpose:** Scans a barcode and returns its value to the product form.
- **Navigation:** Product form scan action; returns scanned string or dismisses.
- **UI:** Camera/scanner view, scan guide/line, dialog and close controls.
- **State/data:** Scanner package/controller state; exact provider unclear.
- **Custom widgets:** Local `_ScanLine` in the same file.
- **Current design issues:** Name still says “test”; platform camera behavior requires device review.

## Units — `frontend/lib/screen/unit/unit_screen.dart`
- **Route:** `/unit`
- **Purpose:** Manages product units.
- **Navigation:** Manage → Unit; add/edit through list controls.
- **UI:** Search/view toggle, table/card list, form actions.
- **State/data:** `UnitController`, unit service/model.
- **Custom widgets:** `screen/unit/widget/unit_table_widget.dart`, `unit_card_widget.dart`, `add_unit_widget.dart`, `edit_unit_widget.dart`.
- **Current design issues:** Responsive variants and literal sizing; specifics unclear.

## Add unit — `frontend/lib/screen/unit/widget/add_unit_widget.dart`
- **Route:** None; presentation unclear.
- **Purpose:** Creates a unit.
- **Navigation:** Unit list add action; returns to host after save/cancel.
- **UI:** Short form and actions.
- **State/data:** `UnitController`, unit create request.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Edit unit — `frontend/lib/screen/unit/widget/edit_unit_widget.dart`
- **Route:** None; presentation unclear.
- **Purpose:** Updates a unit.
- **Navigation:** Unit list edit action; returns to host after save/cancel.
- **UI:** Prefilled form and actions.
- **State/data:** `UnitController`, selected unit.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Redesign notes

**Done (2026-11): Products workflow** — 5 of 10 screens.
- Products list: lazy themed cards below 760px of available width / table at or above, content centered at max 1240px, distinct loading/empty/no-match/failure states with retry banner, search and category filter compose.
- Product detail: image stacked below 900px / beside at or above, wrapping HomeSectionCard rows, SafeArea footer, confirmed deletion, Edit guarded while opening.
- Add/Edit product: one shared `product_form_widget.dart` with HomeSectionCard sections, inline validation in English and Khmer, duplicate-submission guard, draft retention on failed writes, native image upload (web shows an unavailable message).
- Verification: 205 Flutter tests pass, targeted analysis 0 new diagnostics, `flutter build web` exits 0.

**Done (2026-11): Categories workflow** — 3 of 10 screens.
- Categories list: lazy themed cards below 800px of available width / table at or above, content centered at max 1240px, distinct loading/error/empty/no-match states with retry and add actions, keyboard-activatable rows.
- Add/Edit category: one shared `category_form_widget.dart` (dialog at/above 840px, bottom sheet below), inline validation in English and Khmer, duplicate-submission guard, dismissal blocked while saving, draft retention on failed writes, late-fetch route guard.
- Verification: 281 Flutter tests pass with 1 web-only test skipped; `flutter analyze` reports no diagnostics in the changed files (repository baseline: 57 existing issues elsewhere); `flutter build web` exits 0; changed Dart files are `dart format` clean (the two locale maps excluded, already unformatted at baseline).

**Remaining (4 screens):** Units list/add/edit (3), product scanner (1).
**Pending checks:** browser image upload, physical-device camera, TalkBack/VoiceOver, live-API error paths, manual device/browser category walkthrough.

