import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:frontend/controllers/product_controller.dart';

class TestProductScannerPage extends StatefulWidget {
  const TestProductScannerPage({super.key});

  @override
  State<TestProductScannerPage> createState() =>
      _TestProductScannerPageState();
}

class _TestProductScannerPageState extends State<TestProductScannerPage> {
  late final MobileScannerController controller;

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

    final product = productController.findByBarcode(value);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            product != null ? "Product Found" : "Not Found",
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Product"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
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
                "Place barcode inside box",
                style: TextStyle(
                  color: Colors.white,
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