import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/sale/widget/card_item_widget.dart';

Map<String, dynamic> productWithQty(num qty) {
  return {'id': 1, 'name': 'Coke', 'photo': '', 'sale_price': 2.0, 'qty': qty};
}

Widget wrap({required num stockQty}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 200,
        height: 300,
        child: CardItemWidget(
          product: productWithQty(stockQty),
          quantity: 0,
          onTap: () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the Sold out chip when warehouse stock is zero', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(stockQty: 0));

    expect(find.text('Sold out'), findsOneWidget);
  });

  testWidgets('hides the Sold out chip when stock arrives as a decimal', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(stockQty: 5.0));

    expect(find.text('Sold out'), findsNothing);
  });

  testWidgets('hides the Sold out chip when warehouse stock is available', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(stockQty: 5));

    expect(find.text('Sold out'), findsNothing);
  });
}
