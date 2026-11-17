import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_list_detail_widget.dart';

void main() {
  testWidgets(
    'missing detail arguments render unavailable without a controller',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: SaleListDetailWidget()));
      expect(tester.takeException(), isNull);
      expect(find.text('Sale details are unavailable.'), findsOneWidget);
    },
  );
}
