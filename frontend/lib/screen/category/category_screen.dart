import 'package:flutter/material.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});

  final ctr = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Category")),
      body: Center(child: Text("Category Screen")),
    );
  }
}