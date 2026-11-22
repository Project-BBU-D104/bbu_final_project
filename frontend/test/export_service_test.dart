import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/export_service.dart';
import 'package:pdf/pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('saved workbook has only the Report sheet and it is the default', () {
    final excel = ExportService.buildExcelWorkbook(
      title: 'Sales Report',
      headers: const ['Invoice'],
      rows: [
        ['SALE-1'],
      ],
    );

    // Sheet metadata is written at save time, so assert on the saved bytes.
    final saved = Excel.decodeBytes(excel.save()!);

    expect(saved.tables.keys, ['Report']);
    expect(saved.getDefaultSheet(), 'Report');
  });

  test('writes numbers as numeric cells', () {
    final excel = ExportService.buildExcelWorkbook(
      title: 'Sales Report',
      headers: const ['Qty', 'Amount'],
      rows: [
        [3, 20.5],
      ],
    );

    final last = excel.tables['Report']!.rows.last;
    expect(last[0]?.value, const IntCellValue(3));
    expect(last[1]?.value, const DoubleCellValue(20.5));
  });

  test('includes report notes before the column headers', () {
    final excel = ExportService.buildExcelWorkbook(
      title: 'Stock Ledger',
      headers: const ['Product', 'In'],
      rows: const [
        ['Item', 2.5],
      ],
      notes: const ['Stock movements do not include a running balance.'],
    );
    final rows = excel.tables['Report']!.rows;
    final headerIndex = rows.indexWhere(
      (row) => row.first?.value == TextCellValue('Product'),
    );
    expect(headerIndex, greaterThan(0));
    expect(
      rows[headerIndex - 1].first?.value,
      TextCellValue('Stock movements do not include a running balance.'),
    );
    expect(rows[headerIndex + 1][1]?.value, const DoubleCellValue(2.5));
  });

  test('generates a landscape PDF with Khmer text and report notes', () async {
    final bytes = await ExportService.generatePdf(
      title: 'របាយការណ៍ស្តុក',
      headers: const [
        'Date',
        'Product',
        'Warehouse',
        'Type',
        'Reference',
        'In',
        'Out',
        'Unit',
        'Note',
      ],
      rows: List.generate(
        40,
        (index) => [
          '01 Jan 2026',
          'ផលិតផល',
          'Main',
          'Purchase',
          'INV-$index',
          1.5,
          0,
          'pcs',
          '',
        ],
      ),
      notes: const ['No running balance is shown.'],
      pageFormat: PdfPageFormat.a4.landscape,
    );
    expect(bytes.take(4), [0x25, 0x50, 0x44, 0x46]);
  });
}
