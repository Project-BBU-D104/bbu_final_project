import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/home/widget/recent_sale_widget.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_list_detail_widget.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:get/get.dart';

import 'customer_test_support.dart' show setUpCustomerTests;
import 'sale_test_support.dart';

class RecentSaleService extends SaleTestSaleService {
  final requested = <int>[];
  Completer<dynamic>? pending;
  Object? error;

  @override
  Future<dynamic> getSaleById(int id) async {
    requested.add(id);
    if (pending != null) return pending!.future;
    if (error != null) throw error!;
    return saleJson(id);
  }
}

class QuietHomeController extends HomeController {
  QuietHomeController(SaleService sales) : super(saleService: sales);

  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);

  Future<void> showRecentSales(
    WidgetTester tester,
    RecentSaleService sales,
  ) async {
    final controller = Get.put<HomeController>(QuietHomeController(sales));
    controller.salesLoading.value = false;
    controller.recentSaleList.assignAll([
      {'sale_id': 21, 'invoice_no': 'SALE-1', 'subtotal': 10},
      {'sale_id': 22, 'invoice_no': 'SALE-1', 'subtotal': 20},
    ]);
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/home',
        getPages: [
          GetPage(
            name: '/home',
            page: () => Scaffold(body: RecentStockOutWidget()),
          ),
          GetPage(
            name: '/sale-list-detail',
            page: () => const SaleListDetailWidget(),
          ),
          GetPage(
            name: '/sale',
            page: () => const Scaffold(body: Text('New sale page')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('recent row loads the selected sale and opens complete details', (
    tester,
  ) async {
    final sales = RecentSaleService()..pending = Completer<dynamic>();
    await showRecentSales(tester, sales);
    expect(Get.isRegistered<SaleListController>(), isFalse);
    await tester.tap(find.text('SALE-1').last);
    await tester.pump();
    expect(sales.requested, [22]);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('SALE-1').first, warnIfMissed: false);
    expect(sales.requested, [22]);
    sales.pending!.complete({
      ...saleJson(22),
      'invoice_no': 'SELECTED-22',
      'sale_items': [
        {
          'product': saleProductJson(1, 'Water'),
          'qty': 2,
          'sale_price': '5.00',
          'subtotal': '10.00',
        },
      ],
    });
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/sale-list-detail');
    expect(find.text('SELECTED-22'), findsOneWidget);
    expect(find.text('Dara'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget);
    expect(Get.isRegistered<SaleListController>(), isFalse);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/home');
    expect(find.text('SALE-1'), findsNWidgets(2));
  });

  testWidgets('failed detail loading stays on home and permits retry', (
    tester,
  ) async {
    final sales = RecentSaleService()..error = Exception('offline');
    await showRecentSales(tester, sales);
    await tester.tap(find.text('SALE-1').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(Get.currentRoute, '/home');
    expect(find.text('Unable to open sale. Please try again.'), findsOneWidget);
    sales.error = null;
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    await tester.tap(find.text('SALE-1').first);
    await tester.pumpAndSettle();
    expect(sales.requested, [21, 21]);
    expect(Get.currentRoute, '/sale-list-detail');
  });
}
