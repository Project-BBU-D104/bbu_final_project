import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/supplier_model.dart';

void main() {
  test('supplier status accepts API booleans and database 0 or 1', () {
    SupplierModel supplier(dynamic status) => SupplierModel.fromJson({
      'name': 'Supplier',
      'phone': '123',
      'status': status,
    });

    expect(supplier(1).status, isTrue);
    expect(supplier(0).status, isFalse);
    expect(supplier(true).status, isTrue);
    expect(supplier(false).status, isFalse);
    expect(supplier(null).status, isTrue);
    expect(() => supplier(2), throwsFormatException);
  });
}
