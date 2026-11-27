import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/payment/widget/payment_card_list_widget.dart';

void main() {
  testWidgets('payment card tolerates absent sale and malformed date', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PaymentCardListWidget(
            payment: {'amount': '12.50', 'payment_date': 'bad'},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('\$12.50'), findsOneWidget);
  });

  testWidgets('payment card groups details and provides an actions menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var edits = 0;
    var deletes = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaymentCardListWidget(
            payment: const {
              'sale': {
                'invoice_no': 'SALE-3',
                'customer': {'name': 'Alice'},
              },
              'amount': '12.50',
              'payment_method': 'Cash',
              'payment_date': '2026-11-20',
              'reference_no': 'REF-3',
            },
            onEdit: () => edits++,
            onDelete: () => deletes++,
          ),
        ),
      ),
    );

    final footerTop = tester.getTopLeft(find.text('Amount')).dy;
    for (final (label, value) in [
      ('Method', 'Cash'),
      ('Date', '2026-11-20'),
      ('Reference', 'REF-3'),
    ]) {
      final labelPosition = tester.getTopLeft(find.text(label));
      final valuePosition = tester.getTopLeft(find.text(value));
      expect(valuePosition.dx, labelPosition.dx);
      expect(valuePosition.dy, greaterThan(labelPosition.dy));
      expect(valuePosition.dy, lessThan(footerTop));
    }
    await tester.tap(find.byTooltip('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(edits, 1);
    expect(deletes, 1);
    expect(tester.takeException(), isNull);
  });
}
