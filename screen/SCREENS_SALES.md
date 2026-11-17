# Sales

Implementation complete across the six routes and the existing payment Add/Edit forms. Both parallel branches were combined and verified on 2026-11-17 in `sales-integration-redesign`; manual QA listed below remains pending.

## Sale product selection — `frontend/lib/screen/sale/sale_screen/sale_screen.dart`
- **Route:** `/sale`
- **Purpose:** Selects products and starts a customer sale.
- **Navigation:** Manage, Home quick action, or sale history action; continue opens `/current-sale`.
- **UI:** Shared page/header/search, lazy category groups and product grid at normal wide sizes, natural-height cards at compact widths or large text, and safe cart summary/footer.
- **State/data:** `SaleController`, `SaleBinding`, product/sale services and sale/cart models.
- **Custom widgets:** `screen/sale/widget/card_item_widget.dart`, `payment_footer_widget.dart`, `select_customer_card_widget.dart`.
- **Redesign:** Scoped product-name/barcode search, preserved scanner return contract and selected quantities, themed stock indication, distinct loading/error/empty/no-match states, and retry retaining visible data and cart. Customer selection occurs on Current Sale.

## Current sale — `frontend/lib/screen/sale/current_sale/current_sale_screen.dart`
- **Route:** `/current-sale`
- **Purpose:** Reviews the active cart and adjusts quantities before payment.
- **Navigation:** Sale screen Continue opens this route. Payment confirms and creates the sale/payment directly, then opens `/payment-success`; Back to products retains the cart.
- **UI:** Cart item rows, summary and payment/continue actions.
- **State/data:** `SaleController`, active cart and sale item models.
- **Custom widgets:** `screen/sale/current_sale/widget/current_sale_item_widget.dart`, `summary_order_widget.dart`.
- **Redesign:** Shared grouped sections, paired wide layout and stacked large-text fallback, guarded quantities/customer/method selectors, recoverable lookup failures, and explicit empty-cart return action. The inactive Draft button was replaced by Back to products. Confirmation locks before its first await; only successful payment clears the cart. Failed payment retains the draft and attempts sale cleanup, with explicit uncertain-state feedback if cleanup fails.

## Recorded sale payments — `frontend/lib/screen/payment/payment_screen.dart`
- **Route:** `/sale-payment`
- **Purpose:** Manages recorded sale payments, including Add/Edit/Delete. This route is not checkout.
- **Navigation:** Manage opens the list; Add/Edit open the shared form; successful writes return to the refreshed list. Confirmed deletion retains the list route.
- **UI:** Shared header/actions/scoped search, lazy compact cards or wide shared table, retry and distinct load/error/empty/no-match states. The unconnected lifecycle-status chips were removed.
- **State/data:** `PaymentController`, `PaymentBinding`, `SalePaymentService` and `SaleService`.
- **Custom widgets:** `screen/payment/widget/payment_card_list_widget.dart`, `payment_table_widget.dart`, and shared `payment_form_widget.dart` via the existing Add/Edit wrappers.
- **Redesign:** Search covers invoice, customer, amount, method, reference and date. Forms use AppFormShell, paired wide fields, large-text fallback, finite positive amount validation, existing due ceilings and read-only sale identity on Edit. Save/open guards prevent duplicate forms/writes; saving blocks dismissal and desktop navigation. Failed writes retain fields/date, while invalid submissions focus/scroll the first field and provide a linked error summary. Dates retain the existing picker bounds and safe legacy-date initialization.

## Payment success — `frontend/lib/screen/sale/widget/payment_success_widget.dart`
- **Route:** `/payment-success`
- **Purpose:** Confirms a sale and presents receipt details/actions.
- **Navigation:** Checkout completion opens this route with a receipt map; Back to Sale retains the existing Home boundary in the route stack.
- **UI:** Success state, receipt summary and follow-up buttons.
- **State/data:** Receipt route argument; sale/payment models.
- **Custom widgets:** Shared page/header and theme-native receipt/action surfaces; existing injectable `ReportExportController`.
- **Redesign:** Scrollable, wrapping receipt values work on short screens, both themes/locales and large text; missing arguments show an unavailable state. The decorative animation sequence was removed. Guarded PDF export preserves all six fields, currency formatting and cancellation/failure handling. The shared PDF generator embeds the bundled Khmer font when needed; visual shaping quality still needs manual inspection.

## Sales list — `frontend/lib/screen/sale/sale_list/sale_list_screen.dart`
- **Route:** `/sale-list`
- **Purpose:** Browses recorded sales.
- **Navigation:** Manage or Home recent-sales action; row opens `/sale-list-detail`, action may start `/sale`.
- **UI:** Shared header/New Sale/Refresh actions, scoped search, lazy compact cards or shared wide table, large-text fallback and fully scrollable headers on short screens.
- **State/data:** `SaleListController`, sale list service/models.
- **Custom widgets:** `screen/sale/sale_list/widget/sale_card_widget.dart` and detail widget.
- **Redesign:** Retained query/data across refresh or failure, retry and distinct loading/error/empty/no-match states, keyboard-accessible record navigation, and normalized status text with theme-aware badges. The existing 60-second cache is invalidated after successful checkout creation/payment/compensating cleanup and payment create/update/delete.

## Sale detail — `frontend/lib/screen/sale/sale_list/widget/sale_list_detail_widget.dart`
- **Route:** `/sale-list-detail`, selected sale argument.
- **Purpose:** Reviews a recorded sale’s items and payment information.
- **Navigation:** Sales list card; back returns to list.
- **UI:** Shared page/header with Back/New Sale/Delete, grouped invoice/customer/items/payment/amount sections, paired wide layout and stacked large-text fallback.
- **State/data:** Sale argument from `SaleListController`, sale models.
- **Custom widgets:** Local sale detail/card components.
- **Redesign:** Defensive decimal-string/date/nested-map presentation, line prices/subtotals, all existing financial totals and visible delete errors. Invalid route arguments show a safe unavailable state. Confirmed deletion is guarded against duplicate requests and cannot pop a newer route after a held write.

## Redesign notes

- All six screens use shared UI kit/theme/tokens and separate product/history/payment search state. Existing route strings, payload keys, UTC writes, barcode navigation, server-authoritative checkout total, edit balance ceiling and confirmed deletion remain in place.
- The desktop shell now disables sidebar/profile navigation while checkout is confirming/writing or a payment form is saving. This closes the route-removal path outside Navigator modal barriers that PopScope alone could not prevent.
- A fresh independent review found this sidebar issue and a malformed display separator; both were reproduced by tests and fixed before final verification.
- Historical sale/payment API records lack currency metadata. History retains its existing dollar display fallback; checkout/receipt use the loaded shop currency. Historical currency reconstruction is outside this UI change.
- Sale and payment creation remain two HTTP writes with best-effort cleanup. Backend transaction atomicity, timeout reconciliation and idempotency are separate work; the frontend does not automatically repeat ambiguous writes.

## Verification — 2026-11-17

- `flutter test --no-pub --reporter expanded`: **1,028 passed, one web-only test skipped, zero failures** on the final combined tree.
- `flutter analyze --no-pub`: **17 pre-existing diagnostics**, none in changed Dart files. The command remains nonzero because those baseline diagnostics are still present.
- `flutter build web --no-pub`: **exit 0**. Flutter reports existing Wasm dry-run warnings; the standard web build succeeds.
- Explicit changed-file Dart formatting gate (excluding the pre-existing whole-locale-map formatting baseline): passed. `git diff --check`: passed. Generated platform-registrant churn from dependency preparation was restored.
- Focused final-review regressions: **44 passed**, including actual-shell held checkout/payment writes, cross-pass navigation, responsive management layouts and API line-price rendering.
- Added integration coverage includes successful/legacy-fallback sale creation and payment/cleanup cache invalidation, independent queries across history/detail/new-sale/payment-save routes, en/km copy coverage, distinct initial load/error states, paired layouts, first-error focus and linked validation summary.

## Remaining manual checks and limitations

- Live browser/API walks and compact/wide screenshots; physical scanner/camera cancellation and return; keyboard-only and spoken TalkBack/VoiceOver/NVDA checks.
- Visual Khmer receipt PDF shaping, line wrapping and exported-file save/retrieval on the target devices. Automated tests verify glyph availability and the export data contract, not visual shaping quality.
- The existing product web-only upload test remains skipped in the VM suite. Both agent sessions attempted Chrome execution and stalled during test loading; no Chrome pass is claimed for this integration.
- Shared report-export feedback still contains legacy raw error/path copy; this inherited minor remains outside the integration fix pass.

