import 'package:flutter/material.dart';
import 'package:frontend/screen/category/widget/add_category_widget.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final api = ApiService();

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

      final resp = await api.get("category/");
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

}