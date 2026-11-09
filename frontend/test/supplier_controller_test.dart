import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:get/get.dart';
import 'supplier_test_support.dart';

void main() {
  setUp(setUpSupplierTests);
  tearDown(Get.reset);
  test('refresh keeps the current name query', () async {
    final c = SupplierController(service: FakeSupplierService());
    await c.getSuppliers();
    c.searchSupplier(' ALP ');
    await c.getSuppliers();
    expect(c.searchSuppliers.map((s) => s.id), [1]);
    expect(c.suppliers.map((s) => s.id), [1, 2]);
    c.searchSupplier('');
    expect(c.searchSuppliers.length, 2);
    c.onClose();
  });
  test('initial shared query applies to cached records', () async {
    final seed = SupplierController(service: FakeSupplierService());
    await seed.getSuppliers(); seed.onClose();
    final search = Get.put(SearchController());
    search.keyword.value = 'beta';
    final c = Get.put(SupplierController(service: FakeSupplierService()));
    expect(c.searchSuppliers.map((s) => s.id), [2]);
    Get.delete<SupplierController>();
    search.keyword.value = 'alpha';
    expect(c.searchSuppliers.map((s) => s.id), [2]);
  });
  testWidgets('failed refresh retains records and exposes retry state', (tester) async {
    final service = FakeSupplierService();
    final c = SupplierController(service: service);
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    await c.getSuppliers(); service.failGet = true;
    await c.getSuppliers();
    expect(c.loadError.value, isNotEmpty);
    expect(c.isLoading.value, false);
    expect(c.suppliers.length, 2);
    service.failGet = false;
    await c.getSuppliers();
    expect(c.loadError.value, isEmpty);
    c.onClose();
    await tester.pumpAndSettle();
  });
  test('optional dates tolerate invalid input', () {
    for (final value in [null, '', 'invalid']) {
      final m = SupplierModel.fromJson({...supplierJson(1, 'Alpha'), 'created_at': value, 'updated_at': value});
      expect(m.createdAt, isNull); expect(m.updatedAt, isNull);
    }
  });
}
