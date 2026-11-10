import 'dart:async';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/screen/supplier/supplier_screen.dart';
import 'package:frontend/screen/supplier/widgets/supplier_add_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_edit_widget.dart';
import 'package:get/get.dart';
import 'supplier_test_support.dart';

class DelayedSupplierService extends FakeSupplierService {
  final create = Completer<dynamic>();
  final edit = Completer<dynamic>();
  @override
  Future<dynamic> createSupplier(Map<String, dynamic> data) {
    createCalls++;
    lastCreatedData = data;
    return create.future;
  }

  @override
  Future<dynamic> getSupplierById(int id) {
    getByIdCalls++;
    return edit.future;
  }
}

class DelayedRefreshService extends FakeSupplierService {
  Completer<dynamic>? refresh;
  @override
  Future<dynamic> getSuppliers() => refresh?.future ?? super.getSuppliers();
}

void main() {
  setUp(setUpSupplierTests);
  tearDown(Get.reset);
  Future<SupplierController> seed(
    WidgetTester tester,
    FakeSupplierService service,
  ) async {
    final c = SupplierController(service: service);
    await c.getSuppliers();
    Get.put<SupplierController>(c);
    await pumpSupplierHost(tester, home: SupplierScreen());
    return c;
  }

  void fill(SupplierController c) {
    c.supplierNameController.text = ' Alpha ';
    c.supplierPhoneNumberController.text = ' 012345678 ';
    c.supplierEmailController.text = ' supplier@example.com ';
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('blank required fields never write', (tester) async {
    final s = FakeSupplierService();
    final c = await seed(tester, s);
    c.addSupplier(tester.element(find.byType(SupplierScreen)));
    await tester.pumpAndSettle();
    await save(tester);
    expect(s.createCalls, 0);
    expect(find.text('Supplier name is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    fill(c);
    c.supplierNameController.text = '  ';
    c.saveSupplier(tester.element(find.byType(SupplierAddWidget)));
    await tester.pumpAndSettle();
    expect(s.createCalls, 0);
  });
  testWidgets('optional fields and trimmed payload retain contract', (
    tester,
  ) async {
    final s = FakeSupplierService();
    final c = await seed(tester, s);
    c.addSupplier(tester.element(find.byType(SupplierScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await save(tester);
    expect(s.lastCreatedData, {
      'name': 'Alpha',
      'phone': '012345678',
      'email': 'supplier@example.com',
      'map': '',
      'address': '',
      'status': true,
    });
    expect(s.createCalls, 1);
    expect(find.byType(SupplierAddWidget), findsNothing);
  });
  testWidgets('write failure preserves draft and shows error', (tester) async {
    final s = FakeSupplierService()..failWrite = true;
    final c = await seed(tester, s);
    c.addSupplier(tester.element(find.byType(SupplierScreen)));
    await tester.pumpAndSettle();
    fill(c);
    await save(tester);
    expect(c.supplierNameController.text, ' Alpha ');
    expect(find.byType(SupplierAddWidget), findsOneWidget);
    expect(
      find.text('Unable to save supplier. Please try again.'),
      findsOneWidget,
    );
  });
  testWidgets('repeated save taps send one request and block dismissal', (
    tester,
  ) async {
    final s = DelayedSupplierService();
    final c = await seed(tester, s);
    c.addSupplier(tester.element(find.byType(SupplierScreen)));
    await tester.pumpAndSettle();
    fill(c);
    final context = tester.element(find.byType(SupplierAddWidget));
    c.saveSupplier(context);
    c.saveSupplier(context);
    await tester.pump();
    expect(s.createCalls, 1);
    expect(await Navigator.of(context).maybePop(), true);
    await tester.pump();
    expect(find.byType(SupplierAddWidget), findsOneWidget);
    s.create.complete({...supplierJson(3, 'Alpha')});
    await tester.pumpAndSettle();
    expect(find.byType(SupplierAddWidget), findsNothing);
  });
  testWidgets('edit closes only its sheet and updates detail', (tester) async {
    final s = FakeSupplierService();
    final c = await seed(tester, s);
    c.gotoSupplierDetail(c.suppliers.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    c.supplierNameController.text = 'Updated';
    c.status.value = false;
    await save(tester);
    expect(find.byType(SupplierEditWidget), findsNothing);
    expect(Get.currentRoute, '/supplier-detail');
    expect(find.text('Updated'), findsOneWidget);
    expect(c.suppliers.length, 2);
    c.searchSupplier('updated');
    expect(c.searchSuppliers.length, 1);
    expect(c.suppliers.length, 2);
  });
  testWidgets(
    'refresh failure after committed save does not offer resubmission',
    (tester) async {
      final s = FakeSupplierService();
      final c = await seed(tester, s);
      c.addSupplier(tester.element(find.byType(SupplierScreen)));
      await tester.pumpAndSettle();
      fill(c);
      s.failGet = true;
      await save(tester);
      expect(s.createCalls, 1);
      expect(c.suppliers.length, 3);
      expect(find.byType(SupplierAddWidget), findsNothing);
      expect(c.loadError.value, isNotEmpty);
    },
  );
  testWidgets('late edit fetch never opens on another page', (tester) async {
    final s = DelayedSupplierService();
    final c = await seed(tester, s);
    c.gotoSupplierDetail(c.suppliers.first);
    await tester.pumpAndSettle();
    final ctx = tester.element(find.text('Edit'));
    c.editSupplier(1, ctx);
    c.editSupplier(1, ctx);
    Get.back();
    await tester.pumpAndSettle();
    s.edit.complete(supplierJson(1, 'Late'));
    await tester.pumpAndSettle();
    expect(s.getByIdCalls, 1);
    expect(find.byType(SupplierEditWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('delete cancel failure and success preserve stack', (
    tester,
  ) async {
    final s = FakeSupplierService();
    final c = await seed(tester, s);
    c.gotoSupplierDetail(c.suppliers.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(s.deleteCalls, 0);
    s.failWrite = true;
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/supplier-detail');
    expect(c.suppliers.length, 2);
    s.failWrite = false;
    s.failGet = true;
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(find.byType(SupplierScreen), findsOneWidget);
    expect(c.suppliers.map((v) => v.id), [2]);
  });
  testWidgets('supplier form survives keyboard Khmer and large text', (
    tester,
  ) async {
    final s = FakeSupplierService();
    final c = await seed(tester, s);
    await pumpSupplierHost(
      tester,
      home: SupplierScreen(),
      locale: const Locale('km', 'KH'),
      dark: true,
      textScale: 2,
    );
    c.addSupplier(tester.element(find.byType(SupplierScreen)));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'.tr));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'failed update preserves status and controller validation rejects blank values',
    (tester) async {
      final s = FakeSupplierService()..failWrite = true;
      final c = await seed(tester, s);
      c.gotoSupplierDetail(c.suppliers.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      c.supplierNameController.text = 'Changed';
      c.status.value = false;
      await save(tester);
      expect(c.supplierNameController.text, 'Changed');
      expect(c.status.value, false);
      expect(find.byType(SupplierEditWidget), findsOneWidget);
      final context = tester.element(find.byType(SupplierEditWidget));
      c.supplierEmailController.text = ' ';
      await c.updateSupplier(1, context);
      expect(s.updateCalls, 1);
    },
  );
  testWidgets('controller disposal during a write never pops another page', (
    tester,
  ) async {
    final s = DelayedSupplierService();
    final c = await seed(tester, s);
    c.addSupplier(tester.element(find.byType(SupplierScreen)));
    await tester.pumpAndSettle();
    fill(c);
    final pending = c.saveSupplier(
      tester.element(find.byType(SupplierAddWidget)),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    Get.delete<SupplierController>(force: true);
    s.create.complete(supplierJson(3, 'Alpha'));
    await pending;
    expect(tester.takeException(), isNull);
  });
  testWidgets('desktop supplier form uses two columns', (tester) async {
    final c = await seed(tester, FakeSupplierService());
    await pumpSupplierHost(
      tester,
      home: SupplierScreen(),
      size: const Size(1440, 900),
    );
    c.addSupplier(tester.element(find.byType(SupplierScreen)));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    expect(
      tester.getTopLeft(fields.at(1)).dy,
      tester.getTopLeft(fields.at(2)).dy,
    );
    expect(
      tester.getTopLeft(fields.at(2)).dx,
      greaterThan(tester.getTopLeft(fields.at(1)).dx),
    );
  });
  testWidgets('detail remains visible behind its edit sheet', (tester) async {
    final c = await seed(tester, FakeSupplierService());
    c.gotoSupplierDetail(c.suppliers.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data == 'Alpha'),
      findsOneWidget,
    );
  });
  testWidgets('an older refresh cannot overwrite a committed supplier', (
    tester,
  ) async {
    final s = DelayedRefreshService();
    final c = await seed(tester, s);
    s.refresh = Completer<dynamic>();
    final pending = c.getSuppliers();
    await tester.pump();
    c.addSupplier(tester.element(find.byType(SupplierScreen)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    fill(c);
    await c.saveSupplier(tester.element(find.byType(SupplierAddWidget)));
    s.refresh!.complete([supplierJson(1, 'Alpha'), supplierJson(2, 'Beta')]);
    await pending;
    await tester.pumpAndSettle();
    expect(c.suppliers.map((v) => v.id), [1, 2, 3]);
  });
}
