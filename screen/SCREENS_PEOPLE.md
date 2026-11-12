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

Implemented 2026-11-12 across all seven People & Access screens using the
supplier screens in `frontend/lib/screen/supplier/` as the layout, styling,
responsive, and interaction reference. User and role lists now use the same
centered max-1240 content, responsive cards below 800 usable
pixels (and above 130% text scale) or tables at larger widths, bounded search,
Refresh/Add actions, retained-record linear loading, retryable load failures,
distinct empty/no-match states, and theme-aware supplier-style surfaces.

Add/Edit user and role forms share guarded supplier-style form widgets with
rounded filled fields, section headings, SafeArea/max-720 content, and
keyboard-safe scrolling. They open as centered
dialogs at 840 or more content pixels and non-dismissible bottom sheets below
that width. Required fields validate inline, duplicate submissions are blocked,
failed drafts remain visible, and the existing user and role payload keys,
routes, bindings, and service endpoints are unchanged. User upload behavior
continues to use the `user` bucket and `users` folder.

User detail now follows the supplier themed `HomeSectionCard` detail pattern,
safely handles missing IDs, nested roles, photos, and malformed dates, uses
wrapped/selectable information and SafeArea actions, and disables edit or
delete when no valid ID is available. Controllers retain 60-second caches,
preserve search filtering through refreshes and writes, expose retryable load
state, and guard overlapping list/form operations.

Review hardening also covers malformed mobile-card dates/fields, invalid role
action IDs, stale edit fetches, duplicate Add/Edit openings, and refreshes that
retain visible records while loading.

Focused verification: People & Access controller/list/form/detail/integration
tests pass, existing rapid-edit/update regression tests pass, and changed
controller/screen files have no analyzer diagnostics. Remaining manual QA:
physical-device keyboard/back behavior, screen-reader focus and translated
errors, live image upload, live API CRUD/error paths, and an in-app walk
through list → add → edit → detail/delete in both themes.

### Web alignment — 2026-11-12

The user and role tables now follow the supplier web table styling, with themed
status and heading colors, tooltips, formatted created dates, user-row hover
styling, and 48px desktop list actions. User detail edit/delete actions are in the desktop page header;
user and role forms pair fields when content is at least 560px wide. Verification
passed: 468 Flutter tests with 1 known web-only skip, a successful web build,
and a clean format gate. `flutter analyze` reported no diagnostics in changed
screen/test-support paths; 37 existing project diagnostics remain. Manual
checks still needed: live browser walk at desktop width, dark theme, Khmer locale,
and screen-reader behavior.
