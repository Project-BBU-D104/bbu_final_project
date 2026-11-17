import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_list_detail_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'sales_management_test_support.dart';

void main() {
  tearDown(() => Get.reset());
  testWidgets('sale detail sections use shared UI surfaces', (tester) async {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost');
    Get.put(SaleListController(service: ManagementSaleService()));
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: Text('Start')),
        getPages: [
          GetPage(name: '/detail', page: () => const SaleListDetailWidget()),
        ],
      ),
    );
    Get.toNamed(
      '/detail',
      arguments: {
        'id': 1,
        'sale_items': [
          {
            'product': {'name': 'Recorded product'},
            'qty': 2,
            'sale_price': '12.50',
            'subtotal': '25.00',
          },
        ],
        'subtotal': '25.00',
        'tax_amount': '2.50',
        'discount_amount': '1.00',
        'total_amount': '26.50',
        'paid_amount': '20.00',
        'due_amount': '6.50',
      },
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppSectionCard), findsNWidgets(3));
    expect(find.text('Recorded product'), findsOneWidget);
    expect(find.text(r'2 × $12.50'), findsOneWidget);
    expect(find.text(r'$26.50'), findsOneWidget);
    expect(find.text(r'$25.00'), findsNWidgets(2));
    for (final total in [r'$2.50', r'$1.00', r'$20.00', r'$6.50']) {
      expect(find.text(total), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
