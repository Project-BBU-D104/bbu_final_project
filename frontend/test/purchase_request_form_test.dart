import 'dart:async';

import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/screen/purchase_request/purchase_request_screen.dart';
import 'package:frontend/screen/purchase_request/widget/add_purchase_request_widget.dart';
import 'package:frontend/screen/purchase_request/widget/edit_purchase_request_widget.dart';
import 'package:get/get.dart';
import 'purchase_request_test_support.dart';

void main() {
  setUp(setUpPurchaseRequestTests);
  tearDown(Get.reset);

  Future<PurchaseRequestController> seed(
    WidgetTester tester,
    FakePurchaseRequestService service,
  ) async {
    final c = PurchaseRequestController(
      service: service,
      warehouses: FakeWarehouseController(),
      products: FakeProductController(),
    );
    await c.onGetPurchaseRequests();
    Get.put<PurchaseRequestController>(c);
    await pumpPurchaseRequestHost(tester, home: PurchaseRequestScreen());
    return c;
  }

  void fill(PurchaseRequestController c) {
    c.requestTypeController.text = ' purchase ';
    c.requestedByController.text = ' Old Name ';
    c.approvedByController.text = ' Pending ';
    c.reasonController.text = ' Restock ';
    c.selectedWarehouseId.value = 1;
    c.itemLines.first
      ..selectedProduct.value = {'id': 1, 'name': 'Widget'}
      ..quantityController.text = '2'
      ..unitController.text = 'pcs';
  }

  testWidgets('blank required fields never write and show inline errors', (
    tester,
  ) async {
    final s = FakePurchaseRequestService();
    final c = await seed(tester, s);
    c.addPurchaseRequest(tester.element(find.byType(PurchaseRequestScreen)));
    await tester.pumpAndSettle();
    c.requestTypeController.clear();
    c.requestedByController.clear();
    c.approvedByController.clear();
    c.reasonController.clear();
    await tester.ensureVisible(find.text('Create Request'));
    await tester.tap(find.text('Create Request'));
    await tester.pumpAndSettle();
    expect(s.createCalls, 0);
    expect(find.text('Request type is required'), findsOneWidget);
    expect(find.text('Requester is required'), findsOneWidget);
    expect(find.text('Approver is required'), findsOneWidget);
    expect(find.text('Reason is required'), findsOneWidget);
    expect(find.text('Select a warehouse'), findsOneWidget);
    expect(find.text('Select a product'), findsOneWidget);
  });

  testWidgets('trimmed payload keeps the request and item contract', (
    tester,
  ) async {
    final s = FakePurchaseRequestService();
    final c = await seed(tester, s);
    c.addPurchaseRequest(tester.element(find.byType(PurchaseRequestScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await tester.pump();
    await tester.ensureVisible(find.text('Create Request'));
    await tester.tap(find.text('Create Request'));
    await tester.pumpAndSettle();
    expect(s.lastCreatedData!['request_type'], 'purchase');
    expect(s.lastCreatedData!['warehouse_id'], 1);
    expect(s.lastCreatedData!['requested_by'], 'Old Name');
    expect(s.lastCreatedData!['approved_by'], 'Pending');
    expect(s.lastCreatedData!['reason'], 'Restock');
    expect(s.lastCreatedData!['status'], 'pending');
    expect(s.lastCreatedItemData, {
      'stock_request_id': 3,
      'product_id': 1,
      'unit': 'pcs',
      'qty': 2,
    });
    expect(find.byType(AddPurchaseRequestWidget), findsNothing);
  });

  testWidgets('write failure preserves the draft and shows the error', (
    tester,
  ) async {
    final s = FakePurchaseRequestService()..failWrite = true;
    final c = await seed(tester, s);
    c.addPurchaseRequest(tester.element(find.byType(PurchaseRequestScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await tester.pump();
    await tester.ensureVisible(find.text('Create Request'));
    await tester.tap(find.text('Create Request'));
    await tester.pumpAndSettle();
    expect(find.byType(AddPurchaseRequestWidget), findsOneWidget);
    expect(
      find.text('Unable to save purchase request. Please try again.'),
      findsOneWidget,
    );
    expect(c.reasonController.text, ' Restock ');
    expect(c.itemLines, hasLength(1));
  });

  testWidgets('repeated save taps send one request and block dismissal', (
    tester,
  ) async {
    final s = FakePurchaseRequestService()..createGate = Completer();
    final c = await seed(tester, s);
    c.addPurchaseRequest(tester.element(find.byType(PurchaseRequestScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await tester.pump();
    final context = tester.element(find.byType(AddPurchaseRequestWidget));
    c.savePurchaseRequest(context);
    c.savePurchaseRequest(context);
    await tester.pump();
    expect(s.createCalls, 1);
    expect(await Navigator.of(context).maybePop(), true);
    await tester.pump();
    expect(find.byType(AddPurchaseRequestWidget), findsOneWidget);
    s.createGate!.complete({'id': 3});
    await tester.pumpAndSettle();
    expect(find.byType(AddPurchaseRequestWidget), findsNothing);
  });

  testWidgets('edit prefills fields and item lines', (tester) async {
    final s = FakePurchaseRequestService()
      ..requests = [purchaseRequestJson(1, requestNo: 'REQ-1')]
      ..items = [purchaseRequestItemJson(11, requestId: 1)];
    final c = await seed(tester, s);
    unawaited(
      c.editPurchaseRequest(
        tester.element(find.byType(PurchaseRequestScreen)),
        1,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EditPurchaseRequestWidget), findsOneWidget);
    expect(c.requestTypeController.text, 'purchase');
    expect(c.reasonController.text, 'Restock');
    expect(c.itemLines, hasLength(1));
    expect(find.text('Save Changes'), findsOneWidget);
  });
}
