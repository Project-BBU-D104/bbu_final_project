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
}
