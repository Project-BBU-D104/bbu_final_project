# Purchase Requests

## Purchase requests — `frontend/lib/screen/purchase_request/purchase_request_screen.dart`
- **Route:** `/purchase-request`
- **Purpose:** Browses and manages purchase requests.
- **Navigation:** Manage; add/edit/detail actions within the feature.
- **UI:** Search/list cards and create action.
- **State/data:** `PurchaseRequestController`, `PurchaseRequestBinding`, request service/models.
- **Custom widgets:** `screen/purchase_request/widget/card_purchase_request_widget.dart`, request forms.
- **Current design issues:** Specific styling/layout issues unclear.

## Add request — `frontend/lib/screen/purchase_request/widget/add_purchase_request_widget.dart`
- **Route:** No route; embedded form presentation unclear.
- **Purpose:** Creates a purchase request.
- **Navigation:** Request list add action; save/cancel returns to host.
- **UI:** Request form and actions.
- **State/data:** `PurchaseRequestController`, request/item models.
- **Custom widgets:** `purchase_request_form_widget.dart`.
- **Current design issues:** Host presentation unclear.

## Edit request — `frontend/lib/screen/purchase_request/widget/edit_purchase_request_widget.dart`
- **Route:** No route; embedded form presentation unclear.
- **Purpose:** Updates a purchase request.
- **Navigation:** Request list edit action; save/cancel returns to host.
- **UI:** Prefilled request form and actions.
- **State/data:** `PurchaseRequestController`, selected request.
- **Custom widgets:** `purchase_request_form_widget.dart`.
- **Current design issues:** Host presentation unclear.

## Request detail — `frontend/lib/screen/purchase_request/widget/card_purchase_request_detail_widget.dart`
- **Route:** No `GetPage` registration found; actual caller unclear.
- **Purpose:** Displays purchase request details.
- **Navigation:** `card_purchase_request_widget.dart` uses `Get.to` to open a detail widget; whether this exact detail class is instantiated is unclear.
- **UI:** Scaffold, request details and card content.
- **State/data:** Request argument; controller/model source unclear.
- **Custom widgets:** Request card/form components.
- **Current design issues:** Route/caller uncertainty; inspect before redesign.

## Redesign notes

