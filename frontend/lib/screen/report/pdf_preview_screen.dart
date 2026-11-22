import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:frontend/services/export_service.dart';
import 'package:frontend/widget/letter_head_widget.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<dynamic>> rows;
  final double? summaryTotal;
  final List<String> notes;
  final PdfPageFormat initialPageFormat;

  const PdfPreviewScreen({
    super.key,
    required this.title,
    required this.headers,
    required this.rows,
    this.summaryTotal,
    this.notes = const [],
    this.initialPageFormat = PdfPageFormat.a4,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '$title Preview',
        showBack: true,
        onBack: () {
          Navigator.pop(context);
        },
      ),

      body: PdfPreview(
        initialPageFormat: initialPageFormat,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: true,
        canChangePageFormat: true,

        build: (format) async {
          final bytes = await ExportService.generatePdf(
            title: title,
            headers: headers,
            rows: rows,
            notes: notes,
            pageFormat: format,
            letterhead: defaultLetterHead,
            summaryTotal: summaryTotal,
          );

          return Uint8List.fromList(bytes);
        },
      ),
    );
  }
}
