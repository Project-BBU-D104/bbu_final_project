# Inventory management system audit and action plan

**Ready for a supervised demo.** A configured installation can take a purchase through receipt, sale, payment, and history. Daily stock and cash reconciliation depends on fixing warehouse allocation, interrupted checkout, purchase reversals, and supplier settlement.

## What works today

The [README](README.md) describes eleven business areas. Suppliers, customers, and warehouses support basic CRUD. Referenced customers and warehouses can show generic deletion errors. Product search and scanning, category management, transfers, adjustments, sales, purchases, payments, users, and roles are connected, with the limitations below. The app also includes purchase requests, units, currencies, payment types, configuration, audit history, a dashboard, and six report destinations. [Flutter routes](frontend/lib/routes/app_routes.dart)

Keep the existing login timeout feedback, landing-page retry, checkout confirmation and busy states, receipts, deletion confirmation, labeled Back navigation, and profile, language, theme, and logout controls.

## Implementation order

Each step pairs the change with a check. Steps 1–6 address high-severity findings. Step 7 covers a high-priority missing workflow. Steps 8–10 cover medium-severity findings.

1. **Make warehouse allocation explicit.** Show availability per warehouse in the POS and product views. Persist the warehouse and quantity deducted for each sale line and use that allocation on reversal. Check the audit case with one unit in A and four in B. Selling three from B should leave A at one and B at one. Reversing should restore B to four. [Catalog](backend/app/routes/api/product_category.py) · [Sale persistence](backend/app/crud/sale/sale.py)

2. **Make checkout atomic and safe to retry.** Commit the sale, initial payment, and stock deduction in one transaction. Reuse the same checkout ID after a timeout. Simulate a lost response after commit and retry the cart. Expect one invoice, one payment, and one deduction. Disable sold-out items, cap quantities at available stock, surface specific stock errors, and show the persisted invoice number and lines on the receipt. [Checkout](frontend/lib/controllers/sale/sale_controller.dart) · [Receipt](frontend/lib/screen/sale/widget/payment_success_widget.dart)

3. **Protect stock history.** Validate the net whole-unit change per warehouse before editing or deleting a receipt. Receive ten, sell eight, then attempt to delete the receipt. The operation should explain the shortage and preserve the receipt and remaining two units. Require transfers for moves, reasoned adjustments for corrections, and block deletion of live balances. Check that editing a product cannot silently relocate stock. [Purchases](backend/app/crud/purchase/purchase.py) · [Products](backend/app/crud/product/product.py) · [Balances](backend/app/crud/warehouse/warehouse_stock.py)

4. **Settle supplier invoices in their recorded currency.** Store invoice currency. Accept matching payments or store the applied exchange rate and converted amount. Check a KHR invoice with a USD payment so raw amounts can never be summed across currencies. In both currency forms, bind Default and Status to their respective fields and validate a finite positive rate on client and server. [Payment calculation](backend/app/crud/purchase/purchase_payment.py) · [Currency forms](frontend/lib/screen/currency/widget)

5. **Align permissions and login.** Define access for Admin, Supervisor, Cashier, and Stock Manager across API operations, routes, menus, and Home shortcuts. Check Cashier access to Suppliers and Owner visibility of admin actions. Protect the last administrator against role changes, including renaming Admin. Resolve duplicate usernames before enforcing uniqueness, reject disabled accounts before issuing tokens, and replace fixed seed passwords with installation-specific credentials. [Authorization](backend/app/security.py) · [Login](backend/app/services/auth_service.py) · [Shortcuts](frontend/lib/screen/home/widget/quick_action_widget.dart)

6. **Verify installation and sales reporting before daily use.**
   - **Install from an empty database.** Correct the README's SQLite assumption and dependency filename. Document venv creation, MySQL, `DATABASE_URL`, `SECRET_KEY`, `pip install -r requirements.txt`, and `python -m alembic upgrade head`. Seed default data before the admin account, then start Uvicorn. Document Dart `>=3.11.4 <4.0.0`, Supabase URL and anon key, a device-reachable `API_URL`, and Flutter setup. Walk through first login to first sale, including warehouse and currency selection. Verify the promised Khmer default on a fresh install, which the audit found opened in English. [Backend settings](backend/.env.example) · [Frontend settings](frontend/assets/.env.example) · [Language](frontend/lib/controllers/language_controller.dart)
   - **Reconcile the sales report.** Use the start of the next business day as the exclusive upper bound. Include a late sale on the selected end date and exclude one at the next midnight in both totals and export. Use recorded currencies and translated column labels. [Sales report](frontend/lib/screen/report/all_report/sales_report_screen.dart)

7. **Add linked returns and refunds.** Let a cashier return a quantity against an original invoice line. Record warehouse, quantity, refund amount, and reason. Check that a partial refund preserves the original sale and payment history. [Sale deletion](backend/app/crud/sale/sale.py)

8. **Make interrupted work recoverable.** Save purchase-request header and lines in one transaction and verify an interrupted edit leaves the prior order intact. Bound protected HTTP requests, distinguish Payment Types fetch errors from an empty list, and provide retry. Decouple Telegram delivery from category creation so notification failure still shows a successful save. [Purchase requests](frontend/lib/controllers/purchase/purchase_request_controller.dart) · [HTTP client](frontend/lib/services/api_service.dart) · [Categories](backend/app/crud/category/category.py)

9. **Make reporting and audit history trustworthy.** Hide the five title-only reports until usable. Prioritize Stock Ledger, Sale Payment, and Purchase Payment, then Purchase and Profit and Loss. Verify refresh and filtering wherever offered. Generate append-only audit entries in each business transaction. Include products without warehouse rows in low-stock results as zero or explicitly unassigned. [Report menu](frontend/lib/controllers/report_controller.dart) · [Audit API](backend/app/routes/audit_logs/audit_logs.py) · [Dashboard](backend/app/routes/dashboard/dashboard.py)

10. **Verify web, iOS, and accessibility.** Use browser file bytes for exports and product/customer photo editing. Reload product and configuration detail URLs directly. Resolve dependencies and fetch by ID, with recovery for missing records. Add the iOS camera usage description and test scanning. Test the Payment Type form on a narrow screen with Khmer, large text, and the keyboard open. Use a scrollable form, label the Add icon, raise the 45 dp Save target to at least 48 dp, and bring status text contrast from approximately 2.47:1 and 3.22:1 to at least 4.5:1. [Export](frontend/lib/services/export_service.dart) · [Routes](frontend/lib/routes/app_pages.dart) · [iOS configuration](frontend/ios/Runner/Info.plist) · [Payment Type widgets](frontend/lib/screen/payment_type/widget)

## Follow-up workflows

- **Medium — physical stocktake.** Add count sessions with expected and counted quantities, review, and batch posting of approved variances as adjustments.
- **Medium — replenishment.** Support reorder points per product and warehouse, with the configured global threshold as fallback.
- **Low — account recovery.** The login screen directs users to an administrator. Add verified self-service reset if deployments require it.

## Verification on record

The original audit traced Flutter screens through backend persistence. It recorded **64 backend tests passed and 2 HTTP cache tests skipped** because their test-client dependency was unavailable. In-memory checks reproduced the split-warehouse sale rejection and failed purchase reversal. Flutter tests, live MySQL, browser rendering, iOS behavior, and device accessibility remained unverified. The checks in the numbered steps are acceptance criteria for future fixes.
