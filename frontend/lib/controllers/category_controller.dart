import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/category/widget/add_category_widget.dart';
import 'package:frontend/screen/category/widget/edit_category_widget.dart';
import 'package:frontend/services/main_service/category_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final CategoryService service = CategoryService();

  final categoryList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCategory();
  }

  Future<void> getCategory() async {
    try {
      isLoading.value = true;

      final resp = await service.getCategories();

      if (resp is List) {
        categoryList.value = List<Map<String, dynamic>>.from(resp);
      }
    } catch (e) {
        print("Error getCategory: $e");
    } finally {
        isLoading.value = false;
    }
  }

  void addCategory(BuildContext context) {
    AppBottomSheets.show(
      context,
      child: AddCategoryWidget()
    );
  }

  void onSaveCategory() async {

  }

  void onEditCategory(int categoryId, BuildContext context) async {
    AppBottomSheets.show(
      context,
      child: EditCategoryWidget()
    );
  }

  void onDeleteCategory(int categoryId, BuildContext context) async {
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this category?".tr,
      onConfirm: () {
        print("Saved!");
      },
      onCancel: () {
        print("Cancelled!");
      },
    );
    print("Delete Category ID: $categoryId");
  }

}