import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:frontend/localization/km_kh.dart';
import 'package:frontend/themes/app_theme.dart';
import 'package:frontend/screen/supplier/supplier_screen.dart';
import 'package:frontend/screen/supplier/widgets/supplier_card_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_table_widget.dart';
import 'package:get/get.dart';
import 'supplier_test_support.dart';

void main() {
  setUp(setUpSupplierTests);
  tearDown(Get.reset);
  test('supplier text colors meet contrast requirements in both themes', () {
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
      final activeColor = theme.brightness == Brightness.light
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.primary;
      final inactiveColor = theme.colorScheme.onSurface;
      for (final color in [activeColor, inactiveColor]) {
        expect(
          contrast(
            color,
            Color.alphaBlend(color.withValues(alpha: 0.15), theme.cardColor),
          ),
          greaterThanOrEqualTo(4.5),
          reason: '${theme.brightness} $color',
        );
      }
    }
  });
  test('supplier statuses and form feedback have Khmer translations', () {
    for (final key in [
      'Active',
      'Inactive',
      'Cancel',
      'Confirm',
      'Do you want to delete this supplier?',
      'Email is required',
      'Ok',
      'Phone',
      'Phone number is required',
      'Pick Location',
      'Supplier name is required',
      'Actions',
    ]) {
      expect(kmKH[key], isNotNull, reason: key);
      expect(kmKH[key], isNot(key), reason: key);
    }
  });
  Future<SupplierController> seed() async {
    final c = SupplierController(service: FakeSupplierService());
    await c.getSuppliers();
    return Get.put<SupplierController>(c);
  }

  testWidgets('supplier list adapts to usable width and text scale', (
    tester,
  ) async {
    await seed();
    await pumpSupplierHost(
      tester,
      home: SupplierScreen(),
      size: const Size(900, 900),
    );
    expect(find.byType(SupplierCardWidget), findsNWidgets(2));
    expect(find.byType(SupplierTableWidget), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Add Supplier'), findsOneWidget);
    await pumpSupplierHost(
      tester,
      home: SupplierScreen(),
      size: const Size(1440, 900),
    );
    expect(find.byType(SupplierTableWidget), findsOneWidget);
  });
  testWidgets('loading error empty and no matches have distinct actions', (
    tester,
  ) async {
    final c = await seed();
    await pumpSupplierHost(tester, home: SupplierScreen());
    c.loadError.value = 'Unable to load suppliers. Please try again.';
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    c.loadError.value = '';
    c.searchSupplier('missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching suppliers'), findsOneWidget);
    c.suppliers.clear();
    c.searchSupplier('');
    await tester.pumpAndSettle();
    expect(find.text('No suppliers yet'), findsOneWidget);
  });
  testWidgets('detail handles empty name optional fields and absent id', (
    tester,
  ) async {
    final c = await seed();
    await pumpSupplierHost(
      tester,
      home: SupplierScreen(),
      dark: true,
      textScale: 2,
    );
    c.gotoSupplierDetail(const SupplierModel(name: '', phone: ''));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.business_outlined), findsWidgets);
    expect(find.text('-'), findsWidgets);
    expect(tester.takeException(), isNull);
    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Delete'))
          .onPressed,
      isNull,
    );
  });
  testWidgets('detail uses current controller record', (tester) async {
    final c = await seed();
    await pumpSupplierHost(tester, home: SupplierScreen());
    c.gotoSupplierDetail(c.suppliers.first);
    await tester.pumpAndSettle();
    c.suppliers[0] = c.suppliers.first.copyWith(name: 'Updated');
    await tester.pumpAndSettle();
    expect(find.text('Updated'), findsOneWidget);
  });
  testWidgets('supplier actions preserve routes and keyboard access', (
    tester,
  ) async {
    final c = await seed();
    await pumpSupplierHost(tester, home: SupplierScreen());
    final supplier = c.suppliers.first;
    Focus.of(tester.element(find.text('Alpha'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/supplier-detail');
    expect(Get.arguments, same(supplier));
    expect(Get.find<SupplierController>(), same(c));
    expect(
      find.widgetWithText(OutlinedButton, 'Call supplier'),
      findsOneWidget,
    );
  });
  testWidgets('Khmer long supplier content reflows in both themes', (
    tester,
  ) async {
    final c = await seed();
    for (final dark in [false, true]) {
      c.suppliers[0] = c.suppliers.first.copyWith(
        name: 'អ្នកផ្គត់ផ្គង់ ' * 12,
        address: 'អាសយដ្ឋាន ' * 20,
      );
      c.searchSupplier('');
      await pumpSupplierHost(
        tester,
        home: SupplierScreen(),
        dark: dark,
        locale: const Locale('km', 'KH'),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      c.gotoSupplierDetail(c.suppliers.first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      Get.back();
      await tester.pumpAndSettle();
    }
  });
  testWidgets(
    'supplier controls have labels touch targets and themed surfaces',
    (tester) async {
      await seed();
      final semantics = tester.ensureSemantics();
      await pumpSupplierHost(tester, home: SupplierScreen(), dark: true);
      final card = tester.widget<Card>(find.byType(Card).first);
      final theme = Theme.of(tester.element(find.byType(SupplierScreen)));
      expect(card.color, theme.cardColor);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      semantics.dispose();
    },
  );
}
