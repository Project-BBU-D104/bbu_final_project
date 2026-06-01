import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:get/get.dart';

class ProductScreen extends StatelessWidget {
  ProductScreen({super.key});

  final ctr = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product")),
      body: Center(child: Text("Product Screen")),
    );
  }
}