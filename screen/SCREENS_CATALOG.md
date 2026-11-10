# Catalog

## Categories — `frontend/lib/screen/category/category_screen.dart`
- **Route:** `/category`
- **Purpose:** Browses and manages product categories.
- **Navigation:** Manage feature card; add/edit forms are reached from list actions. Next: return to Manage or open another feature.
- **UI:** App bar, search/view toggle, responsive table/cards, add action.
- **State/data:** `CategoryController`, `CategoryBinding`, category service/model.
- **Custom widgets:** `screen/category/widget/table_category_widget.dart`, `card_category_widget.dart`, `add_category_widget.dart`, `edit_category_widget.dart`; shared `custom_app_bar.dart`, `button_change_table_or_card_widget.dart`.
- **Current design issues:** Responsive table/card variants; exact hardcoded values unclear.

## Add category — `frontend/lib/screen/category/widget/add_category_widget.dart`
- **Route:** No route; feature form widget. Host presentation unclear.
- **Purpose:** Enters and saves a category.
- **Navigation:** Opened from category list action; save/cancel returns to its host.
- **UI:** Form fields and save/cancel actions.
- **State/data:** `CategoryController`, category create request.
- **Custom widgets:** None established.
- **Current design issues:** Host and styling specifics unclear.

## Edit category — `frontend/lib/screen/category/widget/edit_category_widget.dart`
- **Route:** No route; feature form widget. Host presentation unclear.
- **Purpose:** Updates a selected category.
- **Navigation:** Opened from category list/card action; save/cancel returns to host.
- **UI:** Prefilled form and actions.
- **State/data:** `CategoryController`, selected category.
- **Custom widgets:** None established.
- **Current design issues:** Host and styling specifics unclear.

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

