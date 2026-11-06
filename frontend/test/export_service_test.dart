import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/export_service.dart';

void main() {
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
}