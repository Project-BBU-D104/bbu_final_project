import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_section_card.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';
import 'sale_test_support.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('section uses shared surface and semantic heading', (
    tester,
  ) async {
    await pumpSalesPage(
      tester,
      const Scaffold(
        body: AppSectionCard(title: 'Order Summary', child: Text('Total: 10')),
      ),
    );
    expect(find.byType(AppListCard), findsOneWidget);
    expect(find.byType(AppFormSection), findsOneWidget);
    expect(
      tester.widget<AppListCard>(find.byType(AppListCard)).margin,
      EdgeInsets.zero,
    );
    expect(find.text('Order Summary'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.text('Order Summary'))
          .getSemanticsData()
          .flagsCollection
          .isHeader,
      isTrue,
    );
  });

  testWidgets('default list spacing is preserved', (tester) async {
    var taps = 0;
    await pumpSalesPage(
      tester,
      Scaffold(
        body: AppListCard(
          onTap: () => taps++,
          child: const Text('Open record'),
        ),
      ),
    );
    expect(
      tester.widget<Card>(find.byType(Card)).margin,
      const EdgeInsets.only(bottom: AppSpacing.lg),
    );
    await tester.tap(find.text('Open record'));
    expect(taps, 1);
  });

  for (final dark in [false, true]) {
    testWidgets('untitled section inherits surface in dark=$dark', (
      tester,
    ) async {
      await pumpSalesPage(
        tester,
        const Scaffold(body: AppSectionCard(child: Text('Receipt'))),
        dark: dark,
      );
      expect(find.byType(AppFormSection), findsNothing);
      expect(
        tester.widget<Card>(find.byType(Card)).color,
        Theme.of(tester.element(find.text('Receipt'))).cardColor,
      );
      expect(tester.widget<Card>(find.byType(Card)).margin, EdgeInsets.zero);
    });
  }
}
