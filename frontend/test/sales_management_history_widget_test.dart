import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_card_widget.dart';
import 'package:frontend/ui/app_list_card.dart';

void main() {
  testWidgets('history card safely displays absent nested data', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SaleCardWidget(sale: {'total_amount': '12.50'})),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(AppListCard), findsOneWidget);
    expect(find.text('\$12.50'), findsOneWidget);
  });

  testWidgets('history card groups and labels amounts on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SaleCardWidget(
            sale: {
              'invoice_no': 'SALE-1',
              'customer': {'name': 'Customer One'},
              'sale_date': '2026-11-20',
              'total_amount': '12.50',
              'paid_amount': '10.00',
              'due_amount': '2.50',
              'payment_status': 'partial',
            },
          ),
        ),
      ),
    );

    final amounts = [
      ('Total', r'$12.50'),
      ('Paid', r'$10.00'),
      ('Due', r'$2.50'),
    ];
    final footerTop = tester.getTopLeft(find.text('Total')).dy;
    for (final (label, value) in amounts) {
      final labelPosition = tester.getTopLeft(find.text(label));
      final valuePosition = tester.getTopLeft(find.text(value));
      expect(labelPosition.dy, footerTop);
      expect(valuePosition.dx, labelPosition.dx);
      expect(valuePosition.dy, greaterThan(labelPosition.dy));
    }
    expect(tester.getTopLeft(find.text('Partial')).dy, lessThan(footerTop));
    expect(tester.takeException(), isNull);
  });
}
