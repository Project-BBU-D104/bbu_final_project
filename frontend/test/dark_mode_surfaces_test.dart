import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/screen/dashboard/widget/card_kpi_widget.dart';
import 'package:frontend/screen/purchases/widget/purchase_kpi_widget.dart';
import 'package:frontend/screen/sale/current_sale/widget/current_sale_item_widget.dart';
import 'package:frontend/screen/sale/current_sale/widget/summary_order_widget.dart';
import 'package:frontend/screen/sale/widget/select_customer_card_widget.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';

class TestSaleController extends SaleController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

Future<void> pumpDark(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

void expectThemedCard(WidgetTester tester) {
  final cardFinder = find.byType(Card).first;
  final context = tester.element(cardFinder);
  expect(
    tester.widget<Card>(cardFinder).color,
    Theme.of(context).cardColor,
  );
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('current sale item renders on the dark card surface',
      (tester) async {
    await pumpDark(
      tester,
      CurrentSaleItemWidget(
        productName: 'Coffee',
        imageUrl: '',
        quantity: 2,
        unitPrice: 1.5,
        subtotal: 3,
        onIncrease: () {},
        onDecrease: () {},
      ),
    );

    expectThemedCard(tester);
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.style?.color, isNot(Colors.black87));
    }
  });

  testWidgets('customer card renders on the dark card surface', (tester) async {
    Get.put<SaleController>(TestSaleController());

    await pumpDark(tester, SelectCustomerCardWidget());

    expectThemedCard(tester);
  });

  testWidgets('purchase KPI renders on the dark card surface', (tester) async {
    await pumpDark(tester, const PurchaseKpiWidget(title: 'Purchases', value: 3));

    expectThemedCard(tester);
  });

  testWidgets('dashboard KPI renders on the dark card surface', (tester) async {
    await pumpDark(
      tester,
      const CardKpiWidget(icon: Icons.shopping_cart, title: 'Sales', value: '5'),
    );

    expectThemedCard(tester);
  });

  testWidgets('order summary renders on the dark card surface', (tester) async {
    await pumpDark(tester, const SummaryOrderWidget(subtotal: 12));

    expectThemedCard(tester);
  });
}
