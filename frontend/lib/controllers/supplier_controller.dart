import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/supplier/widgets/supplier_add_widget.dart';
import 'package:frontend/screen/supplier/widgets/supplier_edit_widget.dart';
import 'package:frontend/services/main_service/supplier_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';

class SupplierController extends GetxController {
  SupplierController({SupplierService? service})
    : service = service ?? SupplierService();
  final loadError = ''.obs;
  final isSaving = false.obs;
  final isOpeningEdit = false.obs;
  final formError = ''.obs;
  bool _formOpen = false;
  bool _confirmingDelete = false;
  int _dataRevision = 0;
  String _query = '';
  Worker? _searchWorker;

  var isLoading = false.obs;
  final selectedTab = "All".obs;
  final SupplierService service;
  final suppliers = <SupplierModel>[].obs;
  final searchSuppliers = <SupplierModel>[].obs;
  final supplierNameController = TextEditingController();
  final supplierPhoneNumberController = TextEditingController();
  final supplierEmailController = TextEditingController();
  final supplierMapController = TextEditingController();
  final supplierAddressController = TextEditingController();
  final status = true.obs;

  final formKey = GlobalKey<FormState>();

  static final List<SupplierModel> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  @override
  void onInit() {
    super.onInit();

    final searchController = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    _query = searchController.keyword.value.trim().toLowerCase();
    _searchWorker = ever(searchController.keyword, searchSupplier);
    if (_hasFreshCache) {
      suppliers.assignAll(_cache);
      searchSupplier(_query);
    } else {
      getSuppliers();
    }
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
    supplierNameController.dispose();
    supplierPhoneNumberController.dispose();
    supplierEmailController.dispose();
    supplierMapController.dispose();
    supplierAddressController.dispose();
  }

  void clearSupplier() {
    supplierNameController.clear();
    supplierPhoneNumberController.clear();
    supplierEmailController.clear();
    supplierMapController.clear();
    supplierAddressController.clear();
    status.value = true;
  }

  Future<void> onRefresh() => getSuppliers();

  Future<void> getSuppliers() async {
    if (isLoading.value || isClosed) return;
    isLoading.value = true;
    loadError.value = '';
    final revision = _dataRevision;
    try {
      final resp = await service.getSuppliers();
      if (isClosed || revision != _dataRevision) return;
      if (resp is! List) throw const FormatException('Expected supplier list');
      final records = resp.map((item) => SupplierModel.fromJson(item)).toList();
      suppliers.assignAll(records);
      searchSupplier(_query);
      _cache
        ..clear()
        ..addAll(records);
      _cachedAt = DateTime.now();
    } catch (_) {
      if (!isClosed) {
        loadError.value = 'Unable to load suppliers. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void searchSupplier(String keyword) {
    _query = keyword.trim().toLowerCase();
    searchSuppliers.assignAll(
      suppliers.where((s) => s.name.toLowerCase().contains(_query)),
    );
  }

  void gotoSupplierDetail(SupplierModel supplier) {
    Get.toNamed(AppRoutes.supplierDetail, arguments: supplier);
  }

  void addSupplier(BuildContext context) {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    clearSupplier();
    formError.value = '';
    _showForm(context, SupplierAddWidget());
  }

  Future<void> _showForm(BuildContext context, Widget child) async {
    _formOpen = true;
    try {
      await AppBottomSheets.show(
        context,
        child: child,
        isDismissible: false,
        enableDrag: false,
        constraints: const BoxConstraints(maxWidth: 760),
      );
    } finally {
      _formOpen = false;
    }
  }

  Future<void> saveSupplier(BuildContext context) => _save(context);

  Future<void> updateSupplier(int supplierId, BuildContext context) =>
      _save(context, supplierId: supplierId);

  Future<void> _save(BuildContext context, {int? supplierId}) async {
    if (isSaving.value || isClosed) return;
    formError.value = '';
    final required = [
      (supplierNameController.text.trim(), 'Supplier name is required'),
      (supplierPhoneNumberController.text.trim(), 'Phone number is required'),
      (supplierEmailController.text.trim(), 'Email is required'),
    ];
    for (final (value, message) in required) {
      if (value.isEmpty) {
        formError.value = message.tr;
        return;
      }
    }
    final data = <String, dynamic>{
      'name': supplierNameController.text.trim(),
      'phone': supplierPhoneNumberController.text.trim(),
      'email': supplierEmailController.text.trim(),
      'map': supplierMapController.text.trim(),
      'address': supplierAddressController.text.trim(),
      'status': status.value,
    };
    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    isSaving.value = true;
    dynamic response;
    try {
      response = supplierId == null
          ? await service.createSupplier(data)
          : await service.updateSupplier(supplierId, data);
    } catch (_) {
      if (!isClosed) {
        formError.value = 'Unable to save supplier. Please try again.'.tr;
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
      final record = SupplierModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      final index = suppliers.indexWhere((s) => s.id == record.id);
      if (index < 0) {
        suppliers.add(record);
      } else {
        suppliers[index] = record;
      }
      _updateCache();
    } catch (_) {
      _cachedAt = null;
    }
    searchSupplier(_query);
    if (context.mounted && route is ModalBottomSheetRoute && route.isCurrent) {
      navigator.pop();
    }
    await getSuppliers();
  }

  void _updateCache() {
    _cache
      ..clear()
      ..addAll(suppliers);
    _cachedAt = DateTime.now();
  }

  Future<void> editSupplier(int supplierId, BuildContext context) async {
    if (_formOpen || isOpeningEdit.value || isSaving.value || isClosed) return;
    final route = ModalRoute.of(context);
    isOpeningEdit.value = true;
    formError.value = '';
    try {
      final supplier = await service.getSupplierById(supplierId);
      if (isClosed || !context.mounted || route?.isCurrent != true) return;
      supplierNameController.text = supplier['name'] ?? '';
      supplierPhoneNumberController.text = supplier['phone'] ?? '';
      supplierEmailController.text = supplier['email'] ?? '';
      supplierMapController.text = supplier['map'] ?? '';
      supplierAddressController.text = supplier['address'] ?? '';
      status.value = supplier['status'] ?? false;
      _showForm(context, SupplierEditWidget(supplierId: supplierId));
    } catch (_) {
      if (!isClosed) {
        formError.value = 'Unable to open supplier. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isOpeningEdit.value = false;
    }
  }

  Future<void> deleteSupplier({
    required int supplierId,
    required BuildContext context,
  }) async {
    if (isClosed ||
        isSaving.value ||
        _confirmingDelete ||
        _formOpen ||
        isOpeningEdit.value) {
      return;
    }
    _confirmingDelete = true;
    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    try {
      await showConfirmDialog(
        context: context,
        title: 'Confirm'.tr,
        cancelText: 'Cancel'.tr,
        confirmText: 'Ok'.tr,
        message: 'Do you want to delete this supplier?'.tr,
        onConfirm: () async {
          if (isClosed || !context.mounted || route?.isCurrent != true) return;
          isSaving.value = true;
          formError.value = '';
          try {
            await service.deleteSupplier(supplierId);
            _cachedAt = null;
            if (isClosed) return;
            _dataRevision++;
            suppliers.removeWhere((s) => s.id == supplierId);
            _updateCache();
            searchSupplier(_query);
            if (context.mounted && route?.isCurrent == true) navigator.pop();
            await getSuppliers();
          } catch (_) {
            if (!isClosed) {
              formError.value = 'Unable to delete supplier. Please try again.'.tr;
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
}
