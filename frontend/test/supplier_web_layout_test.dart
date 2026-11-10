import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/screen/supplier/supplier_screen.dart';
import 'package:frontend/screen/supplier/widgets/supplier_add_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_detail_card_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_table_widget.dart';
import 'package:get/get.dart';
import 'supplier_test_support.dart';

void main() {
  setUp(setUpSupplierTests);
  tearDown(Get.reset);

  Future<SupplierController> open(WidgetTester tester) async {
    final c = SupplierController(service: FakeSupplierService());
    await c.getSuppliers();
    Get.put<SupplierController>(c);
    await pumpSupplierHost(
      tester,
      home: SupplierScreen(),
      size: const Size(1440, 900),
    );
    return c;
  }

  testWidgets(
    'desktop suppliers has one page title and right aligned primary action',
    (tester) async {
      await open(tester);
      expect(find.text('Suppliers'), findsOneWidget);
      final title = tester.getRect(find.text('Suppliers'));
      final add = tester.getRect(
        find.widgetWithText(FilledButton, 'Add Supplier'),
      );
      expect(add.left, greaterThan(title.right + 400));
      expect(find.byType(AppBar), findsNothing);
    },
  );

  testWidgets('supplier table fills its panel and groups secondary actions', (
    tester,
  ) async {
    await open(tester);
    final table = find.byType(DataTable);
    expect(
      tester.getSize(table).width,
      closeTo(tester.getSize(find.byType(SupplierTableWidget)).width, 2),
    );
    expect(
      tester.widget<DataTable>(table).dataRowMaxHeight,
      lessThanOrEqualTo(76),
    );
    expect(find.byType(PopupMenuButton<String>), findsNWidgets(2));
    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    expect(find.text('Call supplier'), findsOneWidget);
    expect(find.text('Email supplier'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop add uses a centered dialog and closes after saving', (
    tester,
  ) async {
    final c = await open(tester);
    await tester.tap(find.text('Add Supplier'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    final rect = tester.getRect(find.byType(Dialog));
    expect(rect.center.dy, closeTo(450, 2));
    c.supplierNameController.text = 'New supplier';
    c.supplierPhoneNumberController.text = '012345678';
    c.supplierEmailController.text = 'new@example.com';
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(SupplierAddWidget), findsNothing);
    expect(c.suppliers.length, 3);
    expect(find.byType(SupplierScreen), findsOneWidget);
  });

  testWidgets('desktop detail keeps edit and delete in its page header', (
    tester,
  ) async {
    final c = await open(tester);
    c.gotoSupplierDetail(c.suppliers.first);
    await tester.pumpAndSettle();
    final scaffold = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(SupplierDetailCardWidget),
        matching: find.byType(Scaffold),
      ),
    );
    expect(scaffold.appBar, isNull);
    expect(scaffold.bottomNavigationBar, isNull);
    expect(tester.getRect(find.text('Edit')).top, lessThan(220));
    expect(tester.getRect(find.text('Delete')).top, lessThan(220));
  });
  testWidgets(
    'supplier names remain verbatim when they match translation keys',
    (tester) async {
      final c = await open(tester);
      c.suppliers[0] = c.suppliers.first.copyWith(name: 'Home');
      await pumpSupplierHost(
        tester,
        home: SupplierScreen(),
        size: const Size(1440, 900),
        locale: const Locale('km', 'KH'),
      );
      c.gotoSupplierDetail(c.suppliers.first);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    },
  );
}
