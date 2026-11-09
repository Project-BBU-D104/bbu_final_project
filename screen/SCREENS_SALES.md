# Sales

## Sale product selection — `frontend/lib/screen/sale/sale_screen/sale_screen.dart`
- **Route:** `/sale`
- **Purpose:** Selects products and starts a customer sale.
- **Navigation:** Manage, Home quick action, or sale history action; continue opens `/current-sale`.
- **UI:** Product search/grid, cart summary/footer, empty state and customer selector.
- **State/data:** `SaleController`, `SaleBinding`, product/sale services and sale/cart models.
- **Custom widgets:** `screen/sale/widget/card_item_widget.dart`, `payment_footer_widget.dart`, `select_customer_card_widget.dart`.
- **Current design issues:** Product-grid layout is responsive; inspect literal colors/spacing in source before redesign.

## Current sale — `frontend/lib/screen/sale/current_sale/current_sale_screen.dart`
- **Route:** `/current-sale`
- **Purpose:** Reviews the active cart and adjusts quantities before payment.
- **Navigation:** Sale screen continue action; checkout proceeds to payment; back returns to sale.
- **UI:** Cart item rows, summary and payment/continue actions.
- **State/data:** `SaleController`, active cart and sale item models.
- **Custom widgets:** `screen/sale/current_sale/widget/current_sale_item_widget.dart`, `summary_order_widget.dart`.
- **Current design issues:** Exact styling concerns unclear.

## Sale payment — `frontend/lib/screen/payment/payment_screen.dart`
- **Route:** `/sale-payment`
- **Purpose:** Records payment method and amount for the current sale.
- **Navigation:** Current sale checkout; success opens payment success page.
- **UI:** Payment form/method cards and confirmation action.
- **State/data:** `PaymentController`, `PaymentBinding`, payment/sale state and payment type service.
- **Custom widgets:** `screen/payment/widget/payment_form_widget.dart`, `screen/payment/sale_with_payment/widget/payment_method_card_widget.dart`.
- **Current design issues:** Exact theme issues unclear.

## Payment success — `frontend/lib/screen/sale/widget/payment_success_widget.dart`
- **Route:** `/payment-success`
- **Purpose:** Confirms a sale and presents receipt details/actions.
- **Navigation:** Payment completion; action routes to sale or returns toward Home. Exact route selection depends on action.
- **UI:** Success state, receipt summary and follow-up buttons.
- **State/data:** Receipt route argument; sale/payment models.
- **Custom widgets:** Shared app bar/receipt components unclear.
- **Current design issues:** Review receipt print/layout on target screen sizes.

## Sales list — `frontend/lib/screen/sale/sale_list/sale_list_screen.dart`
- **Route:** `/sale-list`
- **Purpose:** Browses recorded sales.
- **Navigation:** Manage or Home recent-sales action; row opens `/sale-list-detail`, action may start `/sale`.
- **UI:** Search/list cards and detail/action controls.
- **State/data:** `SaleListController`, sale list service/models.
- **Custom widgets:** `screen/sale/sale_list/widget/sale_card_widget.dart` and detail widget.
- **Current design issues:** Specific issues unclear.

## Sale detail — `frontend/lib/screen/sale/sale_list/widget/sale_list_detail_widget.dart`
- **Route:** `/sale-list-detail`, selected sale argument.
- **Purpose:** Reviews a recorded sale’s items and payment information.
- **Navigation:** Sales list card; back returns to list.
- **UI:** Scaffold, detail rows/cards and totals.
- **State/data:** Sale argument from `SaleListController`, sale models.
- **Custom widgets:** Local sale detail/card components.
- **Current design issues:** Specific issues unclear.

## Redesign notes

