# Reports

## Sales report — `frontend/lib/screen/report/all_report/sales_report_screen.dart`
- **Route:** `/sale-report`
- **Purpose:** Filters, reviews and exports sales data.
- **Navigation:** Report index card; PDF preview flow from export action.
- **UI:** Filters, report/table content, export actions, page-format dialog.
- **State/data:** Report service/controller state and sales data; exact provider unclear from scan.
- **Custom widgets:** Report utilities/export service and shared app bar as used locally.
- **Current design issues:** Large stateful report page; inspect dense filters/table and literal styling.

## Sale payment report — `frontend/lib/screen/report/all_report/sale_payment_report_screen.dart`
- **Route:** `/sale-payment-report`
- **Purpose:** Reviews sale payment reporting data.
- **Navigation:** Report index; back returns to report tab.
- **UI:** Scaffold, app bar and report data content.
- **State/data:** Sale payment report service/state; precise controller unclear.
- **Custom widgets:** `custom_app_bar.dart`.
- **Current design issues:** Specific issues unclear.

## Purchase report — `frontend/lib/screen/report/all_report/purchase_report_screen.dart`
- **Route:** `/purchase-report`
- **Purpose:** Reviews purchase reporting data.
- **Navigation:** Report index; back returns to report tab.
- **UI:** Scaffold and report content.
- **State/data:** Purchase data/service; exact state owner unclear.
- **Custom widgets:** Shared app bar if used; exact reuse unclear.
- **Current design issues:** Specific issues unclear.

## Purchase payment report — `frontend/lib/screen/report/all_report/purchase_payment_report_screen.dart`
- **Route:** `/purchase-payment-report`
- **Purpose:** Reviews purchase payment data.
- **Navigation:** Report index; back returns to report tab.
- **UI:** Scaffold and report content.
- **State/data:** Purchase payment service/data; exact state owner unclear.
- **Custom widgets:** Shared app bar if used; exact reuse unclear.
- **Current design issues:** Specific issues unclear.

## Stock ledger report — `frontend/lib/screen/report/all_report/stock_ledger_report.dart`
- **Route:** `/stock-ledger-report`
- **Purpose:** Reviews stock ledger activity.
- **Navigation:** Report index; back returns to report tab.
- **UI:** Scaffold and ledger report content.
- **State/data:** Stock movement data/service; exact state owner unclear.
- **Custom widgets:** Shared app bar if used; exact reuse unclear.
- **Current design issues:** Specific issues unclear.

## Profit and loss report — `frontend/lib/screen/report/all_report/profit_and_loss_report.dart`
- **Route:** `/profit-and-loss-report`
- **Purpose:** Reviews profit and loss reporting data.
- **Navigation:** Report index; back returns to report tab.
- **UI:** Scaffold and report content.
- **State/data:** Sales/purchase figures; exact state owner unclear.
- **Custom widgets:** Shared app bar if used; exact reuse unclear.
- **Current design issues:** Specific issues unclear.

## PDF preview — `frontend/lib/screen/report/pdf_preview_screen.dart`
- **Route:** No registered route found; usage unclear.
- **Purpose:** Previews generated PDF output.
- **Navigation:** Report export flow is a candidate caller; whether this exact class is used is unclear.
- **UI:** Scaffold, preview and back action.
- **State/data:** PDF document/preview package state; exact source unclear.
- **Custom widgets:** None established.
- **Current design issues:** Potentially unused page; verify before redesign.

## Sales report page-format dialog — in `frontend/lib/screen/report/all_report/sales_report_screen.dart`
- **Route:** Dialog, not a page route.
- **Purpose:** Chooses PDF page format/orientation before export.
- **Navigation:** Opened from sales report export action; returns selected format or dismisses.
- **UI:** Dialog choices for page formats and cancel.
- **State/data:** `PdfPageFormat` selection.
- **Custom widgets:** Flutter dialog widgets.
- **Current design issues:** Dialog sizing and accessibility need review; detailed styling unclear.

## Redesign notes

