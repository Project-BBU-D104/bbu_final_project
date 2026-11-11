import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:frontend/screen/unit/unit_screen.dart';
import 'package:frontend/screen/unit/widget/edit_unit_widget.dart';
import 'package:frontend/screen/unit/widget/unit_card_widget.dart';
import 'package:frontend/screen/unit/widget/unit_table_widget.dart';
import 'package:get/get.dart';
import 'unit_test_support.dart';

void main() {
  setUp(setUpUnitTests);
  tearDown(Get.reset);

  Future<UnitController> seed() async {
    final c = UnitController(service: FakeUnitService());
    await c.getUnitList();
    return Get.put<UnitController>(c);
  }

  testWidgets('unit list adapts to usable width', (tester) async {
    await seed();
    await pumpUnitHost(tester, home: UnitScreen(), size: const Size(900, 900));
    expect(find.byType(UnitCardWidget), findsNWidgets(2));
    expect(find.byType(UnitTableWidget), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Add Unit'), findsOneWidget);
    await pumpUnitHost(tester, home: UnitScreen(), size: const Size(1440, 900));
    expect(find.byType(UnitTableWidget), findsOneWidget);
  });

  testWidgets('loading error empty and no-match states are distinct', (
    tester,
  ) async {
    final c = await seed();
    await pumpUnitHost(tester, home: UnitScreen());
    c.loadError.value = 'Unable to load units. Please try again.';
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    c.loadError.value = '';
    c.searchUnit('missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching units'), findsOneWidget);
    c.unitList.clear();
    c.searchUnit('');
    await tester.pumpAndSettle();
    expect(find.text('No units yet'), findsOneWidget);
    expect(find.byKey(const Key('empty-add-unit')), findsOneWidget);
  });

  testWidgets('missing fields render placeholders', (tester) async {
    final c = await seed();
    c.unitList.assignAll([
      unitJson(1, 'Alpha', description: '', createdAt: null, updatedAt: null),
      {...unitJson(2, 'NoId'), 'id': 'not-an-int'},
    ]);
    c.searchUnit('');
    await pumpUnitHost(tester, home: UnitScreen());
    expect(find.text('-'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unit rows are keyboard accessible', (tester) async {
    await seed();
    await pumpUnitHost(tester, home: UnitScreen());
    Focus.of(tester.element(find.text('Kilogram'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(EditUnitWidget), findsOneWidget);
    expect(find.byType(UnitScreen), findsOneWidget);
  });

  testWidgets('Khmer long unit content reflows in both themes', (tester) async {
    final c = await seed();
    for (final dark in [false, true]) {
      c.unitList[0] = {
        ...c.unitList.first,
        'name': 'ឯកតាផលិតផល ' * 12,
        'description': 'ការពិពណ៌នា ' * 20,
      };
      c.searchUnit('');
      await pumpUnitHost(
        tester,
        home: UnitScreen(),
        dark: dark,
        locale: const Locale('km', 'KH'),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('unit controls are labeled, sized, and themed', (tester) async {
    await seed();
    final semantics = tester.ensureSemantics();
    await pumpUnitHost(tester, home: UnitScreen(), dark: true);
    final card = tester.widget<Card>(find.byType(Card).first);
    final theme = Theme.of(tester.element(find.byType(UnitScreen)));
    expect(card.color, theme.cardColor);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
  });
}
