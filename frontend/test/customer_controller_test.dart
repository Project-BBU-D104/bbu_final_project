import 'dart:async';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/services/main_service/customer_service.dart';
import 'package:get/get.dart';
import 'customer_test_support.dart';

class _FakeCustomerService implements CustomerService {
  @override
  Future<dynamic> getCustomers() async => [];

  @override
  Future<dynamic> getCustomerById(int id) async => null;

  @override
  Future<dynamic> createCustomer(Map<String, dynamic> data) async => data;

  @override
  Future<dynamic> updateCustomer(int id, Map<String, dynamic> data) async =>
      data;

  @override
  Future<dynamic> deleteCustomer(int id) async => true;
}

void main() {
  setUp(setUpCustomerTests);
  tearDown(Get.reset);

  test('counts only customers marked active', () {
    final ctr = CustomerController(service: _FakeCustomerService());
    ctr.customerList.value = [
      {'id': 1, 'is_active': true},
      {'id': 2, 'is_active': false},
      {'id': 3, 'is_active': null},
      {'id': 4, 'is_active': true},
    ];

    expect(ctr.activeCustomerCount, 2);
  });

  test('loads customers and filters by name', () async {
    final c = CustomerController(service: FakeCustomerService());
    await c.getCustomers();
    expect(c.customerList.map((e) => e['name']), ['Alpha', 'Beta']);
    c.searchCustomer('ALP');
    expect(c.searchCustomerList.map((e) => e['name']), ['Alpha']);
    c.searchCustomer('   ');
    expect(c.searchCustomerList.length, 2);
  });

  test('load failure exposes a retryable error', () async {
    final c = CustomerController(service: FakeCustomerService()..failGet = true);
    await c.getCustomers();
    expect(c.isLoading.value, isFalse);
    expect(c.loadError.value, 'Unable to load customers. Please try again.');
    expect(c.customerList, isEmpty);
  });

  test('overlapping loads make one request', () async {
    final s = DelayedCustomerService();
    final c = CustomerController(service: s);
    s.refresh = Completer<dynamic>();
    final first = c.getCustomers();
    await c.getCustomers();
    s.refresh!.complete([customerJson(1, 'Alpha')]);
    await first;
    expect(s.getCalls, 1);
  });

  test('search query survives a refresh', () async {
    final c = CustomerController(service: FakeCustomerService());
    await c.getCustomers();
    c.searchCustomer('beta');
    await c.onRefresh();
    expect(c.searchCustomerList.map((e) => e['name']), ['Beta']);
  });

  testWidgets('blank name never writes', (tester) async {
    final s = FakeCustomerService();
    final c = CustomerController(service: s);
    await c.getCustomers();
    Get.put<CustomerController>(c);
    // A bare host: the old customer card's network image fallback never
    // settles under pumpAndSettle; this test only needs a BuildContext.
    await pumpCustomerHost(tester, home: const Scaffold(body: SizedBox()));
    await c.onSaveCustomer(tester.element(find.byType(Scaffold)));
    expect(s.createCalls, 0);
    expect(c.formError.value, 'Customer name is required');
  });
}