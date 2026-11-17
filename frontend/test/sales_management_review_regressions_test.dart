import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/payment/widget/add_payment_widget.dart';
import 'sales_management_test_support.dart';
import 'payment_crud_test.dart' as fixtures;

void main() {
  tearDown(() => Get.reset());
  setUp(() => dotenv.testLoad(fileInput: 'API_URL=http://localhost'));
  testWidgets('add load failure is visible to the initiating payment list', (
    tester,
  ) async {
    final ctr = PaymentController(
      service: fixtures.FakeSalePaymentService(),
      saleService: ManagementSaleService()..readError = Exception('offline'),
    );
    Get.put(ctr);
    late BuildContext page;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            page = context;
            return const Scaffold();
          },
        ),
      ),
    );
    await ctr.addPayment(page);
    expect(ctr.loadError.value, isNotEmpty);
    ctr.onClose();
  });
  testWidgets('late sale load does not open over another route', (
    tester,
  ) async {
    final held = Completer<dynamic>();
    final ctr = PaymentController(
      service: fixtures.FakeSalePaymentService(),
      saleService: ManagementSaleService()..rows = held.future,
    );
    Get.put(ctr);
    late BuildContext page;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            page = context;
            return const Scaffold();
          },
        ),
      ),
    );
    final opening = ctr.addPayment(page);
    Navigator.of(page).push(
      MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Other'))),
    );
    await tester.pumpAndSettle();
    held.complete([]);
    await tester.pumpAndSettle();
    expect(find.byType(AddPaymentWidget), findsNothing);
    Navigator.of(page).pop();
    await tester.pumpAndSettle();
    // If the old implementation opened a form, close it so the test can finish.
    if (ctr.isOpeningForm.value) {
      Navigator.of(page).pop();
      await tester.pumpAndSettle();
    }
    await opening;
    ctr.onClose();
  });
  testWidgets('system back releases sale confirmation guard', (tester) async {
    final ctr = SaleListController(service: ManagementSaleService());
    Get.put(ctr);
    late BuildContext page;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            page = context;
            return const Scaffold();
          },
        ),
      ),
    );
    final deleting = ctr.onDeleteSale(1, page);
    await tester.pumpAndSettle();
    Navigator.of(page).pop();
    await tester.pumpAndSettle();
    await deleting;
    expect(ctr.deletingIds, isEmpty);
  });

  testWidgets('completed sale delete does not pop a newer route', (
    tester,
  ) async {
    final gate = Completer<void>();
    final service = ManagementSaleService()..deleteGate = gate;
    final ctr = SaleListController(service: service);
    late BuildContext detail;
    await tester.pumpWidget(
      GetMaterialApp(home: const Scaffold(body: Text('Home'))),
    );
    Get.to(
      () => Builder(
        builder: (context) {
          detail = context;
          return const Scaffold(body: Text('Detail'));
        },
      ),
    );
    await tester.pumpAndSettle();
    ctr.onDeleteSale(1, detail);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    Get.to(() => const Scaffold(body: Text('Other')));
    await tester.pumpAndSettle();
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('Other'), findsOneWidget);
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });
}
