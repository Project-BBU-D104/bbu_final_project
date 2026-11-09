# People & Access

## Users — `frontend/lib/screen/user/user_screen.dart`
- **Route:** `/user`
- **Purpose:** Manages user accounts.
- **Navigation:** Manage; add/edit/detail actions. Detail route is registered; caller is unclear.
- **UI:** Search/list, KPI and card/table alternatives, CRUD actions.
- **State/data:** `UserController`, `UserBinding`, user service/model.
- **Custom widgets:** `user_table_list_widget.dart`, `user_card_list_widget.dart`, `kpi_user_widget.dart`, add/edit/detail widgets.
- **Current design issues:** Alternative responsive presentations; specifics unclear.

## Add user — `frontend/lib/screen/user/widget/add_user_widget.dart`
- **Route:** No route; host presentation unclear.
- **Purpose:** Creates a user account.
- **Navigation:** User list add action; save/cancel returns to host.
- **UI:** Account form and actions.
- **State/data:** `UserController`, user service/model, role data.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Edit user — `frontend/lib/screen/user/widget/edit_user_widget.dart`
- **Route:** No route; host presentation unclear.
- **Purpose:** Updates a user account.
- **Navigation:** User list edit action; save/cancel returns to host.
- **UI:** Prefilled account form and actions.
- **State/data:** `UserController`, selected user and role data.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## User detail — `frontend/lib/screen/user/widget/user_detail_card_widget.dart`
- **Route:** `/user-detail`; registration found, caller unclear.
- **Purpose:** Reviews a user account.
- **Navigation:** Intended from user list; source caller not found.
- **UI:** Scaffold and user detail card.
- **State/data:** User argument/controller source unclear.
- **Custom widgets:** `user_detail_card_widget.dart` content.
- **Current design issues:** Caller uncertainty.

## Roles — `frontend/lib/screen/role/role_screen.dart`
- **Route:** `/role`
- **Purpose:** Manages roles and access permissions.
- **Navigation:** Manage; add/edit actions return to role list.
- **UI:** Search/list and role forms/actions.
- **State/data:** `RoleController`, `RoleBinding`, role service/model.
- **Custom widgets:** `role_table_widget.dart`, `role_card_widget.dart`, add/edit widgets.
- **Current design issues:** Table/card alternatives; exact theme issues unclear.

## Add role — `frontend/lib/screen/role/widget/add_role_widget.dart`
- **Route:** None; host presentation unclear.
- **Purpose:** Creates a role.
- **Navigation:** Role list add action; save/cancel returns to host.
- **UI:** Role and permission form with actions.
- **State/data:** `RoleController`, role service/model.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Edit role — `frontend/lib/screen/role/widget/edit_role_widget.dart`
- **Route:** None; host presentation unclear.
- **Purpose:** Updates a role.
- **Navigation:** Role list edit action; save/cancel returns to host.
- **UI:** Prefilled role/permission form and actions.
- **State/data:** `RoleController`, selected role.
- **Custom widgets:** None established.
- **Current design issues:** Host presentation unclear.

## Redesign notes

