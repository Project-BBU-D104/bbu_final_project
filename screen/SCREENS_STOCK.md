# Stock

## Warehouses — `frontend/lib/screen/stock/warehouse/warehouse_screen.dart`
- **Route:** `/warehouse`
- **Purpose:** Manages warehouse records.
- **Navigation:** Manage; add/edit/detail actions in feature. Detail route receives selected warehouse.
- **UI:** Search, table/card list, CRUD actions.
- **State/data:** `WarehouseController`, `WarehouseBinding`, warehouse service/model.
- **Custom widgets:** Adjacent warehouse table/card/add/edit/detail widgets; shared search/view-toggle/app bar.
- **Current design issues:** Responsive list variants; specifics unclear.

## Add warehouse — `frontend/lib/screen/stock/warehouse/widget/add_warehouse_widget.dart`
- **Route:** None; form hosting unclear.
- **Purpose:** Creates a warehouse.
- **Navigation:** Warehouse list add action; save/cancel returns to host.
- **UI:** Warehouse form and actions.
- **State/data:** `WarehouseController`, warehouse service/model.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Edit warehouse — `frontend/lib/screen/stock/warehouse/widget/edit_warehouse_widget.dart`
- **Route:** None; form hosting unclear.
- **Purpose:** Updates a warehouse.
- **Navigation:** Warehouse list edit action; save/cancel returns to host.
- **UI:** Prefilled form and actions.
- **State/data:** `WarehouseController`, selected warehouse.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Warehouse detail — `frontend/lib/screen/stock/warehouse/widget/ware_house_detail_widget.dart`
- **Route:** `/warehouse-detail`; route registered, caller unclear.
- **Purpose:** Reviews a warehouse record.
- **Navigation:** Intended from warehouse list; caller not found in scan.
- **UI:** Scaffold, warehouse detail cards.
- **State/data:** Warehouse argument/controller source unclear.
- **Custom widgets:** `warehouse_card_widget.dart`, app bar.
- **Current design issues:** Caller uncertainty.

## Warehouse stock — `frontend/lib/screen/stock/warehouse_stock/warehouse_stock_screen.dart`
- **Route:** `/warehouse-stock`
- **Purpose:** Views and manages stock at warehouses.
- **Navigation:** Manage; add/edit actions from stock list.
- **UI:** Search/list and stock controls.
- **State/data:** `WarehouseStockController`, binding, warehouse stock service/model.
- **Custom widgets:** `warehouse_stock_table_widget.dart`, `warehouse_stock_card_widget.dart`, add/edit widgets.
- **Current design issues:** Responsive list variants; specifics unclear.

## Add warehouse stock — `frontend/lib/screen/stock/warehouse_stock/widget/add_warehouse_stock_widget.dart`
- **Route:** None; form hosting unclear.
- **Purpose:** Adds stock to a warehouse record.
- **Navigation:** Warehouse stock action; save/cancel returns to host.
- **UI:** Stock form and actions.
- **State/data:** `WarehouseStockController`, warehouse/product/stock data.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Edit warehouse stock — `frontend/lib/screen/stock/warehouse_stock/widget/edit_warehouse_stock_widget.dart`
- **Route:** None; form hosting unclear.
- **Purpose:** Edits a warehouse stock record.
- **Navigation:** Warehouse stock action; save/cancel returns to host.
- **UI:** Prefilled stock form and actions.
- **State/data:** `WarehouseStockController`, selected stock record.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Stock adjustments — `frontend/lib/screen/stock/stock_adjustment/stock_adjustment_screen.dart`
- **Route:** `/stock-adjustment`
- **Purpose:** Records and reviews stock adjustments.
- **Navigation:** Manage; add/edit/detail actions.
- **UI:** Search, table/card list, add action and detail navigation.
- **State/data:** `StockAdjustmentController`, binding, stock adjustment service/model.
- **Custom widgets:** Feature table/card/add/edit/detail widgets; shared view toggle/search.
- **Current design issues:** Responsive layouts; specific styling unclear.

## Add stock adjustment — `frontend/lib/screen/stock/stock_adjustment/widget/add_stock_adjustment_widget.dart`
- **Route:** None; form host unclear.
- **Purpose:** Creates an adjustment for stock.
- **Navigation:** Adjustment list add action; save/cancel returns to host.
- **UI:** Adjustment form, type/quantity and actions.
- **State/data:** `StockAdjustmentController`, adjustment model/service and stock data.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Edit stock adjustment — `frontend/lib/screen/stock/stock_adjustment/widget/edit_stock_adjustment_type_widget.dart`
- **Route:** No named route; exact host unclear.
- **Purpose:** Updates an adjustment/type record.
- **Navigation:** Adjustment feature action; save/cancel returns to host.
- **UI:** Prefilled form and actions.
- **State/data:** `StockAdjustmentController`, selected adjustment.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Stock adjustment detail — `frontend/lib/screen/stock/stock_adjustment/widget/stock_adjustment_detail_widget.dart`
- **Route:** `/stock-adjustment-detail`, selected adjustment argument.
- **Purpose:** Reviews one stock adjustment.
- **Navigation:** Adjustment list selection; back returns to list.
- **UI:** Scaffold and adjustment detail.
- **State/data:** Adjustment argument, `StockAdjustmentController`.
- **Custom widgets:** Feature adjustment card/detail components.
- **Current design issues:** Specific issues unclear.

## Stock transfers — `frontend/lib/screen/stock/stock_transfer/stock_transfer_screen.dart`
- **Route:** `/stock-transfer`
- **Purpose:** Records and reviews transfers between warehouses.
- **Navigation:** Manage; create/edit/detail actions.
- **UI:** Search/list, table/card modes and transfer actions.
- **State/data:** `ProductTransferController`, binding, transfer service/models.
- **Custom widgets:** Feature transfer table/card/add/edit/detail widgets.
- **Current design issues:** Specific issues unclear.

## Add stock transfer — `frontend/lib/screen/stock/stock_transfer/widget/add_stock_transfer_widget.dart`
- **Route:** None; form host unclear.
- **Purpose:** Creates a stock transfer.
- **Navigation:** Transfer list add action; save/cancel returns to host.
- **UI:** Source/destination, item form and actions.
- **State/data:** `ProductTransferController`, warehouse/product/transfer data.
- **Custom widgets:** None established.
- **Current design issues:** Multi-part form; host constraints unclear.

## Edit stock transfer — `frontend/lib/screen/stock/stock_transfer/widget/edit_stock_transfer_widget.dart`
- **Route:** None; form host unclear.
- **Purpose:** Updates a stock transfer.
- **Navigation:** Transfer list edit action; save/cancel returns to host.
- **UI:** Prefilled transfer form and actions.
- **State/data:** `ProductTransferController`, selected transfer.
- **Custom widgets:** None established.
- **Current design issues:** Multi-part form; host constraints unclear.

## Stock transfer detail — `frontend/lib/screen/stock/stock_transfer/widget/stock_transfer_detail_card_widget.dart`
- **Route:** `/stock-transfer-detail`, selected transfer argument.
- **Purpose:** Reviews one stock transfer.
- **Navigation:** Transfer list; controller opens detail with selected transfer.
- **UI:** Scaffold and transfer detail cards.
- **State/data:** Transfer argument/model.
- **Custom widgets:** Transfer card and item detail components.
- **Current design issues:** Specific issues unclear.

## Redesign notes

