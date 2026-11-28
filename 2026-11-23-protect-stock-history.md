# Protect Stock History Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** After receiving ten units and selling eight, a rejected receipt deletion explains the eight-unit shortage and leaves the receipt and its remaining two units intact.

**Architecture:** Purchase CRUD owns the receipt and its signed inventory changes in one database transaction. Product and warehouse-stock CRUD manage assignments, while the existing transfer and adjustment workflows record physical moves and corrections. Flutter exposes those workflows and displays the server's decision on the screen where the user acted.

**Tech Stack:** FastAPI, SQLModel, SQLAlchemy, MySQL/InnoDB, pytest with SQLite fixtures, Flutter and GetX.

**Spec:** [Improve inventory management, implementation order item 3](improve.md#implementation-order). Follow the [repository guide](CLAUDE.md).

## Global Constraints

- “Validate the net whole-unit change per warehouse before editing or deleting a receipt.”
- “Require transfers for moves, reasoned adjustments for corrections, and block deletion of live balances.”
- “Check that editing a product cannot silently relocate stock.”
- Preserve deletion confirmation, existing response models, payment recalculation, and stock cache invalidation after successful writes. Use the shared Flutter UI kit and English and Khmer translations.
- Run backend commands from `backend/` with its virtual environment active and Flutter commands from `frontend/`. Commit only implementation and test files during execution. The plan stays uncommitted.

## Review Focus

1. **Consumed receipt.** Failure on any line preserves all balances, receipt lines, header fields and payments, including after a retry. Tasks 1 and 4.
2. **Repeated lines and whole units.** Compare combined contributions for each product in each warehouse. Reject historical fractions before conversion. Task 1.
3. **Warehouse-only receipt edit.** Reposting a receipt to correct its recorded warehouse must reverse the original contribution in full. Stock elsewhere cannot cover a shortage. Task 1.
4. **Alternate write paths.** Product edits, bulk balance creation, direct PUTs and adjustment edits must never silently reassign on-hand units. Tasks 2 and 3.
5. **Stale stock on screen.** A concurrent sale or receipt can change the balance before confirmation. The server decides from current rows, and Flutter retains the rejected record. Tasks 1, 2 and 4.

---

## File map

| Task | Production files | Test files |
| --- | --- | --- |
| 1. Receipt arithmetic and transaction | `backend/app/crud/purchase/purchase.py`, `backend/app/schemas/purchase/purchase_item.py` | `backend/tests/test_stock_flows.py` |
| 2. Product and balance write guards | `backend/app/crud/product/product.py`, `backend/app/crud/warehouse/warehouse_stock.py`, `backend/app/schemas/warehouse/warehouse_stock.py` | `backend/tests/test_product_warehouse.py`, new `backend/tests/test_warehouse_stock_guards.py` |
| 3. Reasoned corrections | `backend/app/schemas/stock/stock_adjustment.py`, `backend/app/crud/stock/stock_adjustment.py`, `frontend/lib/controllers/stock_adjustment_controller.dart`, `frontend/lib/screen/stock/stock_adjustment/widget/stock_adjustment_form_widget.dart` | `backend/tests/test_stock_flows.py`, `frontend/test/stock_adjustment_{form_test,controller_test,test_support}.dart` |
| 4. Product, purchase and balance screens | `frontend/lib/controllers/{product_controller,warehouse_stock_controller,purchase/purchase_controller}.dart`, `frontend/lib/screen/product/widget/product_form_widget.dart`, `frontend/lib/screen/purchases/widget/purchase_item_row_widget.dart`, `frontend/lib/screen/stock/warehouse_stock/warehouse_stock_screen.dart`, its `widget/{warehouse_stock_card_widget,warehouse_stock_form_widget,edit_warehouse_stock_widget}.dart`, `frontend/lib/services/main_service/warehouse_stock_service.dart` | `frontend/test/product_form_test.dart`, `frontend/test/purchase_{form_test,redesign_test,test_support}.dart`, `frontend/test/warehouse_stock_{controller_test,form_test,redesign_test,test_support}.dart` |

Brace lists denote individual files in the named directory. Tasks 3 and 4 also own their respective new strings in `frontend/lib/localization/en_us.dart` and `frontend/lib/localization/km_kh.dart`. Read `backend/app/routes/purchase/purchase.py`, `backend/app/routes/warehouse/warehouse_stock.py`, and `frontend/lib/services/api_service.dart` for the existing cache and error contracts.

### Task 1. Apply the net receipt change atomically

**Interfaces.** Keep `create_purchase(session: Session, purchase: PurchaseCreate) -> Purchase`, `update_purchase(session: Session, purchase_id: int, purchase: PurchaseUpdate) -> Purchase` and `delete_purchase(session: Session, purchase_id: int) -> dict`. Add a purchase-local `_apply_receipt_delta(session: Session, old: dict[tuple[int, int], int], new: dict[tuple[int, int], int]) -> None`. Keys are `(warehouse_id, product_id)`. HTTP 409 carries a human-readable `detail` for an unsafe reversal. Keep the existing 404 for a missing purchase.

- [ ] In `test_stock_flows.py`, use `make_stocked_product(..., qty=0)`, `make_purchase`, `sale_payload` and the actual sale CRUD. Add these named tests. Re-read persisted records after expiring the session. Check the state after failure before issuing any caller-side rollback.

  | Test | Setup and assertions |
  | --- | --- |
  | `test_consumed_receipt_cannot_be_deleted` | Receive 10 in A, sell 8, try deletion twice. Both return 409 identifying product, A, 10 required, 2 available, 8 short. Assert the original invoice, line IDs and quantities, sale and any linked payment survive, and `stock_qty(...) == 2`. |
  | `test_receipt_edit_uses_combined_net_delta` | Original lines 6 + 4, sell 8. Replacing them with 5 + 5 leaves 2, replacing with 4 + 5 leaves 1. Reducing to 7 fails and preserves the last successful edit. |
  | `test_receipt_failure_preserves_other_lines_and_header` | Change invoice number, paid amount and two products in one PUT. Make the second product short. Assert both original balances, IDs, header values and payment totals survive. A subsequent unrelated successful commit must not persist rejected changes. |
  | `test_receipt_warehouse_change_uses_original_lines` | Parameterize omitted items and explicit replacement lines. With all ten available and B assigned, repost A to B and assert A=0, B=10. With A=2 and B already holding 20, reject and keep both balances and the original warehouse. Omitted items in a same-warehouse metadata edit retain line IDs. |
  | `test_receipt_reversal_requires_valid_recorded_units_and_balance` | Exercise an unassigned destination, a missing source row, ambiguous duplicate balance rows and a stored 1.50-unit line inserted through the model. A stock-changing edit/delete fails with identifying detail and preserves the evidence. A valid stored 10.00 converts exactly. |
  | `test_purchase_quantity_must_be_positive_whole_units` | Create/update input rejects 0, -1 and 1.50. An integral decimal is accepted. Deleting an untouched ten-unit receipt succeeds once and leaves zero. Explicit empty replacement lines reverse the old contribution under the same shortage rule. |

- [ ] Run `python -m pytest tests/test_stock_flows.py -k "receipt or purchase_quantity" -v`. Expect failures on unchecked deletion, warehouse-only updates and nonpositive input.
- [ ] Extend `PurchaseItemCreate.whole_units_only` to require positive integral quantities. When reversing persisted lines, validate each Decimal before converting or aggregating. Leave historical rows readable. Build the two contribution maps from the original header and lines and the effective new header and lines. Creation has an empty old map. Deletion has an empty new map. A metadata-only update skips stock processing.
- [ ] In the three CRUD writers, lock the existing purchase before loading its lines for an update/delete. For each affected pair in stable order, lock and refresh its stock row using `with_for_update()` and `populate_existing=True`. Require an assigned destination and a resolvable source. Validate all pairs before writing: `delta = new.get(key, 0) - old.get(key, 0)`, and for a decrease require `available >= -delta`. On shortage return e.g. `Cannot reverse 10 units of product 4 in warehouse 2: 2 available, 8 short.` Apply each signed delta once. For duplicate historical balance rows, report the ambiguity and leave them intact.
- [ ] Replace the old full subtraction/addition loops. Only replace lines when supplied, preserve existing reference guards, and keep header updates, line changes, stock and `calculate_purchase_payment` in the existing transaction. On any failure roll back before re-raising. Keep the routes' current post-success cache clears.
- [ ] Run `python -m pytest tests/test_stock_flows.py tests/test_purchase_payment_cache.py`. Expect the new cases and existing purchase, sale, transfer, adjustment and payment checks to pass. On disposable MySQL, hold an uncommitted sale of eight from ten in connection A, attempt receipt deletion in B, then commit A. Verify B resumes with 409 and an independent read returns two. SQLite alone cannot establish lock behavior.
- [ ] Commit Task 1 implementation and tests with `backend: validate receipt changes against available stock`. Stage only this task's hunks if the working tree still contains the separate sale allocation work.

### Task 2. Close direct balance mutation paths

**Interfaces.** Keep product create/update and the existing warehouse-stock POST, PUT and DELETE routes. POST accepts zero-quantity assignments. A legacy PUT matching the same product, warehouse and quantity returns the row. A change to those values returns 409 with transfer or adjustment guidance. DELETE removes an unused zero assignment and returns 409 for a live balance. Missing mutation targets return 404.

- [ ] Replace `test_update_product_moves_existing_stock_and_keeps_qty` with `test_product_edit_cannot_move_seven_units`. Attempt a rename plus a switch from A to unassigned B. Assert `status_code == 409`, the old name and row ID survive, A=7, and B has no row. Retain the existing first assignment and metadata-only tests. A legacy client echoing any already assigned warehouse succeeds without touching either balance.
- [ ] In `test_warehouse_stock_guards.py`, add `test_assignment_batch_is_zero_only_and_atomic` (a valid first row followed by a nonzero or duplicate row leaves zero new rows), `test_balance_put_is_idempotent_only` (unchanged payload succeeds, changed quantity, warehouse or product fails), and `test_delete_rechecks_current_balance` (a row displayed as zero later becomes 3, DELETE returns 409 and a fresh read sees 3). Include a legacy negative balance, a missing ID, an empty/multiline PUT, and a successful unused zero deletion. A zero row still needed to reverse recorded history must survive, including a fully sold receipt.
- [ ] Run `python -m pytest tests/test_product_warehouse.py tests/test_warehouse_stock_guards.py -v`. Expect failures on relocation, overwrites, and live deletion.
- [ ] In `_sync_product_warehouse(session, product_id, warehouse_id)`, validate before editing metadata. Permit an existing pair or the first zero assignment for a previously unassigned product. Reject other reassignment attempts with transfer guidance. Keep product creation's initial zero assignment.
- [ ] Constrain direct create to a nonempty batch of zero assignments, detect duplicates, and roll back the batch on failure. Validate PUT cardinality before indexing. Lock and refresh the target in `update_warehouse_stock` and `delete_warehouse_stock` before comparing. Count any nonzero quantity as live. For a zero row, retain it if recorded receipt lines, sale allocations, transfers or adjustments for that product and warehouse rely on it. Check purchase warehouse through its header and transfers through either endpoint. Where a legacy sale's warehouse is unknown, preserve the product's possible source row. Return a clear conflict reason.
- [ ] Run `python -m pytest tests/test_product_warehouse.py tests/test_warehouse_stock_guards.py tests/test_warehouse_cache.py`. Expect the guards and existing read/cache checks to pass. Commit the task with `backend: protect warehouse balances from direct changes`.

### Task 3. Require a reason for stock corrections

**Interfaces.** `StockAdjustmentCreate.reason` and the effective reason on `StockAdjustmentUpdate` must contain non-whitespace text. Quantities are positive whole units. An edit may correct the adjustment at its recorded product and warehouse. Reassigning it to another pair returns 409. Keep the existing transfer API for physical moves.

- [ ] Add `test_adjustment_requires_effective_reason` and `test_adjustment_edit_cannot_relocate_stock` to `test_stock_flows.py`. Test blank, whitespace, omitted update reason with a stored reason, and a legacy empty reason. With “  Damaged  ”, assert `(reason, previous_qty, qty, new_qty) == ("Damaged", 5, 2, 3)` on a decrease. Failed validation, a negative quantity, or an attempted pair change preserves the adjustment and both balances.
- [ ] In the Flutter adjustment form and controller tests, replace expectations that accept a blank reason. Assert `service.payload == null` for whitespace on a fresh fake, a valid reason is trimmed in the outgoing payload, and a legacy empty reason can be supplied during edit. Keep reference number optional. Seed a valid reason in successful-save fixtures.
- [ ] Run `python -m pytest tests/test_stock_flows.py -k adjustment` and `flutter test test/stock_adjustment_form_test.dart test/stock_adjustment_controller_test.dart`. Expect failures on the old optional-reason behavior.
- [ ] Validate supplied quantity and reason in the schemas, then validate the effective stored values and immutable pair in CRUD before touching a balance. Lock and refresh stock on adjustment writes before computing the stored before/after values. Roll back failed mutations. In Flutter, enforce the trimmed reason in `_inputError()` and the Reason field, localize the validation message, and make the warehouse and product selectors read-only on edit.
- [ ] Repeat the focused commands. Expect all checks to pass, including the existing transfer happy path when running `python -m pytest tests/test_stock_flows.py`. Commit with `Require a reason for stock corrections`.

### Task 4. Show users how to resolve blocked stock changes

**Interfaces.** Reuse `ApiException.statusCode` and `ApiException.message`, existing `formError` surfaces, and named destinations `AppRoutes.stockTransfer` and `AppRoutes.stockAdjustment`. Keep the product creation warehouse selector. Product metadata updates omit `warehouse_id`.

- [ ] Add widget assertions to the mapped Flutter tests. In the purchase fake, throw `ApiException(409, 'Cannot reverse 10 units of product 4 in warehouse 2: 2 available, 8 short.')` on edit and delete. Assert the detail appears in the form or detail view, the draft/invoice remains visible, and the cached row survives. A fractional quantity sends zero requests. Preserve generic transport-error coverage.
- [ ] In product form tests assert `service.lastUpdatedData!.containsKey('warehouse_id') == false` using the fake's captured payload and verify the edit form offers no warehouse change. In warehouse-stock tests assert every new assignment sends `qty: 0`, both compact and wide layouts offer transfer and adjustment actions, a live row has no Delete action, and deleting an eligible zero row still requests confirmation. Simulate a server 409 after confirmation and assert the row and explanation stay visible.
- [ ] Run `flutter test test/purchase_form_test.dart test/purchase_redesign_test.dart test/product_form_test.dart test/warehouse_stock_form_test.dart test/warehouse_stock_controller_test.dart test/warehouse_stock_redesign_test.dart`. Expect failures on the generic shortage copy and existing edit controls.
- [ ] In purchase `_save` and `deletePurchase`, show the conflict detail through the existing error text and preserve the fallback for transport failures. Validate positive, finite whole quantities in both the purchase row and submit guard, accepting an existing integral value such as `10.00`. On product edit, remove warehouse selection and its required validation and omit the field from the update payload.
- [ ] Make the warehouse-stock form create zero assignments only, preserving batch product selection. Remove the retired edit widget, its controller/service path and obsolete quantity inputs/tests. Replace the shared card/table Edit action with navigation to the existing transfer and adjustment screens. Offer Delete only for known zero balances. Keep backend conflict detail visible on stale or referenced rows. Update English and Khmer labels and action guidance.
- [ ] Run the focused Flutter command, then `flutter test`, `flutter analyze` and `python -m pytest tests/`. Expect passing tests and no new analyzer findings against the starting revision. Record any skips. On a disposable installation receive 10, sell 8 and confirm deletion in the purchase detail. Reopen the receipt and warehouse view to verify the original ten-unit line, the two-unit balance and the shortage explanation. Verify a product rename conserves that balance and a reasoned adjustment creates a history entry.
- [ ] Commit the Task 4 files with `frontend: guide stock changes through recorded workflows`.
