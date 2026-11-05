import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/services/main_service/customer_service.dart';

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
}
