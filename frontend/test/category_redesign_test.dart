import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/screen/category/category_screen.dart';
import 'package:frontend/screen/category/widget/card_category_widget.dart';
import 'package:frontend/screen/category/widget/edit_category_widget.dart';
import 'package:frontend/screen/category/widget/table_category_widget.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:get/get.dart';
import 'category_test_support.dart';

void main() {
  setUp(setUpCategoryTests);
  tearDown(Get.reset);

  Future<CategoryController> seed() async {
    final c = CategoryController(service: FakeCategoryService());
    await c.getCategory();
    return Get.put<CategoryController>(c);
  }

  test('category text colors meet contrast requirements in both themes', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return ((x > y ? x : y) + 0.05) / ((x < y ? x : y) + 0.05);
    }

    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      for (final color in [
        theme.colorScheme.onSurface,
        theme.colorScheme.onSurfaceVariant,
        theme.colorScheme.primary,
        theme.colorScheme.error,
      ]) {
        expect(contrast(color, theme.cardColor), greaterThanOrEqualTo(4.5));
      }
    }
  });

  testWidgets('category list adapts to usable width', (tester) async {
    await seed();
    await pumpCategoryHost(
      tester,
      home: CategoryScreen(),
      size: const Size(900, 900),
    );
    expect(find.byType(CategoryCardWidget), findsNWidgets(2));
    expect(find.byType(CategoryTableWidget), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Add Category'), findsOneWidget);
    await pumpCategoryHost(
      tester,
      home: CategoryScreen(),
      size: const Size(1440, 900),
    );
    expect(find.byType(CategoryTableWidget), findsOneWidget);
  });

  testWidgets('loading error empty and no-match states are distinct', (
    tester,
  ) async {
    final c = await seed();
    await pumpCategoryHost(tester, home: CategoryScreen());
    c.loadError.value = 'Unable to load categories. Please try again.';
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    c.loadError.value = '';
    c.searchCategory('missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching categories'), findsOneWidget);
    c.categoryList.clear();
    c.searchCategory('');
    await tester.pumpAndSettle();
    expect(find.text('No categories yet'), findsOneWidget);
    expect(find.byKey(const Key('empty-add-category')), findsOneWidget);
  });

  testWidgets('missing description and date render placeholders', (
    tester,
  ) async {
    final c = await seed();
    c.categoryList.assignAll([
      categoryJson(1, 'Alpha', description: '', createdAt: null),
    ]);
    c.searchCategory('');
    await pumpCategoryHost(tester, home: CategoryScreen());
    expect(find.text('-'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category rows are keyboard accessible', (tester) async {
    await seed();
    await pumpCategoryHost(tester, home: CategoryScreen());
    Focus.of(tester.element(find.text('Alpha'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(EditCategoryWidget), findsOneWidget);
    expect(find.byType(CategoryScreen), findsOneWidget);
  });

  testWidgets('Khmer long category content reflows in both themes', (
    tester,
  ) async {
    final c = await seed();
    for (final dark in [false, true]) {
      c.categoryList[0] = {
        ...c.categoryList.first,
        'name': 'ប្រភេទផលិតផល ' * 12,
        'description': 'ការពិពណ៌នា ' * 20,
      };
      c.searchCategory('');
      await pumpCategoryHost(
        tester,
        home: CategoryScreen(),
        dark: dark,
        locale: const Locale('km', 'KH'),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('category controls are labeled, sized, and themed', (
    tester,
  ) async {
    await seed();
    final semantics = tester.ensureSemantics();
    await pumpCategoryHost(tester, home: CategoryScreen(), dark: true);
    final card = tester.widget<Card>(find.byType(Card).first);
    final theme = Theme.of(tester.element(find.byType(CategoryScreen)));
    expect(card.color, theme.cardColor);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
  });
}
