import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'sales_management_test_support.dart';

void main() {
  setUp(() => dotenv.testLoad(fileInput: 'API_URL=http://localhost'));
  test(
    'malformed refresh retains records and query; retry replaces data',
    () async {
      SaleListController.invalidateCache();
      final fake = ManagementSaleService()
        ..rows = [
          {'id': 1, 'invoice_no': 'INV-1'},
        ];
      final ctr = SaleListController(service: fake);
      await ctr.onGetSaleList();
      ctr.searchCtr.keyword.value = 'INV';
      fake.rows = null;
      await ctr.onRefresh();
      expect(ctr.saleList.length, 1);
      expect(ctr.loadError.value, isNotEmpty);
      expect(ctr.filteredSaleList.length, 1);
      fake.rows = [
        {'id': 2},
      ];
      await ctr.onRefresh();
      expect(ctr.saleList.single['id'], 2);
      expect(ctr.loadError.value, isEmpty);
    },
  );
}
