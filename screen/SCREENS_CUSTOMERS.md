# Customers

## Customers — `frontend/lib/screen/customer/customer_screen.dart`
- **Route:** `/customer`
- **Purpose:** Searches and manages customer records.
- **Navigation:** Manage; add/edit actions open forms. Sale customer selection is a separate sale-flow selector.
- **UI:** Search, KPI/list content, table/card presentation and actions.
- **State/data:** `CustomerController`, `CustomerBinding`, customer service/model.
- **Custom widgets:** `screen/customer/widget/customer_table_widget.dart`, `customer_card_widget.dart`, `customer_kpi_widget.dart`, add/edit forms; shared view toggle/search/app bar.
- **Current design issues:** Responsive layouts; exact style issues unclear.

## Add customer — `frontend/lib/screen/customer/widget/add_customer_widget.dart`
- **Route:** None; form widget, host presentation unclear.
- **Purpose:** Creates a customer record.
- **Navigation:** Customer list add action; save/cancel returns to host.
- **UI:** Customer fields and submit/cancel actions.
- **State/data:** `CustomerController`, customer create request.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Edit customer — `frontend/lib/screen/customer/widget/edit_customer_widget.dart`
- **Route:** None; form widget, host presentation unclear.
- **Purpose:** Updates a customer record.
- **Navigation:** Customer list edit action; save/cancel returns to host.
- **UI:** Prefilled customer fields and actions.
- **State/data:** `CustomerController`, selected customer.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Sale customer selector — `frontend/lib/screen/sale/widget/select_customer_card_widget.dart`
- **Route:** No named route; selection widget/dialog host unclear.
- **Purpose:** Chooses a customer for the active sale.
- **Navigation:** Sale flow customer action; selecting or dismissing returns to sale.
- **UI:** Customer selection cards/list and selection action.
- **State/data:** Customer list/state; exact controller injection unclear from this inventory scan.
- **Custom widgets:** Local `_CustomerPicker`; customer model/card.
- **Current design issues:** Embedded selector layout and host constraints require review.

## Redesign notes

