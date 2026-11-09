# Purchases

## Purchases — `frontend/lib/screen/purchases/purchases_screen.dart`
- **Route:** `/purchase`
- **Purpose:** Browses and manages purchase records.
- **Navigation:** Manage or Home recent-purchase action; rows open detail; add/edit actions open forms.
- **UI:** KPI summary, search, responsive table/cards and add action.
- **State/data:** `PurchaseController`, `PurchaseBinding`, purchase service/models.
- **Custom widgets:** `screen/purchases/widget/purchase_kpi_widget.dart`, `purchase_table_widget.dart`, `purchase_card_widget.dart`, add/edit forms.
- **Current design issues:** Multiple responsive/list representations; exact theme deviations unclear.

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

