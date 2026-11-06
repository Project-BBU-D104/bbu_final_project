import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Company details used by the on-screen letterhead, PDF export and Excel
/// export. Edit [defaultLetterHead] to match your business.
class LetterHeadData {
  const LetterHeadData({
    this.companyName = 'ePOS App',
    this.tagline = 'Point of Sale & Inventory Management',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.logoAsset = 'assets/icon/logo.jpg',
    this.accentColor = 0xFF1565C0,
  });

  final String companyName;
  final String tagline;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String logoAsset;

  /// ARGB value, e.g. 0xFF1565C0.
  final int accentColor;

  Color get color => Color(accentColor);

  PdfColor get pdfColor => PdfColor.fromInt(accentColor);

  /// Address / phone / email / website, skipping empty values.
  List<String> get contactLines => [
    if (address.trim().isNotEmpty) address.trim(),
    if (phone.trim().isNotEmpty) 'Tel: ${phone.trim()}',
    if (email.trim().isNotEmpty) 'Email: ${email.trim()}',
    if (website.trim().isNotEmpty) website.trim(),
  ];
}

const LetterHeadData defaultLetterHead = LetterHeadData();

/// On-screen letterhead used by report previews.
class LetterHeadWidget extends StatelessWidget {
  const LetterHeadWidget({
    super.key,
    this.data = defaultLetterHead,
    this.compact = false,
  });

  final LetterHeadData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final contact = data.contactLines.join('   |   ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: data.color, width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.logoAsset.trim().isNotEmpty) ...[
            Image.asset(
              data.logoAsset,
              width: compact ? 40 : 50,
              height: compact ? 40 : 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.companyName,
                  style: TextStyle(
                    fontSize: compact ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: data.color,
                  ),
                ),
                if (data.tagline.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    data.tagline,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (contact.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact,
                    style: TextStyle(
                      fontSize: compact ? 10 : 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Builds the PDF page header: logo, company details, report title and rule.
Future<pw.Widget> buildPdfLetterHead({
  required String title,
  LetterHeadData data = defaultLetterHead,
}) async {
  final logo = await _loadLogo(data.logoAsset);
  final contact = data.contactLines;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (logo != null) ...[
            pw.Container(
              width: 50,
              height: 50,
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 12),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  data.companyName,
                  style: pw.TextStyle(
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                    color: data.pdfColor,
                  ),
                ),
                if (data.tagline.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    data.tagline,
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
                if (contact.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    contact.join('   |   '),
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                title,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Generated ${_formatDate(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Container(height: 2, color: data.pdfColor),
      pw.SizedBox(height: 12),
    ],
  );
}

/// Letterhead rows to put at the top of an Excel sheet.
List<List<dynamic>> excelLetterHeadRows([
  LetterHeadData data = defaultLetterHead,
]) {
  final contact = data.contactLines.join('   |   ');

  return [
    [data.companyName],
    if (data.tagline.trim().isNotEmpty) [data.tagline],
    if (contact.isNotEmpty) [contact],
    const <dynamic>[],
  ];
}

Future<pw.MemoryImage?> _loadLogo(String asset) async {
  if (asset.trim().isEmpty) return null;

  try {
    final data = await rootBundle.load(asset);
    return pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) {
    // A missing or unreadable logo must never break an export.
    return null;
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}