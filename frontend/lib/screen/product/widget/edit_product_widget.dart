import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/screen/product/widget/product_form_widget.dart';
import 'package:get/get.dart';

/// Edit-form adapter; the shared form owns the UI.
class EditProductWidget extends StatelessWidget {
  final int productId;

  EditProductWidget({super.key, required this.productId});

  final ctr = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return ProductFormWidget(
      controller: ctr,
      title: 'Edit Product',
      submitLabel: 'Update',
      onSubmit: (context) => ctr.onUpdateProduct(productId, context),
    );
  }
}
