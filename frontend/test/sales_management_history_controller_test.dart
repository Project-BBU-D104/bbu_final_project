import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'sale_test_support.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/sale/sale_list_controller.dart';
import 'sales_management_test_support.dart';

class ConflictService extends ManagementSaleService {
  @override
  Future<dynamic> deleteSale(int id) async =>
      throw ApiException(409, 'Missing allocation');
}

void main() {
  setUp(() => dotenv.testLoad(fileInput: 'API_URL=http://localhost'));
  testWidgets(
    'historical invoice remains visible with allocation review guidance',
    (tester) async {
      final ctr = SaleListController(service: ConflictService());
      ctr.saleList.add({'id': 1});
      await pumpSalesPage(tester, const Scaffold(body: Text('Invoice')));
      final action = ctr.onDeleteSale(1, tester.element(find.text('Invoice')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();
      await action;
      expect(ctr.saleList.single['id'], 1);
      expect(ctr.loadError.value, contains('stock allocation needs review'));
    },
  );
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
