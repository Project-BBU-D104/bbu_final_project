import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/screen/customer/widget/customer_card_widget.dart';
import 'package:frontend/screen/customer/widget/customer_table_widget.dart';
import 'package:frontend/services/main_service/customer_service.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:get/get.dart';

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
  tearDown(Get.reset);

  setUp(() {
    Get.put(CustomerController(service: _FakeCustomerService()));
  });

  final customer = <String, dynamic>{
    'id': 1,
    'name': 'Dara',
    'phone': '012345678',
    'address': 'Phnom Penh',
    'photo': 'https://example.com/dara.jpg',
    'is_active': true,
    'created_at': '2025-01-01T00:00:00',
  };

  testWidgets('customer table renders its photo through AppCachedImage', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CustomerTableWidget(items: [customer])),
      ),
    );

    final image = tester.widget<AppCachedImage>(find.byType(AppCachedImage));
    expect(image.url, 'https://example.com/dara.jpg');
  });

  testWidgets('customer card renders its photo through AppCachedImage', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CustomerCardWidget(item: customer)),
      ),
    );

    final image = tester.widget<AppCachedImage>(find.byType(AppCachedImage));
    expect(image.url, 'https://example.com/dara.jpg');
  });
}
