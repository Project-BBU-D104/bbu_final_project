import 'package:flutter/material.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/screen/category/widget/category_form_widget.dart';
import 'package:get/get.dart';

class AddCategoryWidget extends StatelessWidget {
  AddCategoryWidget({super.key});
  final ctr = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) => CategoryFormWidget(
    controller: ctr,
    title: 'Add Category',
    onSubmit: ctr.onSaveCategory,
  );
}
