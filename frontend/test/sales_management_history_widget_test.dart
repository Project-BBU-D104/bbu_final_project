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
}
