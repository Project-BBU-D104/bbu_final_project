# Settle supplier invoices in their recorded currency — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A supplier payment can change an invoice balance only when both amounts are in the invoice’s recorded currency.

**Architecture:** Choose the matching-payment option in the audit. Record the currency on purchase creation, keep it fixed, and validate the effective invoice/payment pair on the server before any write. Flutter takes payment currency from the invoice. The currency maintenance forms validate rates independently of settlement.

**Tech Stack:** FastAPI, SQLModel, Pydantic, Alembic/MySQL, pytest, Flutter, GetX and flutter_test.

**Spec:** [improve.md, implementation order, item 4](improve.md#implementation-order). Repository conventions are in [CLAUDE.md](CLAUDE.md).

## Global Constraints

- “Store invoice currency. Accept matching payments or store the applied exchange rate and converted amount.”
- “Check a KHR invoice with a USD payment so raw amounts can never be summed across currencies.”
- “In both currency forms, bind Default and Status to their respective fields and validate a finite positive rate on client and server.”
- The existing initial payment is denominated in the invoice currency. Only later payments whose normalized status is `completed` count toward paid. Keep existing purchase/payment cache invalidation, stock transactions and Khmer/English localization.

## Review Focus

1. A USD payment of 1 against a KHR invoice of 40,000 must leave the ledger and balance untouched, including through a partial payment update (Task 2).
2. Historical invoices have no reliable denomination. A payment’s currency, a product’s currency and today’s default are insufficient evidence. Preserve historical amounts and expose unresolved records for review (Tasks 1–3).
3. Changing defaults or disabling a currency must preserve the original invoice denomination. Switching a draft invoice from USD to KHR must never silently relabel entered prices (Tasks 1 and 3).
4. Moving a payment, completing a pending payment, or deleting a completed one must recalculate the affected invoices exactly once, retaining their initial payment (Task 2).
5. A valid positive fractional rate and opposite checkbox values must round-trip on add and edit. Zero, negatives, overflow and non-finite values must fail on both write paths (Task 5).

---

## File structure and execution order

Tasks 1–2 own purchase persistence, settlement and historical records. Task 3 owns invoice and payment entry in Flutter. Task 4 owns the existing read surfaces that assume every purchase is in dollars or share one chart series. Task 5 owns currency maintenance. Paths below are relative to the root unless a directory prefix is given. Run Python commands from `backend/` with its virtual environment active, Flutter commands from `frontend/`. Each commit instruction applies only to the named implementation changes. Keep this plan uncommitted and stage individual hunks in shared files.

### Task 1 — Record and expose the invoice denomination

**Files:** Under `backend/`, modify `app/models/purchase.py`, `app/schemas/purchase/purchase.py`, `app/schemas/currency/currency.py`, `app/crud/currency/currency.py`, `app/crud/purchase/purchase.py`, `app/crud/purchase/purchase_payment.py` (read options), `app/seeders/create_test_data.py` and `tests/test_stock_flows.py`. Create `alembic/versions/ca4180d60a12_purchase_invoice_currency.py` and `tests/test_purchase_currency_migration.py`.

**Interfaces:** `PurchaseCreate.currency_id: int` is required. `PurchaseRead.currency_id: int | None` and `PurchaseRead.currency: CurrencySimple | None` are returned by create, update, list, recent, detail and nested payment reads. Expose `code: str` on `CurrencySimple` alongside its existing fields. `PurchaseUpdate.currency_id` may be omitted or echo the stored ID.

- [ ] **Write failing tests.** Extend `make_purchase` to pass the fixture currency. In `test_purchase_records_currency`, create a KHR invoice, change the default to USD, deactivate KHR, expire the session and assert `PurchaseRead.model_validate(get_purchase(session, invoice.id)).currency.code == "KHR"`. Assert missing ID fails schema validation, unknown/inactive ID fails creation before stock changes, and a PUT supplying USD or explicit null receives 409 before any fields or lines change. Exercise nested payment reads with the session detached after eager loading.
- [ ] **Run red.** `python -m pytest tests/test_stock_flows.py -k currency -q` must fail on the missing currency contract.
- [ ] **Add the migration and model.** Add an indexed nullable FK from `purchases.currency_id` to `currency.id` with restricted deletion and a matching `Purchase.currency` relationship. Leave pre-upgrade rows null. Confirm the single integration head with `python -m alembic heads` before setting `down_revision` (the sale warehouse migration is `6e8b1a0dc249`). Use batch operations compatible with the project’s SQLite tests and MySQL. Downgrade removes the FK, index and column.
- [ ] **Wire writes and reads.** Resolve an active currency before flushing a new purchase. Reject any attempted change of recorded ID. Give unresolved invoices a 409 on updates that would trigger balance recalculation, before mutating the ORM object. Eager-load the currency in all three purchase queries and through `_purchase_payment_options()`. Keep the recorded inactive currency readable and eligible for settlement. Set the USD currency on new demo purchases. The seeder currently records the same deposit in both initial paid and a completed payment. Represent it once in new demo data so recalculation reproduces the seeded balance.
- [ ] **Protect the recorded code.** In `test_referenced_purchase_currency_keeps_code`, assert `update_currency` changing KHR to another code and `delete_currency` return 409 while an invoice references it. Run red, add the reference check to these two operations, then rerun. Rate, default and status edits must still work.
- [ ] **Verify the upgrade.** In `test_upgrade_preserves_unresolved_purchase`, run the new revision against a populated prior-schema fixture using Alembic operations, including differently denominated payments. Assert `(currency_id, paid_amount, due_amount)` equals `(None, old_paid, old_due)`, payment rows are identical, the FK exists and downgrade restores the prior shape. Run `python -m pytest tests/test_purchase_currency_migration.py tests/test_stock_flows.py -q`; expect pass. Before deployment, exercise the revision on a disposable MySQL copy. Coordinate the API and Flutter rollout because older purchase-create callers omit the required ID.
- [ ] **Commit** the scoped changes with `backend: Record supplier invoice currency`.

### Task 2 — Enforce the invariant on every settlement write

**Files:** `backend/app/crud/purchase/purchase_payment.py`, `backend/app/crud/purchase/purchase.py`, `backend/tests/test_stock_flows.py`. Use the existing create/update/delete routes and their cache tests in `backend/tests/test_purchase_payment_cache.py`.

**Interfaces:** Preserve `get_completed_purchase_payment_total(session: Session, purchase_id: int) -> Decimal` and the existing payment request/response shapes. Return 404 for a missing invoice and 409 for an unresolved invoice, a currency mismatch or inconsistent stored payment history. Include a human-readable detail, e.g. `Payment currency must match invoice currency (KHR).`

- [ ] **Write failing ledger tests** using the existing stock-flow factories. Use these fixtures and assertions:

  | Test | Operation and assertion |
  | --- | --- |
  | `test_reject_usd_for_khr` | KHR total 40,000, initial paid 4,000. Try USD 1 with completed and pending status. Assert `exc.value.status_code == 409`, payment count unchanged and `(paid, due) == (4000, 36000)` after reloading. |
  | `test_recalculate_khr_history` | Add pending KHR 12,000, complete it, then delete it. Assert paid/due/status successively equal `(4000, 36000, "partial")`, `(16000, 24000, "partial")`, `(4000, 36000, "partial")`. A final matching KHR 36,000 settles the invoice. |
  | `test_payment_update_validates_effective_pair` | Update only `currency_id` to USD, then only `purchase_id` to a USD invoice. Each returns 409 and preserves the row and both balances. Moving a matching payment between two KHR invoices succeeds and updates both. |
  | `test_unresolved_or_inconsistent_history_is_preserved` | Insert a legacy null-currency invoice and a separate KHR invoice with a stored USD payment. Attempt create, edit, delete, invoice amount update and direct recalculation. Assert 409, original payment IDs/amounts and original invoice totals after rollback and reload. |

- [ ] **Run red.** `python -m pytest tests/test_stock_flows.py -k "khr or effective_pair or inconsistent_history" -q`. Expect an accepted mismatch or an incorrectly changed balance.
- [ ] **Validate before mutation.** Reuse one internal invoice/history check in purchase edit, payment create, update, delete and total calculation. Validate stored payment currency IDs before adding any amounts. For partial updates resolve omitted IDs from the stored payment. Check the old and destination invoices, and the proposed effective currency, before editing the row. Check all statuses at the boundary. Silently filtering mismatched rows would produce a plausible but incomplete balance.
- [ ] **Recalculate within the existing transaction.** Serialize concurrent settlement writes on the affected purchase rows in stable ID order on MySQL; for a mutable payment, lock and read its current row before resolving the old invoice. Read current payment history under those locks. Flush an accepted mutation, then derive paid from initial paid plus matching completed amounts, clamp due and retain existing status rules. Keep the existing single commit and successful route invalidations.
- [ ] **Verify.** Run `python -m pytest tests/test_stock_flows.py tests/test_purchase_payment_cache.py -q`. On disposable MySQL, submit two matching payments of KHR 1,000 and 2,000 in parallel against the same KHR 40,000 invoice with initial paid 4,000. Reload in a fresh session and assert `(paid, due) == (7000, 33000)`. SQLite alone cannot verify MySQL row locking.
- [ ] **Commit** with `backend: Enforce supplier payment currency on settlement`.

**Existing installation recovery.** During deployment, list unresolved purchase IDs and invoice numbers. Reconcile them against supplier invoices and receipts. With application writes paused, assign a verified currency only when every recorded tender matches and the verified opening payment plus completed payments agrees with paid/due/status. Verify the result on a copy before applying reviewed corrections. Keep missing evidence, mixed tenders and inconsistent opening balances unresolved and read-only for settlement. A live rate cannot reconstruct the historical transaction.

### Task 3 — Carry invoice currency through purchase and payment entry

**Files:** Under `frontend/lib/`, modify `binding/purchase/purchase_binding.dart`, `controllers/purchase/{purchase_controller,purchase_payment_controller}.dart`, `screen/purchases/widget/{purchase_form_widget,purchase_item_row_widget}.dart`, `screen/purchase_payment/widget/purchase_payment_form_widget.dart` and `localization/{en_us,km_kh}.dart`. Under `frontend/test/`, update `purchase_test_support.dart`, `purchase_form_test.dart`, `purchase_payment_test_support.dart`, `purchase_payment_form_test.dart`, `purchase_payment_crud_test.dart` and `purchase_payment_controller_test.dart` for the invoice-driven field.

**Interfaces:** `PurchaseController.selectedCurrencyId: RxnInt` supplies the create payload. Replace mutable `PurchasePaymentController.selectedCurrencyId` with a derived `int? get invoiceCurrencyId` from the selected purchase, falling back to the nested original invoice on edit. Both read `currency_id` from Task 1. Payment payload field remains `currency_id`.

- [ ] **Write failing form tests.** In `purchase_form_test.dart`, select KHR with USD as default and assert `lastCreatedData!['currency_id'] == khrId`. Open an existing KHR invoice after disabling KHR and assert its recorded code is visible and fixed. Pick a USD-priced product for a KHR invoice and assert `costCtrl.text.isEmpty` until the user enters a KHR cost. Test that a draft with monetary input cannot switch denominations. In `purchase_payment_form_test.dart`, select a USD invoice then a KHR invoice and assert `lastCreatedData!['currency_id'] == khrId` on save. Test edit fallback and unresolved legacy invoices with `expect(service.updateCalls, 0)`.
- [ ] **Run red.** `flutter test test/purchase_form_test.dart test/purchase_payment_form_test.dart`. Expect missing invoice ID and independently editable payment currency.
- [ ] **Implement purchase entry.** Use the existing currency list on the purchase form. Offer active currencies and preselect a default only if exactly one active default exists. Require selection before monetary entry. Lock the draft denomination once a line cost, tax, discount or initial payment has been entered; reset selection on a new draft. Only prefill product cost when the nested product currency ID matches. Display the invoice code beside form amounts and use the stored currency on edit. An unresolved invoice displays a translated reconciliation message and cannot be saved.
- [ ] **Implement payment entry.** Replace the independent currency dropdown and its controller dependency with the recorded invoice code beside amount and due. Clear the entered payment amount when switching invoices. Validate the derived ID on submit and preserve the current finite positive amount / available-balance checks (add the missing `isFinite` check). Allow the existing completed amount back into the edit limit only for the same verified invoice/currency. Show an actionable localized message if the invoice currency is unresolved or stored tender conflicts. Guard edit/delete and save paths consistently with Task 2.
- [ ] **Run green.** `flutter test test/purchase_form_test.dart test/purchase_controller_test.dart test/purchase_payment_form_test.dart test/purchase_payment_crud_test.dart test/purchase_payment_controller_test.dart`; expect all passing. Refresh fixture registrations for the purchase form so these tests use fake currencies.
- [ ] **Commit** with `frontend: Use recorded currency for supplier payment entry`.

### Task 4 — Show the same units wherever invoice balances are read

**Files:** Under `frontend/lib/`, change `screen/purchases/widget/{purchase_card_widget,purchase_table_widget,purchase_detail_widget}.dart`, `screen/home/widget/recent_orders_widget.dart` (purchase branch), `screen/report/all_report/purchase_report_screen.dart`, and `localization/{en_us,km_kh}.dart`. Tests in `frontend/test/purchase_redesign_test.dart`, `frontend/test/home_screen_test.dart` and new `frontend/test/purchase_report_currency_test.dart`.

**Interfaces:** Consume `purchase['currency']` and `purchase['currency_id']`. Use the existing formatting utilities and show the recorded currency code unambiguously. Preserve stored precision when displaying invoice balances, including a nonzero fractional balance. For null currency, show the numeric value with “Currency unrecorded” in table/detail/export; omit it from chart aggregation.

- [ ] **Write failing tests.** Render a KHR 40,000 invoice on phone and desktop and assert that total, paid and due carry KHR across list and detail. Exercise the recent purchase row. For the report, feed a single day with KHR 40,000, USD 10 and an unresolved 7. Assert the two plotted values are `40000` and `10`, the three numeric export rows have currency labels `KHR`, `USD`, `Currency unrecorded`, and the legacy row remains visible. Include KHR due 0.50 so a visible outstanding amount cannot round to zero.
- [ ] **Run red.** `flutter test test/purchase_redesign_test.dart test/home_screen_test.dart test/purchase_report_currency_test.dart`. Expect dollar labels and one combined chart point.
- [ ] **Update the read surfaces.** Pass invoice currency into line-cost and summary formatting. Group the purchase chart by recorded currency ID and date with a labeled series per ID, following the existing purchase payment report’s multi-series chart. Include a translated currency column in the existing purchase report export and keep totals numeric. Use an optional `PurchaseService? service` constructor argument on `PurchaseReportScreen` for fixture-driven tests.
- [ ] **Run green** with the same three Flutter test files, then commit with `frontend: Show recorded units for supplier invoice balances`.

### Task 5 — Fix currency maintenance on client and server

**Files:** `backend/app/schemas/currency/currency.py`, new `backend/tests/test_currency_rate.py`, `frontend/lib/controllers/currency_controller.dart`, `frontend/lib/screen/currency/widget/{add_currency_widget,edit_currency_widget}.dart`, `frontend/lib/localization/{en_us,km_kh}.dart` and new `frontend/test/currency_form_test.dart`.

**Interfaces:** `CurrencyCreate.exchange_rate` is a finite positive float. `CurrencyUpdate` permits omission to retain the stored value; reject explicitly submitted null. Use one Dart validator `String? validateExchangeRate(String? raw)` for both forms. Keep request keys `exchange_rate`, `is_default` and `status`.

- [ ] **Write failing tests.** Parameterize backend create/update and both Flutter forms with blank, zero, negative, `NaN`, `Infinity`, `-Infinity` and `1e309`. Assert validation failure and no service write. Accept `0.25`. In widget tests tap the labeled controls separately and assert the captured payloads contain `(is_default, status) == (true, false)` and `(false, true)` on add and edit. Verify edit initialization and that an omitted rate on backend update preserves the existing value.
- [ ] **Run red.** `python -m pytest tests/test_currency_rate.py -q` and `flutter test test/currency_form_test.dart` should expose the accepted invalid rates and reversed checkboxes.
- [ ] **Implement validation and binding.** Enforce finiteness and positivity on both write schemas with Pydantic. Convert both rate inputs to validated form fields; trim and parse with `double.tryParse`, require `isFinite && rate > 0`, then send a numeric rate. Bind the Default control to `isDefault` and Status to `isActive` for both the value and change handler. Reuse existing form validation and translations. Allow an optional `CurrencyService? service` in `CurrencyController` for payload capture.
- [ ] **Run green** with the two focused commands. Commit with `Fix currency rate validation and default and status controls`.

## Final verification

- [ ] Run `python -m pytest tests/`, `flutter test` and `flutter analyze`. Record any existing failures separately with reproduction commands.
- [ ] On a disposable migrated MySQL installation, create a KHR 40,000 invoice with KHR 4,000 initially paid. Submit USD 1 directly to the payment API. Verify HTTP 409, zero new rows and KHR 36,000 still due on a fresh read. Pay KHR 36,000 in Flutter and verify the persisted status is paid and the balance is zero after reopening. Repeat with the default currency changed to USD.
