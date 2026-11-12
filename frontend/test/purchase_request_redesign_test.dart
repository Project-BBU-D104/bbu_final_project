import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/screen/purchase_request/widget/card_purchase_request_widget.dart';
import 'package:frontend/screen/purchase_request/widget/purchase_request_table_widget.dart';
import 'package:get/get.dart';
import 'purchase_request_test_support.dart';

void main() {
  setUp(setUpPurchaseRequestTests);
  tearDown(Get.reset);

  testWidgets('card handles missing fields and follows the theme', (
    tester,
  ) async {
    Get.put(
      PurchaseRequestController(
        service: FakePurchaseRequestService(),
        warehouses: FakeWarehouseController(),
        products: FakeProductController(),
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: CardPurchaseRequestWidget(
            purchaseRequest: {
              'id': 1,
              'request_no': 'REQ-1',
              'warehouse_id': null,
              'request_date': null,
            },
          ),
        ),
      ),
    );
    expect(find.text('REQ-1'), findsOneWidget);
    expect(find.text('-'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('card shows translated status, type, warehouse and reason', (
    tester,
  ) async {
    Get.put(
      PurchaseRequestController(
        service: FakePurchaseRequestService(),
        warehouses: FakeWarehouseController(),
        products: FakeProductController(),
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: CardPurchaseRequestWidget(
            purchaseRequest: purchaseRequestJson(1, status: 'approved'),
          ),
        ),
      ),
    );
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('purchase'), findsOneWidget);
    expect(find.textContaining('Main'), findsOneWidget);
    expect(find.text('Restock'), findsOneWidget);
  });

  testWidgets('table renders one row per request', (tester) async {
    Get.put(
      PurchaseRequestController(
        service: FakePurchaseRequestService(),
        warehouses: FakeWarehouseController(),
        products: FakeProductController(),
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: PurchaseRequestTableWidget(
            requests: [
              purchaseRequestJson(1),
              purchaseRequestJson(2, requestNo: 'REQ-2'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Request No'), findsOneWidget);
    expect(find.text('REQ-1'), findsOneWidget);
    expect(find.text('REQ-2'), findsOneWidget);
  });
}
