# Purchases

## Purchases — `frontend/lib/screen/purchases/purchases_screen.dart`
- **Route:** `/purchase`
- **Purpose:** Browses and manages purchase records.
- **Navigation:** Manage or Home recent-purchase action; rows open detail; add/edit actions open forms.
- **UI:** Search, responsive table/cards and add action.
- **State/data:** `PurchaseController`, `PurchaseBinding`, purchase service/models.
- **Custom widgets:** `screen/purchases/widget/purchase_kpi_widget.dart`, `purchase_table_widget.dart`, `purchase_card_widget.dart`, add/edit forms.
- **Current design issues:** None known from the redesign; manual device, browser, and screen-reader checks pending.

## Add purchase — `frontend/lib/screen/purchases/widget/add_purchase_widget.dart`
- **Route:** No route; form widget, host presentation unclear.
- **Purpose:** Creates a purchase with supplier and item details.
- **Navigation:** Purchase list add action; save/cancel returns to host.
- **UI:** Supplier and item entry form, summary and actions.
- **State/data:** `PurchaseController`, purchase/item models and supplier/product data.
- **Custom widgets:** `purchase_item_form.dart`, `purchase_item_row_widget.dart`, `summary_row_widget.dart`.
- **Current design issues:** Dense multi-item form; host constraints unclear.

## Edit purchase — `frontend/lib/screen/purchases/widget/edit_purchase_widget.dart`
- **Route:** No route; form widget, host presentation unclear.
- **Purpose:** Updates an existing purchase.
- **Navigation:** Purchase list action; save/cancel returns to host.
- **UI:** Prefilled purchase/item fields, summary and actions.
- **State/data:** `PurchaseController`, selected purchase/items.
- **Custom widgets:** Purchase item form/row and summary row.
- **Current design issues:** Dense form; host constraints unclear.

## Purchase detail — `frontend/lib/screen/purchases/widget/purchase_detail_widget.dart`
- **Route:** `/purchase-detail`, purchase argument.
- **Purpose:** Reviews one purchase and its line items/totals.
- **Navigation:** Purchase list selection; back returns to list.
- **UI:** Scaffold, purchase summary and item details.
- **State/data:** Purchase argument/model passed by `PurchaseController`.
- **Custom widgets:** `purchase_item_row_widget.dart`, `summary_row_widget.dart`.
- **Current design issues:** Specific issues unclear.

## Redesign notes

Done: the purchase list, add form, edit form, and detail screen are complete. The list has distinct loading, error/retry, empty, and no-match states, keeps search across refresh, and adapts between cards and a table. The add/edit form is one shared supplier-style form with inline validation, a totals summary, a duplicate-submission guard, blocked dismissal while saving, and draft retention on failed writes. The detail screen uses the supplier-style themed layout and closes after a successful delete. The `/purchase` and `/purchase-detail` routes, service methods, and purchase payload keys are unchanged.

Validation: all 29 Purchases tests pass (localization 1, controller 4, card/list/detail 17, form 7). Targeted analysis reports no errors or warnings in the changed paths; three informational `value` deprecation lints remain in the form dropdowns. `flutter build web` exited 0. The full suite passed (416 passed, 1 skipped). Live API, complete browser workflow, physical-device, and screen-reader checks remain pending.
