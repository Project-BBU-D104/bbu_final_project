import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/screen/customer/customer_screen.dart';
import 'package:frontend/screen/customer/widget/customer_card_widget.dart';
import 'package:frontend/screen/customer/widget/customer_table_widget.dart';
import 'package:frontend/screen/customer/widget/edit_customer_widget.dart';
import 'package:get/get.dart';
import 'customer_test_support.dart';

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);

  Future<CustomerController> seed() async {
    final c = CustomerController(service: FakeCustomerService());
    await c.getCustomers();
    return Get.put<CustomerController>(c);
  }

  testWidgets('customer list adapts to usable width', (tester) async {
    await seed();
    await pumpCustomerHost(
      tester,
      home: CustomerScreen(),
      size: const Size(900, 900),
    );
    expect(find.byType(CustomerCardWidget), findsNWidgets(2));
    expect(find.byType(CustomerTableWidget), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Add Customer'), findsOneWidget);
    await pumpCustomerHost(
      tester,
      home: CustomerScreen(),
      size: const Size(1440, 900),
    );
    expect(find.byType(CustomerTableWidget), findsOneWidget);
  });

  testWidgets('loading error empty and no-match states are distinct', (
    tester,
  ) async {
    final c = await seed();
    await pumpCustomerHost(tester, home: CustomerScreen());
    c.loadError.value = 'Unable to load customers. Please try again.';
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    c.loadError.value = '';
    c.searchCustomer('missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching customers'), findsOneWidget);
    c.customerList.clear();
    c.searchCustomer('');
    await tester.pumpAndSettle();
    expect(find.text('No customers yet'), findsOneWidget);
    expect(find.byKey(const Key('empty-add-customer')), findsOneWidget);
  });

  testWidgets('missing fields render placeholders', (tester) async {
    final c = await seed();
    c.customerList.assignAll([
      customerJson(1, 'Alpha', phone: '', address: '', createdAt: null),
      {...customerJson(2, 'NoId'), 'id': 'not-an-int'},
    ]);
    c.searchCustomer('');
    await pumpCustomerHost(tester, home: CustomerScreen());
    expect(find.text('-'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer rows are keyboard accessible', (tester) async {
    await seed();
    await pumpCustomerHost(tester, home: CustomerScreen());
    Focus.of(tester.element(find.text('Alpha'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(EditCustomerWidget), findsOneWidget);
    expect(find.byType(CustomerScreen), findsOneWidget);
  });

  testWidgets('Khmer long customer content reflows in both themes', (
    tester,
  ) async {
    final c = await seed();
    for (final dark in [false, true]) {
      c.customerList[0] = {
        ...c.customerList.first,
        'name': 'អតិថិជន ' * 12,
        'address': 'អាសយដ្ឋាន ' * 20,
      };
      c.searchCustomer('');
      await pumpCustomerHost(
        tester,
        home: CustomerScreen(),
        dark: dark,
        locale: const Locale('km', 'KH'),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('customer controls are labeled, sized, and themed', (
    tester,
  ) async {
    await seed();
    final semantics = tester.ensureSemantics();
    await pumpCustomerHost(tester, home: CustomerScreen(), dark: true);
    final card = tester.widget<Card>(find.byType(Card).first);
    final theme = Theme.of(tester.element(find.byType(CustomerScreen)));
    expect(card.color, theme.cardColor);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
  });
}
