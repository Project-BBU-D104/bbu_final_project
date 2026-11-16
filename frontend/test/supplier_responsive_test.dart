import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/screen/supplier/supplier_screen.dart';
import 'package:frontend/screen/supplier/widgets/supplier_card_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_table_widget.dart';
import 'package:get/get.dart';
import 'supplier_test_support.dart';

void main() {
  setUp(setUpSupplierTests);
  tearDown(Get.reset);

  Future<void> seed() async {
    final controller = SupplierController(service: FakeSupplierService());
    await controller.getSuppliers();
    Get.put<SupplierController>(controller);
  }

  testWidgets('mobile supplier actions align left below the description', (
    tester,
  ) async {
    await seed();
    await pumpSupplierHost(
      tester,
      home: SupplierScreen(),
      size: const Size(375, 812),
    );
    final subtitle = tester.getRect(
      find.text('Manage supplier contacts and locations.'),
    );
    final refresh = tester.getRect(find.byTooltip('Refresh'));
    final add = tester.getRect(
      find.widgetWithText(FilledButton, 'Add Supplier'),
    );
    expect(refresh.left, closeTo(subtitle.left, 0.1));
    expect(refresh.top, greaterThan(subtitle.bottom));
    expect(add.left, greaterThan(refresh.right));
    expect(add.center.dy, closeTo(refresh.center.dy, 0.1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a wide page falls back to cards when the text is scaled up', (
    tester,
  ) async {
    await seed();
    await pumpSupplierHost(
      tester,
      home: SupplierScreen(),
      size: const Size(1440, 900),
      textScale: 1.3,
    );
    expect(find.byType(SupplierCardWidget), findsWidgets);
    expect(find.byType(SupplierTableWidget), findsNothing);
  });

  testWidgets('a wide page uses the table at the normal text scale', (
    tester,
  ) async {
    await seed();
    await pumpSupplierHost(
      tester,
      home: SupplierScreen(),
      size: const Size(1440, 900),
    );
    expect(find.byType(SupplierTableWidget), findsOneWidget);
  });
}
