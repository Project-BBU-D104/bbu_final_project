# Inventory Management System — Progress Report & Code Audit

Date: 2026-11-05
Scope: entire repository (`backend/` + `frontend/`)
Mode: read-only audit. No application code was changed.
Method: read the docs, config, models, routes, CRUD, services, controllers, screens, and tests; traced the main money and stock flows end to end.

> **Important:** `flutter test`, `flutter analyze`, and `pytest` were **not run** because they write build/cache artifacts and the audit was read-only. "DONE" below means "implemented and read end to end", not "verified running".

---

## Update — 2026-11-06: findings 1, 2, 3, 5, 11 fixed

Everything below this section is the original audit snapshot. These findings no longer describe the code:

- **Finding 1 — fixed (backend).** `update_user` only hashes a non-blank, non-whitespace password, so a blank edit keeps the stored hash (`backend/app/crud/user/user.py:43-46`). The UI hint ("leave blank to keep current") was **not** added, and login still accepts an account whose stored hash is the old empty string — reset any accounts that were wiped before this fix.
- **Finding 2 — fixed.** `Product.stock_qty` sums `warehouse_stock` and is exposed on `ProductRead` (`backend/app/models/product.py:64-67`). The cache coder serializes class properties, so cache hits carry the value too.
- **Finding 3 — fixed, and wider than written.** A shared `clear_stock_caches()` (`backend/app/core/cache.py:16-20`) clears both `"warehouse"` and `"product"` (the latter because `ProductRead` now embeds stock). Called from sale, purchase, purchase item, stock adjustment, product transfer, **product transfer item** (missed by this report), warehouse stock, and product routes. Until the fix, `product_transfer_item` mutations moved stock with no invalidation at all.
- **Finding 5 — fixed.** `qty`/`allow_insert_qty` removed from `ProductUpdate` and from `update_product`.
- **Finding 11 — fixed.** Counter template deleted. A second red test existed: `edit_user_twice_test.dart` failed on a duplicate `GlobalKey<FormState>` when the sheet opened twice; the controller now ignores a second open.

Also: `pytest==9.2.0` is in `backend/requirements.txt`, and the two `TestClient` tests skip (rather than abort collection) when `httpx2` is absent.

**Verified 2026-11-06:** `pytest tests/` → 30 passed, 2 skipped; `flutter test` → 44 passed; `flutter analyze` → 0 errors.

**Still open:** findings 6–8, 12–15, 17–20; the UI half of finding 1; the login-side rejection of empty passwords (minor reviewer note); and the gap between `stock_qty` (all warehouses) and checkout (one warehouse row).

---

## Update — 2026-11-07: finding 4 fixed

- **Finding 4 — fixed.** `create`, `update`, and `delete` sale payments now
  recalculate `paid_amount`, `due_amount`, and `payment_status` on the sale in
  the same transaction (`backend/app/crud/sale/sale_payment.py`). Moving a
  payment between sales recalculates both. The sale-payment router clears the
  `"sale"` cache namespace after mutations. The Flutter checkout no longer
  sends the compensating `PUT /sale/{id}`. Covered by
  `backend/tests/test_sale_payment.py`.

---

## Update — 2026-11-07: findings 9, 10, 16 fixed

- **Finding 9 — fixed by deletion.** The standalone `/purchase_item` route and
  its CRUD module are gone (`backend/app/routes/purchase/purchase_item.py`,
  `backend/app/crud/purchase/purchase_item.py`). The frontend never called
  them, and the create endpoint could not work (`PurchaseItemCreate` has no
  `purchase_id`, so the CRUD read a missing attribute and every call 500'd).
  Items are managed through `/purchase`, which already reverses stock on
  delete. The `PurchaseItem` model and its Create/Read schemas stay — the
  purchase schemas use them.
- **Finding 10 — fixed.** `compute_stock_qty` returns
  `max(0, base_qty + sum(movements))`; negative on-hand stock is clamped to
  zero, matching the rest of the app (`backend/app/seeders/create_test_data.py`).
- **Finding 16 — fixed.** `backend/tests/test_stock_flows.py` covers sale
  stock deduction, overselling, and selling a product with no stock row;
  purchase stock increase and payment recalculation (pending payments
  excluded); transfer between warehouses; and stock adjustment increase and
  decrease-below-stock rejection. `backend/tests/test_compute_stock_qty.py`
  pins the seeder helper. Writing the purchase tests exposed a real defect:
  `increase_stock` added a `Decimal` purchase quantity to the integer
  `warehouse_stock.qty` column, which SQLite refuses to bind; the helper now
  coerces `qty` to `int` (`backend/app/crud/warehouse/warehouse_stock.py`).
  Purchase item quantities must now be whole numbers — `PurchaseItemCreate`
  rejects fractions, because the integer stock column cannot represent them;
  truncating would make recorded purchases and on-hand stock silently diverge.

**Verified 2026-11-07:** `pytest tests/` → 52 passed, 2 skipped.

**Still open from this work:** update paths (`update_sale`,
`update_stock_adjustment`, `update_product_transfer`) still have no stock
tests; `delete_purchase` can drive stock negative; and invoice numbers can
still collide (finding 13).

---

## Part 1 — What this project is

A small-business inventory and point-of-sale system with two applications:

- `backend/` — FastAPI + SQLModel, JWT auth, MySQL (despite the README saying SQLite), Alembic migrations, in-memory response cache.
- `frontend/` — Flutter + GetX app for desktop/mobile/web, bilingual (Khmer default), barcode scanner, POS checkout, admin screens.

The backend exposes ~125 endpoints covering products, categories, units, currencies, payment types, suppliers, customers, warehouses, warehouse stock, stock adjustments, product transfers, purchases, purchase payments, purchase requests, sales, sale payments, users, roles, system configuration, dashboard, home lists, audit logs, and Telegram notifications.

**Assumed load:** one shop, 1–5 concurrent cashiers/admins on a LAN, one uvicorn process, a few thousand products and sales. At that size the code mostly holds; the important risks are correctness, security, and stale data rather than throughput.

### Main flows traced

1. **Login** → JWT stored encrypted in `GetStorage` → every request sends `Authorization: Bearer`.
2. **Sale/POS** → cart → `POST /sale` (server prices items, checks and deducts warehouse stock, generates invoice) → `POST /sale_payment` → `PUT /sale/{id}` with `paid_amount` → receipt screen.
3. **Purchase** → `POST /purchase` (creates items, increases warehouse stock) → optional later purchase payments, which recalculate paid/due/status.
4. **Stock** → adjustments and transfers update `warehouse_stock`; both are reversible on edit/delete.
5. **Dashboard** → five read-only SQL endpoints; home → recent purchase/sale list endpoints.

---

## Part 2 — Backend feature status

| Feature | Status | Notes |
|---|---|---|
| JWT login / auth guard | **DONE** | `is_active` is not checked at login (finding 8) |
| Users CRUD | **DONE** | Edit endpoint resets the password (finding 1) |
| Roles CRUD | **DONE** | Admin-only; delete blocked while a user uses the role |
| Categories | **DONE** | CRUD + cache invalidation |
| Units | **DONE** | CRUD + cache invalidation |
| Currencies | **DONE** | CRUD + cache invalidation |
| Payment types | **DONE** | CRUD + cache invalidation |
| Products | **DONE** | CRUD, warehouse assignment; `qty` fields crash (finding 5) |
| Suppliers | **DONE** | Includes map/location |
| Customers | **DONE** | CRUD |
| Warehouses | **DONE** | Response includes stock lines |
| Warehouse stock | **DONE** | CRUD; its UI screen is unreachable |
| Stock adjustments | **DONE** | Validates stock, reverses on edit/delete |
| Product transfers | **DONE** | Validates source/destination, positive qty, duplicate products, reversal |
| Purchases | **DONE** | Increases stock; does not clear warehouse cache (finding 3) |
| Purchase items | **DONE** | Standalone create adds stock; standalone delete does not reverse it (finding 9) |
| Purchase payments | **DONE** | Recalculates paid/due/status in the same transaction |
| Purchase requests | **DONE** | Two-step create (request, then items); list read omits items |
| Purchase request items | **DONE** | CRUD |
| Sales | **DONE** | Server-side prices, stock check/deduction, invoice generation, rollback |
| Sale payments | **PARTIAL** | Recording a payment does not update the sale (finding 4) |
| Dashboard API | **DONE** | KPI, monthly sales, revenue by category, low stock, top products |
| Home recent lists | **DONE** | `/api/recent-purchases`, `/api/recent-sales` |
| System configuration | **DONE** | Low-stock threshold consumed by the dashboard |
| Audit logs | **PARTIAL** | Table + CRUD API only; no mutation writes a log; UI unreachable |
| Telegram notify | **PARTIAL** | Endpoint exists; ignores failures, no timeout, returns success always |
| Seeders (admin/default) | **DONE** | Idempotent, covered by tests |
| Seeder (test data) | **PARTIAL** | Crashes on `compute_stock_qty` (finding 10) |
| Reports API | **NOT STARTED** | No backend report endpoints; one report is computed client-side |
| Automated backend tests | **PARTIAL** | Product/warehouse, user cache, system config, admin seeder only (finding 16) |

### Backend layering (as designed)

```
routes/ (HTTP) → crud/ (queries, takes Session) → models/ (SQLModel tables)
                                              → schemas/ (Create/Update/Read)
```

Caching pattern: GET handlers use `@cache(namespace=..., expire=60)`, and each mutation clears its namespace. A custom `ORMJsonCoder` serializes loaded relationships so cache hits still validate against `response_model`.

---

## Part 3 — Frontend feature status

| Feature | Status | Notes |
|---|---|---|
| Login / landing / session expiry | **DONE** | Ships prefilled `admin / 123456` |
| Home | **DONE** | Welcome, quick actions, recent purchase/sale |
| Dashboard | **DONE** | Wired to the real dashboard APIs |
| Manage menu | **DONE** | Role-filtered menu |
| Products | **PARTIAL** | Stock status filter is always wrong (finding 2) |
| Categories / Units / Currencies / Payment types | **DONE** | Full CRUD |
| Suppliers | **DONE** | Includes map location picker (has tests) |
| Customers | **DONE** | Full CRUD |
| Warehouses | **DONE** | List + detail with stock |
| Warehouse stock screen | **PARTIAL** | Registered route but no menu entry → unreachable |
| Stock adjustments | **DONE** | Create/edit/detail |
| Stock transfers | **DONE** | Create/edit/detail |
| Purchases | **DONE** | Create/edit/detail, item form |
| Purchase requests | **DONE** | Create/edit/detail, items created after the request |
| Purchase payments | **DONE** | Create/edit/detail |
| Sale / POS | **DONE** | Barcode scan, cart, customer/payment selection, checkout |
| Sale list | **DONE** | List + detail |
| Payment success | **DONE** | Receipt screen (has a disposal test) |
| Sale payment screen | **PARTIAL** | Registered but menu entry commented out |
| Users / Roles | **DONE** | Admin UI; user edit password bug (finding 1) |
| System configuration | **DONE** | CRUD |
| Profile | **PARTIAL** | Read-only; `EditProfileWidget` is a placeholder |
| Reports | **PARTIAL** | 1 real (Sales), 5 stubs, 4 unregistered (finding 12) |
| Audit logs screen | **PARTIAL** | Built but unreachable and no data is produced |
| Barcode scanner | **DONE** | Used by add/edit product and search |
| Image upload (Supabase) | **DONE** | Used by product/user forms |
| Localization | **DONE** | ~500 `.tr` uses, 180 keys in both locales |
| Dark mode | **NOT STARTED** | Dead controller + theme; toggle commented out |
| Telegram client | **NOT STARTED** | Service registered but never called |
| Push notifications | **NOT STARTED** | A non-interactive row in settings |

---

## Part 4 — Leftovers

### 4.1 TODO / FIXME / HACK

Only one real marker exists:

- `TODO(human)` in `backend/app/seeders/create_test_data.py:162`, immediately followed by `raise NotImplementedError` at line 165.

### 4.2 Hardcoded test values and credentials

| What | Where |
|---|---|
| Login form prefilled `admin` / `123456` | `frontend/lib/controllers/login_controller.dart:8` |
| Admin, cashier, stock manager seeded with `123456` | `backend/app/seeders/create_admin_user.py:93,113,124` |
| Password reset script hardcodes `123456` | `backend/app/reset_admin_password.py:21` |
| Product "LOW STOCK" filter hardcodes `10` instead of the configured threshold | `frontend/lib/controllers/product_controller.dart:215` |
| Product cache TTL is 3.3 hours (`12000` seconds) | `frontend/lib/controllers/product_controller.dart:66` |

### 4.3 Commented-out code

At least 25 blocks, including:

- Menu entries for Warehouse Stock, Sale Payment, and Audit Logs — `frontend/lib/controllers/manage_controller.dart:91,150,202`
- `DevicePreview` wrapper — `frontend/lib/main.dart:38`
- Dark-mode toggle — `frontend/lib/screen/profile/widget/setting_widget.dart:29`
- Legacy block in `purchase_item_row_widget.dart`
- Debug `print()` calls and commented prints in several controllers

### 4.4 Dead / empty files

| File | Problem |
|---|---|
| `frontend/lib/services/stock_transfer_service.dart` | 0 bytes |
| `frontend/lib/services/app_service.dart` | 0 bytes |
| `frontend/lib/screen/navigation_tab.dart` | Returns an empty `Container()` |
| `frontend/lib/controllers/location_controller.dart` | Never referenced |
| `frontend/lib/controllers/theme_controller.dart` | Only used by the dead dark-mode toggle |
| `frontend/lib/services/telegram_service.dart` | Registered in locator, never called |
| `frontend/test/widget_test.dart` | Untouched Flutter counter template |

### 4.5 Hardcoded visual values

- 127 `Color(0x…)` literals, ~500 `Colors.*` uses, 403 `fontSize:` literals.
- Eight competing accent colours; app bars/nav bars are `Colors.white` while the theme says blue.
- These are documented in the earlier `frontend/design.md`; its fake dashboard numbers and unformatted money findings are now fixed.

---

## Part 5 — Must-fix findings

### Finding 1 — Editing a user silently resets their password to empty

- **What this is:** An admin opens a user, changes their phone number, and saves.
- **Problem:** `UserRead` never returns `password`, so the edit form’s password box is always blank (`frontend/lib/controllers/user_controller.dart:192`). The password field is not required (`frontend/lib/screen/user/widget/edit_user_widget.dart:171-176`), so the blank value is sent (`user_controller.dart:223`). The backend always re-hashes whatever it receives (`backend/app/crud/user/user.py:43`), making the password the empty string. The UI blocks empty login, so the user is locked out; a direct API call can log in with an empty password.
- **Fix:** On update, hash and set the password only when the request value is non-empty; otherwise keep the stored hash. Show "leave blank to keep current" in the form.
- **If we skip it:** Any routine user edit locks that account out, and the account accepts an empty password over the API.

### Finding 2 — Product stock filter is always wrong

- **What this is:** The product screen filters by IN STOCK / LOW STOCK / OUT OF STOCK.
- **Problem:** The filter reads `item['stock_qty']` (`frontend/lib/controllers/product_controller.dart:212`), but nothing ever sets `stock_qty`. The list comes straight from `/product` (`product_controller.dart:127`), whose response schema has no stock quantity. Every product therefore reads as `0`: IN/LOW STOCK show nothing, OUT OF STOCK shows everything.
- **Fix:** Add `stock_qty` (sum of `warehouse_stock.qty`) to `ProductRead`/the product query, or compute it in `getProducts` from existing warehouse data. One field, no new endpoint.
- **If we skip it:** The status filter is decorative and misleading.

### Finding 3 — Warehouse quantities go stale after stock changes

- **What this is:** Warehouse responses include stock quantities and are cached for 60 seconds.
- **Problem:** Only the sale router clears the `"warehouse"` cache (`backend/app/routes/sale/sale.py:17-19`). Purchase, stock adjustment, product transfer, product create/update, and warehouse-stock routes clear only their own namespace (`purchase.py:17`, `stock_adjustment.py:17`, `product.py:17`, `product_transfer.py:16`). After receiving a purchase, the warehouse detail screen can show the old quantity for up to a minute.
- **Fix:** Clear `"warehouse"` in every router that changes `warehouse_stock` or moves a product between warehouses, using the same helper the sale router uses.
- **If we skip it:** Users will "fix" correct stock numbers by hand because the screen is out of date.

### Finding 4 — Recording a sale payment does not update the sale

- **What this is:** `/sale_payment` records money received, like `/purchase_payment` does for purchases.
- **Problem:** `create_sale_payment` only inserts the row (`backend/app/crud/sale/sale_payment.py:7`). It never recalculates `paid_amount`, `due_amount`, or `payment_status`. The Flutter checkout compensates with a second `PUT /sale/{id}` (`frontend/lib/controllers/sale/sale_controller.dart:301-312`), so it works in the app but not through the API, and the two writes can half-succeed. Deleting a sale payment has the same gap.
- **Fix:** Copy the purchase-payment pattern: after insert/update/delete, sum the payments and update the sale in the same transaction.
- **If we skip it:** Payments recorded by any other client leave the sale marked unpaid; the app’s two-step checkout can record money and still leave the sale unpaid if the second call fails.

### Finding 5 — Editing a product with `qty` returns a 500

- **What this is:** `ProductUpdate` advertises `qty` and `allow_insert_qty`.
- **Problem:** `Product` has neither field. `update_product` assigns them (`backend/app/crud/product/product.py:121-124`), and SQLModel raises `ValueError: object has no field "qty"` (confirmed with a local model). Any API client sending those fields gets a server error, not a validation error.
- **Fix:** Delete those four lines, or move quantity changes to `warehouse_stock` (where they belong). Deleting is the smaller change; the frontend never sends them.
- **If we skip it:** A documented request field crashes the endpoint.

### Finding 6 — Default credentials and prefilled login ship with the app

- **What this is:** The seeder creates `admin`, `cashier`, and `stockmanager` all with `123456`; the login form opens prefilled with `admin / 123456`.
- **Problem:** Anyone with the repo or the app can log in as admin unless every deployment changes the passwords, which nothing forces.
- **Fix:** Seed a random password printed once, or require `SEED_PASSWORD` from the environment; remove the prefilled text (keep demo convenience behind a debug flag if needed).
- **If we skip it:** The first internet-facing deployment is admin-owned.

### Finding 7 — CORS allows every origin with credentials

- **What this is:** `allow_origins=["*"]` together with `allow_credentials=True` (`backend/main.py:28-29`).
- **Problem:** Browsers reject that combination for credential requests, and any origin can call the API. It is a development default; CLAUDE.md already says not to ship it.
- **Fix:** Read allowed origins from env and list the real frontend origin(s).
- **If we skip it:** Inconsistent browser behaviour now, a wide-open API later.

### Finding 8 — Deactivated users can still log in

- **What this is:** `is_active` is meant to disable an account.
- **Problem:** Login checks only username and password (`backend/app/services/auth_service.py:26`); `is_active` is checked later by every request. A disabled user gets a valid token, then every screen fails with 401 "Invalid user".
- **Fix:** After password verification, reject `not user.is_active` with the same generic "Invalid name or password".
- **If we skip it:** Disabling a user looks broken rather than blocked.

### Finding 9 — Deleting a purchase item does not reverse its stock

- **What this is:** `/purchase_item` has standalone create and delete endpoints.
- **Problem:** Create increases warehouse stock (`backend/app/crud/purchase/purchase_item.py:8-28`); delete removes the row without decreasing stock (`purchase_item.py:32-37`). The app does not call delete today, so the bug is latent.
- **Fix:** Reverse stock on delete, or delete the standalone endpoints and manage items only through the purchase.
- **If we skip it:** A future client inflates stock with no transaction behind it.

---

## Part 6 — Should-fix findings

### Finding 10 — The test-data seeder crashes

- **What this is:** `python -m app.seeders.create_test_data` builds demo data across two warehouses.
- **Problem:** `compute_stock_qty` is a TODO that raises `NotImplementedError` (`backend/app/seeders/create_test_data.py:155-165`), and `_seed_stock` calls it.
- **Fix:** `return base_qty + sum(movements)` after deciding the negative-stock rule (clamp at zero is the safe default). One line.
- **If we skip it:** The most useful demo tool in the repo cannot run.

### Finding 11 — `flutter test` is red

- **What this is:** The suite has 15 good files, but one is the untouched Flutter counter template.
- **Problem:** `frontend/test/widget_test.dart` expects a counter in `MyApp` and also pumps `MyApp` without `dotenv`, `GetStorage`, and the service locator. It fails, which makes the whole command fail and trains people to ignore tests.
- **Fix:** Delete the file. The other tests cover real behaviour.
- **If we skip it:** "Run the tests" is permanently untrustworthy.

### Finding 12 — The Report feature is mostly a shell

- **What this is:** The Report tab offers six reports.
- **Problem:** Only Sales Report is real. Sale Payment, Purchase, Purchase Payment, Stock Ledger, and Profit/Loss are single `Text` widgets (`frontend/lib/screen/report/all_report/purchase_report_screen.dart:9`, etc.). Four are not registered in `frontend/lib/routes/app_pages.dart`, and `frontend/lib/controllers/report_controller.dart:35` points the purchase/stock/profit items at `AppRoutes.saleReport`, so every one opens the Sales report.
- **Fix:** Either wire each tile to its screen and implement the query, or remove the five tiles until they exist. Deleting is the smaller change today.
- **If we skip it:** Users click "Profit and Loss" and get sales data, or a route-not-found error.

### Finding 13 — Invoice numbers can collide

- **What this is:** Sale, purchase, transfer, adjustment, request, and payment numbers are generated by "read the last row, add one".
- **Problem:** There is no unique constraint on `invoice_no`/`reference_no` in the models (`backend/app/models/sale.py:19`, `backend/app/models/purchase.py:22`), and the read-then-write is not locked (`backend/app/crud/sale/sale.py:108-130`). Two cashiers checking out at the same moment can get the same invoice number.
- **Fix:** Add a unique index on the number columns and retry once on collision, or use the row id as the number. Do not add a lock library at this scale.
- **If we skip it:** Duplicate invoice numbers appear exactly when the shop is busiest.

### Finding 14 — Soft-delete columns are set on creation

- **What this is:** `deleted_at` is supposed to mark a deleted row.
- **Problem:** `Product`, `Purchase`, and `PurchaseItem` default it to `now()` (`backend/app/models/product.py:41`, `purchase.py:33`, `purchase_item.py:23`). Nothing filters on it today, so the bug is invisible; the first "active only" query would hide every row.
- **Fix:** Make them `Optional[datetime] = None`, matching `Sale`.
- **If we skip it:** A future report or filter silently returns nothing.

### Finding 15 — Audit logging is a UI shell

- **What this is:** There is an audit-log table, CRUD API, screen, controller, and detail view.
- **Problem:** No mutation ever writes a log (grep finds no `AuditLogs` use outside its own module), and the menu entry is commented out (`frontend/lib/controllers/manage_controller.dart:202`). The feature exists but cannot be used.
- **Fix:** Decide: either add one small `log()` call in the shared create/update/delete paths (users, products, sales, purchases), or delete the screen and API until it is needed.
- **If we skip it:** A security feature is "done" only in appearance.

### Finding 16 — Money and stock flows have no backend tests

- **What this is:** Backend tests exist for product/warehouse, user cache, system config, and the admin seeder.
- **Problem:** There is no test for sale creation and stock deduction, purchase stock increase, payment recalculation, stock transfer, or stock adjustment — the paths where a bug costs money. `pytest` is also absent from `requirements.txt`.
- **Fix:** Add one test per flow using the existing `session`/`seed` fixtures: selling more than stock is rejected, a sale reduces quantity, a purchase payment changes paid/due, a transfer moves quantity. Add `pytest` to requirements.
- **If we skip it:** Findings 3, 4, and 9 will recur.

---

## Part 7 — Nice-to-have findings

### Finding 17 — Dead files and one dead dependency

- **What this is:** Empty services, an empty navigation widget, unused controllers.
- **Problem:** `stock_transfer_service.dart` and `app_service.dart` are 0 bytes; `navigation_tab.dart` returns an empty container; `location_controller.dart` is unused; the frontend Telegram service is registered but never called.
- **Fix:** Delete them. Also remove `device_preview` from `pubspec.yaml` and the `DevicePreview.appBuilder` wrapper in `frontend/lib/main.dart:102` — it is inert in release but confusing.
- **If we skip it:** Every reader spends time deciding whether they matter.

### Finding 18 — Screens that cannot be reached

- **What this is:** Sale Payment and Warehouse Stock screens are registered routes.
- **Problem:** Their menu entries are commented out (`frontend/lib/controllers/manage_controller.dart:91,150`), and no other code navigates to them. `gotoStock()` also points at an unregistered `/stock-movement` route.
- **Fix:** Either re-enable the entries and role mapping, or delete the routes/screens.
- **If we skip it:** Half-finished features look finished in the route table.

### Finding 19 — The docs contradict the code

- **What this is:** README files.
- **Problem:** README says SQLite twice (`README.md:7,12`); the app runs MySQL. Both READMEs tell users to `pip install -r requiment.txt` (typo). README orders `create_admin_user` before `create_default_data`, but the admin seeder raises if no system configuration exists and tells you to run default data first.
- **Fix:** Correct the three lines; the code is right.
- **If we skip it:** A new developer’s first setup fails.

### Finding 20 — The API trusts the client's `user_id`

- **What this is:** `SaleCreate` and `PurchaseCreate` require `user_id` in the body.
- **Problem:** The backend never checks it against the JWT owner, so a cashier can attribute a sale or purchase to another user. The Flutter app sends the stored user id, but nothing enforces it.
- **Fix:** Take the user from `get_current_user` and ignore the body field (or reject a mismatch). Small change in the two create routes.
- **If we skip it:** Audit trails and cashier accountability are spoofable.

### Smaller items not listed above (5)

1. Telegram endpoints swallow failures with no timeout.
2. List-by-id endpoints return `None` → 500 instead of 404.
3. `HomeController` startup calls lack error handling.
4. Product list cache is considered fresh for 3.3 hours.
5. Two chart dependencies (`syncfusion_flutter_charts` and `fl_chart`) where one would do.

---

## Part 8 — Verdict and prioritized next steps

### Verdict

**Not ready to ship, but close to demo-ready.** The core inventory, purchase, and POS flows are implemented and coherent. Fix the password-reset bug, the stock filter, warehouse cache invalidation, and sale-payment accounting first; then make the tests green. Everything else is polish or deletion.

**Lean:** roughly **-150 lines and -1 dependency** (`device_preview`) possible from findings 12, 17, and 18 without losing a working feature.

### Next steps, in order

1. **Fix user update** so a blank password keeps the existing one (finding 1). One condition, guards every account.
2. **Fix the product stock filter** by returning `stock_qty` (finding 2) — small backend change.
3. **Clear the `"warehouse"` cache in every stock-changing router** (finding 3) — six lines.
4. **Make sale payments recalculate the sale** on the backend (finding 4), then remove the frontend’s second `updateSale` call.
5. **Delete the four lines that crash product updates** (finding 5) and the counter test (finding 11).
6. **Get `flutter test` and `pytest` green**, then add the money/stock tests (finding 16).
7. **Before any deployment:** remove default passwords and the prefilled login, restrict CORS, block inactive logins (findings 6–8).
8. **Decide the report scope:** wire the five report tiles or delete them (finding 12). Do the same for audit logs (15) and the unreachable screens (18).
9. **Fix the test-data seeder** (finding 10) so demo setup works in one command.
10. **Correct the README** (finding 19), then delete the dead files (finding 17).

---

## Part 9 — Not checked

- `flutter test`, `flutter analyze`, and `pytest` were not run, so I cannot confirm the tests that look green actually pass or that analysis is clean.
- The app was not launched; no live MySQL database or API was hit.
- The PDF in `.doc/SaronaDraftProject.pdf` was not opened.
- The Khmer translation text was not read (the key counts match across locales).
- Android/iOS/macOS/Linux/Windows runner folders and generated platform files were not audited.
- Widget internals were read only where they touch the main flows; purely visual widgets were not reviewed line by line.