import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/add_stock_transfer_widget.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/edit_stock_transfer_widget.dart';
import 'package:frontend/services/main_service/warehouse_stock_service.dart';
import 'package:frontend/services/main_service/product_transfer_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';

class ProductTransferController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;
  var isStockLoading = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final ProductTransferService service = ProductTransferService();
  final WarehouseStockService warehouseStockService = WarehouseStockService();
  final stockTransfer = <Map<String, dynamic>>[].obs;
  final searchStockTransferList = <Map<String, dynamic>>[].obs;
  final warehouseStock = <Map<String, dynamic>>[].obs;
  final transferItems = <Map<String, dynamic>>[].obs;
  final RxnInt selectedFromWarehouse = RxnInt();
  final RxnInt selectedToWarehouse = RxnInt();
  final RxnInt selectedProduct = RxnInt();
  final RxnInt quantity = RxnInt();
  final quantityController = TextEditingController();
  final productTransferRefController = TextEditingController();
  final productTransferDate = TextEditingController();

  final Rxn<Map<String, dynamic>> editingTransfer = Rxn<Map<String, dynamic>>();

  // Separate caches: the transfer list and warehouse stock are different data.
  static final List<Map<String, dynamic>> _transferCache = [];
  static DateTime? _transferCachedAt;
  static const Duration _transferCacheTtl = Duration(seconds: 60);

  static bool get _hasFreshTransferCache =>
      _transferCachedAt != null &&
      DateTime.now().difference(_transferCachedAt!) < _transferCacheTtl;

  static final List<Map<String, dynamic>> _stockCache = [];
  static DateTime? _stockCachedAt;
  static const Duration _stockCacheTtl = Duration(seconds: 60);

  static bool get _hasFreshStockCache =>
      _stockCachedAt != null &&
      DateTime.now().difference(_stockCachedAt!) < _stockCacheTtl;

  @override
  void onInit() {
    super.onInit();

    if (_hasFreshTransferCache) {
      stockTransfer.value = List<Map<String, dynamic>>.from(_transferCache);
      searchStockTransferList.value = stockTransfer;
    } else {
      onGetProductTransferList();
    }

    if (_hasFreshStockCache) {
      warehouseStock.value = List<Map<String, dynamic>>.from(_stockCache);
    } else {
      onGetWarehouseStock();
    }
    

    final search = Get.put(SearchController());
    ever(search.keyword, (keyword) {
      searchStockTransfer(keyword);
    });
  }

  void onClear() {
    selectedFromWarehouse.value = null;
    selectedToWarehouse.value = null;
    selectedProduct.value = null;
    quantity.value = null;
    productTransferDate.clear();
    productTransferRefController.clear();
    quantityController.clear();
    transferItems.clear();
    editingTransfer.value = null;
    selectedDate.value = DateTime.now();
  }

  Future<void> onGetWarehouseStock() async {
    try {
      isStockLoading.value = true;
      final response = await warehouseStockService.getWarehouseStock();
      if (response is List) {
        warehouseStock.value = List<Map<String, dynamic>>.from(response);

        _stockCache
          ..clear()
          ..addAll(warehouseStock);
        _stockCachedAt = DateTime.now();
      }
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    } finally {
      isStockLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get availableProducts {
    final warehouseId = selectedFromWarehouse.value;
    if (warehouseId == null) return [];
    return warehouseStock.where((stock) {
      final productId = int.tryParse(stock['product']?['id']?.toString() ?? '');
      return int.tryParse(stock['warehouse_id'].toString()) == warehouseId &&
          productId != null &&
          availableQtyFor(productId) > 0 &&
          stock['product'] is Map;
    }).toList();
  }

  int availableQtyFor(int productId) {
    final stock = warehouseStock.firstWhereOrNull(
      (item) =>
          int.tryParse(item['warehouse_id'].toString()) ==
              selectedFromWarehouse.value &&
          int.tryParse(item['product']?['id']?.toString() ?? '') == productId,
    );
    var available = int.tryParse(stock?['qty']?.toString() ?? '') ?? 0;
    final original = editingTransfer.value;
    if (original != null &&
        int.tryParse(
              original['from_warehouse_id']?.toString() ??
                  original['from_warehouse']?['id']?.toString() ??
                  '',
            ) ==
            selectedFromWarehouse.value) {
      for (final item in (original['product_transfer_items'] as List? ?? [])) {
        final itemProductId = int.tryParse(
          item['product_id']?.toString() ??
              item['product']?['id']?.toString() ??
              '',
        );
        if (itemProductId == productId) {
          available += int.tryParse(item['qty']?.toString() ?? '') ?? 0;
        }
      }
    }
    return available;
  }

  void selectFromWarehouse(int? warehouseId) {
    selectedFromWarehouse.value = warehouseId;
    quantityController.clear();
    quantity.value = null;
    final firstStockedProduct = availableProducts.firstOrNull;
    selectedProduct.value = firstStockedProduct == null
        ? null
        : int.tryParse(firstStockedProduct['product']?['id']?.toString() ?? '');
  }

  void addDraftItem() {
    final productId = selectedProduct.value;
    final qty = int.tryParse(quantityController.text.trim());
    final fromId = selectedFromWarehouse.value;
    final toId = selectedToWarehouse.value;

    if (fromId == null || toId == null || fromId == toId) {
      ToastWidget.show(
        message: 'Select different source and destination warehouses.',
        type: ToastType.error,
      );
      return;
    }
    if (productId == null || qty == null || qty <= 0) {
      ToastWidget.show(
        message: 'Select a stocked product and enter a positive quantity.',
        type: ToastType.error,
      );
      return;
    }

    final currentQty = transferItems
        .where((item) => item['product_id'] == productId)
        .fold<int>(0, (sum, item) => sum + (item['qty'] as int));
    if (currentQty + qty > availableQtyFor(productId)) {
      ToastWidget.show(
        message: 'Quantity exceeds available stock.',
        type: ToastType.error,
      );
      return;
    }

    final stock = warehouseStock.firstWhereOrNull(
      (item) =>
          int.tryParse(item['warehouse_id'].toString()) == fromId &&
          int.tryParse(item['product']?['id']?.toString() ?? '') == productId,
    );
    if (stock == null) return;

    final product = Map<String, dynamic>.from(stock['product'] as Map);
    final existingIndex = transferItems.indexWhere(
      (item) => item['product_id'] == productId,
    );
    if (existingIndex >= 0) {
      transferItems[existingIndex] = {
        ...transferItems[existingIndex],
        'qty': currentQty + qty,
      };
    } else {
      transferItems.add({
        'product_id': productId,
        'product': product,
        'qty': qty,
      });
    }
    selectedProduct.value = null;
    quantityController.clear();
    quantity.value = null;
  }

  void removeDraftItem(int index) => transferItems.removeAt(index);

  int get totalDraftQuantity =>
      transferItems.fold<int>(0, (total, item) => total + (item['qty'] as int));

  Future<void> onGetProductTransferList() async {
    try {
      isLoading.value = true;

      final resp = await service.getProductTransfers();

      if (resp is List) {
        stockTransfer.value = List<Map<String, dynamic>>.from(resp);

        // search
        searchStockTransferList.value = stockTransfer;

        _transferCache
          ..clear()
          ..addAll(stockTransfer);
        _transferCachedAt = DateTime.now();
      }
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void searchStockTransfer(String keyword) {
    final search = keyword.trim().toLowerCase();

    if (search.isEmpty) {
      searchStockTransferList.value = stockTransfer;
      return;
    }

    searchStockTransferList.value = stockTransfer.where((transfer) {
      final items = transfer['product_transfer_items'] as List? ?? [];
      final productsMatch = items.any(
        (item) => (item['product']?['name'] ?? '')
            .toString()
            .toLowerCase()
            .contains(search),
      );
      return (transfer['reference_no'] ?? '').toString().toLowerCase().contains(
            search,
          ) ||
          (transfer['from_warehouse']?['name'] ?? '')
              .toString()
              .toLowerCase()
              .contains(search) ||
          (transfer['to_warehouse']?['name'] ?? '')
              .toString()
              .toLowerCase()
              .contains(search) ||
          productsMatch;
    }).toList();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  String get formattedDate {
    return selectedDate.value.toString().split(" ")[0];
  }

  Future<void> addStockTransfer(BuildContext context) async {
    onClear();
    await onGetWarehouseStock();
    if (!context.mounted) return;
    AppBottomSheets.show(context, child: AddStockTransferWidget());
  }

  Future<void> onSaveStockTransfer(BuildContext context) async {
    if (!_validateDraft()) return;
    try {
      isSaving.value = true;
      final data = {
        "from_warehouse_id": selectedFromWarehouse.value,
        "to_warehouse_id": selectedToWarehouse.value,
        "reference_no": productTransferRefController.text.trim().isEmpty
            ? null
            : productTransferRefController.text.trim(),
        "transfer_date": selectedDate.value.toUtc().toIso8601String(),
        "product_transfer_items": transferItems
            .map(
              (item) => {"product_id": item['product_id'], "qty": item['qty']},
            )
            .toList(),
      };

      await service.createProductTransfer(data);

      ToastWidget.show(
        message: "Stock transfer created successfully",
        type: ToastType.success,
      );

      // Reload Product Transfer
      await onGetProductTransferList();
      await onGetWarehouseStock();

      // Close BottomSheet
      if (context.mounted) Navigator.pop(context);

      // Clear textfields
      onClear();
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  bool _validateDraft() {
    if (selectedFromWarehouse.value == null ||
        selectedToWarehouse.value == null ||
        selectedFromWarehouse.value == selectedToWarehouse.value ||
        transferItems.isEmpty) {
      ToastWidget.show(
        message: 'Choose different warehouses and add at least one item.',
        type: ToastType.error,
      );
      return false;
    }
    for (final item in transferItems) {
      final productId = int.tryParse(item['product_id']?.toString() ?? '');
      final qty = int.tryParse(item['qty']?.toString() ?? '');
      if (productId == null ||
          qty == null ||
          qty <= 0 ||
          qty > availableQtyFor(productId)) {
        ToastWidget.show(
          message: 'A transfer quantity exceeds available source stock.',
          type: ToastType.error,
        );
        return false;
      }
    }
    return true;
  }

  Future<void> gotoStockTransferDetail(
    Map<String, dynamic> stockTransfer,
  ) async {
    final id = int.tryParse(stockTransfer['id']?.toString() ?? '');
    if (id == null) {
      Get.toNamed(AppRoutes.stockTransferDetail, arguments: stockTransfer);
      return;
    }

    try {
      final response = await service.getProductTransferById(id);
      final transfer = response is Map
          ? Map<String, dynamic>.from(response)
          : stockTransfer;
      Get.toNamed(AppRoutes.stockTransferDetail, arguments: transfer);
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
      Get.toNamed(AppRoutes.stockTransferDetail, arguments: stockTransfer);
    }
  }

  Future<void> editStockTransfer(
    BuildContext context,
    Map<String, dynamic> stockTransfer,
  ) async {
    try {
      final transfer = await service.getProductTransferById(
        stockTransfer["id"],
      );

      editingTransfer.value = transfer;
      selectedFromWarehouse.value = int.tryParse(
        transfer['from_warehouse']?['id']?.toString() ?? '',
      );
      selectedToWarehouse.value = int.tryParse(
        transfer['to_warehouse']?['id']?.toString() ?? '',
      );
      productTransferRefController.text =
          transfer['reference_no']?.toString() ?? '';
      selectedDate.value =
          DateTime.tryParse(
            transfer['transfer_date']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now();
      final items = transfer['product_transfer_items'] as List? ?? [];
      transferItems.assignAll(
        items
            .map((item) {
              final product = item['product'] is Map
                  ? Map<String, dynamic>.from(item['product'] as Map)
                  : <String, dynamic>{};
              return {
                'product_id': int.tryParse(
                  item['product_id']?.toString() ??
                      product['id']?.toString() ??
                      '',
                ),
                'product': product,
                'qty': int.tryParse(item['qty']?.toString() ?? '') ?? 0,
              };
            })
            .where((item) => item['product_id'] != null),
      );
      await onGetWarehouseStock();
      if (!context.mounted) return;
      AppBottomSheets.show(context, child: EditStockTransferWidget());
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    }
  }

  Future<void> onUpdate(
    BuildContext context,
    Map<String, dynamic> stockTransfer,
  ) async {
    if (!_validateDraft()) return;
    try {
      isSaving.value = true;

      final data = {
        "from_warehouse_id": selectedFromWarehouse.value,
        "to_warehouse_id": selectedToWarehouse.value,
        "reference_no": productTransferRefController.text.trim(),
        "transfer_date": selectedDate.value.toUtc().toIso8601String(),
        "product_transfer_items": transferItems
            .map(
              (item) => {"product_id": item['product_id'], "qty": item['qty']},
            )
            .toList(),
      };

      await service.updateProductTransfer(stockTransfer["id"], data);
      ToastWidget.show(
        message: "Stock transfer updated successfully",
        type: ToastType.success,
      );

      await onGetProductTransferList();
      await onGetWarehouseStock();

      // Close BottomSheet
      if (context.mounted) Navigator.pop(context);

      onClear();
    } catch (e) {
      ToastWidget.show(message: e.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  void onDeleteStockTransfer(
    BuildContext context,
    int productTransferId,
  ) async {
    final messengerContext = context;
    showConfirmDialog(
      context: messengerContext,
      message: "Do you want to delete this stock transfer?".tr,
      onConfirm: () async {
        try {
          await service.deleteProductTransfer(productTransferId);

          // Refresh category list
          await onGetProductTransferList();
          await onGetWarehouseStock();

          if (messengerContext.mounted) Navigator.pop(messengerContext);

          ToastWidget.show(
            message: "Stock transfer deleted successfully".tr,
            type: ToastType.success,
          );
        } catch (e) {
          ToastWidget.show(message: e.toString(), type: ToastType.error);
        }
      },
      onCancel: () {
        // Do nothing
      },
    );
  }
}
