# Unfinished Frontend Screens — Problem List

Found by the 2026-11-07 gap audit. Every backend domain HAS a screen — nothing is missing outright. The problems are grouped into 5 parts, ordered by how much they hurt. Work on any part independently.

---

## Part 1: Fake UI — looks done, does nothing

### 1.1 Sale Payment screen is a hollow shell
- `lib/screen/payment/payment_screen.dart` — read-only list, no way to add/edit/delete a payment from it.
- `lib/controllers/payment_controller.dart` — only has `onGetPaymentList()`, no other methods.
- `lib/screen/payment/widget/add_payment_widget.dart` — placeholder: just `Text("Add Payment Screen")`, referenced nowhere.
- `lib/screen/payment/widget/edit_payment_widget.dart` — placeholder: `Text("Edit Payment Screen")`, referenced nowhere.
- `lib/screen/payment/widget/payment_card_detail_widget.dart` — placeholder: empty `Container()`, referenced nowhere.
- **To fix:** either build the add/edit forms + controller methods, or delete the 3 placeholders and accept the screen as read-only.

### 1.2 Audit log add/edit forms are fake
- `lib/screen/audit_logs/widget/add_audit_log_widget.dart` — TextFields with no controllers; "Save" button just does `Navigator.pop(context)` (~line 119).
- `lib/screen/audit_logs/widget/edit_audit_log_widget.dart` — same fake pattern (~line 118). This one IS wired: `audit_log_detail_widget.dart:336` calls it — and nothing happens.
- `lib/controllers/audit_log_controller.dart:57-66` — `onEditAuditLog()` opens the fake form; `onDeleteAuditLog()` is completely empty.
- **To fix:** logs should be immutable — delete the buttons, the two widgets, and the two controller methods. Keep list/detail read-only.

### 1.3 Purchase payment has no edit/delete
- `lib/screen/purchase_payment/widget/edit_purchase_payment_widget.dart` — **0-byte file**, unreferenced.
- `lib/controllers/purchase_payment_controller.dart` — only list + add methods, no edit/delete.
- **To fix:** real feature work — needs edit/delete in the controller + a real form widget (backend endpoints exist).

### 1.4 "Export Receipt" is a dead button
- `lib/screen/sale/widget/payment_success_widget.dart:325` — `onPressed: () {}`. The "Back to Sale" button next to it works.
- `lib/services/export_service.dart` already exists and can generate the PDF (`exportPdf`), and `lib/controllers/report_export_controller.dart:25-43` shows the exact try/catch + toast pattern to copy.
- Note: the widget gets its receipt data via `Get.arguments` (passed at `sale_controller.dart:324`) but currently ignores it; the `onConfirm` path (`sale_controller.dart:369`) passes NO arguments — hide the button in that case.
- **To fix:** small — read the receipt map, call `ExportService.exportPdf`, toast the result.

### 1.5 Profile has no edit capability
- `lib/screen/profile/widget/edit_profile_widget.dart` — placeholder: `Card(child: Text("Edit Profile Widget"))`, unreferenced.
- `lib/controllers/profile_controller.dart` — only loads from storage + logout. No change-password UI either.
- **To fix:** real feature work (edit form + password change, backend endpoints exist).

### 1.6 Settings screen is half-disabled
- `lib/screen/profile/widget/setting_widget.dart:29-38` — Dark Mode toggle is commented out; `lib/controllers/theme_controller.dart` is referenced nowhere else (dead).
- Same file — "Push Notifications" row is static decoration: `active: true`, no `onSwitch`, no `onTap`. Looks interactive, does nothing.
- **To fix:** either implement dark mode (real work: theme controller + GetX theme switching) or remove both rows.

---

## Part 2: Complete screens nobody can reach

All three are fully built (screen + controller + route + binding) but their menu entries are commented out in `lib/controllers/manage_controller.dart`:

### 2.1 Warehouse Stock
- Menu item commented out at lines 87–92. Role entry exists (`_routeRoles` line 19: stock manager).
- **To fix:** uncomment 6 lines.

### 2.2 Sale Payment list
- Menu item commented out at lines 146–151. Route registered at `app_pages.dart:126-130`. No `_routeRoles` entry → currently admin-only.
- **To fix:** uncomment 6 lines + add a role entry (e.g. `AppRoutes.salePayment: {'cashier'}`).

### 2.3 Audit Logs
- Whole "History Management" section commented out at lines 195–205. No `_routeRoles` entry → admin-only is fine for logs.
- **To fix:** uncomment 11 lines.

---

## Part 3: Role access bug

### 3.1 Customer blocked for non-admin roles
- `lib/controllers/manage_controller.dart:13-32` — `_routeRoles` has NO `AppRoutes.customer` entry, so `canAccessRoute` returns false for everyone except admin/owner → cashier tapping Customer gets the "Access denied" snackbar (line 278).
- Cashiers need customers to make sales.
- **To fix:** one line — add `AppRoutes.customer: {'cashier'},` to the map.

---

## Part 4: Dead code (delete candidates)

Each item verified to have no live caller. Grep the name before deleting; run `flutter analyze` after.

| # | Item | Location | Evidence |
|---|------|----------|----------|
| 4.1 | `stockMovement` route | `app_routes.dart:16` | No GetPage registered — navigating would throw "route not found". Only caller `HomeController.gotoStock()` (`home_controller.dart:103-105`) is itself never called. |
| 4.2 | `SaleWithPaymentScreen` | `lib/screen/payment/sale_with_payment/sale_with_payment_screen.dart` + route (`app_routes.dart:23`, `app_pages.dart:24,166-169`) | Zero navigations anywhere; superseded by the current_sale flow. **CAREFUL:** keep `widget/payment_method_card_widget.dart` in that folder — `current_sale_screen.dart:3` imports it. `widget/payment_card_summary_widget.dart` can go (only the dead screen uses it). |
| 4.3 | `navigation_tab.dart` | `lib/screen/navigation_tab.dart` | 9-line `Container()` stub, class never instantiated. |
| 4.4 | Empty purchase-request detail | `lib/screen/purchase_request/widget/purchase_request_detail_widget.dart` | Empty `Container()`, unreferenced. The real detail is `card_purchase_request_detail_widget.dart` — don't touch that one. |
| 4.5 | `LocationController` | `lib/controllers/location_controller.dart` | Referenced nowhere; map picking uses `location_picker_page.dart` (alive). |
| 4.6 | `ThemeController` | `lib/controllers/theme_controller.dart` | Only usage is inside the commented-out dark-mode block (see 1.6). |
| 4.7 | `TelegramService` | `lib/services/telegram_service.dart` + `locator.dart:10` + `global.dart:24` | Registered at startup but `telegram.sendMessage` is never called; file even contains a commented "how to use" example. Remove all three places together or the app won't start. |

---

## Part 5: Known open backend issues (context — not frontend work)

Listed in `AUDIT_REPORT.md` / the stock-flow plan's Review Focus; mentioned here so the list is complete:
- Invoice-number collision under concurrent checkouts (finding 13).
- `_warehouse_stock_for_product` takes `.first()` with no warehouse filter — ambiguous deduction for multi-warehouse products.
- `delete_purchase` can drive stock negative (no floor check).

---

## Suggested order when you start

1. **Part 2 + 3.1** — one file, ~15 uncommented/added lines, instantly unlocks 3 screens and fixes the cashier bug.
2. **Part 4** — pure deletion, zero behavior change, shrinks the codebase.
3. **Part 1.2** — delete the fake audit-log stubs (immutable logs = correct design).
4. **Part 1.4** — small, visible win (Export Receipt works).
5. **Part 1.1 / 1.3 / 1.5 / 1.6** — real features; decide per item: build it or delete the placeholder.
