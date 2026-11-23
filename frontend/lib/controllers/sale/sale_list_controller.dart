import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/main_service/sale_service.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class SaleListController extends GetxController {
  SaleListController({SaleService? service})
    : service = service ?? SaleService();
  final loadError = ''.obs;
  final deletingIds = <int>{}.obs;
  static void invalidateCache() {
    _cache.clear();
    _cachedAt = null;
  }

  Future<void> onRefresh() => onGetSaleList();

  var isLoading = false.obs;

  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  @override
  void onInit() {
    super.onInit();

    if (_hasFreshCache) {
      saleList.value = List<Map<String, dynamic>>.from(_cache);
    } else {
      onGetSaleList();
    }
  }

  final SaleService service;
  final saleList = <Map<String, dynamic>>[].obs;

  final searchCtr = SearchController();

  List<Map<String, dynamic>> get filteredSaleList {
    final keyword = searchCtr.keyword.value.trim().toLowerCase();

    if (keyword.isEmpty) return saleList;

    return saleList.where((sale) {
      final customer = sale['customer'];
      final customerName = customer is Map
          ? (customer['name'] ?? '').toString()
          : (customer ?? '').toString();

      final searchable = [
        customerName,
        sale['invoice_no'],
        sale['payment_status'],
        sale['payment_method'],
        sale['sale_date'],
        sale['total_amount'],
      ].map((value) => (value ?? '').toString().toLowerCase()).join(' ');

      return searchable.contains(keyword);
    }).toList();
  }

  void gotoSaleListDetail(Map<String, dynamic> sale) {
    Get.toNamed(AppRoutes.saleListDetail, arguments: sale);
  }

  void onNewSale() {
    Get.toNamed(AppRoutes.sale);
  }

  Future<void> onGetSaleList() async {
    try {
      isLoading.value = true;

      final resp = await service.getSales();

      if (resp is! List) throw const FormatException('Invalid sales response');
      saleList.value = List<Map<String, dynamic>>.from(resp);
      loadError.value = '';

      _cache
        ..clear()
        ..addAll(saleList);
      _cachedAt = DateTime.now();
    } catch (e) {
      loadError.value = 'Unable to load sales. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onDeleteSale(int saleId, BuildContext context) async {
    if (!deletingIds.add(saleId)) return;
    final origin = ModalRoute.of(context);
    var confirmed = false;
    try {
      await showConfirmDialog(
        context: context,
        message: "Do you want to delete this sale?".tr,
        onConfirm: () async {
          confirmed = true;
          try {
            await service.deleteSale(saleId);
            invalidateCache();

            if (context.mounted && (origin?.isCurrent ?? false)) {
              Navigator.of(context).pop();
            }

            // Refresh recorded sales
            await onGetSaleList();

            ToastWidget.show(
              message: "Sale deleted successfully".tr,
              type: ToastType.success,
            );
          } catch (e) {
            if (e is ApiException && e.statusCode == 409) {
              loadError.value =
                  'The stock allocation needs review before deleting this sale.';
              ToastWidget.show(
                message: loadError.value.tr,
                type: ToastType.error,
              );
            } else {
              loadError.value = 'Unable to delete sale. Please try again.';
            }
          } finally {
            deletingIds.remove(saleId);
          }
        },
        onCancel: () {
          deletingIds.remove(saleId);
        },
      );
    } finally {
      if (!confirmed) deletingIds.remove(saleId);
    }
  }

  @override
  void onClose() {
    searchCtr.onClose();
    super.onClose();
  }
}
