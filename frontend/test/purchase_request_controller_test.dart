import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:get/get.dart';
import 'purchase_request_test_support.dart';

void main() {
  setUp(setUpPurchaseRequestTests);
  tearDown(Get.reset);

  test('loads requests with their items', () async {
    final s = FakePurchaseRequestService()
      ..requests = [purchaseRequestJson(1), purchaseRequestJson(2)]
      ..items = [
        purchaseRequestItemJson(11, requestId: 1),
        purchaseRequestItemJson(12, requestId: 2),
      ];
    final c = PurchaseRequestController(
      service: s,
      warehouses: FakeWarehouseController(),
      products: FakeProductController(),
    );
    await c.onGetPurchaseRequests();
    expect(c.requestList.length, 2);
    expect(c.requestList.first['items'], hasLength(1));
  });

  test('failed load exposes retry copy instead of throwing', () async {
    final s = FakePurchaseRequestService()..failGet = true;
    final c = PurchaseRequestController(
      service: s,
      warehouses: FakeWarehouseController(),
      products: FakeProductController(),
    );
    await c.onGetPurchaseRequests();
    expect(
      c.loadError.value,
      'Unable to load purchase requests. Please try again.',
    );
    expect(c.requestList, isEmpty);
  });

  test('retry keeps the active search filter', () async {
    final search = Get.put(SearchController());
    final s = FakePurchaseRequestService()
      ..requests = [
        purchaseRequestJson(1, requestNo: 'REQ-ALPHA'),
        purchaseRequestJson(2, requestNo: 'REQ-BETA'),
      ];
    final c = PurchaseRequestController(
      service: s,
      warehouses: FakeWarehouseController(),
      products: FakeProductController(),
    );
    await c.onGetPurchaseRequests();
    Get.put(c);
    search.keyword.value = 'alpha';
    expect(c.searchRequestList.map((r) => r['request_no']), ['REQ-ALPHA']);
    await c.onRefresh();
    expect(c.searchRequestList.map((r) => r['request_no']), ['REQ-ALPHA']);
  });

  testWidgets('a save already in flight is ignored', (tester) async {
    final s = FakePurchaseRequestService();
    final c = PurchaseRequestController(
      service: s,
      warehouses: FakeWarehouseController(),
      products: FakeProductController(),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final context = tester.element(find.byType(SizedBox));
    c.isSaving.value = true;
    await c.savePurchaseRequest(context);
    c.isSaving.value = true;
    await c.updatePurchaseRequest(context, 1);
    expect(s.createCalls, 0);
    expect(s.updateCalls, 0);
  });
}
