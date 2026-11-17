import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screen/sale/sale_list/widget/sale_list_detail_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';

void main() {
  tearDown(Get.reset);
  for (final page in [const SaleListDetailWidget()]) {
    testWidgets(
      'missing detail keeps mobile recovery without controllers at 2x Khmer',
      (tester) async {
        await pumpSalesPage(
          tester,
          page,
          size: const Size(844, 390),
          locale: const Locale('km', 'KH'),
          textScale: 2,
        );
        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.byType(AppPageHeader), findsOneWidget);
        await tester.scrollUntilVisible(
          find.widgetWithText(TextButton, 'Back'.tr),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.text('Back'.tr).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'missing detail arguments render unavailable without a controller',
    (tester) async {
      await tester.pumpWidget(MaterialApp(home: SaleListDetailWidget()));
      expect(tester.takeException(), isNull);
      expect(find.text('Sale details are unavailable.'), findsOneWidget);
    },
  );
}
