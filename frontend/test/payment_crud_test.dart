import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/screen/payment/payment_screen.dart';
import 'package:frontend/screen/payment/widget/add_payment_widget.dart';
import 'package:frontend/screen/payment/widget/edit_payment_widget.dart';
import 'package:frontend/screen/payment/widget/payment_card_list_widget.dart';
import 'package:frontend/services/main_service/sale_payment_service.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:get/get.dart';

class FakeStorageService implements IStorageService {
  @override
  Map<String, dynamic> get lastUserLoginRead => {
        'token': 'token',
        'user': {'id': 7},
      };

  @override
  String get currentUserRole => 'cashier';

  @override
  bool hasRole(String role) => false;

  @override
  T? readStorage<T>(StorageKey key) => null;

  @override
  Future<void> writeStorage(StorageKey key, dynamic value) async {}

  @override
  Future<void> removeStorage(StorageKey key) async {}

  @override
  Future<void> removeStorageMultiple(List<StorageKey> keys) async {}

  @override
  Future<void> appStartUpWrite({required String route}) async {}

  @override
  String get appStartUpRead => '';

  @override
  Future<void> lastUserLoginWrite({required Map<String, dynamic> data}) async {}

  @override
  Future<void> lastUserLoginRemove() async {}
}

class FakeSalePaymentService implements SalePaymentService {
  FakeSalePaymentService({List<Map<String, dynamic>>? payments})
      : payments = payments ?? [];

  List<Map<String, dynamic>> payments;
  Exception? failure;
  Completer<void>? createGate;

  final createCalls = <Map<String, dynamic>>[];
  final updateCalls = <Map<String, dynamic>>[];
  final deleteCalls = <int>[];
  int getPaymentsCalls = 0;

  @override
  Future<dynamic> getPayments() async {
    getPaymentsCalls++;
    return payments;
  }

  @override
  Future<dynamic> getSalePaymentById(int id) async => {};

  @override
  Future<dynamic> createSalePayment(Map<String, dynamic> data) async {
    if (createGate != null) await createGate!.future;
    if (failure != null) throw failure!;
    createCalls.add(data);
    return data;
  }

  @override
  Future<dynamic> updateSalePayment(int id, Map<String, dynamic> data) async {
    if (failure != null) throw failure!;
    updateCalls.add({'id': id, 'data': data});
    return data;
  }

  @override
  Future<dynamic> deleteSalePayment(int id) async {
    if (failure != null) throw failure!;
    deleteCalls.add(id);
    return {};
  }
}

class FakeSaleService implements SaleService {
  FakeSaleService({List<Map<String, dynamic>>? sales}) : sales = sales ?? [];

  List<Map<String, dynamic>> sales;

  @override
  Future<dynamic> getSales() async => sales;

  @override
  Future<dynamic> getProductCategories() async => [];

  @override
  Future<dynamic> getSaleById(int id) async => {};

  @override
  Future<dynamic> createSale(Map<String, dynamic> data) async => data;

  @override
  Future<dynamic> updateSale(int id, Map<String, dynamic> data) async => data;

  @override
  Future<dynamic> deleteSale(int id) async => {};
}

Map<String, dynamic> saleFixture({double due = 50.0}) => {
      'id': 3,
      'invoice_no': 'SALE-3',
      'due_amount': due,
      'payment_status': 'unpaid',
      'customer': {'name': 'Alice'},
    };

Map<String, dynamic> paymentFixture({
  int id = 11,
  num amount = 40.0,
  double saleDue = 60.0,
}) =>
    {
      'id': id,
      'amount': amount,
      'payment_method': 'Cash',
      'reference_no': 'REF-1',
      'payment_date': '2026-11-01T00:00:00Z',
      'note': 'Existing',
      'user': {'id': 7},
      'sale': {
        'id': 3,
        'invoice_no': 'SALE-3',
        'due_amount': saleDue,
        'payment_status': 'Partial',
        'customer': {'name': 'Alice'},
      },
    };

Future<void> closeToasts(WidgetTester tester) async {
  Get.closeAllSnackbars();
  await tester.pumpAndSettle();
}

Future<void> openAddSheet(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> fillValidPayment(PaymentController ctr, {String amount = '25.5'}) async {
  ctr.selectedSaleId.value = 3;
  ctr.amountCtrl.text = amount;
  ctr.methodCtrl.text = 'Cash';
  ctr.referenceCtrl.text = 'REF-1';
  ctr.noteCtrl.text = 'Deposit';
  ctr.paymentDate.value = DateTime.utc(2026, 11, 8);
}

Future<void> tapSave(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(ElevatedButton, label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    if (!locator.isRegistered<IStorageService>()) {
      locator.registerSingleton<IStorageService>(FakeStorageService());
    }
  });

  tearDown(() {
    Get.reset();
  });

  Future<PaymentController> pumpScreen(
    WidgetTester tester, {
    required FakeSalePaymentService paymentService,
    List<Map<String, dynamic>>? sales,
  }) async {
    final ctr = PaymentController(
      service: paymentService,
      saleService: FakeSaleService(sales: sales ?? [saleFixture()]),
    );
    Get.put<PaymentController>(ctr);
    await tester.pumpWidget(GetMaterialApp(home: PaymentScreen()));
    await tester.pumpAndSettle();
    return ctr;
  }

  testWidgets('create sends the full sale payment payload', (tester) async {
    final paymentService = FakeSalePaymentService();
    final ctr = await pumpScreen(tester, paymentService: paymentService);

    await openAddSheet(tester);
    expect(find.byType(AddPaymentWidget), findsOneWidget);
    expect(find.text('Add Payment Screen'), findsNothing);

    await fillValidPayment(ctr);
    await tester.pump();
    await tapSave(tester, 'Save');

    expect(paymentService.createCalls, hasLength(1));
    final payload = paymentService.createCalls.single;
    expect(payload['user_id'], 7);
    expect(payload['sale_id'], 3);
    expect(payload['amount'], 25.5);
    expect(payload['payment_method'], 'Cash');
    expect(payload['reference_no'], 'REF-1');
    expect(payload['note'], 'Deposit');
    expect(payload['payment_date'], '2026-11-08T00:00:00.000Z');
    expect(DateTime.parse(payload['created_at'] as String).isUtc, isTrue);
    expect(paymentService.getPaymentsCalls, greaterThan(1));
    expect(find.byType(AddPaymentWidget), findsNothing);

    await closeToasts(tester);
  });

  testWidgets('rejects zero, negative, non-numeric and over-due amounts',
      (tester) async {
    final paymentService = FakeSalePaymentService();
    final ctr = await pumpScreen(tester, paymentService: paymentService);

    await openAddSheet(tester);
    await fillValidPayment(ctr);

    for (final invalid in ['0', '-5', 'abc', '50.01']) {
      ctr.amountCtrl.text = invalid;
      await tester.pump();
      await tapSave(tester, 'Save');
      expect(
        paymentService.createCalls,
        isEmpty,
        reason: 'amount $invalid must not submit',
      );
    }

    ctr.amountCtrl.text = '50';
    await tester.pump();
    await tapSave(tester, 'Save');
    expect(paymentService.createCalls, hasLength(1));

    await closeToasts(tester);
  });

  testWidgets('edit prefills and updates only editable fields', (tester) async {
    final paymentService = FakeSalePaymentService(
      payments: [paymentFixture()],
    );
    final ctr = await pumpScreen(tester, paymentService: paymentService);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.byType(EditPaymentWidget), findsOneWidget);
    expect(find.text('Edit Payment Screen'), findsNothing);
    expect(ctr.editingPaymentId.value, 11);
    expect(ctr.selectedSaleId.value, 3);
    expect(ctr.originalPayment?['user']?['id'], 7);
    expect(double.parse(ctr.amountCtrl.text), 40.0);

    ctr.amountCtrl.text = '75.0';
    ctr.methodCtrl.text = 'Bank';
    ctr.referenceCtrl.text = 'REF-9';
    ctr.noteCtrl.text = 'Updated';
    ctr.paymentDate.value = DateTime.utc(2026, 11, 9);
    await tester.pump();
    await tapSave(tester, 'Update');

    expect(paymentService.updateCalls, hasLength(1));
    expect(paymentService.updateCalls.single['id'], 11);
    final payload =
        paymentService.updateCalls.single['data'] as Map<String, dynamic>;
    expect(payload.keys.toSet(), {
      'amount',
      'payment_method',
      'reference_no',
      'payment_date',
      'note',
    });
    expect(payload['amount'], 75.0);
    expect(payload['payment_method'], 'Bank');
    expect(payload['reference_no'], 'REF-9');
    expect(payload['note'], 'Updated');
    expect(payload['payment_date'], '2026-11-09T00:00:00.000Z');

    await closeToasts(tester);
  });

  testWidgets('edit ceiling uses the refreshed sale balance', (tester) async {
    final paymentService = FakeSalePaymentService(
      payments: [paymentFixture(amount: 40.0, saleDue: 60.0)],
    );
    final ctr = await pumpScreen(
      tester,
      paymentService: paymentService,
      sales: [saleFixture(due: 10.0)],
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    ctr.amountCtrl.text = '50.01';
    await tester.pump();
    await tapSave(tester, 'Update');
    expect(paymentService.updateCalls, isEmpty);

    ctr.amountCtrl.text = '50';
    await tester.pump();
    await tapSave(tester, 'Update');
    expect(paymentService.updateCalls, hasLength(1));
    expect(paymentService.updateCalls.single['data']['amount'], 50.0);

    await closeToasts(tester);
  });

  testWidgets('service failure keeps the sheet open and resets isSaving',
      (tester) async {
    final paymentService = FakeSalePaymentService()
      ..failure = Exception('boom');
    final ctr = await pumpScreen(tester, paymentService: paymentService);

    await openAddSheet(tester);
    await fillValidPayment(ctr);
    await tester.pump();
    await tapSave(tester, 'Save');

    expect(ctr.isSaving.value, isFalse);
    expect(find.byType(AddPaymentWidget), findsOneWidget);
    expect(paymentService.createCalls, isEmpty);

    await closeToasts(tester);
  });

  testWidgets('delete cancels without a call and confirms without leaving screen',
      (tester) async {
    final paymentService = FakeSalePaymentService(
      payments: [paymentFixture()],
    );
    await pumpScreen(tester, paymentService: paymentService);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog).evaluate().isEmpty, isTrue);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(paymentService.deleteCalls, isEmpty);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    final callsBefore = paymentService.getPaymentsCalls;
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    expect(paymentService.deleteCalls, [11]);
    expect(paymentService.getPaymentsCalls, greaterThan(callsBefore));
    expect(find.byType(PaymentScreen), findsOneWidget);

    await closeToasts(tester);
  });

  testWidgets('two rapid saves make one request', (tester) async {
    final paymentService = FakeSalePaymentService()..createGate = Completer();
    final ctr = await pumpScreen(tester, paymentService: paymentService);

    await openAddSheet(tester);
    await fillValidPayment(ctr);
    await tester.pump();

    final ctx = tester.element(find.byType(AddPaymentWidget));
    final first = ctr.onSavePayment(ctx);
    final second = ctr.onSavePayment(ctx);
    paymentService.createGate!.complete();
    await tester.pump();
    await Future.wait([first, second]);
    await tester.pumpAndSettle();

    expect(paymentService.createCalls, hasLength(1));
    expect(ctr.isSaving.value, isFalse);

    await closeToasts(tester);
  });

  testWidgets('payments list renders card data from the service', (tester) async {
    final paymentService = FakeSalePaymentService(
      payments: [paymentFixture()],
    );
    await pumpScreen(tester, paymentService: paymentService);

    expect(find.byType(PaymentCardListWidget), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('SALE-3'), findsOneWidget);
  });
}
