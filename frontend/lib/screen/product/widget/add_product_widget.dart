import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/screen/product/widget/product_form_widget.dart';
import 'package:get/get.dart';

/// Route adapter for '/add-product'; the shared form owns the UI.
class AddProductWidget extends StatelessWidget {
  AddProductWidget({super.key});

  final ctr = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return ProductFormWidget(
      controller: ctr,
      title: 'Add Product',
      submitLabel: 'Save',
      onSubmit: (context) => ctr.onSaveProduct(context),
    );
  }
}
