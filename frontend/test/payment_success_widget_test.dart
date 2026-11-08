import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/report_export_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/sale/widget/payment_success_widget.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';

class ExportCall {
  ExportCall({
    required this.title,
    required this.headers,
    required this.rows,
    required this.pageFormat,
    required this.summaryTotal,
  });

  final String title;
  final List<String> headers;
  final List<List<dynamic>> rows;
  final PdfPageFormat? pageFormat;
  final double? summaryTotal;
}

class FakeReportExportController extends ReportExportController {
  final calls = <ExportCall>[];
  String? result;
  Object? error;
  Completer<String?>? held;

  @override
  Future<String?> exportPdf({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
    PdfPageFormat? pageFormat,
    double? summaryTotal,
  }) async {
    calls.add(
      ExportCall(
        title: title,
        headers: headers,
        rows: rows,
        pageFormat: pageFormat,
        summaryTotal: summaryTotal,
      ),
    );
    isExporting.value = true;

    try {
      if (held != null) return await held!.future;
      if (error != null) throw error!;
      return result;
    } finally {
      isExporting.value = false;
    }
  }
}

const receipt = <String, dynamic>{
  'customer': 'Alice',
  'payment_method': 'Cash',
  'payment_date': '2026-11-08T04:30:00.000Z',
  'transaction_id': 'SALE-1',
  'subtotal': 8.0,
  'total': 10.0,
  'currency': {'symbol': '\$', 'code': 'USD'},
};

Widget app(ReportExportController controller) {
  return GetMaterialApp(
    initialRoute: '/',
    getPages: [
      GetPage(name: '/', page: () => const Scaffold(body: Text('home'))),
      GetPage(
        name: AppRoutes.paymentSuccess,
        page: () => PaymentSuccessWidget(exportController: controller),
      ),
    ],
  );
}

Future<void> openSuccess(
  WidgetTester tester,
  FakeReportExportController fake,
  Map<String, dynamic> arguments,
) async {
  await tester.pumpWidget(app(fake));
  Get.toNamed(AppRoutes.paymentSuccess, arguments: arguments);
  await tester.pumpAndSettle();
}

void setLargeView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> settleToast(WidgetTester tester) async {
  Get.closeAllSnackbars();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  tearDown(() {
    Get.closeAllSnackbars();
    Get.reset();
  });

  testWidgets('does not run animations after the widget is disposed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: PaymentSuccessWidget()));

    // Let the badge and check animations finish, then stop during the
    // sequence's 100ms delay before it starts the content animation.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 50));

    // Simulate leaving the success screen before the sequence finishes.
    await tester.pumpWidget(const SizedBox());

    // Give the pending delay a chance to resume and call forward().
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.takeException(), isNull);
  });

  testWidgets('hides Export Receipt when there are no receipt arguments', (
    tester,
  ) async {
    setLargeView(tester);
    final fake = FakeReportExportController();

    await openSuccess(tester, fake, {});

    expect(find.text('Export Receipt'), findsNothing);
    expect(find.text('Back to Sale'), findsOneWidget);
  });

  testWidgets('exports one summary PDF for a fixed receipt', (tester) async {
    setLargeView(tester);
    final fake = FakeReportExportController()..result = '/receipt.pdf';

    await openSuccess(tester, fake, receipt);
    await tester.tap(find.text('Export Receipt'));
    await tester.pump();

    expect(fake.calls, hasLength(1));
    final call = fake.calls.single;
    expect(call.title, 'Sale Receipt SALE-1');
    expect(call.headers, ['Field', 'Value']);

    final paymentDate = DateTime.parse(
      receipt['payment_date']! as String,
    ).toLocal();
    expect(call.rows, [
      ['Customer', 'Alice'],
      ['Payment Method', 'Cash'],
      ['Date', DateFormatter.formatDateTime(paymentDate)],
      ['Transaction ID', 'SALE-1'],
      ['Subtotal', '\$8.00'],
      ['Total', '\$10.00'],
    ]);
    expect(call.pageFormat, isNull);
    expect(call.summaryTotal, isNull);

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('PDF saved to:\n/receipt.pdf'), findsOneWidget);
    await settleToast(tester);
  });

  testWidgets('shows no success toast when export is cancelled', (
    tester,
  ) async {
    setLargeView(tester);
    final fake = FakeReportExportController()..result = null;

    await openSuccess(tester, fake, receipt);
    await tester.tap(find.text('Export Receipt'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(fake.calls, hasLength(1));
    expect(find.textContaining('PDF saved to:'), findsNothing);
    expect(find.text('Export Receipt'), findsOneWidget);
  });

  testWidgets('shows Export Error and resets loading when export fails', (
    tester,
  ) async {
    setLargeView(tester);
    final fake = FakeReportExportController()
      ..error = Exception('disk full');

    await openSuccess(tester, fake, receipt);
    await tester.tap(find.text('Export Receipt'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Export Error'), findsOneWidget);
    expect(find.text('Exporting...'), findsNothing);
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Export Receipt'),
    );
    expect(button.onPressed, isNotNull);
    await settleToast(tester);
  });

  testWidgets('held export disables the button and ignores duplicate taps', (
    tester,
  ) async {
    setLargeView(tester);
    final fake = FakeReportExportController()
      ..held = Completer<String?>();

    await openSuccess(tester, fake, receipt);

    await tester.tap(find.text('Export Receipt'));
    await tester.pump();

    expect(find.text('Exporting...'), findsOneWidget);
    final busyButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Exporting...'),
    );
    expect(busyButton.onPressed, isNull);

    await tester.tap(find.text('Exporting...'), warnIfMissed: false);
    await tester.pump();
    expect(fake.calls, hasLength(1));

    fake.held!.complete('/receipt.pdf');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('PDF saved to:\n/receipt.pdf'), findsOneWidget);
    await settleToast(tester);
  });
}
