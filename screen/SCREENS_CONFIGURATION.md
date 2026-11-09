# Configuration

## Payment types — `frontend/lib/screen/payment_type/payment_type_screen.dart`
- **Route:** `/payment-type`
- **Purpose:** Manages payment method definitions.
- **Navigation:** Manage; add/edit from list.
- **UI:** Table/card list and CRUD actions.
- **State/data:** `PaymentTypeController`, payment type service/model.
- **Custom widgets:** `payment_type_table_widget.dart`, `payment_type_card_widget.dart`, add/edit widgets.
- **Current design issues:** Responsive alternatives; specifics unclear.

## Add payment type — `frontend/lib/screen/payment_type/widget/add_payment_type_widget.dart`
- **Route:** None; host presentation unclear.
- **Purpose:** Creates a payment type.
- **Navigation:** Payment type list add action; save/cancel returns to host.
- **UI:** Form and actions.
- **State/data:** `PaymentTypeController`, create request.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Edit payment type — `frontend/lib/screen/payment_type/widget/edit_payment_type_widget.dart`
- **Route:** None; host presentation unclear.
- **Purpose:** Updates a payment type.
- **Navigation:** List edit action; save/cancel returns to host.
- **UI:** Prefilled form and actions.
- **State/data:** `PaymentTypeController`, selected type.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Currencies — `frontend/lib/screen/currency/currency_screen.dart`
- **Route:** `/currency`
- **Purpose:** Manages currencies.
- **Navigation:** Manage; add/edit from list.
- **UI:** Table/card list and CRUD actions.
- **State/data:** `CurrencyController`, currency service/model.
- **Custom widgets:** `currency_table_widget.dart`, `currency_card_widget.dart`, add/edit widgets.
- **Current design issues:** Responsive variants; specifics unclear.

## Add currency — `frontend/lib/screen/currency/widget/add_currency_widget.dart`
- **Route:** None; host presentation unclear.
- **Purpose:** Creates a currency.
- **Navigation:** Currency list add action; save/cancel returns to host.
- **UI:** Currency form and actions.
- **State/data:** `CurrencyController`, currency create request.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Edit currency — `frontend/lib/screen/currency/widget/edit_currency_widget.dart`
- **Route:** None; host presentation unclear.
- **Purpose:** Updates a currency.
- **Navigation:** List edit action; save/cancel returns to host.
- **UI:** Prefilled form and actions.
- **State/data:** `CurrencyController`, selected currency.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## System configuration — `frontend/lib/screen/system_configuration/system_configuration_screen.dart`
- **Route:** `/system-configuration`
- **Purpose:** Manages application configuration entries.
- **Navigation:** Manage; add/edit/detail actions.
- **UI:** Search/list, table/card alternatives, CRUD actions.
- **State/data:** `SystemConfigurationController`, system configuration service/model.
- **Custom widgets:** `table_system_configuration_widget.dart`, `card_system_configuration_widget.dart`, add/edit/detail widgets.
- **Current design issues:** Table/card variants; specifics unclear.

## Add configuration — `frontend/lib/screen/system_configuration/widget/add_system_configuration_widget.dart`
- **Route:** No named route; host presentation unclear.
- **Purpose:** Creates a configuration entry.
- **Navigation:** Configuration list add action; save/cancel returns to host.
- **UI:** Key/value form and actions.
- **State/data:** `SystemConfigurationController`, configuration model/service.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Edit configuration — `frontend/lib/screen/system_configuration/widget/edit_system_configuration_widget.dart`
- **Route:** No named route; host presentation unclear.
- **Purpose:** Updates a configuration entry.
- **Navigation:** List edit action; save/cancel returns to host.
- **UI:** Stateful form, validation/save and actions.
- **State/data:** `SystemConfigurationController`, selected configuration.
- **Custom widgets:** None established.
- **Current design issues:** Form complexity and host constraints need review.

## Configuration detail — `frontend/lib/screen/system_configuration/widget/card_system_cofiguration_detail_widget.dart`
- **Route:** `/system-configuration-detail`, configuration map argument.
- **Purpose:** Reviews one configuration entry.
- **Navigation:** Configuration list detail action; back returns to list.
- **UI:** Scaffold and key/value detail card.
- **State/data:** Map passed through GetX arguments.
- **Custom widgets:** Configuration card component.
- **Current design issues:** Specific issues unclear.

## Redesign notes

