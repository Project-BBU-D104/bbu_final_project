import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:get/get.dart';
import 'category_test_support.dart';

void main() {
  setUp(setUpCategoryTests);
  tearDown(Get.reset);

  test('loads categories and filters by name', () async {
    final c = CategoryController(service: FakeCategoryService());
    await c.getCategory();
    expect(c.categoryList.map((e) => e['name']), ['Alpha', 'Beta']);
    c.searchCategory('ALP');
    expect(c.searchCategoryList.map((e) => e['name']), ['Alpha']);
    c.searchCategory('   ');
    expect(c.searchCategoryList.length, 2);
  });

  test('load failure exposes a retryable error', () async {
    final c = CategoryController(
      service: FakeCategoryService()..failGet = true,
    );
    await c.getCategory();
    expect(c.isLoading.value, isFalse);
    expect(c.loadError.value, 'Unable to load categories. Please try again.');
    expect(c.categoryList, isEmpty);
  });

  test('overlapping loads make one request', () async {
    final s = DelayedCategoryService();
    final c = CategoryController(service: s);
    s.refresh = Completer<dynamic>();
    final first = c.getCategory();
    await c.getCategory();
    s.refresh!.complete([categoryJson(1, 'Alpha')]);
    await first;
    expect(s.getCalls, 1);
  });
}