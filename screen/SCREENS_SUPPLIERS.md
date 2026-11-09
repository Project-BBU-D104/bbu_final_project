# Suppliers

## Suppliers — `frontend/lib/screen/supplier/supplier_screen.dart`
- **Route:** `/supplier`
- **Purpose:** Searches and manages supplier records.
- **Navigation:** Manage/Home shortcut; add/edit/detail actions. A supplier form can open the location picker.
- **UI:** List with table/card alternatives, search and CRUD actions.
- **State/data:** `SupplierController`, `SupplierBinding`, supplier service/model.
- **Custom widgets:** `screen/supplier/widgets/supplier_table_widget.dart`, `supplier_card_widget.dart`, `supplier_add_widget.dart`, `supplier_edit_widget.dart`, `supplier_detail_card_widget.dart`; shared view toggle/search/app bar.
- **Current design issues:** Responsive alternative layouts; exact theme inconsistencies unclear.

## Add supplier — `frontend/lib/screen/supplier/widgets/supplier_add_widget.dart`
- **Route:** None; feature form, host presentation unclear.
- **Purpose:** Creates a supplier record.
- **Navigation:** Supplier list add action; location button opens map picker; save/cancel returns to host.
- **UI:** Contact/details form, location entry, actions.
- **State/data:** `SupplierController`, supplier service/model.
- **Custom widgets:** Location picker via `global.dart` helper.
- **Current design issues:** Host presentation unclear.

## Edit supplier — `frontend/lib/screen/supplier/widgets/supplier_edit_widget.dart`
- **Route:** None; feature form, host presentation unclear.
- **Purpose:** Updates a supplier record.
- **Navigation:** Supplier list edit action; location picker available; save/cancel returns to host.
- **UI:** Prefilled contact/details form and actions.
- **State/data:** `SupplierController`, selected supplier.
- **Custom widgets:** Location picker via `global.dart` helper.
- **Current design issues:** Host presentation unclear.

## Supplier detail — `frontend/lib/screen/supplier/widgets/supplier_detail_card_widget.dart`
- **Route:** `/supplier-detail`, supplier argument.
- **Purpose:** Reviews a selected supplier’s contact and location details.
- **Navigation:** Supplier list detail action; back returns to supplier list.
- **UI:** Scaffold, information cards and contact/map actions.
- **State/data:** Supplier object passed in GetX arguments.
- **Custom widgets:** `frontend/lib/widget/custom_app_bar.dart` and local detail card.
- **Current design issues:** Has conditional Scaffold rendering; visual consistency unclear.

## Supplier location picker — `frontend/lib/screen/supplier/location_picker_page.dart`
- **Route:** None; pushed by `Navigator.push(MaterialPageRoute)` through `openSupplierMap` in `frontend/lib/global.dart`.
- **Purpose:** Picks a map coordinate for a supplier.
- **Navigation:** Add/edit supplier location action; returns selected `LatLng` to form.
- **UI:** Map, marker/selection, app bar/back and confirm action.
- **State/data:** Initial coordinate, device location/permission via geolocator, `latlong2`.
- **Custom widgets:** Shared `CustomAppBar`; location helpers in `frontend/lib/utils/location_utils.dart`.
- **Current design issues:** Depends on location permission and map availability; device-specific layout needs review.

## Redesign notes

