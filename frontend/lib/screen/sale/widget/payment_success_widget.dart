import 'package:flutter/material.dart';
import 'package:frontend/controllers/report_export_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PaymentSuccessWidget extends StatefulWidget {
  const PaymentSuccessWidget({super.key, this.exportController});

  final ReportExportController? exportController;

  @override
  State<PaymentSuccessWidget> createState() => _PaymentSuccessWidgetState();
}

class _PaymentSuccessWidgetState extends State<PaymentSuccessWidget>
    with TickerProviderStateMixin {
  static const primaryBlue = Color(0xFF1479F2);
  static const darkNavy = Color(0xFF16215B);
  static const lightGrey = Color(0xFFF3F4F8);

  late final ReportExportController _exportController =
      widget.exportController ?? ReportExportController();
  final RxBool _exporting = false.obs;

  late final AnimationController _badgeController;
  late final AnimationController _checkController;
  late final AnimationController _sparkleController;
  late final AnimationController _contentController;

  late final Animation<double> _badgeScale;
  late final Animation<double> _checkScale;
  late final Animation<double> _checkOpacity;
  late final Animation<double> _sparkleOpacity;
  late final Animation<double> _sparkleScale;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();

    // Outer rings pop in with a slight overshoot
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScale = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.elasticOut,
    );

    // Checkmark scales/fades in after the badge
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutBack,
    );
    _checkOpacity = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeIn,
    );

    // Sparkles fade/pop in last, slightly staggered
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sparkleOpacity = CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeIn,
    );
    _sparkleScale = CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.elasticOut,
    );

    // Text + details slide up and fade in
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
        );
    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _badgeController.forward();
    if (!mounted) return;

    await _checkController.forward();
    if (!mounted) return;

    _sparkleController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    _contentController.forward();
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _checkController.dispose();
    _sparkleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawReceipt = Get.arguments;
    final receipt = rawReceipt is Map
        ? Map<String, dynamic>.from(rawReceipt)
        : <String, dynamic>{};
    final currency = receipt['currency'] is Map
        ? Map<String, dynamic>.from(receipt['currency'] as Map)
        : null;
    final paymentDate = DateTime.tryParse(
      receipt['payment_date']?.toString() ?? '',
    );
    final rows = _receiptRows(receipt, currency, paymentDate);

    return Scaffold(
      backgroundColor: lightGrey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),

              // Animated badge with sparkles
              SizedBox(
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _sparkle(
                      left: 30,
                      top: 20,
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.purple.shade300,
                        size: 22,
                      ),
                    ),
                    _sparkle(
                      right: 100,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.pinkAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    _sparkle(
                      left: 40,
                      bottom: 20,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.pinkAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    _sparkle(
                      right: 30,
                      bottom: 30,
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.pinkAccent,
                        size: 22,
                      ),
                    ),

                    ScaleTransition(
                      scale: _badgeScale,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryBlue.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    ScaleTransition(
                      scale: _badgeScale,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryBlue.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    ScaleTransition(
                      scale: _checkScale,
                      child: FadeTransition(
                        opacity: _checkOpacity,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryBlue,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              FadeTransition(
                opacity: _contentOpacity,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      const Text(
                        'Payment Successful',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your transaction has been completed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              FadeTransition(
                opacity: _contentOpacity,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        if (i == rows.length - 1) ...[
                          CustomPaint(
                            painter: _DashedLinePainter(),
                            child: const SizedBox(
                              width: double.infinity,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _detailRow(
                          '${rows[i][0]}:',
                          rows[i][1].toString(),
                          boldValue: i == rows.length - 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // --- Your original button block, untouched ---
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    if (receipt.isNotEmpty) ...[
                      Obx(() {
                        final busy = _exporting.value;

                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: busy
                                ? null
                                : () => _exportReceipt(
                                    receipt,
                                    currency,
                                    paymentDate,
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryBlue,
                              elevation: 0,
                              side: const BorderSide(
                                color: primaryBlue,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              busy ? 'Exporting...' : 'Export Receipt',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offNamedUntil(
                            AppRoutes.sale,
                            ModalRoute.withName(AppRoutes.home),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Back to Sale',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sparkle({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required Widget child,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: ScaleTransition(
        scale: _sparkleScale,
        child: FadeTransition(opacity: _sparkleOpacity, child: child),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool boldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: boldValue ? 18 : 14,
            fontWeight: boldValue ? FontWeight.bold : FontWeight.w600,
            color: darkNavy,
          ),
        ),
      ],
    );
  }

  Future<void> _exportReceipt(
    Map<String, dynamic> receipt,
    Map<String, dynamic>? currency,
    DateTime? paymentDate,
  ) async {
    if (_exporting.value) return;

    _exporting.value = true;
    try {
      final transactionId = receipt['transaction_id']?.toString() ?? '';
      final path = await _exportController.exportPdf(
        title: 'Sale Receipt $transactionId'.trim(),
        headers: const ['Field', 'Value'],
        rows: _receiptRows(receipt, currency, paymentDate),
        pageFormat: null,
        summaryTotal: null,
      );

      if (!mounted) return;
      if (path != null) {
        ToastWidget.show(
          message: 'PDF saved to:\n$path',
          type: ToastType.success,
        );
      }
    } catch (error) {
      if (!mounted) return;
      ToastWidget.show(
        title: 'Export Error',
        message: error.toString(),
        type: ToastType.error,
      );
    } finally {
      _exporting.value = false;
    }
  }

  List<List<dynamic>> _receiptRows(
    Map<String, dynamic> receipt,
    Map<String, dynamic>? currency,
    DateTime? paymentDate,
  ) {
    return [
      ['Customer', receipt['customer']?.toString() ?? '—'],
      ['Payment Method', receipt['payment_method']?.toString() ?? '—'],
      ['Date', DateFormatter.formatDateTime(paymentDate?.toLocal())],
      ['Transaction ID', receipt['transaction_id']?.toString() ?? '—'],
      ['Subtotal', _formatAmount(receipt['subtotal'], currency)],
      ['Total', _formatAmount(receipt['total'], currency)],
    ];
  }

  String _formatAmount(Object? value, Map<String, dynamic>? currency) {
    final amount = double.tryParse(value?.toString() ?? '') ?? 0;
    return CurrencyFormatter.format(amount, currency);
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
