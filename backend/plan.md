# Backend Work Plan

Scope: secure the API first, then fix correctness and reliability issues. Work on one group at a time and check the group before starting the next.

## Current State

- `POST /auth/login/` is public and returns a JWT.
- JWT validation and most route authorization are incomplete.
- Roles already exist: `Admin`, `Cashier`, and `Stock Manager`.
- No backend test suite currently exists.
- `.env` contains secrets and must never be committed or shared.

## Group 1: Secrets and Authentication

- [ ] Rotate the database password, Telegram token, and JWT `SECRET_KEY`.
- [ ] Confirm `.env` is ignored and absent from git history.
- [ ] Replace seeded `123456` passwords with required environment values or a forced first-login change.
- [x] `app/security.py`: add `HTTPBearer`, JWT decoding, `get_current_user()`, and database user lookup.
- [x] Load the role from the database on every request.
- [x] Use timezone-aware UTC expiry timestamps.
- [x] Add `require_roles("Admin", ...)`.
- [ ] Fail clearly when `SECRET_KEY` or token expiry configuration is missing/invalid.
- [ ] Remove the plaintext-password fallback after legacy passwords are migrated.
- [x] Check `is_active` during login; verify the model default is correct.
- [ ] Remove MySQL-specific `User.name.collate(...)`; add unique constraints for username/email.
- [ ] Restrict CORS to configured frontend origins.

## Group 2: Protect Routes and Apply Roles

Keep only login, health, and deliberately public endpoints unauthenticated.

- [ ] Add `Depends(get_current_user)` to every business router in `main.py`.
- [x] Protect the role router.
- [ ] Add route-level `require_roles(...)` checks for create, update, and delete operations.
- [ ] Confirm exact role spelling in the seeder/database before applying checks.
- [ ] Keep audit logs server-written; remove public update/delete operations.
- [ ] Require auth for Telegram; escape message text and handle request timeouts/errors.

### Initial Permission Matrix

| Area | Read | Create / Update | Delete |
|---|---|---|---|
| Users, roles | Admin | Admin | Admin |
| Products, categories | Admin, Cashier, Stock Manager | Admin, Stock Manager | Admin |
| Suppliers, warehouses, stock, adjustments, purchases, transfers | Admin, Stock Manager | Admin, Stock Manager | Admin |
| Customers, sales, sale payments | Admin, Cashier | Admin, Cashier | Admin |
| Currency, units, payment types | Admin | Admin | Admin |
| Audit logs | Admin | System/admin only | Admin |
| Telegram | Admin, authorized staff | Admin, authorized staff | N/A |

Treat this as the starting policy and confirm it with the business owner. Add ownership checks later where needed, such as cashiers editing only their own sales.

## Group 3: Correctness and Data Safety

- [ ] Fix `POST /sale/`: validate with `Sale.model_validate(...)`, create sale items, and decrease stock in one transaction.
- [ ] Fix `POST /sale_payment/`: validate with `SalePayment.model_validate(...)`.
- [ ] Recompute purchase/sale totals on the server; validate item subtotal calculations.
- [ ] Unify money columns as `Numeric(12,2)`/`Decimal`; unify quantity types; add migrations.
- [ ] Add shared `get_or_404(...)`; replace missing-record `500` responses with `404`.
- [ ] Make deletes return `204` or an id only; never return deleted user objects/password hashes.
- [ ] Convert foreign-key delete failures to `409 Conflict`.
- [ ] Fix the default `deleted_at` values or remove soft-delete fields; choose one delete strategy.
- [ ] Add unique constraints for stock pairs and document/payment numbers; make number generation concurrency-safe.
- [ ] Add a separate `UserUpdate` schema; prevent unauthorized role changes.
- [ ] Fix schema/model mismatches in product, purchase, purchase-request items, warehouse stock, payments, and read-model ids.
- [ ] Fix relationship cardinality for purchase payments, currencies, and payment types.

## Group 4: Performance, Cleanup, and Tests

- [ ] Add `selectinload` to user, warehouse, stock, purchase-payment, purchase, sale-payment, and related list queries.
- [ ] Add `limit`/`offset` to list endpoints.
- [ ] Fix the home dashboard query: limit parent purchases, use `get_session`, and remove duplicate behavior.
- [ ] Fix stock update edge cases: empty items, all items, partial warehouse updates, and insufficient stock errors.
- [ ] Replace `datetime.utcnow()` and deprecated `from_orm()` calls.
- [ ] Gate SQL echo behind a debug setting; pin dependencies and run `pip-audit`.
- [ ] Delete or finish dashboard stubs and the empty user seeder.
- [ ] Standardize HTTP error handling in routes/services rather than CRUD modules.
- [ ] Add smoke and authorization tests. Backend tests should cover login, `401`, expired/invalid/deleted users, inactive roles, allowed roles, denied roles, and the two sale endpoints.

## Required Checks

From `backend/`:

```powershell
python -m compileall app main.py database.py
pytest
uvicorn main:app --reload --port 8000
```

Open `http://127.0.0.1:8000/docs` and verify:

- login works without a token;
- protected requests without/bad/expired tokens return `401`;
- valid users with the wrong role return `403`;
- valid users with the correct role succeed;
- protected operations show a security requirement in OpenAPI;
- seeded Admin, Cashier, and Stock Manager accounts behave as expected.

## Later Hardening

- [ ] Login rate limiting and timing-safe nonexistent-user handling.
- [ ] Password change/reset and account lockout.
- [ ] Audit login failures, role changes, and destructive actions.
- [ ] Prevent deleting/deactivating the last active Admin.
- [ ] HTTPS outside development; refresh/revocation strategy if required.
- [ ] Replace role-name checks with explicit permissions if the system grows.
