import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/sales_report_utils.dart';

Map<String, dynamic> rawSale({
  String invoice = 'SALE-1',
  String customer = 'Walk-in',
  String date = '2026-11-05T10:00:00',
  String total = '90.00',
  String paymentStatus = 'paid',
  String status = 'completed',
  Object? deletedAt,
  List<Map<String, dynamic>>? items,
}) {
  return {
    'invoice_no': invoice,
    'customer': {'name': customer},
    'sale_date': date,
    'total_amount': total,
    'payment_status': paymentStatus,
    'status': status,
    'deleted_at': deletedAt,
    'sale_items': items ?? _defaultItems,
  };
}

const List<Map<String, dynamic>> _defaultItems = [
  {
    'product': {
      'id': 1,
      'name': 'Helmet',
      'unit': {'id': 1, 'name': 'Piece', 'short_name': 'pcs'},
    },
    'qty': 3,
    'sale_price': '20.00',
    'subtotal': '60.00',
  },
  {
    'product': {
      'id': 2,
      'name': 'Oil',
      'unit': {'id': 2, 'name': 'Litre', 'short_name': 'l'},
    },
    'qty': 2,
    'sale_price': '15.00',
    'subtotal': '30.00',
  },
];

void main() {
  group('parseAmount', () {
    test('parses decimal strings from the API', () {
      expect(parseAmount('150.00'), 150.0);
    });

    test('accepts numbers', () {
      expect(parseAmount(12), 12.0);
      expect(parseAmount(12.5), 12.5);
    });

    test('falls back to zero', () {
      expect(parseAmount(null), 0);
      expect(parseAmount(''), 0);
      expect(parseAmount('n/a'), 0);
    });
  });

  group('saleReportRow', () {
    test('maps API strings and items to typed row values', () {
      final row = saleReportRow(rawSale());

      expect(row, isNotNull);
      expect(row!['invoice'], 'SALE-1');
      expect(row['total'], 90.0);
      expect(row['status'], 'Paid');
      expect(row['date'], isA<DateTime>());

      final items = row['items'] as List;
      expect(items, hasLength(2));
      expect(items.first['product'], 'Helmet');
      expect(items.first['unit'], 'pcs');
      expect(items.first['qty'], 3);
      expect(items.first['price'], 20.0);
      expect(items.first['amount'], 60.0);
    });

    test('returns null for cancelled sales', () {
      expect(saleReportRow(rawSale(status: 'cancelled')), isNull);
    });

    test('returns null for soft-deleted sales', () {
      expect(
        saleReportRow(rawSale(deletedAt: '2026-11-05T10:00:00')),
        isNull,
      );
    });

    test('returns null when the sale date is invalid', () {
      expect(saleReportRow(rawSale(date: 'not-a-date')), isNull);
    });
  });

  group('saleItemRows', () {
    test('creates one row per product sold', () {
      final rows = saleItemRows([saleReportRow(rawSale())!]);

      expect(rows, hasLength(2));
      expect(rows.map((row) => row['product']), ['Helmet', 'Oil']);
      expect(rows.map((row) => row['unit']), ['pcs', 'l']);
      expect(rows.map((row) => row['qty']), [3, 2]);
    });

    test('shows a placeholder when a sale has no items', () {
      final row = saleReportRow(rawSale(items: []))!;
      final rows = saleItemRows([row]);

      expect(rows, hasLength(1));
      expect(rows.single['product'], '-');
      expect(rows.single['unit'], '-');
      expect(rows.single['qty'], 0);
      expect(rows.single['amount'], 90.0);
    });
  });

  group('quantityByUnit', () {
    test('sums quantity only within the same unit', () {
      final first = saleReportRow(rawSale(invoice: 'A'))!;
      final second = saleReportRow(
        rawSale(
          invoice: 'B',
          items: [
            {
              'product': {
                'id': 3,
                'name': 'Gloves',
                'unit': {'id': 1, 'name': 'Piece', 'short_name': 'pcs'},
              },
              'qty': 4,
              'sale_price': '5.00',
              'subtotal': '20.00',
            },
          ],
        ),
      )!;

      final totals = quantityByUnit([first, second]);

      expect(totals['pcs'], 7);
      expect(totals['l'], 2);
    });

    test('keeps different units in separate buckets', () {
      final totals = quantityByUnit([saleReportRow(rawSale())!]);

      expect(totals, {'pcs': 3, 'l': 2});
    });
  });

  group('saleMatchesSearch', () {
    test('matches invoice and product name', () {
      final row = saleReportRow(rawSale())!;

      expect(saleMatchesSearch(row, 'sale-1'), isTrue);
      expect(saleMatchesSearch(row, 'helmet'), isTrue);
      expect(saleMatchesSearch(row, 'missing'), isFalse);
    });
  });

  group('mergeSaleItems', () {
    Map<String, dynamic> item({
      Object? productId = 1,
      required String product,
      required String unit,
      required int qty,
      required String price,
      required String amount,
    }) {
      return {
        'productId': productId,
        'product': product,
        'unit': unit,
        'qty': qty,
        'price': parseAmount(price),
        'amount': parseAmount(amount),
      };
    }

    test('sums quantity and amount for the same product', () {
      final merged = mergeSaleItems([
        item(
          product: 'Helmet',
          unit: 'pcs',
          qty: 2,
          price: '20.00',
          amount: '40.00',
        ),
        item(
          product: 'Helmet',
          unit: 'pcs',
          qty: 3,
          price: '20.00',
          amount: '60.00',
        ),
        item(product: 'Oil', unit: 'l', qty: 1, price: '15.00', amount: '15.00'),
      ]);

      expect(merged, hasLength(2));

      final helmet = merged.firstWhere((row) => row['product'] == 'Helmet');
      expect(helmet['qty'], 5);
      expect(helmet['amount'], 100.0);
      expect(helmet['price'], 20.0);
    });

    test('keeps the same product name apart when the unit differs', () {
      final merged = mergeSaleItems([
        item(product: 'Rope', unit: 'm', qty: 2, price: '5.00', amount: '10.00'),
        item(
          product: 'Rope',
          unit: 'roll',
          qty: 1,
          price: '50.00',
          amount: '50.00',
        ),
      ]);

      expect(merged, hasLength(2));
    });

    test('groups by product id when available', () {
      final merged = mergeSaleItems([
        item(
          productId: 7,
          product: 'Old name',
          unit: 'pcs',
          qty: 1,
          price: '10.00',
          amount: '10.00',
        ),
        item(
          productId: 7,
          product: 'New name',
          unit: 'pcs',
          qty: 2,
          price: '10.00',
          amount: '20.00',
        ),
      ]);

      expect(merged, hasLength(1));
      expect(merged.single['qty'], 3);
      expect(merged.single['amount'], 30.0);
    });
  });

  group('saleExportRows', () {
    test('writes one row per merged product with formatted values', () {
      final row = saleReportRow(
        rawSale(
          items: [
            {
              'product': {
                'id': 1,
                'name': 'Helmet',
                'unit': {'id': 1, 'name': 'Piece', 'short_name': 'pcs'},
              },
              'qty': 2,
              'sale_price': '20.00',
              'subtotal': '40.00',
            },
            {
              'product': {
                'id': 1,
                'name': 'Helmet',
                'unit': {'id': 1, 'name': 'Piece', 'short_name': 'pcs'},
              },
              'qty': 3,
              'sale_price': '20.00',
              'subtotal': '60.00',
            },
          ],
        ),
      )!;

      final rows = saleExportRows([row]);

      expect(rows, hasLength(1));
      expect(rows.single, [
        'SALE-1',
        '05 Nov 2026',
        'Helmet',
        5,
        'pcs',
        '20.00',
        '100.00',
        'Paid',
      ]);
    });

    test('exports a sale without items as a single summary row', () {
      final row = saleReportRow(rawSale(items: []))!;
      final rows = saleExportRows([row]);

      expect(rows, hasLength(1));
      expect(rows.single[2], '-');
      expect(rows.single[6], '90.00');
    });
  });

  }