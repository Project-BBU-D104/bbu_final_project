import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:frontend/screen/unit/unit_screen.dart';
import 'package:frontend/screen/unit/widget/add_unit_widget.dart';
import 'package:frontend/screen/unit/widget/edit_unit_widget.dart';
import 'package:get/get.dart';
import 'unit_test_support.dart';

void main() {
  setUp(setUpUnitTests);
  tearDown(Get.reset);

  Future<UnitController> seed(
    WidgetTester tester,
    FakeUnitService service,
  ) async {
    final c = UnitController(service: service);
    await c.getUnitList();
    Get.put<UnitController>(c);
    await pumpUnitHost(tester, home: UnitScreen());
    return c;
  }

  void fill(UnitController c) {
    c.unitNameController.text = ' Kilogram ';
    c.unitShortNameController.text = ' kg ';
    c.unitDescriptionController.text = ' Everyday goods ';
    c.isActive.value = true;
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('blank name or short name never writes', (tester) async {
    final s = FakeUnitService();
    final c = await seed(tester, s);
    c.addUnit(tester.element(find.byType(UnitScreen)));
    await tester.pumpAndSettle();
    await save(tester);
    expect(s.createCalls, 0);
    expect(find.text('Unit name is required'), findsOneWidget);
    c.unitNameController.text = 'Kilogram';
    await save(tester);
    expect(s.createCalls, 0);
    expect(find.text('Short name is required'), findsOneWidget);
    c.unitNameController.text = '   ';
    c.unitShortNameController.text = '   ';
    await c.onSaveUnit(tester.element(find.byType(AddUnitWidget)));
    await tester.pumpAndSettle();
    expect(s.createCalls, 0);
  });

  testWidgets('trimmed payload keeps the unit contract', (tester) async {
    final s = FakeUnitService();
    final c = await seed(tester, s);
    c.addUnit(tester.element(find.byType(UnitScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await save(tester);
    expect(s.lastCreatedData, {
      'name': 'Kilogram',
      'short_name': 'kg',
      'description': 'Everyday goods',
      'status': true,
    });
    expect(s.createCalls, 1);
    expect(find.byType(AddUnitWidget), findsNothing);
  });

  testWidgets('write failure preserves the draft and shows an error', (
    tester,
  ) async {
    final s = FakeUnitService()..failWrite = true;
    final c = await seed(tester, s);
    c.addUnit(tester.element(find.byType(UnitScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await save(tester);
    expect(c.unitNameController.text, ' Kilogram ');
    expect(find.byType(AddUnitWidget), findsOneWidget);
    expect(find.text('Unable to save unit. Please try again.'), findsOneWidget);
  });

  testWidgets('repeated save taps send one request and block dismissal', (
    tester,
  ) async {
    final s = DelayedUnitService();
    final c = await seed(tester, s);
    c.addUnit(tester.element(find.byType(UnitScreen)));
    await tester.pumpAndSettle();
    fill(c);
    final context = tester.element(find.byType(AddUnitWidget));
    c.onSaveUnit(context);
    c.onSaveUnit(context);
    await tester.pump();
    expect(s.createCalls, 1);
    expect(await Navigator.of(context).maybePop(), true);
    await tester.pump();
    expect(find.byType(AddUnitWidget), findsOneWidget);
    s.create.complete(unitJson(3, 'Kilogram'));
    await tester.pumpAndSettle();
    expect(find.byType(AddUnitWidget), findsNothing);
  });

  testWidgets('edit prefills status and saves a real bool', (tester) async {
    final s = FakeUnitService();
    final c = await seed(tester, s);
    await c.onEditUnit(1, tester.element(find.byType(UnitScreen)));
    await tester.pumpAndSettle();
    expect(find.byType(EditUnitWidget), findsOneWidget);
    expect(c.isActive.value, isTrue);
    c.isActive.value = false;
    c.unitNameController.text = 'Updated';
    await save(tester);
    expect(s.lastUpdatedData!['status'], isFalse);
    expect(c.unitList.first['name'], 'Updated');
    expect(find.byType(EditUnitWidget), findsNothing);
    expect(find.byType(UnitScreen), findsOneWidget);
  });

  testWidgets('refresh failure after a committed save keeps the new row', (
    tester,
  ) async {
    final s = FakeUnitService();
    final c = await seed(tester, s);
    c.addUnit(tester.element(find.byType(UnitScreen)));
    await tester.pumpAndSettle();
    fill(c);
    s.failGet = true;
    await save(tester);
    expect(s.createCalls, 1);
    expect(
      c.unitList.any((e) => e['name'] == 'Kilogram' && e['id'] == 3),
      isTrue,
    );
    expect(find.byType(AddUnitWidget), findsNothing);
    expect(c.loadError.value, isNotEmpty);
  });

  testWidgets('late edit fetch never opens on another page', (tester) async {
    final s = DelayedUnitService();
    final c = await seed(tester, s);
    final ctx = tester.element(find.byType(UnitScreen));
    c.onEditUnit(1, ctx);
    c.onEditUnit(1, ctx);
    Get.to(() => const Scaffold(body: Text('Other')));
    await tester.pumpAndSettle();
    s.edit.complete(unitJson(1, 'Late'));
    await tester.pumpAndSettle();
    expect(s.getByIdCalls, 1);
    expect(find.byType(EditUnitWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete cancel, failure, and success keep the list route', (
    tester,
  ) async {
    final s = FakeUnitService();
    final c = await seed(tester, s);
    Future<void> openDelete() async {
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
    }

    await openDelete();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(s.deleteCalls, 0);
    s.failWrite = true;
    await openDelete();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(find.byType(UnitScreen), findsOneWidget);
    expect(c.unitList.length, 2);
    s.failWrite = false;
    await openDelete();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(find.byType(UnitScreen), findsOneWidget);
    expect(c.unitList.map((e) => e['id']), [2]);
  });

  testWidgets('failed update preserves the draft and blank names never write', (
    tester,
  ) async {
    final s = FakeUnitService()..failWrite = true;
    final c = await seed(tester, s);
    await c.onEditUnit(1, tester.element(find.byType(UnitScreen)));
    await tester.pumpAndSettle();
    c.unitNameController.text = 'Changed';
    await save(tester);
    expect(c.unitNameController.text, 'Changed');
    expect(find.byType(EditUnitWidget), findsOneWidget);
    c.unitNameController.text = ' ';
    await c.onUpdateUnit(1, tester.element(find.byType(EditUnitWidget)));
    expect(s.updateCalls, 1);
  });

  testWidgets('form survives keyboard, Khmer, and large text', (tester) async {
    final c = await seed(tester, FakeUnitService());
    await pumpUnitHost(
      tester,
      home: UnitScreen(),
      locale: const Locale('km', 'KH'),
      dark: true,
      textScale: 2,
    );
    c.addUnit(tester.element(find.byType(UnitScreen)));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'.tr));
    expect(tester.takeException(), isNull);
  });

  testWidgets('controller disposal during a write never pops another page', (
    tester,
  ) async {
    final s = DelayedUnitService();
    final c = await seed(tester, s);
    c.addUnit(tester.element(find.byType(UnitScreen)));
    await tester.pumpAndSettle();
    fill(c);
    final pending = c.onSaveUnit(tester.element(find.byType(AddUnitWidget)));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    Get.delete<UnitController>(force: true);
    s.create.complete(unitJson(3, 'Kilogram'));
    await pending;
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop form opens as a dialog', (tester) async {
    final c = await seed(tester, FakeUnitService());
    await pumpUnitHost(tester, home: UnitScreen(), size: const Size(1440, 900));
    c.addUnit(tester.element(find.byType(UnitScreen)));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(AddUnitWidget), findsOneWidget);
  });
}
