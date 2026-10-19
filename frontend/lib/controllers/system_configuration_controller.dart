import 'package:flutter/material.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/system_configuration/widget/add_system_configuration_widget.dart';
import 'package:frontend/services/main_service/currency_service.dart';
import 'package:frontend/services/main_service/payment_type_service.dart';
import 'package:frontend/services/main_service/system_configuration_service.dart';
import 'package:frontend/services/main_service/warehouse_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class SystemConfigurationController extends GetxController {
  final SystemConfigurationService service = SystemConfigurationService();
  final CurrencyService currencyService = CurrencyService();
  final WarehouseService warehouseService = WarehouseService();
  final PaymentTypeService paymentTypeService = PaymentTypeService();

  final systemConfigurationList = <Map<String, dynamic>>[].obs;
  final currencies = <Map<String, dynamic>>[].obs;
  final warehouses = <Map<String, dynamic>>[].obs;
  final paymentTypes = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isOptionsLoading = false.obs;
  final isSaving = false.obs;

  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
    _cachedAt != null &&
    DateTime.now().difference(_cachedAt!) < _cacheTtl;

  @override
  void onInit() {
    super.onInit();

    if(_hasFreshCache) {
      systemConfigurationList.value = List<Map<String, dynamic>>.from(_cache);
    }else{
      getSystemConfigurations();
    }
  }

  Future<void> getSystemConfigurations() async {
    try {
      isLoading.value = true;

      final resp = await service.getSystemConfigurations();

      if (resp is List) {

        systemConfigurationList.value = List<Map<String, dynamic>>.from(resp);

        _cache
          ..clear()
          ..addAll(systemConfigurationList);
        _cachedAt = DateTime.now();
      }
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSystemConfiguration(BuildContext context) async {
    await loadConfigurationOptions();
    if (!context.mounted) return;
    await AppBottomSheets.show(context, child: AddSystemConfigurationWidget());
  }

  Future<void> loadConfigurationOptions() async {
    try {
      isOptionsLoading.value = true;
      final results = await Future.wait([
        currencyService.getCurrencies(),
        warehouseService.getWarehouses(),
        paymentTypeService.getPaymentTypes(),
      ]);
      if (results[0] is List) {
        currencies.value = List<Map<String, dynamic>>.from(results[0] as List);
      }
      if (results[1] is List) {
        warehouses.value = List<Map<String, dynamic>>.from(results[1] as List);
      }
      if (results[2] is List) {
        paymentTypes.value = List<Map<String, dynamic>>.from(
          results[2] as List,
        ).where((type) => type['status'] == true).toList();
      }
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    } finally {
      isOptionsLoading.value = false;
    }
  }

  Future<void> createSystemConfiguration(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      final response = await service.createSystemConfiguration(data);
      if (response is Map) {
        systemConfigurationList.insert(0, Map<String, dynamic>.from(response));
      } else {
        await getSystemConfigurations();
      }

      if (context.mounted) Navigator.pop(context);
      ToastWidget.show(
        message: 'System configuration created successfully',
        type: ToastType.success,
      );
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  void openDetail(Map<String, dynamic> configuration) {
    Get.toNamed(AppRoutes.systemConfigurationDetail, arguments: configuration);
  }

  Future<bool> updateSystemConfiguration(
    Map<String, dynamic> configuration,
    Map<String, dynamic> data,
  ) async {
    final id = int.tryParse(configuration['id']?.toString() ?? '');
    if (id == null) return false;

    try {
      isSaving.value = true;
      final response = await service.updateSystemConfiguration(id, data);
      if (response is Map) {
        configuration.addAll(Map<String, dynamic>.from(response));
      } else {
        configuration.addAll(data);
      }

      final index = systemConfigurationList.indexWhere(
        (item) => item['id'] == id,
      );
      if (index >= 0) {
        systemConfigurationList[index] = configuration;
      }
      ToastWidget.show(
        message: 'System configuration updated successfully',
        type: ToastType.success,
      );
      return true;
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void deleteSystemConfiguration(
    BuildContext context,
    Map<String, dynamic> configuration,
  ) {
    final id = int.tryParse(configuration['id']?.toString() ?? '');
    if (id == null) return;

    showConfirmDialog(
      context: context,
      title: 'Delete system configuration',
      message: 'Are you sure you want to delete this configuration?',
      confirmText: 'Delete',
      onConfirm: () async {
        try {
          await service.deleteSystemConfiguration(id);
          systemConfigurationList.removeWhere((item) => item['id'] == id);
          Get.back();
          ToastWidget.show(
            message: 'System configuration deleted successfully',
            type: ToastType.success,
          );
        } catch (error) {
          ToastWidget.show(message: error.toString(), type: ToastType.error);
        }
      },
    );
  }
}
