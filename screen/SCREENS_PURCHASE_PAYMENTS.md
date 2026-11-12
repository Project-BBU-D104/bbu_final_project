# Purchase Payments

## Purchase payments — `frontend/lib/screen/purchase_payment/purchase_payment_screen.dart`
- **Route:** `/purchase-payment`
- **Purpose:** Browses and manages payments against purchases.
- **Navigation:** Manage; add/edit/detail actions within the feature.
- **UI:** Searchable responsive card/table list with add, edit and delete actions.
- **State/data:** `PurchasePaymentController`, `PurchasePaymentBinding`, payment service/models.
- **Custom widgets:** `screen/purchase_payment/widget/purchase_payment_card_widget.dart`, add/edit/detail widgets.
- **Current design issues:** Specific styling issues unclear.

## Add purchase payment — `frontend/lib/screen/purchase_payment/widget/add_purchase_payment_widget.dart`
- **Route:** None; form widget, exact host unclear.
- **Purpose:** Records a purchase payment.
- **Navigation:** Payment list add action; save/cancel returns to host.
- **UI:** Payment fields and actions.
- **State/data:** `PurchasePaymentController`, purchase/payment data and service.
- **Custom widgets:** Feature payment card/form components.
- **Current design issues:** Hosting constraints unclear.

## Edit purchase payment — `frontend/lib/screen/purchase_payment/widget/edit_purchase_payment_widget.dart`
- **Route:** None; form widget, exact host unclear.
- **Purpose:** Updates a purchase payment.
- **Navigation:** Payment list edit action; save/cancel returns to host.
- **UI:** Prefilled payment form and actions.
- **State/data:** `PurchasePaymentController`, selected payment.
- **Custom widgets:** Feature payment card/form components.
- **Current design issues:** Hosting constraints unclear.

## Purchase payment detail — `frontend/lib/screen/purchase_payment/widget/purchase_payment_detail_widget.dart`
- **Route:** Not registered in `AppPages`; pushed from the list card and table row.
- **Purpose:** Reviews one purchase payment record.
- **Navigation:** Expected from the payment list; exact caller unclear.
- **UI:** Scaffold and payment detail content.
- **State/data:** Selected payment; exact injection unclear.
- **Custom widgets:** `purchase_payment_card_widget.dart`.
- **Current design issues:** Caller uncertainty; verify usage before redesign.

## Redesign notes

Done: the purchase payment list, add form, edit form, and detail are redesigned. The list has distinct loading, error/retry, empty, and no-match states, keeps search across refresh, and adapts between cards and a table. Add and Edit share one supplier-style form with inline validation, a duplicate-submission guard, blocked dismissal while saving, and draft retention on failed writes. The detail screen uses the same themed surfaces and closes after a successful delete. The `/purchase-payment` route, service methods, and payment payload keys are unchanged.

Validation: the Flutter suite passed (407 passed, 1 web-only test skipped), targeted analysis reported no issues in the changed paths, and `flutter build web` exited 0. Live API, complete browser workflow, physical-device, and screen-reader checks remain pending.

