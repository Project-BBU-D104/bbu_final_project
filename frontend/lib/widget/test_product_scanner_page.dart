import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TestProductScannerPage extends StatefulWidget {
  final bool returnImmediately;

  const TestProductScannerPage({super.key, this.returnImmediately = false});

  @override
  State<TestProductScannerPage> createState() => _TestProductScannerPageState();
}

class _TestProductScannerPageState extends State<TestProductScannerPage>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController controller;
  late final AnimationController _scanLineController;

  final productController = Get.put(ProductController());

  bool scanned = false;

  @override
  void initState() {
    super.initState();

    controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      formats: BarcodeFormat.values,
    );

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (scanned) return;
    if (capture.barcodes.isEmpty) return;

    final value = capture.barcodes.first.rawValue;

    if (value == null || value.isEmpty) return;

    scanned = true;

    if (widget.returnImmediately) {
      controller.stop();
      Navigator.pop(context, value);
      return;
    }

    final product = productController.findByBarcode(value);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(product != null ? "Product Found" : "Not Found"),
          content: product != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${product['name']}"),
                    Text("Barcode: ${product['barcode']}"),
                    Text("Price: ${product['salePrice']}"),
                    Text("Stock: ${product['qty']}"),
                  ],
                )
              : Text("No product found for:\n$value"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                scanned = false;
              },
              child: const Text("Scan Again"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, value);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    // also update controller state
    productController.onBarcodeScanned(value);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text(
          "Scan Barcode",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          tooltip: "Close",
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: controller,
            builder: (context, state, _) {
              final isTorchOn = state.torchState == TorchState.on;

              return IconButton(
                tooltip: isTorchOn
                    ? "Turn off flashlight"
                    : "Turn on flashlight",
                icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
                onPressed: () => controller.toggleTorch(),
              );
            },
          ),
          IconButton(
            tooltip: "Switch camera",
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => controller.switchCamera(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanSize = math.min(
            math.min(constraints.maxWidth * 0.74, constraints.maxHeight * 0.42),
            300.0,
          );

          final scanWindow = Rect.fromCenter(
            center: Offset(
              constraints.maxWidth / 2,
              constraints.maxHeight / 2 - 24,
            ),
            width: scanSize,
            height: scanSize,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: controller,
                onDetect: _onDetect,
                placeholderBuilder: (context) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1DB584)),
                ),
                errorBuilder: (context, error) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.no_photography_outlined,
                          color: Colors.white70,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Unable to open the camera.\n${error.errorCode.name}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Dimmed background with a clear scan window.
              CustomPaint(
                painter: _ScannerOverlayPainter(scanWindow: scanWindow),
              ),

              /// Animated scan line inside the window.
              Positioned.fromRect(
                rect: scanWindow,
                child: _ScanLine(animation: _scanLineController),
              ),

              /// Bottom instruction.
              Positioned(
                left: 24,
                right: 24,
                bottom: bottomPadding + 28,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: Color(0xFF1DB584),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Align the barcode inside the frame",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Scanning happens automatically",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScanLine extends StatelessWidget {
  const _ScanLine({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Align(
            alignment: Alignment(0, animation.value * 2 - 1),
            child: Container(
              width: double.infinity,
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1DB584).withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1DB584).withValues(alpha: 0.55),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({required this.scanWindow});

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    /// Dark scrim with a transparent cut-out for the scan window.
    final scrim = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(scanWindow, const Radius.circular(18)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      scrim,
      Paint()..color = Colors.black.withValues(alpha: 0.60),
    );

    /// Green corner brackets.
    const corner = 30.0;

    final left = scanWindow.left;
    final top = scanWindow.top;
    final right = scanWindow.right;
    final bottom = scanWindow.bottom;

    final corners = Path()
      ..moveTo(left, top + corner)
      ..lineTo(left, top)
      ..lineTo(left + corner, top)
      ..moveTo(right - corner, top)
      ..lineTo(right, top)
      ..lineTo(right, top + corner)
      ..moveTo(right, bottom - corner)
      ..lineTo(right, bottom)
      ..lineTo(right - corner, bottom)
      ..moveTo(left + corner, bottom)
      ..lineTo(left, bottom)
      ..lineTo(left, bottom - corner);

    canvas.drawPath(
      corners,
      Paint()
        ..color = const Color(0xFF1DB584)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow;
  }
}
