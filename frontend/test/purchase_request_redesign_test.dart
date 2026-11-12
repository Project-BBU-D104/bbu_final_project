import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/screen/purchase_request/purchase_request_screen.dart';
import 'package:frontend/screen/purchase_request/widget/card_purchase_request_detail_widget.dart';
import 'package:frontend/screen/purchase_request/widget/card_purchase_request_widget.dart';
import 'package:frontend/screen/purchase_request/widget/purchase_request_table_widget.dart';
import 'package:get/get.dart';
import 'purchase_request_test_support.dart';

Future<PurchaseRequestController> seedPurchaseRequestController() async {
  final s = FakePurchaseRequestService()
    ..requests = [
      purchaseRequestJson(1, requestNo: 'REQ-1'),
      purchaseRequestJson(2, requestNo: 'REQ-2'),
    ]
    ..items = [purchaseRequestItemJson(11, requestId: 1)];
  final c = PurchaseRequestController(
    service: s,
    warehouses: FakeWarehouseController(),
    products: FakeProductController(),
  );
  await c.onGetPurchaseRequests();
  return Get.put<PurchaseRequestController>(c);
}

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

  testWidgets('list adapts cards/table to usable width', (tester) async {
    await seedPurchaseRequestController();
    await pumpPurchaseRequestHost(
      tester,
      home: PurchaseRequestScreen(),
      size: const Size(900, 900),
    );
    expect(find.byType(CardPurchaseRequestWidget), findsNWidgets(2));
    expect(find.byType(PurchaseRequestTableWidget), findsNothing);
    await pumpPurchaseRequestHost(
      tester,
      home: PurchaseRequestScreen(),
      size: const Size(1440, 900),
    );
    expect(find.byType(PurchaseRequestTableWidget), findsOneWidget);
  });

  testWidgets('loading, error, empty and no-match states are distinct', (
    tester,
  ) async {
    final c = await seedPurchaseRequestController();
    c.loadError.value = 'Unable to load purchase requests. Please try again.';
    await pumpPurchaseRequestHost(tester, home: PurchaseRequestScreen());
    expect(find.text('Retry'), findsOneWidget);
    c.loadError.value = '';
    c.searchRequests('missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching purchase requests'), findsOneWidget);
    c.requestList.clear();
    c.searchRequests('');
    await tester.pumpAndSettle();
    expect(find.text('No purchase requests yet'), findsOneWidget);
    expect(find.byKey(const Key('empty-add-purchase-request')), findsOneWidget);
  });

  testWidgets('long Khmer content reflows in both themes', (tester) async {
    final c = await seedPurchaseRequestController();
    c.requestList[0] = {
      ...c.requestList.first,
      'request_no': 'សំណើទិញ ' * 12,
      'reason': 'មូលហេតុ ' * 20,
    };
    c.searchRequests('');
    for (final dark in [false, true]) {
      await pumpPurchaseRequestHost(
        tester,
        home: PurchaseRequestScreen(),
        size: const Size(360, 720),
        dark: dark,
        locale: const Locale('km', 'KH'),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('detail renders placeholders for missing fields', (tester) async {
    Get.put(
      PurchaseRequestController(
        service: FakePurchaseRequestService(),
        warehouses: FakeWarehouseController(),
        products: FakeProductController(),
      ),
    );
    await pumpPurchaseRequestHost(
      tester,
      home: const CardPurchaseRequestDetailWidget(
        purchaseRequest: {'id': 1, 'request_no': 'REQ-1', 'items': []},
      ),
    );
    expect(find.text('REQ-1'), findsWidgets);
    expect(find.text('-'), findsWidgets);
    expect(find.text('No items in this request'), findsOneWidget);
    expect(find.byType(HomeTabLayout), findsOneWidget);
    expect(find.byType(HomeSectionCard), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Edit'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Delete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete from detail refreshes the list and invokes the close '
      'callback', (tester) async {
    final s = FakePurchaseRequestService()
      ..requests = [purchaseRequestJson(1)]
      ..items = [];
    final c = PurchaseRequestController(
      service: s,
      warehouses: FakeWarehouseController(),
      products: FakeProductController(),
    );
    await c.onGetPurchaseRequests();
    Get.put(c);
    await pumpPurchaseRequestHost(tester, home: PurchaseRequestScreen());
    var deleted = false;
    c.deletePurchaseRequest(
      tester.element(find.byType(PurchaseRequestScreen)),
      1,
      onDeleted: () => deleted = true,
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Do you want to delete this purchase request?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(s.deleteCalls, 1);
    expect(deleted, isTrue);
    expect(c.requestList, isEmpty);
  });

  testWidgets('detail localizes the items heading in Khmer', (tester) async {
    Get.put(
      PurchaseRequestController(
        service: FakePurchaseRequestService(),
        warehouses: FakeWarehouseController(),
        products: FakeProductController(),
      ),
    );
    await pumpPurchaseRequestHost(
      tester,
      home: const CardPurchaseRequestDetailWidget(
        purchaseRequest: {
          'id': 1,
          'request_no': 'REQ-1',
          'items': [
            {'product_id': 1, 'qty': 2, 'unit': 'pcs'},
          ],
        },
      ),
      locale: const Locale('km', 'KH'),
    );
    expect(find.textContaining('ទំនិញដែលបានស្នើ'), findsOneWidget);
    expect(find.textContaining('Requested Items'), findsNothing);
  });

  testWidgets('table localizes its headers in Khmer', (tester) async {
    Get.put(
      PurchaseRequestController(
        service: FakePurchaseRequestService(),
        warehouses: FakeWarehouseController(),
        products: FakeProductController(),
      ),
    );
    await pumpPurchaseRequestHost(
      tester,
      home: Scaffold(
        body: PurchaseRequestTableWidget(requests: [purchaseRequestJson(1)]),
      ),
      locale: const Locale('km', 'KH'),
    );
    expect(find.text('លេខសំណើ'), findsOneWidget);
    expect(find.text('Request No'), findsNothing);
  });
}
