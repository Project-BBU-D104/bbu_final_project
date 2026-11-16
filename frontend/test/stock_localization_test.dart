import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/localization/en_us.dart';
import 'package:frontend/localization/km_kh.dart';

void main() {
  test(
    'Stock form actions search and delete confirmations have Khmer copy',
    () {
      for (final key in [
        'Add Warehouse Stock',
        'Edit Warehouse Stock',
        'Search Warehouse Stock',
        'Do you want to delete this warehouse stock?',
        'Do you want to delete this stock transfer?',
      ]) {
        expect(enUS[key], isNotEmpty, reason: key);
        expect(kmKH[key], matches(RegExp(r'[\u1780-\u17ff]')), reason: key);
      }
    },
  );
}
