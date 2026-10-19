import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/category/widget/add_category_widget.dart';
import 'package:frontend/screen/category/widget/edit_category_widget.dart';
import 'package:frontend/services/main_service/category_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';

class CategoryController extends GetxController {
  final CategoryService service = CategoryService();

  // Shared cache so re-opening the screen does not re-fetch every time.
  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null &&
      DateTime.now().difference(_cachedAt!) < _cacheTtl;

  final categoryList = <Map<String, dynamic>>[].obs;
  final searchCategoryList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();

    if (_hasFreshCache) {
      categoryList.value = List<Map<String, dynamic>>.from(_cache);
      searchCategoryList.value = categoryList;
    } else {
      getCategory();
    }

    final search = Get.put(SearchController());
    ever(
      search.keyword,
      (keyword) {
        searchCategory(keyword);
      },
    );
  }

  @override
    void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> getCategory() async {
    try {
      isLoading.value = true;

      final resp = await service.getCategories();

      if (resp is List) {
        categoryList.value = List<Map<String, dynamic>>.from(resp);

        searchCategoryList.value = categoryList;

        // Update the shared cache so the next visit reuses this data.
        _cache
          ..clear()
          ..addAll(categoryList);
        _cachedAt = DateTime.now();
      }
    } catch (e) {
        ToastWidget.show(
          message: e.toString(),
          type: ToastType.error,
        );
    } finally {
        isLoading.value = false;
    }
  }

  void searchCategory(String keyword) {
    final search = keyword.trim().toLowerCase();

    if (search.isEmpty) {
      searchCategoryList.value = categoryList;
      return;
    }

    searchCategoryList.value = categoryList.where((category) {
      return (category["name"] ?? "").toString().toLowerCase().contains(search);
    }).toList();
  }

  void addCategory(BuildContext context) {
    AppBottomSheets.show(
      context,
      child: AddCategoryWidget()
    );
  }

  Future<void> onSaveCategory(BuildContext context) async {
    try{
      final data = {
        "name": nameController.text.trim(),
        "description": descriptionController.text.trim(),
      };

       await service.createCategory(data);

      ToastWidget.show(
        message: "Category created successfully",
        type: ToastType.success,
      );

    // Reload Category
    await getCategory();

    // Clear textfields
    nameController.clear();
    descriptionController.clear();

    // Close BottomSheet
    Navigator.pop(context);

    }catch(e){
      final error = e.toString();
      final msg = error.split('msg: ')[1].split(', input:')[0];

      ToastWidget.show(
        message: msg.toString(),
        type: ToastType.error,
      );
    }
  }

  void onEditCategory(int categoryId, BuildContext context) async {
    try{
      final category = await service.getCategoryById(categoryId);
      nameController.text = category["name"] ?? "";
      descriptionController.text = category["description"] ?? "";

      AppBottomSheets.show(
        context,
        child: EditCategoryWidget(
          categoryId: categoryId,
        )
      );
    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> onUpdateCategory(
    int categoryId,
    BuildContext context) async
  {
    try{
      final data = {
        "name": nameController.text.trim(),
        "description": descriptionController.text.trim(),
      };

      await service.updateCategory(categoryId, data);

      // Reload Category
      await getCategory();

      Navigator.pop(context);

      ToastWidget.show(
        message: "Category updated successfully",
        type: ToastType.success,
      );
    }catch(e){
      // Do nothing
    }
  }

  Future<void> onDeleteCategory(int categoryId, BuildContext context) async {
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this category?".tr,
      onConfirm: () async {
        try{
          await service.deleteCategory(categoryId);

          // Refresh category list
          await getCategory();

          ToastWidget.show(
            message: "Category deleted successfully".tr,
            type: ToastType.success,
          );

          Get.back();

        }catch(e){
          ToastWidget.show(
            message: e.toString(),
            type: ToastType.error,
          );
        }
      },
      onCancel: () {
        // Do nothing
      },
    );
  }
}