import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/category/widget/add_category_widget.dart';
import 'package:frontend/screen/category/widget/edit_category_widget.dart';
import 'package:frontend/services/main_service/category_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  CategoryController({CategoryService? service})
    : service = service ?? CategoryService();

  final CategoryService service;

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
  final loadError = ''.obs;
  final isSaving = false.obs;
  final isOpeningEdit = false.obs;
  final formError = ''.obs;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _formOpen = false;
  bool _confirmingDelete = false;
  int _dataRevision = 0;
  String _query = '';
  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();

    final search = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    _query = search.keyword.value.trim().toLowerCase();
    _searchWorker = ever(search.keyword, searchCategory);

    if (_hasFreshCache) {
      categoryList.assignAll(_cache);
      searchCategory(_query);
    } else {
      getCategory();
    }
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> getCategory() async {
    if (isLoading.value || isClosed) return;
    isLoading.value = true;
    loadError.value = '';
    final revision = _dataRevision;
    try {
      final resp = await service.getCategories();
      if (isClosed || revision != _dataRevision) return;
      if (resp is! List) throw const FormatException('Expected category list');
      categoryList.assignAll(
        resp.map((item) => Map<String, dynamic>.from(item as Map)),
      );
      searchCategory(_query);
      _cache
        ..clear()
        ..addAll(categoryList);
      _cachedAt = DateTime.now();
    } catch (_) {
      if (!isClosed) {
        loadError.value = 'Unable to load categories. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> onRefresh() => getCategory();

  void searchCategory(String keyword) {
    _query = keyword.trim().toLowerCase();
    searchCategoryList.assignAll(
      _query.isEmpty
          ? categoryList
          : categoryList.where((category) {
              final name = (category['name'] ?? '').toString().toLowerCase();
              return name.contains(_query);
            }),
    );
  }

  void clearCategory() {
    nameController.clear();
    descriptionController.clear();
  }

  void addCategory(BuildContext context) {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    clearCategory();
    formError.value = '';
    _showForm(context, AddCategoryWidget());
  }

  Future<void> _showForm(BuildContext context, Widget child) async {
    _formOpen = true;
    try {
      if (MediaQuery.sizeOf(context).width >= 840) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            constraints: const BoxConstraints(maxWidth: 720),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
        );
      } else {
        await AppBottomSheets.show(
          context,
          child: child,
          isDismissible: false,
          enableDrag: false,
          constraints: const BoxConstraints(maxWidth: 760),
        );
      }
    } finally {
      _formOpen = false;
    }
  }

  Future<void> onEditCategory(int categoryId, BuildContext context) async {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    final route = ModalRoute.of(context);
    isOpeningEdit.value = true;
    formError.value = '';
    try {
      final category = await service.getCategoryById(categoryId);
      if (isClosed || !context.mounted || route?.isCurrent != true) return;
      final data = Map<String, dynamic>.from(category as Map);
      nameController.text = (data['name'] ?? '').toString();
      descriptionController.text = (data['description'] ?? '').toString();
      _showForm(context, EditCategoryWidget(categoryId: categoryId));
    } catch (_) {
      if (!isClosed) {
        ToastWidget.show(
          message: 'Unable to open category. Please try again.'.tr,
          type: ToastType.error,
        );
      }
    } finally {
      if (!isClosed) isOpeningEdit.value = false;
    }
  }

  Future<void> onSaveCategory(BuildContext context) => _save(context);

  Future<void> onUpdateCategory(int categoryId, BuildContext context) =>
      _save(context, categoryId: categoryId);

  Future<void> _save(BuildContext context, {int? categoryId}) async {
    if (isSaving.value || isClosed) return;
    formError.value = '';
    final name = nameController.text.trim();
    if (name.isEmpty) {
      formError.value = 'Category name is required'.tr;
      return;
    }
    final data = <String, dynamic>{
      'name': name,
      'description': descriptionController.text.trim(),
    };
    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    isSaving.value = true;
    dynamic response;
    try {
      response = categoryId == null
          ? await service.createCategory(data)
          : await service.updateCategory(categoryId, data);
    } catch (_) {
      if (!isClosed) {
        formError.value = 'Unable to save category. Please try again.'.tr;
      }
      return;
    } finally {
      if (!isClosed) isSaving.value = false;
    }
    if (isClosed) {
      _cachedAt = null;
      return;
    }
    _dataRevision++;
    // A committed write must never become a retryable form error.
    try {
      final record = Map<String, dynamic>.from(response as Map);
      final index = categoryList.indexWhere(
        (category) => category['id'] == record['id'],
      );
      if (index < 0) {
        categoryList.add(record);
      } else {
        categoryList[index] = record;
      }
      _updateCache();
    } catch (_) {
      _cachedAt = null;
    }
    searchCategory(_query);
    if (context.mounted && route is PopupRoute && route.isCurrent) {
      navigator.pop();
    }
    await getCategory();
    if (!isClosed) {
      ToastWidget.show(
        message: (categoryId == null
                ? 'Category created successfully'
                : 'Category updated successfully')
            .tr,
        type: ToastType.success,
      );
    }
  }

  Future<void> onDeleteCategory(int categoryId, BuildContext context) async {
    if (isClosed ||
        isSaving.value ||
        _confirmingDelete ||
        _formOpen ||
        isOpeningEdit.value) {
      return;
    }
    _confirmingDelete = true;
    final route = ModalRoute.of(context);
    try {
      await showConfirmDialog(
        context: context,
        title: 'Confirm'.tr,
        cancelText: 'Cancel'.tr,
        confirmText: 'Ok'.tr,
        message: 'Do you want to delete this category?'.tr,
        onConfirm: () async {
          if (isClosed || !context.mounted || route?.isCurrent != true) return;
          isSaving.value = true;
          formError.value = '';
          try {
            await service.deleteCategory(categoryId);
            _cachedAt = null;
            if (isClosed) return;
            _dataRevision++;
            categoryList.removeWhere(
              (category) => category['id'] == categoryId,
            );
            _updateCache();
            searchCategory(_query);
            ToastWidget.show(
              message: 'Category deleted successfully'.tr,
              type: ToastType.success,
            );
          } catch (_) {
            if (!isClosed) {
              ToastWidget.show(
                message: 'Unable to delete category. Please try again.'.tr,
                type: ToastType.error,
              );
            }
          } finally {
            if (!isClosed) isSaving.value = false;
          }
        },
      );
    } finally {
      _confirmingDelete = false;
    }
  }

  void _updateCache() {
    _cache
      ..clear()
      ..addAll(categoryList);
    _cachedAt = DateTime.now();
  }
}