import 'package:flutter/material.dart';
import 'package:frontend/screen/report/pdf_preview_screen.dart';
import 'package:frontend/services/export_service.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';

class ReportExportData {
  const ReportExportData({
    required this.title,
    required this.headers,
    required this.rows,
    this.notes = const [],
  });

  final String title;
  final List<String> headers;
  final List<List<dynamic>> rows;
  final List<String> notes;
}

/// Takes a snapshot of the currently filtered report when an action is chosen.
class ReportExportMenu extends StatefulWidget {
  const ReportExportMenu({
    super.key,
    required this.buildData,
    this.enabled = true,
  });

  final ReportExportData Function() buildData;
  final bool enabled;

  @override
  State<ReportExportMenu> createState() => _ReportExportMenuState();
}

class _ReportExportMenuState extends State<ReportExportMenu> {
  bool _busy = false;

  Future<void> _handle(String action) async {
    final data = widget.buildData();
    if (data.rows.isEmpty) {
      ToastWidget.show(
        message: 'No report data to export.'.tr,
        type: ToastType.error,
      );
      return;
    }
    final format = data.headers.length >= 6
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;
    if (action == 'preview') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PdfPreviewScreen(
            title: data.title,
            headers: data.headers,
            rows: data.rows,
            notes: data.notes,
            initialPageFormat: format,
          ),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final path = action == 'pdf'
          ? await ExportService.exportPdf(
              title: data.title,
              headers: data.headers,
              rows: data.rows,
              notes: data.notes,
              pageFormat: format,
            )
          : await ExportService.exportExcel(
              title: data.title,
              headers: data.headers,
              rows: data.rows,
              notes: data.notes,
            );
      if (mounted && path != null) {
        ToastWidget.show(
          message: '${'Report saved to:'.tr}\n$path',
          type: ToastType.success,
        );
      }
    } catch (error) {
      if (mounted) {
        ToastWidget.show(
          message: '${'Export Error'.tr}: $error',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return PopupMenuButton<String>(
      enabled: widget.enabled,
      tooltip: 'Export / Print'.tr,
      icon: const Icon(Icons.print_outlined),
      onSelected: _handle,
      itemBuilder: (context) => [
        PopupMenuItem(value: 'preview', child: Text('Print Preview'.tr)),
        PopupMenuItem(value: 'pdf', child: Text('Export PDF'.tr)),
        PopupMenuItem(value: 'excel', child: Text('Export Excel'.tr)),
      ],
    );
  }
}
