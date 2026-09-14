# Backend Security and Authorization Plan

## Current Status

- The backend has a login endpoint at `POST /auth/login/`.
- Login checks the user's name and password.
- Passwords are hashed when new users are created.
- Login returns a JWT bearer token containing the user's ID in the `sub` claim.
- The backend currently does not validate JWTs on normal API requests.
- The current CRUD routes only depend on the database session, for example `Depends(get_session)`.
- There is no current `jwt.decode`, `OAuth2PasswordBearer`, `HTTPBearer`, `get_current_user`, or role-permission dependency in the route layer.
- Therefore, users can currently call most read, create, update, and delete endpoints without logging in.

## Main Goal

Require a valid JWT before accessing protected API routes, then use the logged-in user's role to decide which operations are allowed.

The intended behavior is:

- No token: return `401 Unauthorized`.
- Invalid or expired token: return `401 Unauthorized`.
- Valid token with insufficient permissions: return `403 Forbidden`.
- Valid token with an allowed role: allow the request.
- Login must remain public so users can obtain a token.

## Existing Role Structure

The database already has the required relationship:

- `User.role_id` references the role table.
- `User.role` provides the related role object.
- `Role.name` stores the role name.
- Existing seed data currently includes roles such as:
  - `Admin`
  - `Cashier`
  - `Stock Manager`

Confirm the exact role names in the seeder/database before writing permission checks. Role name comparisons should use one consistent spelling and capitalization.

## Implementation Plan

### 1. Complete JWT Security Helpers

File: `app/security.py`

Add:

- `HTTPBearer()` or an equivalent FastAPI bearer-token scheme.
- `get_current_user()` dependency.
- JWT decoding using the configured `SECRET_KEY` and `ALGORITHM`.
- Validation that the token includes a valid `sub` user ID.
- Database lookup of the user from the token user ID.
- Rejection of missing, invalid, expired, or unknown-user tokens.
- Optional rejection when the user's role is inactive.

Suggested behavior:

```python
get_current_user() -> User
```

This dependency should load the current user from the database on each request. The role should be read from the database rather than trusted only from a token claim, so changing a user's role takes effect immediately.

Also improve the existing security code:

- Fail clearly when `SECRET_KEY` is missing.
- Use timezone-aware UTC timestamps for token expiration.
- Remove the plaintext-password fallback when all old passwords have been migrated.
- Never commit `.env` or expose the JWT secret.
- Rotate the secret if it has been shared or exposed.

### 2. Protect Business Routers

File: `main.py`

Keep the authentication router public:

```python
app.include_router(auth_router)
```

Add `Depends(get_current_user)` to business routers, either:

- At router registration level for authentication required by every endpoint, or
- Directly on individual route handlers when some endpoints should remain public.

Example registration:

```python
app.include_router(
    product_router,
    dependencies=[Depends(get_current_user)],
)
```

Apply authentication to routers such as:

- Users
- Categories
- Products
- Suppliers
- Customers
- Roles
- Audit logs
- Warehouses
- Warehouse stock
- Stock adjustments
- Product transfers
- Purchases
- Sales
- Currencies
- Payment types
- Units
- Purchase payments
- Telegram, if sending messages should require login

Do not protect:

- `POST /auth/login/`
- Health or public status endpoints, unless the project specifically requires that protection.

### 3. Add Role Authorization Helper

File: `app/security.py`

Add a reusable dependency factory such as:

```python
require_roles("Admin", "Stock Manager")
```

It should:

1. Depend on `get_current_user()`.
2. Read `current_user.role.name`.
3. Allow the request when the role is in the approved list.
4. Raise `403 Forbidden` otherwise.

This keeps role rules reusable and prevents duplicating role-checking code in every endpoint.

### 4. Apply Permissions Per Operation

Role rules should be attached to the route that performs the operation. A router-level authentication dependency confirms that the user is logged in; a route-level role dependency confirms that the user may perform that action.

Example:

```python
@router.post(
    "/",
    dependencies=[Depends(require_roles("Admin", "Stock Manager"))],
)
```

Suggested initial permission matrix:

| Area | Read | Create/Add | Edit/Update | Delete |
|---|---|---|---|---|
| Users | Admin | Admin | Admin | Admin |
| Roles | Admin | Admin | Admin | Admin |
| Products | Admin, Cashier, Stock Manager | Admin, Stock Manager | Admin, Stock Manager | Admin |
| Categories | Admin, Cashier, Stock Manager | Admin, Stock Manager | Admin, Stock Manager | Admin |
| Suppliers | Admin, Stock Manager | Admin, Stock Manager | Admin, Stock Manager | Admin |
| Customers | Admin, Cashier | Admin, Cashier | Admin, Cashier | Admin |
| Warehouses | Admin, Stock Manager | Admin, Stock Manager | Admin, Stock Manager | Admin |
| Warehouse stock | Admin, Stock Manager | Admin, Stock Manager | Admin, Stock Manager | Admin |
| Stock adjustments | Admin, Stock Manager | Admin, Stock Manager | Admin, Stock Manager | Admin |
| Purchases | Admin, Stock Manager | Admin, Stock Manager | Admin, Stock Manager | Admin |
| Sales | Admin, Cashier | Admin, Cashier | Admin | Admin |
| Sale payments | Admin, Cashier | Admin, Cashier | Admin | Admin |
| Product transfers | Admin, Stock Manager | Admin, Stock Manager | Admin, Stock Manager | Admin |
| Audit logs | Admin | Usually system/admin only | Usually system/admin only | Admin |
| Currency, units, payment types | Admin | Admin | Admin | Admin |
| Telegram messages | Admin, possibly authorized staff | Admin, possibly authorized staff | Not applicable | Not applicable |

This matrix is a starting point. Confirm the real business rules before applying it to production.

### 5. Decide Whether Read Endpoints Are Public

Recommended first version:

- Require login for all business data, including GET endpoints.
- Keep only login, health, and deliberately public endpoints open.

If the frontend needs public catalog data, make only those specific GET endpoints public rather than leaving an entire router unauthenticated.

### 6. Consider Ownership Rules

Role checks alone may not be enough for every resource. Later, consider whether a user may edit only records they created.

Examples:

- A cashier may create sales and view sales, but may not edit another cashier's sale.
- A stock manager may update stock records but not user accounts.
- Admin may access all records.

This requires checking fields such as `user_id` on the target record in addition to checking the role.

## Swagger Testing Plan

Development API URL:

```text
http://127.0.0.1:8001/docs
```

Test steps:

1. Start the API on port `8001`.
2. Open `/docs`.
3. Call `POST /auth/login/` with a valid username and password.
4. Copy the returned `access_token`.
5. Click the Swagger `Authorize` button.
6. Paste only the token if using `HTTPBearer`.
7. Authorize the Swagger session.
8. Call a protected GET endpoint.
9. Call a protected POST, PUT, or DELETE endpoint.
10. Repeat with a user from each role.

Expected results:

- No authorization: `401 Unauthorized`.
- Bad token: `401 Unauthorized`.
- Expired token: `401 Unauthorized`.
- Correct role: request succeeds.
- Wrong role: `403 Forbidden`.

Example manual checks:

- A logged-out request to `POST /product/` must fail with `401`.
- A logged-in Cashier request to `POST /product/` should fail with `403`.
- A logged-in Stock Manager request to `POST /product/` should succeed.
- A logged-in non-Admin request to `DELETE /product/{product_id}` should fail with `403`.
- An Admin request to manage users and roles should succeed.

## Testing and Verification

Add automated tests for:

- Login with valid credentials.
- Login with invalid credentials.
- Access with no token.
- Access with malformed token.
- Access with expired token.
- Access with a deleted user.
- Access with an inactive role.
- Each allowed role/action combination.
- Each denied role/action combination.
- Swagger/OpenAPI security behavior.

After implementation, run:

```bash
python -m compileall app main.py database.py
```

Then start the API:

```bash
uvicorn main:app --reload --port 8001
```

Check the OpenAPI document and manually verify that protected endpoints show a security requirement and that requests from Swagger include an `Authorization: Bearer <token>` header.

## Additional Security Ideas

- Use a strong random `SECRET_KEY` from environment configuration.
- Keep `.env` out of source control.
- Restrict CORS instead of using `allow_origins=["*"]` in deployed environments.
- Add rate limiting to login.
- Avoid exposing password fields in API responses.
- Add password reset/change functionality securely.
- Add account lockout or temporary throttling after repeated failed logins.
- Add audit logging for login failures, user changes, role changes, and destructive operations.
- Validate that users cannot assign themselves an elevated role.
- Prevent deletion or deactivation of the last active Admin account.
- Use HTTPS outside local development.
- Consider refresh tokens if access tokens need short expiration times.
- Add logout/token revocation strategy if immediate invalidation is required.
- Review file upload and Telegram endpoints for authorization and input validation.
- Add database constraints and validation for duplicate usernames/emails.

## Future Ideas

- Add more roles as the business rules become clearer.
- Replace role names with explicit permissions if the application grows.
- Create a permissions table and role-permission relationship.
- Add an admin screen for managing roles and permissions.
- Add endpoint documentation showing the required role for each operation.
- Add integration tests that run against a test database.
- Add security review before deployment.

## Implementation Checklist

- [ ] Add JWT decoding and `get_current_user()`.
- [ ] Add `require_roles()`.
- [ ] Protect all business routers with authentication.
- [ ] Add role checks to create, update, and delete routes.
- [ ] Decide and document read permissions.
- [ ] Confirm exact role names in the database.
- [ ] Test with Admin, Cashier, and Stock Manager accounts.
- [ ] Verify `401` and `403` responses in Swagger.
- [ ] Add automated authorization tests.
- [ ] Remove plaintext password fallback after migration.
- [ ] Restrict CORS before deployment.
- [ ] Review and extend the permission matrix as requirements change.

---

## Backend Review – 2026-09-07

Full codebase review (routers, CRUD, models, schemas, services, security, config, deps). Items marked ✅ were verified by running the actual venv (no DB needed); no source code was modified.

### CRITICAL

**backend/.env**
- L3-L12 — Live production secrets in plaintext: Aiven MySQL `avnadmin` password, Telegram bot token, JWT `SECRET_KEY` (SECRET_KEY leak = forge any token, even after auth is added). Verified `.env` is NOT in git or its history — exposure is the file itself. **Fix:** rotate all three immediately; never paste/share the file; if the repo goes to a remote, keep `.env` out.

**main.py**
- L33-L62 — Zero authentication: no `get_current_user`, `HTTPBearer`, or `jwt.decode` anywhere in the codebase (grep = 0 hits). Every endpoint — users, roles, audit_logs, sales, purchases, system_configuration — is fully open. (Matches this plan's "Current Status"; implementation checklist above is still unchecked.) **Fix:** follow plan steps 1–4.

**app/crud/sale/sale.py**
- L11 ✅ `sale.model_validate(sale)` validates the *request schema against itself* → returns a `SaleCreate` (not the `Sale` table model) → `session.add()` raises `UnmappedInstanceError`. **POST /sale/ always returns 500.** Fix: `Sale.model_validate(sale)`.
- L1-L11 (whole create path) — Sale never creates `sale_items` and never decrements `warehouse_stock` (`decrease_stock` is defined but never called). Sales and stock are completely disconnected. Fix: mirror the purchase flow (items + `decrease_stock` in one transaction).

**app/crud/sale/sale_payment.py**
- L8 ✅ Same `x.model_validate(x)` bug → `POST /sale_payment/` always 500s. Fix: `SalePayment.model_validate(sale)`.

**app/security.py**
- L31-L33 — Plaintext fallback: on `UnknownHashError`, `password == stored_password` keeps any legacy plaintext password valid forever (and is timing-unsafe). **Fix:** migrate legacy rows to bcrypt, then delete the fallback.

**app/seeders/create_admin_user.py**
- L48-L84 — Hardcoded default accounts `admin/cashier/stockmanager` all with password `123456`; emails seeded as bare names. Combined with no auth (above), anyone who finds `/docs` owns the system. **Fix:** force strong seeded passwords via env var or first-login change; never seed weak creds to a real DB.

### HIGH

**main.py**
- L23-L29 — `allow_origins=["*"]` + `allow_credentials=True` is an invalid/dangerous CORS combo. **Fix:** explicit origin list per environment.
- L10, L15-L20 — Two `app = FastAPI()` definitions with the lifespan one commented out; `create_admin_user` never runs. Confusing dead scaffolding; **Fix:** single app creation, keep commented lifespan out or gate on env.

**app/models/product.py / sale.py / purchase.py / purchase_item.py**
- product L41, sale L28, purchase L32, purchase_item L23 — `deleted_at: datetime = Field(default_factory=datetime.utcnow)` stamps every row as "deleted" at insert time, yet no query filters on it and deletes are hard `session.delete()`. Soft-delete is both broken and inconsistent. **Fix:** `Optional[datetime] = None` or remove; pick one delete strategy.

**app/models/sale.py, sale_items.py, sale_payment.py, purchase_payment.py**
- sale L19-L24, sale_items L16-L17, sale_payment L14 — money columns are `int`; purchase_payment `amount: float`. Purchases/products use Decimal. Cent truncation + rounding in the sales ledger. **Fix:** migrate to `Numeric(12,2)` Decimal like product (alembic `e048075493fd` did this for product only).

**app/models/purchase_item.py vs warehouse_stock.py**
- purchase_item L21 `qty: Decimal(10,2)` feeds `increase_stock(qty: int)` (crud/warehouse/warehouse_stock.py L122-L140) into `WarehouseStock.qty: int` → a purchase of 2.5 units silently truncates. Same for stock_adjustment. **Fix:** one numeric type for qty everywhere + migration.

**app/crud/purchase/purchase.py + app/crud/sale/sale.py**
- purchase L32-L75, L109-L217 — `subtotal`, `tax_amount`, `total_amount`, `paid_amount`, `due_amount` stored exactly as sent by the client; item `subtotal` never checked against `qty × cost_price`. Financial records are tamperable by any caller. **Fix:** recompute server-side; validate with Pydantic `model_validator`.

**Missing-404 → 500 pattern (routes with `response_model` get `None`)**
- `crud/user/user.py` L25-L42, `role.py` L17-L34, `category/category.py` L54-L75, `product/product.py` L28-L72, `supplier/supplier.py` L33-L58, `customer/customer.py` L16-L37, `warehouse/warehouse.py` L40-L59, `warehouse_stock.py` L89-L113, `sale/sale.py` L29-L74, `sale_payment.py` L24-L57, `stock/stock_adjustment.py` L99-L122, `payment_type.py` L28-L51, `currency.py` L28-L57, `unit.py` L28-L53, `system_configuration.py` L16-L49, product_transfer + items, purchase_request*. — `GET/PUT /{id}` with a nonexistent id returns `None` → FastAPI `ResponseValidationError` = **500 instead of 404**. Behavior is inconsistent across modules (some raise 404, most don't). **Fix:** one shared helper: `def get_or_404(session, model, id)` used everywhere.

**Delete endpoints (all CRUD modules)**
- e.g. `crud/user/user.py` L44-L52 — returning 200 "User deleted successfully" for a **nonexistent** id (no 404); returning the deleted ORM object/dict means **DELETE /users/{id} leaks the password hash** in the response (✅ serialization verified). Deleting a referenced row (category with products, supplier with purchases) surfaces as an unhandled FK `IntegrityError` → 500. **Fix:** 404 when missing, `204` (or id only) on success, catch `IntegrityError` → 409 "in use".

**app/crud/audit_logs/audit_logs.py + routes**
- L33-L62 — Audit trail has client-facing UPDATE and DELETE endpoints, unauthenticated. The audit log is not trustworthy. **Fix:** remove PUT/DELETE routes; write logs server-side only.

**app/services/auth_service.py**
- L11-L30 — `is_active` never checked at login; a "disabled" user still gets a token (and `User.is_active` defaults to `False` in the model, L24 — so the flag is meaningless both ways). Also `User.name.collate("utf8mb4_bin")` (L13) is MySQL-only and prevents any index use → full table scan on every login attempt. **Fix:** check `is_active`; add unique index on `name`; drop collate (or set DB collation).

**Document-number generators — race + bare except**
- `crud/purchase/purchase.py` L15-L30, `warehouse/warehouse.py` L6-L21, `product_transfer/product_transfer.py` L7-L22, `stock/stock_adjustment.py` L10-L25 — `SELECT last … +1` under concurrency produces duplicate `invoice_no`/`reference_no`; no unique constraint backs it up; `except:` swallows everything. **Fix:** unique DB constraint + retry, or a counter table / auto-derived number (`P{id}`).

**Notification side effects inside CRUD**
- `crud/category/category.py` L25-L47 — sends Telegram inline after commit with no timeout/error handling: if Telegram is slow/down the already-saved category request hangs or 500s. **Fix:** `try/except` + log, or move to a background task (`BackgroundTasks`) with a timeout.

**app/routes/telegram/telegram_router.py + app/services/telegram_service.py**
- router L10-L23 — unauthenticated endpoint that posts arbitrary attacker text to the company chat (spam/HTML-injection via `parse_mode=HTML`, unescaped). `telegram_service.py` L14-L21 — `requests.post` with **no timeout, no status check, no exception handling**. **Fix:** require auth (after plan step 2), escape user text, add `timeout=` and error handling.

**N+1 / eager-loading gaps (list endpoints)**
- `get_all_users` (user.py L22-L23) → `UserRead.role` lazy-loads 1 query/user.
- `get_all_warehouse` (warehouse.py L37-L38) → `WarehouseRead.warehouse_stock` → each `WarehouseStockRead.product` → `ProductRead.category/unit/currency` — deep fan-out, worst offender.
- `get_all_warehouse_stock` (L86-L87), `get_all_purchase_payment` (purchase_payment.py L15-L16), `get_recent_purchases` (purchase.py L100-L107), `get_sale_payment`-family (SaleRead.user → role again), `get_purchase`/`get_sale` single-reads skip items.
- No pagination/limit on ANY `GET /` list. **Fix:** `selectinload` (pattern already correct in `get_all_product`) + `limit/offset` params.

**app/routes/home/home.py**
- L44-L46, L86-L88 — `LIMIT 5` applies to the *joined* rows, not 5 purchases: a purchase with 3 line items eats 3 of the 5 rows, so the "recent purchases" widget shows ~1-2 purchases. No session dependency (`engine.connect()` direct, L49) — bypasses `get_session`. Duplicates `/purchase/recent` with different semantics. **Fix:** limit on parent id in a subquery; route through CRUD.

**app/crud/warehouse/warehouse_stock.py**
- L166-L169 — `decrease_stock` raises bare `ValueError` → 500 when eventually wired to sales (should be 400 via HTTPException/service error).
- L92-L113 `update_warehouse_stock` — `items[0]` → **IndexError 500** on empty `items`; silently ignores `items[1:]`; `warehouse_id` overwritten even when the intent is partial update.

### MEDIUM

**Pydantic v2 deprecations / misc security hygiene**
- `from_orm()` (deprecated, warns) still used: `role.py:8`, `category.py:20`, `supplier.py:24`, `currency.py:18`, `unit.py:18`, `payment_type.py:18`, `purchase_payment.py:8`, `purchase_requests.py:8`, `purchase_request_items.py:8`, `system_configuration.py:7` → `model_validate`.
- `datetime.utcnow()` (naive, deprecated) in every CRUD + models + `security.py:39` → `datetime.now(timezone.utc)`.
- `security.py:12` — `SECRET_KEY` may be `None` → first login raises `TypeError` (500); add fail-fast `if not SECRET_KEY: raise`. `L14` — `int(os.getenv(...))` crashes on empty string.
- `hash_password` — no bcrypt 72-byte input limit check; longer passwords silently truncate.

**Schema/model drift (silent loss or 500s)**
- `schemas/product/product.py:30-31` — `qty`/`allow_insert_qty` don't exist on `Product` → `update_product` (crud L55-L58) ✅ raises `ValueError` (500) the moment a client sends `qty`; also dead duplicated `unit_id` block (L59-L60 vs L63-L64).
- `schemas/purchase/purchase.py:28,44` — `description` has no `Purchase` column ✅ silently dropped on create; never handled in update.
- `schemas/purchase/purchase_request_items.py` — schema says `stock_request_id`, model column is `purchase_request_id` ✅ create raises ValidationError; `updated_at` written by CRUD ✅ doesn't exist on model → PUT always 500. Routes are commented out (`main.py:57-58`) — they'll break on re-enable.
- `WarehouseStockRead.note` (warehouse_stock schema L25) — no such column; `SaleCreate`/`SalePaymentCreate`/`AuditLogsCreate` force clients to send `created_at`.
- Read schemas missing `id`: `PurchasePaymentRead`, `SalePaymentRead`, `PurchaseRequestRead`, `PurchaseRequestItemRead`, `SystemConfigurationRead` — clients can't target rows for PUT/DELETE.

**Relationship cardinality**
- `models/purchase.py:46` — `purchase_payments: Optional["PurchasePayment"]` should be `List[...]` (one purchase, many payments) → breaks with a 2nd payment.
- `models/currency.py:25` / `payment_type.py:21` — scalar side of one-to-many with `SystemConfiguration` should be `List`.

**Missing DB constraints**
- No unique on `user.name`/`user.email` (login looks up by name!), `supplier.phone`/`email` (app check at `supplier.py:9-22` is racy), `warehouse_stock(warehouse_id, product_id)` (create checks in a loop but races; `increase_stock` inserts duplicates), `invoice_no`/`reference_no`/`payment_no`. `email-validator` is installed but no field uses `EmailStr`; no `max_length` anywhere.

**Auth/authz details**
- Login returns no `expires_in`; token lacks `iat`/`jti`; no revocation story (plan already covers).
- `users.py:22` PUT reuses `UserCreate` → every user edit requires re-sending the password (and lets any caller change any user's `role_id`). Needs `UserUpdate` + admin-only.
- User enumeration: nonexistent-user path skips bcrypt, wrong-password path runs it → timing oracle; no login rate limiting (plan covers).

**Error handling / architecture**
- `HTTPException` raised from the CRUD layer everywhere (transport concern in data layer) while other paths return `None` — two conventions. Pick one: raise in routes/services, keep CRUD pure.
- 15+ near-identical CRUD modules (hand-rolled field-by-field updates, `if x is not None` ladders — `stock_adjustment.py` L111-L250 is the extreme). A generic `apply_update(obj, data.model_dump(exclude_unset=True))` helper removes hundreds of lines.
- `app/routes/dashboard/dashboard.py` — 5 stub endpoints all `return None` (200 + null) and the router isn't even registered — dead code; delete or finish.
- `app/seeders/user_seeder.py` — empty file; delete.
- No backend tests exist at all (AGENTS.md confirms); the ✅-verified 500s above are exactly what a 20-line smoke test would catch.

**Config / deps**
- `database.py:11` — `echo=True` logs every SQL with bound parameters (PII + credentials noise in logs, measurable perf hit against remote Aiven DB). Gate on `DEBUG` env.
- `requirements.txt` — `sqlmodel`, `requests`, `python-jose`, `passlib`, `python-multipart` unpinned (installed jose 3.5.0 is past the 2024 CVEs; bcrypt 4.0.1 pin for passlib is correct). Pin exact versions; add `pip-audit`.

### LOW

- `routes/stock/stock_adjustment.py:22` — `updatestock_adjustment_route` (typo, missing `_`); `routes/product_transfer/product_transfer.py:18` — handler named `read_stock_adjustment` (copy-paste); `routes/sale/sale.py:10` — param `payment:` for a `SaleCreate`; `routes/sale/sale_payment.py:10` — `create_new_sale` for a payment.
- Wrong error strings: `crud/unit/unit.py:35,59,68` — "Payment type not found" in the Unit module; `crud/purchase/purchase_request_items.py:59` — response key `purchase_request` holds an item; `crud/product/product.py:79` — leading space in `" Product not found."`.
- `crud/purchase/purchase.py:13` — unused `text` import; `routes/purchase/purchase.py:4` — unused `PurchaseSimple`; `models/product.py:10-11` — duplicate `PurchaseItem` import; `models/supplier.py:20-21` — forward refs to `Purchase`/`PurchasePayment` with no `TYPE_CHECKING` block (fine at runtime, breaks type checkers); `models/purchase_item.py:5` — runtime import of `Purchase` duplicating the TYPE_CHECKING one (circular-import hazard).
- `schemas/product_transfer/product_transfer.py:26-28` — `updated_at` declared twice in `ProductTransferRead`.
- `models/system_configuration.py:26` — `tax_enabled : bool` spacing; `routes/__init__.py:33` — `__all__` list without spaces (also `main.py:8` one 400-char import line).
- `app/` has no `__init__.py` (namespace packages work, but be consistent since subpackages have them).
- `auth.py:12` login route has no `response_model` (raw dict); `verify_password` plaintext-compare timing (covered under Critical, cleanup when fallback is removed).
- Style: POSTs should use `status_code=201`, deletes `204` or an `id`-only body; adopt `Annotated[Session, Depends(get_session)]` uniformly.
- All routes are correctly `def` (sync) so `get_session`'s blocking I/O is safe — keep it that way if auth deps are added (or make the new `get_current_user` sync too, else blocking calls land on the event loop).

### Suggested fix order

1. Rotate secrets (.env) + seed passwords — before anything else.
2. The two always-500 endpoints (`sale`, `sale_payment`) — one-word fixes each.
3. Auth per the existing plan (steps 1–4) — it gates most other security findings.
4. 404/409/delete-semantics helper (one shared `get_or_404` + response models on deletes).
5. Money/qty type migration + server-side total recomputation.
6. Eager loading + pagination pass.
7. Cleanup pass (deprecated APIs, dead code, naming, pins).

No code was changed. Approve items (by number/heading) and I'll implement them.

---

## Fix Groups (session checklist)

Work through ONE group per session. Check items off as they're completed. Commit to git after each group before moving to the next. If a session runs out of tokens mid-group, resume with `/resume` and re-check this list — anything unchecked in the current group is still pending.

### Group 1 — Rotate secrets (do this first, before any other work)
- [ ] Rotate Aiven MySQL `avnadmin` password
- [ ] Rotate Telegram bot token
- [ ] Rotate JWT `SECRET_KEY`
- [ ] Confirm `.env` is not committed to git or its history
- [ ] Force strong passwords for seeded `admin` / `cashier` / `stockmanager` accounts (env var or forced first-login change) — `app/seeders/create_admin_user.py`

### Group 2 — Fix the two always-500 endpoints
- [ ] `app/crud/sale/sale.py` L11 — change `sale.model_validate(sale)` → `Sale.model_validate(sale)`
- [ ] `app/crud/sale/sale_payment.py` L8 — same fix: `SalePayment.model_validate(sale)`
- [ ] `app/crud/sale/sale.py` — wire up `sale_items` creation and call `decrease_stock` in the same transaction (sale flow currently never touches stock)

### Group 3 — Authentication & authorization (plan steps 1–4 above)
- [x] `app/security.py` — add `HTTPBearer()`, `get_current_user()`, JWT decode using `SECRET_KEY`/`ALGORITHM`
- [x] `get_current_user()` loads user + role from DB on every request (not just from token claim)
- [ ] Fail fast if `SECRET_KEY` is missing or empty
- [x] Use timezone-aware UTC timestamps for token expiry
- [ ] Remove plaintext-password fallback in `security.py` L31-L33 (after legacy passwords migrated)
- [x] Add `require_roles()` dependency factory
- [ ] Apply `Depends(get_current_user)` to all business routers in `main.py` (keep `/auth/login/` public) — **role_router done, rest pending**
- [ ] Apply the permission matrix (role checks) per route, per the table in this plan — **role_router done, rest pending**
- [ ] Check `is_active` at login in `app/services/auth_service.py` (currently never checked, and defaults to `False` — so it's meaningless)
- [ ] Fix `User.name.collate("utf8mb4_bin")` (MySQL-only, blocks index use — drop or set DB collation)
- [ ] Restrict CORS (`main.py` L23-L29 — `allow_origins=["*"]` + `allow_credentials=True` is invalid/dangerous)
- [ ] Remove the duplicate `app = FastAPI()` definition in `main.py`
- [ ] Test with Admin / Cashier / Stock Manager accounts per the Swagger Testing Plan above
- [ ] Verify `401`/`403` responses match the expected table above

### Group 4 — 404/409/delete-semantics helper
- [ ] Add shared `get_or_404(session, model, id)` helper
- [ ] Apply it across all listed modules (user, role, category, product, supplier, customer, warehouse, warehouse_stock, sale, sale_payment, stock_adjustment, payment_type, currency, unit, system_configuration, product_transfer + items, purchase_request*)
- [ ] Fix delete endpoints: 404 on missing id, `204`/id-only response on success (never return the deleted ORM object — currently leaks password hash on user delete)
- [ ] Catch `IntegrityError` on delete of referenced rows → return `409` instead of 500
- [ ] Remove unauthenticated PUT/DELETE on `app/crud/audit_logs/audit_logs.py` (audit trail should be server-write-only)
- [ ] Require auth on `app/routes/telegram/telegram_router.py`; escape user text before sending (HTML injection); add `timeout=` and error handling to `telegram_service.py`

### Group 5 — Money/qty types + server-side recomputation
- [ ] Unify `qty` type across `purchase_item.py` and `warehouse_stock.py` (Decimal vs int truncation) + migration
- [ ] Unify money columns to `Numeric(12,2)` Decimal in `sale.py`, `sale_items.py`, `sale_payment.py`, `purchase_payment.py` (currently mixed int/float) + migration
- [ ] Recompute `subtotal`/`tax_amount`/`total_amount`/`paid_amount`/`due_amount` server-side in purchase/sale CRUD instead of trusting client values
- [ ] Validate item `subtotal` against `qty × cost_price` with a Pydantic `model_validator`
- [ ] Add unique DB constraint + retry (or counter table) for document-number generators (`purchase.py`, `warehouse.py`, `product_transfer.py`, `stock_adjustment.py`) — replace bare `except:`

### Group 6 — Eager loading + pagination
- [ ] Add `selectinload` to `get_all_users`, `get_all_warehouse` (worst N+1 offender), `get_all_warehouse_stock`, `get_all_purchase_payment`, `get_recent_purchases`, `get_sale_payment`-family (pattern already correct in `get_all_product` — copy it)
- [ ] Add `limit`/`offset` params to every `GET /` list endpoint (none currently paginated)
- [ ] Fix `app/routes/home/home.py` — `LIMIT 5` applies to joined rows not parent rows; move to a subquery on parent id
- [ ] Route `home.py` through `get_session` instead of a direct `engine.connect()`
- [ ] Fix `decrease_stock` bare `ValueError` → proper `HTTPException`/service error (400, not 500)
- [ ] Fix `update_warehouse_stock` `items[0]` IndexError on empty `items`; handle `items[1:]`; don't overwrite `warehouse_id` on partial update

### Group 7 — Cleanup pass
- [ ] Replace deprecated `from_orm()` → `model_validate()` (10 files listed in Medium section)
- [ ] Replace `datetime.utcnow()` → `datetime.now(timezone.utc)` (all CRUD + models + `security.py`)
- [ ] Fix schema/model drift issues (product `qty`/`allow_insert_qty`, purchase `description`, purchase_request_items field name mismatch, missing `id` on several Read schemas)
- [ ] Fix relationship cardinality (`purchase_payments` should be `List[...]`, currency/payment_type → `List`)
- [ ] Add missing DB unique constraints (`user.name`/`email`, `supplier.phone`/`email`, `warehouse_stock(warehouse_id, product_id)`, invoice/reference/payment numbers)
- [ ] Split `UserUpdate` from `UserCreate` so editing a user doesn't require resending the password / doesn't allow any caller to change `role_id`
- [ ] Fix login timing oracle (nonexistent-user path should still run bcrypt-equivalent work)
- [ ] Pick one convention for `HTTPException` (routes/services only, not CRUD layer)
- [ ] Delete dead code: `app/routes/dashboard/dashboard.py` stubs, empty `app/seeders/user_seeder.py`
- [ ] Gate `database.py` `echo=True` behind `DEBUG` env var
- [ ] Pin exact versions in `requirements.txt`; run `pip-audit`
- [ ] Fix LOW-severity typos/naming/unused imports listed in the LOW section
- [ ] Write basic smoke tests (none exist currently) — at minimum cover the two endpoints fixed in Group 2