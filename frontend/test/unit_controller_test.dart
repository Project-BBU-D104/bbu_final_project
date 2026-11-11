import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:get/get.dart';
import 'unit_test_support.dart';

void main() {
  setUp(setUpUnitTests);
  tearDown(Get.reset);

  test('loads units and filters by name and short name', () async {
    final c = UnitController(service: FakeUnitService());
    await c.getUnitList();
    expect(c.unitList.map((e) => e['name']), ['Kilogram', 'Box']);
    c.searchUnit('KIL');
    expect(c.searchUnitList.map((e) => e['name']), ['Kilogram']);
    c.searchUnit('bx');
    expect(c.searchUnitList.map((e) => e['name']), ['Box']);
    c.searchUnit('   ');
    expect(c.searchUnitList.length, 2);
  });

  test('load failure exposes a retryable error', () async {
    final c = UnitController(service: FakeUnitService()..failGet = true);
    await c.getUnitList();
    expect(c.isLoading.value, isFalse);
    expect(c.loadError.value, 'Unable to load units. Please try again.');
    expect(c.unitList, isEmpty);
  });

  test('overlapping loads make one request', () async {
    final s = DelayedUnitService();
    final c = UnitController(service: s);
    s.refresh = Completer<dynamic>();
    final first = c.getUnitList();
    await c.getUnitList();
    s.refresh!.complete([unitJson(1, 'Kilogram')]);
    await first;
    expect(s.getCalls, 1);
  });

  test('loaded rows keep the product dropdown contract', () async {
    final c = UnitController(service: FakeUnitService());
    await c.getUnitList();
    expect(c.unitList.first['short_name'], 'kg');
    expect(c.unitList.first['status'], isTrue);
    expect(c.isSaving.value, isFalse);
  });
}
