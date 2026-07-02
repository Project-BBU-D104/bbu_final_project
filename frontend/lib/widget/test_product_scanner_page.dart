import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TestProductScannerPage extends StatefulWidget {
  const TestProductScannerPage({super.key});

  @override
  State<TestProductScannerPage> createState() =>
      _TestProductScannerPageState();
}

class _TestProductScannerPageState extends State<TestProductScannerPage> {
  late final MobileScannerController controller;

  bool scanned = false;

  @override
  void initState() {
    super.initState();

    controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      formats: BarcodeFormat.values,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
  if (scanned) return;

  if (capture.barcodes.isEmpty) return;

  final value = capture.barcodes.first.rawValue;

  if (value == null || value.isEmpty) return;

  scanned = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("Scan Result"),
        content: Text(value),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog

              // Allow scanning again
              scanned = false;
            },
            child: const Text("Scan Again"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, value); // Return value and close scanner
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Product"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              controller.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () {
              controller.switchCamera();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // Scanner overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Place the QR code or barcode inside the box",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}