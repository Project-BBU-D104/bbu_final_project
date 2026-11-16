import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

void main() {
  test('Warehouse copy has English and Khmer translations', () {
    for (final key in [
      'Warehouses',
      'Warehouse Detail',
      'Warehouse details',
      'Add Warehouse',
      'Edit Warehouse',
      'Warehouse Name',
      'Reference No',
      'Location',
      'Note',
      'Please enter warehouse name',
      'Please enter location',
      'Search Warehouses',
      'Manage warehouse locations and stock.',
      'No warehouses yet',
      'No matching warehouses',
      'Warehouse unavailable',
      'Not available',
      'No warehouse stock yet',
      'Clear search',
      'Unable to load warehouses. Please try again.',
      'Unable to save warehouse. Please try again.',
      'Unable to open warehouse. Please try again.',
      'Unable to delete warehouse. Please try again.',
      'Do you want to delete this warehouse?',
    ]) {
      expect(enUS[key], isNotEmpty, reason: key);
      expect(kmKH[key], isNotEmpty, reason: key);
      expect(kmKH[key], isNot(key), reason: key);
    }
  });
}
