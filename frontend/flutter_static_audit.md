# Flutter Static Content Audit — Fix Guide by Route

Organized by FastAPI route group. For each one: current status, files involved, and exactly what to fix. Auth token wiring is intentionally deprioritized per current focus — noted where it will matter later, not required now.

Legend: ✅ Dynamic (working) · 🟡 Partial · 🔴 Static · ⛔ Blocked (backend not ready)

---

## Core Auth

### `POST /auth/login/` — 🟡 Partial
**Files:** `controllers/login_controller.dart`, `screen/auth/login_screen.dart`, `services/auth_service.dart`
**Fix:**
- Remove hardcoded `admin` / `123456` pre-filled into the login form.
- Token is saved to GetStorage but never reused — leave as-is for now per your priority, but flag for later.

---

## Checkout / POS Flow (highest priority — biggest static surface)

### `GET /product/` → Sale grid — 🔴 Static
**Files:** `screen/sale/sale_screen/sale_screen.dart`, `screen/sale/widget/card_item_widget.dart`, `controllers/sale/sale_controller.dart`
**Fix:**
- Replace the 8 hardcoded product cards ("Titanium", "$12.50", Unsplash URL) with a real `GET /product/` call.
- `sale_controller.dart` currently only navigates — load products into an `.obs` list on init.
- Barcode scanner search is commented out — re-enable and wire it to filter/search the loaded product list.

### `POST /sale/` → Current Sale (cart) — 🔴 Static
**Files:** `screen/sale/current_sale/current_sale_screen.dart`, `widget/current_sale_item_widget.dart`, `screen/sale/widget/summary_order_widget.dart`, `select_customer_card_widget.dart`
**Fix:**
- Replace hardcoded rows ("Product Name", unitPrice 1000, Coca-Cola images) with the cart built from products selected on the sale grid.
- Replace hardcoded summary ($1,093.38, 8% tax, $1,130.85) with real computed totals from cart items.
- Customer card is placeholder text — wire it to `GET /customer/` selection.
- "Draft" button does nothing — either implement draft-save or remove it for now.
- `createSale` already exists in the service but is never called — call it here on submit.

### `GET /payment_type/` + `POST /sale_payment/` → Sale With Payment — 🔴 Static
**Files:** `screen/payment/sale_with_payment/sale_with_payment_screen.dart`, `widget/payment_method_card_widget.dart`, `payment_card_summary_widget.dart`, `input_amount_widget.dart`
**Fix:**
- Replace the three identical hardcoded VISA cards with methods loaded from `GET /payment_type/`.
- Summary is placeholder — pull from the actual cart/sale total.
- Amount input has no controller attached — wire one up.
- Save-as-draft is commented out — implement or remove.
- On confirm, call `createSalePayment` (exists in `sale_payment_service.dart`, currently unused).

### Payment Success (receipt) — 🔴 Static
**Files:** `screen/sale/widget/payment_success_widget.dart`
**Fix:**
- Replace static receipt (VISA Classic, $450, fake transaction IDs) with the actual result returned from `POST /sale_payment/`.
- "Export Receipt" button is a no-op — implement (PDF/share) or remove.
- Remove the fake `Future.delayed(100ms)` loading simulation.

---

## Dashboard

### `GET /api/recent-sales`, `GET /api/recent-purchases`, `GET /api/product-category/`, `GET /warehouse_stock/`, `GET /sale/` — 🔴 Static
**Files:** `screen/dashboard/dashboard_screen.dart`, `screen/dashboard/widget/card_kpi_widget.dart`, `stock_in_chart_widget.dart`, `category_revenue_widget.dart`, `low_stock_widget.dart`, `top_proudct_widget.dart`
**Fix:**
- KPI cards hardcoded (`"$ 1,000,00"`, `"42 Items"`, `"8.4x"`) — replace with real aggregates from `/api/recent-sales` + `/api/recent-purchases`.
- Stock In chart has hardcoded Jan–May values — replace with real data grouped by month from `/api/recent-purchases` or `/warehouse_stock/`.
- Category Revenue chart hardcoded (Coffee/Tea/Cake/Snack) — replace with `GET /api/product-category/`.
- Low Stock widget hardcoded (Laptop ASUS, Keyboard, Mouse) — replace with `GET /warehouse_stock/` filtered by low-threshold.
- Top Products hardcoded — replace with aggregated `GET /sale/` data.
- Note: these two backend endpoints exist but currently have **zero** Flutter call sites: `/api/product-category/`, `/health`.

---

## Stock Movement

### `GET /stock_adjustment/` + `GET /product_transfer/` — 🔴 Static
**Files:** `screen/stock/stock_movement/stock_movementscreen.dart`, `controllers/stock_movement_controller.dart` (currently empty)
**Fix:**
- Implement the empty controller: fetch and merge `/stock_adjustment/` + `/product_transfer/` into one movement list.
- Replace the static date band ("Oct 24 - Oct 31, 2023") with a real, adjustable date filter.
- Replace hardcoded movement rows with the real merged list.
- FAB `onPressed: () {}` — wire to the add-adjustment or add-transfer flow.

---

## Audit Logs

### `GET/POST/PUT/DELETE /audit_logs/` — 🟡 Partial
**Files:** `controllers/audit_log_controller.dart`, `audit_logs_screen.dart`, `audit_log_detail_widget.dart`, `widget/add_audit_log_widget.dart`, `edit_audit_log_widget.dart`
**Fix:**
- List (`GET`) already works — leave as-is.
- Add/Edit widgets are static forms where Save just pops the screen — wire to `POST`/`PUT /audit_logs/`.
- `onDeleteAuditLog()` is a no-op even though `DELETE /audit_logs/{id}` exists on the backend — wire it up.

---

## Sale Payments

### `GET /sale_payment/` (list works) + create/update/delete — 🟡 Partial
**Files:** `controllers/payment_controller.dart`, `payment_screen.dart`, `payment_card_list_widget.dart`, `widget/add_payment_widget.dart`
**Fix:**
- List already reads from `GET /sale_payment/` — leave as-is.
- Add Payment widget is literally a placeholder screen with no fields — build the real form.
- `createSalePayment` / `getSalePaymentById` already exist in the service, unused — call them from the new form.

---

## Purchase Payments

### `GET /purchase_payment/` (list works) + create/update/delete — 🟡 Partial
**Files:** `controllers/purchase/purchase_payment_controller.dart`, `purchase_payment_screen.dart`, `widget/add_purchase_payment_widget.dart`
**Fix:**
- List already reads from `GET /purchase_payment/` — leave as-is.
- Add widget is a copy-pasted "Add Category" form — replace with actual purchase payment fields.
- `createPurchasePayment` exists but is unused — call it once the form is real.
- FAB is currently inert — connect it to open the (rebuilt) add form.

---

## System Configuration

### `GET/POST/PUT/DELETE /system_configuration/` — 🔴 Static (UI only)
**Files:** `screen/system_configuration/system_configuration_screen.dart`, `widget/add_system_configuration_widget.dart`
**Fix:**
- Controller already fetches the real list via `GET /system_configuration/`, but the screen just renders the text "System Configuration Content" instead of showing it — connect the fetched data to the actual UI.
- Add widget is a stub — build the real create form and wire `POST`.
- Add edit/update and delete wiring — currently missing entirely.

---

## Customer

### `GET/POST/PUT/DELETE /customer/` — 🟡 Partial
**Files:** `controllers/customer_controller.dart`, `screen/customer/customer_screen.dart`
**Fix:**
- CRUD already works.
- "Active Customers" KPI is hardcoded `"1,000"` — replace with a real count (or active-status count) from `GET /customer/`.

---

## Profile

### `GET/PUT /users/{user_id}` — 🔴 Static
**Files:** `controllers/profile_controller.dart`, `screen/profile/`, `widget/edit_profile_widget.dart`
**Fix:**
- Currently only reads the cached `user` object from GetStorage — add a real `GET /users/{user_id}` refresh call.
- Edit Profile widget is placeholder text only — build the real form and wire `PUT /users/{user_id}`.
- Avatar falls back to a hardcoded URL — replace with the user's actual avatar field, or a generated placeholder tied to their name/initials.

---

## Already Fully Working — No Action Needed

These already call their backend routes correctly through a service layer:

| Route | Controller |
|---|---|
| `/category/` | `category_controller.dart` |
| `/product/` (CRUD, not the sale grid) | `product_controller.dart` |
| `/supplier/` | `supplier_controller.dart` |
| `/warehouse/` | `warehouse_controller.dart` |
| `/warehouse_stock/` | `warehouse_stock_controller.dart` |
| `/stock_adjustment/` (CRUD, not the movement tab) | `stock_adjustment_controller.dart` |
| `/product_transfer/` (CRUD, not the movement tab) | `product_transfer_controller.dart` |
| `/purchase/` | `purchase_controller.dart` |
| `/sale/` (list/delete only) | `sale_list_controller.dart` |
| `/role/` | `role_controller.dart` |
| `/users/` (CRUD, not profile self-view) | `user_controller.dart` |
| `/currency/` | `currency_controller.dart` |
| `/unit/` | `unit_controller.dart` |
| `/payment_type/` (CRUD, not the payment screen) | `payment_type_controller.dart` |

---

## Blocked — Do Not Build Yet

### `/purchase_request/`, `/purchase_request_items/` — ⛔ Blocked
**Files:** `screen/purchase_request/purchase_request_screen.dart`, `controllers/purchase/purchase_request_controller.dart`, `services/main_service/purchase/purchase_request_service.dart`
**Status:** Backend routes are commented out in `backend/main.py`. Leave the screen/controller as-is (empty/placeholder) until the backend implements these routes — don't spend time here yet.

---

## Suggested Build Order

1. Sale grid → `GET /product/`
2. Current sale cart → real totals + `createSale`
3. Payment screen → `GET /payment_type/` + `createSalePayment`
4. Receipt → render real result
5. Dashboard → `/api/recent-sales`, `/api/recent-purchases`, `/api/product-category/`
6. Stock Movement tab → `/stock_adjustment/` + `/product_transfer/`
7. Audit Logs delete + add/edit forms
8. Sale Payments + Purchase Payments add forms
9. System Configuration display + CRUD
10. Customer KPI fix
11. Profile refresh + edit
12. (Later, before opening up beyond dev) — auth token attach + 401 handling