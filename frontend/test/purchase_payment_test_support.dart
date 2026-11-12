import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/currency_controller.dart';
import 'package:frontend/controllers/payment_type_controller.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/services/main_service/purchase/purchase_payment_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'profile_widget_test.dart' show FakeStorageService;

Map<String, dynamic> purchaseFixture({
  int id = 3,
  String invoiceNo = 'PUR-3',
  double due = 60.0,
  double total = 100.0,
}) => {
  'id': id,
  'invoice_no': invoiceNo,
  'due_amount': due,
  'total_amount': total,
  'supplier': {'id': 9, 'name': 'Supplier A'},
};

Map<String, dynamic> purchasePaymentJson(
  int id, {
  String paymentNo = 'PP-1',
  num amount = 40,
  String? paymentDate = '2026-11-01T00:00:00Z',
  String? status = 'completed',
  String? note = 'Existing',
  double purchaseDue = 60.0,
}) => {
  'id': id,
  'payment_no': paymentNo,
  'amount': amount,
  'payment_date': paymentDate,
  'status': status,
  'note': note,
  'purchase': purchaseFixture(due: purchaseDue),
  'supplier': {'id': 9, 'name': 'Supplier A'},
  'payment_type': {'id': 2, 'name': 'Cash'},
  'currency': {'id': 1, 'name': 'USD', 'symbol': '\$'},
};

class FakePurchasePaymentService implements PurchasePaymentService {
  FakePurchasePaymentService({List<Map<String, dynamic>>? payments})
    : payments =
          payments ??
          [purchasePaymentJson(11), purchasePaymentJson(12, paymentNo: 'PP-2')];

  List<Map<String, dynamic>> payments;
  bool failGet = false;
  bool failWrite = false;
  int getPaymentsCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  Map<String, dynamic>? lastCreatedData;
  Map<String, dynamic>? lastUpdatedData;
  Completer<dynamic>? createGate;
  Completer<void>? updateGate;

  @override
  Future<dynamic> getPurchasePayments() async {
    getPaymentsCalls++;
    if (failGet) throw Exception('offline');
    return payments;
  }

  @override
  Future<dynamic> getPurchasePaymentById(int id) async =>
      payments.firstWhere((p) => p['id'] == id);

  @override
  Future<dynamic> createPurchasePayment(Map<String, dynamic> data) async {
    createCalls++;
    lastCreatedData = data;
    if (createGate != null) await createGate!.future;
    if (failWrite) throw Exception('failed');
    final created = {...purchasePaymentJson(3), ...data, 'id': 3};
    payments = [...payments, created];
    return created;
  }

  @override
  Future<dynamic> updatePurchasePayment(
    int id,
    Map<String, dynamic> data,
  ) async {
    if (updateGate != null) await updateGate!.future;
    if (failWrite) throw Exception('failed');
    updateCalls++;
    lastUpdatedData = data;
    final updated = {
      ...payments.firstWhere((p) => p['id'] == id),
      ...data,
      'id': id,
    };
    payments = [
      for (final p in payments)
        if (p['id'] == id) updated else p,
    ];
    return updated;
  }

  @override
  Future<dynamic> deletePurchasePayment(int id) async {
    deleteCalls++;
    if (failWrite) throw Exception('failed');
    payments = payments.where((p) => p['id'] != id).toList();
    return true;
  }
}

class FakePurchaseController extends PurchaseController {
  FakePurchaseController({List<Map<String, dynamic>>? purchases}) {
    purchaseList.value = purchases ?? [purchaseFixture()];
  }

  int refreshCalls = 0;

  @override
  Future<void> onGetPurchaseList() async {
    refreshCalls++;
  }
}

class DelayedPurchaseController extends FakePurchaseController {
  DelayedPurchaseController({super.purchases, required this.gate});

  final Completer<void> gate;

  @override
  Future<void> onGetPurchaseList() async {
    await gate.future;
    await super.onGetPurchaseList();
  }
}

class FakePaymentTypeController extends PaymentTypeController {
  FakePaymentTypeController({required List<Map<String, dynamic>> types}) {
    paymentTypeList.value = types;
  }
}

class FakeCurrencyController extends CurrencyController {
  FakeCurrencyController({required List<Map<String, dynamic>> currencies}) {
    currencyList.value = currencies;
  }
}

void setUpPurchasePaymentTests() {
  dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
  if (!locator.isRegistered<IStorageService>()) {
    locator.registerSingleton<IStorageService>(FakeStorageService());
  }
  Get.testMode = true;
}

Future<void> pumpPurchasePaymentHost(
  WidgetTester tester, {
  required Widget home,
  Size size = const Size(390, 844),
  bool dark = false,
  Locale locale = const Locale('en', 'US'),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslation(),
      locale: locale,
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      defaultTransition: Transition.noTransition,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: DesktopAppShell(route: '/purchase-payment', child: child!),
      ),
      home: home,
    ),
  );
  await tester.pumpAndSettle();
  Get.updateLocale(locale);
  await tester.pumpAndSettle();
}

Future<PurchasePaymentController> seedPurchasePaymentController({
  FakePurchasePaymentService? service,
  List<Map<String, dynamic>>? purchases,
}) async {
  final c = PurchasePaymentController(
    service: service ?? FakePurchasePaymentService(),
    purchaseCtr: FakePurchaseController(purchases: purchases),
    paymentTypeCtr: FakePaymentTypeController(
      types: [
        {'id': 2, 'name': 'Cash'},
      ],
    ),
    currencyCtr: FakeCurrencyController(
      currencies: [
        {'id': 1, 'name': 'USD', 'symbol': '\$'},
      ],
    ),
  );
  await c.onGetPaymentList();
  return Get.put<PurchasePaymentController>(c);
}
