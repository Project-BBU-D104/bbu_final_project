
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:frontend/services/export_service.dart';

class ReportExportController extends GetxController {
  final isExporting = false.obs;

  Future<String?> exportExcel({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    String? savedPath;
    await _run(() async {
      savedPath = await ExportService.exportExcel(
        title: title,
        headers: headers,
        rows: rows,
      );
    });
    return savedPath;
  }

  Future<String?> exportPdf({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
    PdfPageFormat? pageFormat,
    bool showSummary = false,
  }) async {
    String? savedPath;
    await _run(() async {
      savedPath = await ExportService.exportPdf(
        title: title,
        headers: headers,
        rows: rows,
        pageFormat: pageFormat,
        showSummary: showSummary,
      );
    });
    return savedPath;
  }

  Future<void> printPdf({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    await _run(() async {
      await ExportService.printPdf(
        title: title,
        headers: headers,
        rows: rows,
      );
    });
  }

  Future<void> _run(
    Future<void> Function() action,
  ) async {
    if (isExporting.value) return;

    try {
      isExporting.value = true;

      await action();

    } catch (e) {
      Get.snackbar(
        'Export Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
    }
  }
}
