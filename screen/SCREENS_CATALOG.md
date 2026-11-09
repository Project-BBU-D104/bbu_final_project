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
- **UI:** App bar, search, filter, table/card layout, add button.
- **State/data:** `ProductController`, `ProductBinding`, product service/model.
- **Custom widgets:** `screen/product/widget/product_table_widget.dart`, `product_card_widget.dart`, `filter_widget.dart`; shared search and view-toggle widgets.
- **Current design issues:** Responsive table/card layouts; specific theme deviations unclear.

## Add product — `frontend/lib/screen/product/widget/add_product_widget.dart`
- **Route:** `/add-product`
- **Purpose:** Creates a product with identifying, price, stock and image information.
- **Navigation:** Product list add action; barcode action pushes scanner page. Save/cancel returns to caller/list.
- **UI:** Long form, image upload, barcode scan, save/cancel.
- **State/data:** `ProductController`, product model/service, image upload controller/service.
- **Custom widgets:** `frontend/lib/widget/image_upload_widget.dart`, scanner page below.
- **Current design issues:** Long form; exact spacing/theme issues unclear.

## Edit product — `frontend/lib/screen/product/widget/edit_product_widget.dart`
- **Route:** `/edit-product`, product ID in GetX arguments.
- **Purpose:** Updates an existing product.
- **Navigation:** Product list action; barcode action pushes scanner. Save/cancel returns to list/detail context.
- **UI:** Prefilled product form, image and barcode actions.
- **State/data:** `ProductController`, product ID/model/service.
- **Custom widgets:** `frontend/lib/widget/image_upload_widget.dart`, scanner page.
- **Current design issues:** Long form; exact spacing/theme issues unclear.

## Product detail — `frontend/lib/screen/product/widget/product_card_detail_widget.dart`
- **Route:** `/product-card-detail`, product object argument.
- **Purpose:** Reviews a selected product.
- **Navigation:** Product card action; back returns to products.
- **UI:** Scaffold with product details/card content.
- **State/data:** Product argument/model; controller origin unclear.
- **Custom widgets:** Product card/detail widgets in the same folder.
- **Current design issues:** Specific issues unclear.

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

