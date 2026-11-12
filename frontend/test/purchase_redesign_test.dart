import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/purchases/widget/purchase_card_widget.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('purchase card handles missing supplier and follows theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: PurchaseCardWidget(
            purchase: {
              'invoice_no': 'INV-1',
              'supplier': null,
              'purchase_date': null,
              'total_amount': 10,
            },
          ),
        ),
      ),
    );
    expect(find.text('INV-1'), findsOneWidget);
    expect(find.text('\$10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
