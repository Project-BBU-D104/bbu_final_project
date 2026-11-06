import 'package:intl/intl.dart';

/// Helpers for the sales report.
///
/// The API serializes Decimal fields as strings (e.g. "150.00"), so money
/// values are parsed defensively instead of being cast to `num`.
double parseAmount(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

int _parseQty(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

String capitalizeLabel(String? value) {
  if (value == null || value.isEmpty) return '';
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

/// Maps one raw sale from `GET /sale` into the row shape used by the report.
///
/// Returns null when the sale should not be reported: soft-deleted,
/// cancelled, or missing a parseable sale date.
Map<String, dynamic>? saleReportRow(Map<String, dynamic> sale) {
  if (sale['deleted_at'] != null) return null;
  if ((sale['status'] ?? '').toString().toLowerCase() == 'cancelled') {
    return null;
  }

  final date = DateTime.tryParse(sale['sale_date']?.toString() ?? '');
  if (date == null) return null;

  final items = <Map<String, dynamic>>[];

  final rawItems = sale['sale_items'];
  if (rawItems is List) {
    for (final rawItem in rawItems) {
      if (rawItem is! Map) continue;

      final product = rawItem['product'];
      final unit = product is Map ? product['unit'] : null;

      items.add({
        'productId': product is Map ? product['id'] : null,
        'product': product is Map ? (product['name'] ?? '').toString() : '',
        'unit': unit is Map
            ? (unit['short_name'] ?? unit['name'] ?? '').toString()
            : '',
        'qty': _parseQty(rawItem['qty']),
        'price': parseAmount(rawItem['sale_price']),
        'amount': parseAmount(rawItem['subtotal']),
      });
    }
  }

  return {
    'invoice': (sale['invoice_no'] ?? '').toString(),
    'customer': sale['customer'] is Map
        ? (sale['customer']['name'] ?? '').toString()
        : '',
    'date': date,
    'total': parseAmount(sale['total_amount']),
    'status': capitalizeLabel(sale['payment_status']?.toString()),
    'items': items,
  };
}

/// Expands sale rows into one row per product sold.
///
/// A sale without line items still gets a placeholder row so its total is
/// not silently lost from the report.
List<Map<String, dynamic>> saleItemRows(List<Map<String, dynamic>> sales) {
  final rows = <Map<String, dynamic>>[];

  for (final sale in sales) {
    final items = sale['items'] as List? ?? const [];

    if (items.isEmpty) {
      rows.add({
        'invoice': sale['invoice'],
        'customer': sale['customer'],
        'date': sale['date'],
        'total': sale['total'],
        'status': sale['status'],
        'product': '-',
        'unit': '-',
        'qty': 0,
        'price': 0.0,
        'amount': sale['total'],
      });
      continue;
    }

    for (final item in items) {
      final data = item as Map<String, dynamic>;
      rows.add({
        'invoice': sale['invoice'],
        'date': sale['date'],
        'total': sale['total'],
        'status': sale['status'],
        'product': data['product'],
        'unit': data['unit'],
        'qty': data['qty'],
        'price': data['price'],
        'amount': data['amount'],
      });
    }
  }

  return rows;
}

/// Sums quantities per unit.
///
/// Products can use different units, so quantities are never added across
/// units: each unit gets its own bucket.
const List<String> salesExportHeaders = [
  'Invoice',
  'Customer',
  'Date',
  'Product',
  'Qty',
  'Unit',
  'Price',
  'Amount',
  'Status',
];

final DateFormat _exportDateFormat = DateFormat('dd MMM yyyy');
final NumberFormat _exportMoneyFormat = NumberFormat('#,##0.00');

/// Flattens the report into export rows: one line per product, with
/// duplicate products inside the same invoice already merged.
List<List<dynamic>> saleExportRows(List<Map<String, dynamic>> sales) {
  final rows = <List<dynamic>>[];

  for (final sale in sales) {
    final items = mergeSaleItems(sale['items'] as List? ?? const []);
    final rawDate = sale['date'];
    final date = rawDate is DateTime
        ? _exportDateFormat.format(rawDate)
        : (rawDate ?? '').toString();

    if (items.isEmpty) {
      rows.add([
        sale['invoice'],
        sale['customer'],
        date,
        '-',
        0,
        '-',
        '-',
        _exportMoneyFormat.format(parseAmount(sale['total'])),
        sale['status'],
      ]);
      continue;
    }

    for (final item in items) {
      final unit = (item['unit'] ?? '').toString().trim();
      rows.add([
        sale['invoice'],
        sale['customer'],
        date,
        item['product'],
        item['qty'],
        unit.isEmpty ? '-' : unit,
        _exportMoneyFormat.format(parseAmount(item['price'])),
        _exportMoneyFormat.format(parseAmount(item['amount'])),
        sale['status'],
      ]);
    }
  }

  return rows;
}

/// Collapses duplicate lines of the same product inside one sale.
///
/// Lines are grouped by product id when the API provides one, otherwise by
/// product name, and always by unit. Quantity and amount are summed within a
/// group; the unit price becomes amount / quantity so mixed line prices stay
/// consistent.
List<Map<String, dynamic>> mergeSaleItems(List<dynamic> items) {
  final merged = <String, Map<String, dynamic>>{};

  for (final rawItem in items) {
    if (rawItem is! Map) continue;

    final product = (rawItem['product'] ?? '').toString();
    final unit = (rawItem['unit'] ?? '').toString().trim();
    final productId = rawItem['productId'];
    final key = '${productId ?? product}|$unit';

    final qty = _parseQty(rawItem['qty']);
    final amount = parseAmount(rawItem['amount']);

    final existing = merged[key];
    if (existing == null) {
      merged[key] = {
        'productId': productId,
        'product': product,
        'unit': unit,
        'qty': qty,
        'amount': amount,
        'price': parseAmount(rawItem['price']),
      };
    } else {
      existing['qty'] = (existing['qty'] as int) + qty;
      existing['amount'] = (existing['amount'] as double) + amount;
    }
  }

  for (final row in merged.values) {
    final qty = row['qty'] as int;
    final amount = row['amount'] as double;
    if (qty > 0) {
      row['price'] = amount / qty;
    }
  }

  return merged.values.toList();
}

Map<String, int> quantityByUnit(List<Map<String, dynamic>> sales) {
  final totals = <String, int>{};

  for (final sale in sales) {
    final items = sale['items'] as List? ?? const [];

    for (final item in items) {
      final data = item as Map<String, dynamic>;
      final unit = (data['unit'] ?? '').toString().trim();
      final qty = _parseQty(data['qty']);

      if (unit.isEmpty || qty <= 0) continue;

      totals.update(unit, (value) => value + qty, ifAbsent: () => qty);
    }
  }

  return totals;
}

/// Whether a sale row matches the free-text search: invoice or any product
/// name.
bool saleMatchesSearch(Map<String, dynamic> sale, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return true;

  final invoice = (sale['invoice'] ?? '').toString().toLowerCase();

  if (invoice.contains(normalized)) {
    return true;
  }

  final customer = (sale['customer'] ?? '').toString().toLowerCase();
  if (customer.contains(normalized)) {
    return true;
  }

  final items = sale['items'] as List? ?? const [];
  for (final item in items) {
    final product = item is Map ? (item['product'] ?? '') : '';
    if (product.toString().toLowerCase().contains(normalized)) {
      return true;
    }
  }

  return false;
}