import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:get/get.dart';
import 'purchase_test_support.dart';

void main() {
  setUp(setUpPurchaseTests);
  tearDown(Get.reset);

  test('refresh keeps the current search query', () async {
    final c = PurchaseController(service: FakePurchaseService());
    await c.onGetPurchaseList();
    c.searchPurchase(' beta ');
    // Reload so the filter must survive a fresh result set.
    await c.onGetPurchaseList();
    expect(c.purchaseList.length, 2);
    expect(c.searchPurchaseList.map((p) => p['invoice_no']), ['BETA-2']);
  });

  test('initial shared query applies to cached records', () async {
    final seed = PurchaseController(service: FakePurchaseService());
    await seed.onGetPurchaseList();
    seed.onClose();
    final search = Get.put(SearchController());
    search.keyword.value = 'inv-1';
    final c = Get.put(PurchaseController(service: FakePurchaseService()));
    expect(c.searchPurchaseList.map((p) => p['invoice_no']), ['INV-1']);
    c.onClose();
  });

  testWidgets('failed refresh retains rows and exposes retry copy', (
    tester,
  ) async {
    final service = FakePurchaseService();
    final c = PurchaseController(service: service);
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    await c.onGetPurchaseList();
    service.failGet = true;
    await c.onRefresh();
    expect(c.loadError.value, 'Unable to load purchases. Please try again.');
    expect(c.purchaseList.length, 2);
    service.failGet = false;
    await c.onRefresh();
    expect(c.loadError.value, isEmpty);
    c.onClose();
    await tester.pumpAndSettle();
  });

  testWidgets('a save already in flight is ignored', (tester) async {
    final service = FakePurchaseService();
    final c = PurchaseController(service: service);
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
    c.isSaving.value = true;
    await c.createPurchase(tester.element(find.byType(SizedBox)));
    await c.onUpdatePurchase(tester.element(find.byType(SizedBox)));
    expect(service.createCalls, 0);
    expect(service.updateCalls, 0);
  });
}
