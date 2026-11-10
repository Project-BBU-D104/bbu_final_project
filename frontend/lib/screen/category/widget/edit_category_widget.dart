import 'package:flutter/material.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/screen/category/widget/category_form_widget.dart';
import 'package:get/get.dart';

class EditCategoryWidget extends StatelessWidget {
  EditCategoryWidget({super.key, required this.categoryId});
  final int categoryId;
  final ctr = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) => CategoryFormWidget(
    controller: ctr,
    title: 'Edit Category',
    onSubmit: (context) => ctr.onUpdateCategory(categoryId, context),
  );
}