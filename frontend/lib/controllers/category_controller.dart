import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/category/widget/add_category_widget.dart';
import 'package:frontend/screen/category/widget/edit_category_widget.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final api = ApiService();

  // final categoryList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // getCategory();
  }

  // Future<void> getCategory() async {
  //   try {
  //     isLoading.value = true;

  //     final resp = await api.get("category/");
  //   if (resp is List) {
  //       categoryList.value = List<Map<String, dynamic>>.from(resp);
  //   }
    
  //   } catch (e) {
  //     print("Error getCategory: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  final categoryList = [
    {"id": 1, "name": "Sting", "description": "This is a Sting", "icon": "category_icon", "created_at": "2024-06-05T10:00:00Z", "updated_at": "2024-06-05T10:00:00Z"},
    {"id": 2, "name": "Cocacola", "description": "This is Cocacola", "icon": "category_icon", "created_at": "2024-06-05T10:00:00Z", "updated_at": "2024-06-05T10:00:00Z"},
    {"id": 3, "name": "Ize", "description": "This is Ize", "icon": "category_icon", "created_at": "2024-06-05T10:00:00Z", "updated_at": "2024-06-05T10:00:00Z"},
    {"id": 4, "name": "Energy Drinks", "description": "This is Energy Drinks", "icon": "category_icon", "created_at": "2024-06-05T10:00:00Z", "updated_at": "2024-06-05T1OTH:0O:OOTH"},
    {"id": 5, "name": "Fruit Juices", "description": "This is Fruit Juices", "icon": "category_icon", "created_at": "2024-06-₀5T1₀:₀₀:₀₀Z", "updated_at": "2₀₂₄-₀₆-₀₅T1₀:₀₀:₀₀Z"},
    {"id": 6, "name": "Water", "description": "This is Water", "icon": "category_icon", "created_at": "2024-06-05T10:00:00Z", "updated_at": "2024-06-05T10:00:00Z"},
    {"id": 7, "name": "Tea", "description": "This is Tea", "icon": "category_icon", "created_at": "2024-06-05T10:00:00Z", "updated_at": "2024-06-05T10:00:00Z"},
    {"id": 8, "name": "Coffee", "description": "This is Coffee", "icon": "category_icon", "created_at": "2024-06-05T10:00:00Z", "updated_at": "2024-06-05T10:00:00Z"},
    {"id": 9, "name": "Soft Drinks", "description": "This is Soft Drinks", "icon": "category_icon", "created_at": "2024-06-05T10:00:00Z", "updated_at": "2024-06-05T10:00:00Z"},
    {"id": 10, "name": "Milkshakes", "description": "This is Milkshakes", "icon": "category_icon", "created_at": "2024-06-05T10:00:00Z", "updated_at": "2024-06-05T10:00:00Z"},
  ];

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