import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TestProductScannerPage extends StatefulWidget {
  const TestProductScannerPage({super.key});

  @override
  State<TestProductScannerPage> createState() =>
      _TestProductScannerPageState();
}

class _TestProductScannerPageState extends State<TestProductScannerPage> {
  final MobileScannerController controller = MobileScannerController();

  bool scanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Product"),
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          if (scanned) return;

          if (capture.barcodes.isEmpty) return;

          final barcode = capture.barcodes.first;

          if (barcode.rawValue == null) return;

          scanned = true;

          Navigator.pop(context, barcode.rawValue);
        },
      ),
    );
  }
} 