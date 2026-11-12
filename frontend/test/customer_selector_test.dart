import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/localization/app_translation.dart';
import 'package:frontend/screen/sale/widget/select_customer_card_widget.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'customer_test_support.dart';

class TestSaleController extends SaleController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class CountingSaleController extends TestSaleController {
  int loadCalls = 0;

  @override
  Future<void> loadCustomers() async {
    loadCalls++;
  }
}

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    Get.testMode = true;
  });
  tearDown(Get.reset);

  Future<void> pumpSelector(WidgetTester tester, {bool dark = false}) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslation(),
        locale: const Locale('en', 'US'),
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        defaultTransition: Transition.noTransition,
        home: Scaffold(body: SelectCustomerCardWidget()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('card shows the selected customer and localized fallback', (
    tester,
  ) async {
    final c = Get.put<SaleController>(TestSaleController());
    await pumpSelector(tester);
    expect(find.text('Select Customer'), findsOneWidget);
    expect(
      find.text('Please select a customer for this sale.'),
      findsOneWidget,
    );
    c.selectedCustomer.value = customerJson(1, 'Dara');
    await tester.pumpAndSettle();
    expect(find.text('Dara'), findsOneWidget);
    expect(find.text('012345678'), findsOneWidget);
  });

  testWidgets('picker selects a customer and closes', (tester) async {
    final c = Get.put<SaleController>(TestSaleController());
    c.customers.assignAll([customerJson(1, 'Alpha'), customerJson(2, 'Beta')]);
    await pumpSelector(tester);
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2));
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(c.selectedCustomer.value?['id'], 2);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('picker search filters by name and phone', (tester) async {
    final c = Get.put<SaleController>(TestSaleController());
    c.customers.assignAll([
      customerJson(1, 'Alpha', phone: '012345678'),
      customerJson(2, 'Beta', phone: '0987654321'),
    ]);
    await pumpSelector(tester);
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0987');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
    await tester.enterText(find.byType(TextField), 'ALP');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsNothing);
  });

  testWidgets('empty picker offers retry', (tester) async {
    final c = CountingSaleController();
    Get.put<SaleController>(c);
    await pumpSelector(tester);
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.text('No customers found'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(c.loadCalls, 1);
  });

  testWidgets('dismiss without selecting keeps the current customer', (
    tester,
  ) async {
    final c = Get.put<SaleController>(TestSaleController());
    c.customers.assignAll([customerJson(1, 'Alpha'), customerJson(2, 'Beta')]);
    c.selectedCustomer.value = customerJson(1, 'Alpha');
    await pumpSelector(tester);
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(c.selectedCustomer.value?['id'], 1);
    expect(find.text('Alpha'), findsOneWidget);
  });

  testWidgets('card and picker use the dark card surface', (tester) async {
    final c = Get.put<SaleController>(TestSaleController());
    c.customers.assignAll([customerJson(1, 'Alpha')]);
    await pumpSelector(tester, dark: true);
    final card = tester.widget<Card>(find.byType(Card).first);
    final theme = Theme.of(
      tester.element(find.byType(SelectCustomerCardWidget)),
    );
    expect(card.color, theme.cardColor);
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
