
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:frontend/widget/letter_head_widget.dart';

class ExportService {
  // ==========================================
  // 1. EXPORT EXCEL
  // ==========================================

  static Future<String?> exportExcel({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
    LetterHeadData letterhead = defaultLetterHead,
  }) async {
    final excel = Excel.createExcel();

    final sheet = excel['Report'];

    // Company letterhead
    for (final row in excelLetterHeadRows(letterhead)) {
      sheet.appendRow(
        row.map((value) => TextCellValue(value?.toString() ?? '')).toList(),
      );
    }

    // Add title
    sheet.appendRow([
      TextCellValue(title),
    ]);

    // Add headers
    sheet.appendRow(
      headers.map((e) => TextCellValue(e)).toList(),
    );

    // Add data
    for (final row in rows) {
      sheet.appendRow(
        row.map(
          (value) => TextCellValue(
            value?.toString() ?? '',
          ),
        ).toList(),
      );
    }

    final bytes = excel.save();

    if (bytes == null) {
      throw Exception('Cannot generate Excel file');
    }

    return _saveFile(
      fileName: '${_safeName(title)}.xlsx',
      bytes: Uint8List.fromList(bytes),
      dialogTitle: 'Save Excel Report',
      extension: 'xlsx',
    );
  }

  // ==========================================
  // 2. GENERATE PDF
  // ==========================================

  static Future<Uint8List> generatePdf({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
    PdfPageFormat? pageFormat,
    LetterHeadData letterhead = defaultLetterHead,
    bool showSummary = false,
  }) async {
    final pdf = pw.Document();
    final letterheadWidget = await buildPdfLetterHead(
      title: title,
      data: letterhead,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat ?? PdfPageFormat.a4,

        margin: const pw.EdgeInsets.all(25),

        // PDF HEADER / LETTERHEAD
        header: (context) => letterheadWidget,

        // PDF FOOTER
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(
              top: 15,
            ),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 9,
              ),
            ),
          );
        },

        // PDF CONTENT
        build: (context) {
          return [
            pw.TableHelper.fromTextArray(
              headers: headers,

              data: rows.map((row) {
                return row.map(
                  (value) => value?.toString() ?? '',
                ).toList();
              }).toList(),

              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),

              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey800,
              ),

              cellStyle: const pw.TextStyle(
                fontSize: 10,
              ),

              cellAlignment: pw.Alignment.centerLeft,

              headerAlignment: pw.Alignment.centerLeft,

              cellPadding: const pw.EdgeInsets.all(8),
            ),
            if (showSummary) _buildSummary(rows),
          ];
        },
      ),
    );

    // FIX: RETURN Uint8List
    final bytes = await pdf.save();

    return Uint8List.fromList(bytes);
  }

  // ==========================================
  // 3. EXPORT PDF
  // ==========================================

  static Future<String?> exportPdf({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
    PdfPageFormat? pageFormat,
    bool showSummary = false,
  }) async {
    final bytes = await generatePdf(
      title: title,
      headers: headers,
      rows: rows,
      pageFormat: pageFormat,
      showSummary: showSummary,
    );

    return _saveFile(
      fileName: '${_safeName(title)}.pdf',
      bytes: bytes,
      dialogTitle: 'Save PDF Report',
      extension: 'pdf',
    );
  }

  // ==========================================
  // 4. PRINT PDF
  // ==========================================

  static Future<void> printPdf({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final bytes = await generatePdf(
      title: title,
      headers: headers,
      rows: rows,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: '${_safeName(title)}.pdf',
    );
  }

  // ==========================================
  // 5. PDF PREVIEW
  // ==========================================

  static Future<void> previewPdf({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final bytes = await generatePdf(
      title: title,
      headers: headers,
      rows: rows,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: '${_safeName(title)}.pdf',
    );
  }

  // ==========================================
  // 6. PDF TOTAL SUMMARY
  // ==========================================

  static pw.Widget _buildSummary(List<List<dynamic>> rows) {
    var total = 0.0;
    for (final row in rows) {
      if (row.length > 6) {
        total += _parseNumber(row[6]);
      }
    }

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 320,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1.3),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Total Amount',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    '\$${NumberFormat('#,##0.00').format(total)}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static double _parseNumber(dynamic value) {
    return double.tryParse(
          value?.toString().replaceAll(',', '').trim() ?? '',
        ) ??
        0;
  }

  // ==========================================
  // 7. SAVE FILE (desktop uses a Save As dialog)
  // ==========================================

  static Future<String?> _saveFile({
    required String fileName,
    required Uint8List bytes,
    required String dialogTitle,
    required String extension,
  }) async {
    // Mobile: saveFile writes the bytes itself and returns the saved path.
    if (Platform.isAndroid || Platform.isIOS) {
      return FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [extension],
        bytes: bytes,
      );
    }

    // Desktop: saveFile only returns the chosen path, so write it here.
    final path = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [extension],
      lockParentWindow: true,
    );
    if (path == null) return null;

    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  // ==========================================
  // 7. SAFE FILE NAME
  // ==========================================

  static String _safeName(String name) {
    return name
        .replaceAll(
          RegExp(r'[<>:"/\\|?*]'),
          '_',
        )
        .replaceAll(' ', '_');
  }
}
