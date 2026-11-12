import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/customer/widget/add_customer_widget.dart';
import 'package:frontend/screen/customer/widget/edit_customer_widget.dart';
import 'package:frontend/services/main_service/customer_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController {
  CustomerController({CustomerService? service})
    : service = service ?? CustomerService();

  final CustomerService service;

  // Shared cache so re-opening the screen does not re-fetch every time.
  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  final customerList = <Map<String, dynamic>>[].obs;
  final searchCustomerList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  final loadError = ''.obs;
  final isSaving = false.obs;
  final isOpeningEdit = false.obs;
  final formError = ''.obs;
  final customerPhotoController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerPhoneNumberController = TextEditingController();
  final customerAddressController = TextEditingController();
  final isActive = false.obs;
  final formKey = GlobalKey<FormState>();

  bool _formOpen = false;
  bool _confirmingDelete = false;
  int _dataRevision = 0;
  String _query = '';
  Worker? _searchWorker;

  int get activeCustomerCount =>
      customerList.where((customer) => customer['is_active'] == true).length;

  @override
  void onInit() {
    super.onInit();

    final search = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    _query = search.keyword.value.trim().toLowerCase();
    _searchWorker = ever(search.keyword, searchCustomer);

    if (_hasFreshCache) {
      customerList.assignAll(_cache);
      searchCustomer(_query);
    } else {
      getCustomers();
    }
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    customerPhotoController.dispose();
    customerNameController.dispose();
    customerPhoneNumberController.dispose();
    customerAddressController.dispose();
    super.onClose();
  }

  Future<void> getCustomers() async {
    if (isLoading.value || isClosed) return;
    isLoading.value = true;
    loadError.value = '';
    final revision = _dataRevision;
    try {
      final resp = await service.getCustomers();
      if (isClosed || revision != _dataRevision) return;
      if (resp is! List) throw const FormatException('Expected customer list');
      customerList.assignAll(
        resp.map((item) => Map<String, dynamic>.from(item as Map)),
      );
      searchCustomer(_query);
      _cache
        ..clear()
        ..addAll(customerList);
      _cachedAt = DateTime.now();
    } catch (_) {
      if (!isClosed) {
        loadError.value = 'Unable to load customers. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> onRefresh() => getCustomers();

  void searchCustomer(String keyword) {
    _query = keyword.trim().toLowerCase();
    searchCustomerList.assignAll(
      _query.isEmpty
          ? customerList
          : customerList.where((customer) {
              final name = (customer['name'] ?? '').toString().toLowerCase();
              return name.contains(_query);
            }),
    );
  }

  void clearCustomer() {
    customerPhotoController.clear();
    customerNameController.clear();
    customerPhoneNumberController.clear();
    customerAddressController.clear();
    isActive.value = false;
  }

  void addCustomer(BuildContext context) {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    clearCustomer();
    formError.value = '';
    _showForm(context, AddCustomerWidget());
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

  Future<void> editCustomer(BuildContext context, int customerId) async {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    final route = ModalRoute.of(context);
    isOpeningEdit.value = true;
    formError.value = '';
    try {
      final customer = await service.getCustomerById(customerId);
      if (isClosed || !context.mounted || route?.isCurrent != true) return;
      final data = Map<String, dynamic>.from(customer as Map);
      customerPhotoController.text = (data['photo'] ?? '').toString();
      customerNameController.text = (data['name'] ?? '').toString();
      customerPhoneNumberController.text = (data['phone'] ?? '').toString();
      customerAddressController.text = (data['address'] ?? '').toString();
      isActive.value = data['is_active'] == true;
      _showForm(context, EditCustomerWidget(customerId: customerId));
    } catch (_) {
      if (!isClosed) {
        ToastWidget.show(
          message: 'Unable to open customer. Please try again.'.tr,
          type: ToastType.error,
        );
      }
    } finally {
      if (!isClosed) isOpeningEdit.value = false;
    }
  }

  Future<void> onSaveCustomer(BuildContext context) => _save(context);

  Future<void> onUpdateCustomer(int customerId, BuildContext context) =>
      _save(context, customerId: customerId);

  Future<void> _save(BuildContext context, {int? customerId}) async {
    if (isSaving.value || isClosed) return;
    formError.value = '';
    final name = customerNameController.text.trim();
    if (name.isEmpty) {
      formError.value = 'Customer name is required'.tr;
      return;
    }
    final data = <String, dynamic>{
      'photo': customerPhotoController.text.trim(),
      'name': name,
      'phone': customerPhoneNumberController.text.trim(),
      'address': customerAddressController.text.trim(),
      'is_active': isActive.value,
    };
    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    isSaving.value = true;
    dynamic response;
    try {
      response = customerId == null
          ? await service.createCustomer(data)
          : await service.updateCustomer(customerId, data);
    } catch (_) {
      if (!isClosed) {
        formError.value = 'Unable to save customer. Please try again.'.tr;
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
      final index = customerList.indexWhere((c) => c['id'] == record['id']);
      if (index < 0) {
        customerList.add(record);
      } else {
        customerList[index] = record;
      }
      _updateCache();
    } catch (_) {
      _cachedAt = null;
    }
    searchCustomer(_query);
    if (context.mounted && route is PopupRoute && route.isCurrent) {
      navigator.pop();
    }
    await getCustomers();
    if (!isClosed) {
      ToastWidget.show(
        message:
            (customerId == null
                    ? 'Customer created successfully'
                    : 'Customer updated successfully')
                .tr,
        type: ToastType.success,
      );
    }
  }

  void onDeleteCustomer(int customerId, BuildContext context) {
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
      showConfirmDialog(
        context: context,
        title: 'Confirm'.tr,
        cancelText: 'Cancel'.tr,
        confirmText: 'Ok'.tr,
        message: 'Do you want to delete this customer?'.tr,
        onConfirm: () async {
          if (isClosed || !context.mounted || route?.isCurrent != true) return;
          isSaving.value = true;
          formError.value = '';
          try {
            await service.deleteCustomer(customerId);
            _cachedAt = null;
            if (isClosed) return;
            _dataRevision++;
            customerList.removeWhere((c) => c['id'] == customerId);
            _updateCache();
            searchCustomer(_query);
            ToastWidget.show(
              message: 'Customer deleted successfully'.tr,
              type: ToastType.success,
            );
            await getCustomers();
          } catch (_) {
            if (!isClosed) {
              ToastWidget.show(
                message: 'Unable to delete customer. Please try again.'.tr,
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
      ..addAll(customerList);
    _cachedAt = DateTime.now();
  }
}
