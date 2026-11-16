import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/add_stock_transfer_widget.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/edit_stock_transfer_widget.dart';
import 'package:frontend/services/main_service/warehouse_stock_service.dart';
import 'package:frontend/services/main_service/product_transfer_service.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/utils/stock_refresh.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';

class ProductTransferController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;
  var isStockLoading = false.obs;
  final isOpeningEdit = false.obs;
  final searchQuery = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  ProductTransferController({
    ProductTransferService? service,
    WarehouseStockService? warehouseStockService,
    Future<void> Function()? onStockChanged,
  }) : service = service ?? ProductTransferService(),
       warehouseStockService = warehouseStockService ?? WarehouseStockService(),
       _onStockChanged = onStockChanged ?? refreshStockReadModels;

  final ProductTransferService service;
  final WarehouseStockService warehouseStockService;
  final Future<void> Function() _onStockChanged;
  final loadError = ''.obs;
  final formError = ''.obs;
  final stockError = ''.obs;
  final draftError = ''.obs;
  String get _query => searchQuery.value;
  set _query(String value) => searchQuery.value = value;
  Worker? _searchWorker;
  int _listGeneration = 0, _stockGeneration = 0, _entryGeneration = 0;
  bool _closed = false, _formOpen = false, _confirmingDelete = false;

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

  @override
  void onInit() {
    super.onInit();
    final search = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    _query = search.keyword.value;
    _searchWorker = ever(search.keyword, searchStockTransfer);
    onGetProductTransferList();
    onGetWarehouseStock();
  }

  @override
  void onClose() {
    _closed = true;
    _listGeneration++;
    _stockGeneration++;
    _entryGeneration++;
    _searchWorker?.dispose();
    quantityController.dispose();
    productTransferRefController.dispose();
    productTransferDate.dispose();
    super.onClose();
  }

  Future<void> onRefresh() => onGetProductTransferList();

  Future<void> _refreshAfterWrite() async {
    await Future.wait([onGetProductTransferList(), onGetWarehouseStock()]);
    if (_closed) return;
    if (stockError.isNotEmpty && loadError.isEmpty) {
      loadError.value =
          'Transfer saved, but related stock could not be refreshed.';
    }
    try {
      await _onStockChanged();
      if (Get.isRegistered<WarehouseStockController>() &&
          !Get.isPrepared<WarehouseStockController>()) {
        await Get.find<WarehouseStockController>().getWarehouseStock();
      }
    } catch (_) {
      if (!_closed) {
        loadError.value =
            'Transfer saved, but related stock could not be refreshed.';
      }
    }
  }

  void onClear() {
    if (isSaving.value) return;
    draftError.value = formError.value = stockError.value = '';
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

  Future<void> onGetWarehouseStock() => _loadStock();

  Future<void> _loadStock() async {
    final generation = ++_stockGeneration;
    isStockLoading.value = true;
    // A failed refresh must invalidate authorization from a warm snapshot.
    stockError.value = 'Unable to load current stock. Please try again.';
    try {
      final response = await warehouseStockService.getWarehouseStock();
      if (_closed || generation != _stockGeneration) return;
      if (response is! List) throw const FormatException();
      warehouseStock.assignAll(List<Map<String, dynamic>>.from(response));
      stockError.value = '';
    } catch (_) {
      if (!_closed && generation == _stockGeneration) {
        stockError.value = 'Unable to load current stock. Please try again.';
      }
    } finally {
      if (!_closed && generation == _stockGeneration) {
        isStockLoading.value = false;
      }
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
    if (stock == null || stock['product'] is! Map) return 0;
    var available = int.tryParse(stock['qty']?.toString() ?? '') ?? 0;
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
    if (isSaving.value) return;
    selectedFromWarehouse.value = warehouseId;
    quantityController.clear();
    quantity.value = null;
    final firstStockedProduct = availableProducts.firstOrNull;
    selectedProduct.value = firstStockedProduct == null
        ? null
        : int.tryParse(firstStockedProduct['product']?['id']?.toString() ?? '');
  }

  void addDraftItem() {
    if (isSaving.value) return;
    draftError.value = '';
    if (stockError.isNotEmpty || isStockLoading.value) {
      draftError.value = 'Unable to load current stock. Please try again.';
      return;
    }
    final productId = selectedProduct.value;
    final qty = int.tryParse(quantityController.text.trim());
    final fromId = selectedFromWarehouse.value;
    final toId = selectedToWarehouse.value;

    if (fromId == null || toId == null || fromId == toId) {
      draftError.value = 'Choose different warehouses';
      return;
    }
    if (productId == null) {
      draftError.value = 'Select a product';
      return;
    }
    if (qty == null || qty <= 0) {
      draftError.value = 'Enter a whole quantity greater than zero';
      return;
    }

    final currentQty = transferItems
        .where((item) => item['product_id'] == productId)
        .fold<int>(0, (sum, item) => sum + (item['qty'] as int));
    if (currentQty + qty > availableQtyFor(productId)) {
      draftError.value = 'Quantity exceeds available stock.';
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

  void removeDraftItem(int index) {
    if (!isSaving.value) transferItems.removeAt(index);
  }

  int get totalDraftQuantity =>
      transferItems.fold<int>(0, (total, item) => total + (item['qty'] as int));

  Future<void> onGetProductTransferList() async {
    final generation = ++_listGeneration;
    isLoading.value = true;
    try {
      final response = await service.getProductTransfers();
      if (_closed || generation != _listGeneration) return;
      if (response is! List) throw const FormatException();
      stockTransfer.assignAll(List<Map<String, dynamic>>.from(response));
      searchStockTransfer(_query);
      loadError.value = '';
    } catch (_) {
      if (!_closed && generation == _listGeneration) {
        loadError.value = 'Unable to load stock transfers. Please try again.';
      }
    } finally {
      if (!_closed && generation == _listGeneration) isLoading.value = false;
    }
  }

  void searchStockTransfer(String keyword) {
    _query = keyword;
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
    if (isSaving.value) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (!_closed && !isSaving.value && picked != null) {
      selectedDate.value = picked;
    }
  }

  String get formattedDate {
    return selectedDate.value.toLocal().toString().split(" ")[0];
  }

  Future<void> addStockTransfer(BuildContext context) async {
    if (_closed || isSaving.value || isOpeningEdit.value || _formOpen) return;
    final route = ModalRoute.of(context);
    final entry = ++_entryGeneration;
    onClear();
    _formOpen = true;
    try {
      await onGetWarehouseStock();
      if (_closed ||
          entry != _entryGeneration ||
          !context.mounted ||
          route?.isCurrent != true) {
        return;
      }
      await AppFormShell.show(context, AddStockTransferWidget());
    } finally {
      _formOpen = false;
    }
  }

  Future<void> onSaveStockTransfer(BuildContext context) => _save(context);

  bool validateDraft() {
    draftError.value = '';
    if (selectedFromWarehouse.value == null ||
        selectedToWarehouse.value == null ||
        selectedFromWarehouse.value == selectedToWarehouse.value) {
      draftError.value = 'Choose different warehouses';
    } else if (transferItems.isEmpty) {
      draftError.value = 'Add at least one product';
    } else if (stockError.isNotEmpty || isStockLoading.value) {
      draftError.value = 'Unable to load current stock. Please try again.';
    } else {
      final totals = <int, int>{};
      for (final item in transferItems) {
        final id = int.tryParse(item['product_id']?.toString() ?? '');
        final qty = int.tryParse(item['qty']?.toString() ?? '');
        if (id == null || qty == null || qty <= 0) {
          draftError.value = 'Enter a whole quantity greater than zero';
          break;
        }
        totals[id] = (totals[id] ?? 0) + qty;
        if (totals[id]! > availableQtyFor(id)) {
          draftError.value = 'Quantity exceeds available stock.';
          break;
        }
      }
    }
    return draftError.isEmpty;
  }

  Future<void> _save(
    BuildContext context, {
    Map<String, dynamic>? original,
  }) async {
    if (_closed || isSaving.value) return;
    final route = ModalRoute.of(context), navigator = Navigator.of(context);
    isSaving.value = true;
    formError.value = '';
    try {
      await onGetWarehouseStock();
      if (_closed ||
          !context.mounted ||
          route?.isCurrent != true ||
          !validateDraft()) {
        return;
      }
      final data = <String, dynamic>{
        'from_warehouse_id': selectedFromWarehouse.value,
        'to_warehouse_id': selectedToWarehouse.value,
        'reference_no':
            original == null && productTransferRefController.text.trim().isEmpty
            ? null
            : productTransferRefController.text.trim(),
        'transfer_date': selectedDate.value.toUtc().toIso8601String(),
        'product_transfer_items': transferItems
            .map(
              (item) => {'product_id': item['product_id'], 'qty': item['qty']},
            )
            .toList(),
      };
      try {
        if (original == null) {
          await service.createProductTransfer(data);
        } else {
          await service.updateProductTransfer(original['id'], data);
          if (!_closed) {
            final index = stockTransfer.indexWhere(
              (r) => r['id'] == original['id'],
            );
            if (index >= 0) {
              stockTransfer[index] = {
                ...original,
                ...data,
                'product_transfer_items': transferItems
                    .map((r) => Map<String, dynamic>.from(r))
                    .toList(),
                'from_warehouse': _warehouse(selectedFromWarehouse.value),
                'to_warehouse': _warehouse(selectedToWarehouse.value),
              };
            }
          }
        }
      } catch (_) {
        if (!_closed) {
          formError.value = 'Unable to save stock transfer. Please try again.';
        }
        return;
      }
      // Any successful HTTP response is committed, including an empty body.
      if (_closed) return;
      ++_listGeneration;
      ++_stockGeneration;
      await _refreshAfterWrite();
      if (_closed) return;
      isSaving.value = false;
      onClear();
      if (context.mounted &&
          route is PopupRoute &&
          route.isCurrent &&
          navigator.canPop()) {
        navigator.pop();
      }
    } finally {
      if (!_closed) isSaving.value = false;
    }
  }

  Map<String, dynamic>? _warehouse(int? id) {
    if (!Get.isRegistered<WarehouseController>()) return null;
    final rows = Get.find<WarehouseController>().warehouseList;
    final row = rows.firstWhereOrNull((r) => r['id'] == id);
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  Future<void> gotoStockTransferDetail(
    Map<String, dynamic> stockTransfer,
  ) async {
    if (_closed || isSaving.value) return;
    final id = int.tryParse(stockTransfer['id']?.toString() ?? '');
    if (id == null) {
      Get.toNamed(AppRoutes.stockTransferDetail, arguments: stockTransfer);
      return;
    }

    final entry = ++_entryGeneration;
    final route = Get.rawRoute;
    try {
      final response = await service.getProductTransferById(id);
      if (_closed ||
          entry != _entryGeneration ||
          !identical(Get.rawRoute, route) ||
          route?.isCurrent == false) {
        return;
      }
      final transfer = response is Map
          ? Map<String, dynamic>.from(response)
          : stockTransfer;
      final index = this.stockTransfer.indexWhere((r) => r['id'] == id);
      if (index >= 0) this.stockTransfer[index] = transfer;
      searchStockTransfer(_query);
      Get.toNamed(AppRoutes.stockTransferDetail, arguments: transfer);
    } catch (error) {
      if (_closed ||
          entry != _entryGeneration ||
          !identical(Get.rawRoute, route) ||
          route?.isCurrent == false) {
        return;
      }
      formError.value = 'Unable to open stock transfer. Please try again.';
      Get.toNamed(AppRoutes.stockTransferDetail, arguments: stockTransfer);
    }
  }

  Future<void> editStockTransfer(
    BuildContext context,
    Map<String, dynamic> stockTransfer,
  ) async {
    if (_closed || isSaving.value || isOpeningEdit.value || _formOpen) return;
    final entry = ++_entryGeneration;
    final route = ModalRoute.of(context);
    isOpeningEdit.value = true;
    try {
      final response = await service.getProductTransferById(
        stockTransfer["id"],
      );

      if (_closed ||
          entry != _entryGeneration ||
          !context.mounted ||
          route?.isCurrent != true) {
        return;
      }
      if (response is! Map) throw const FormatException();
      final transfer = Map<String, dynamic>.from(response);
      onClear();
      editingTransfer.value = transfer;
      selectedFromWarehouse.value = int.tryParse(
        transfer['from_warehouse_id']?.toString() ??
            transfer['from_warehouse']?['id']?.toString() ??
            '',
      );
      selectedToWarehouse.value = int.tryParse(
        transfer['to_warehouse_id']?.toString() ??
            transfer['to_warehouse']?['id']?.toString() ??
            '',
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
        items.map((item) {
          final product = item['product'] is Map
              ? Map<String, dynamic>.from(item['product'] as Map)
              : <String, dynamic>{};
          return {
            'product_id': int.tryParse(
              item['product_id']?.toString() ?? product['id']?.toString() ?? '',
            ),
            'product': product,
            'qty': int.tryParse(item['qty']?.toString() ?? '') ?? 0,
          };
        }),
      );
      await onGetWarehouseStock();
      if (_closed ||
          entry != _entryGeneration ||
          !context.mounted ||
          route?.isCurrent != true) {
        return;
      }
      _formOpen = true;
      isOpeningEdit.value = false;
      await AppFormShell.show(context, EditStockTransferWidget());
    } catch (e) {
      if (!_closed &&
          entry == _entryGeneration &&
          context.mounted &&
          route?.isCurrent == true) {
        formError.value = 'Unable to open stock transfer. Please try again.';
      }
    } finally {
      _formOpen = false;
      if (!_closed) isOpeningEdit.value = false;
    }
  }

  Future<void> onUpdate(
    BuildContext context,
    Map<String, dynamic> stockTransfer,
  ) => _save(context, original: stockTransfer);

  Future<void> onDeleteStockTransfer(
    BuildContext context,
    int productTransferId, {
    bool closeDetailOnSuccess = false,
  }) async {
    if (_closed ||
        isSaving.value ||
        isOpeningEdit.value ||
        _formOpen ||
        _confirmingDelete) {
      return;
    }
    final route = ModalRoute.of(context), navigator = Navigator.of(context);
    _confirmingDelete = true;
    showConfirmDialog(
      context: context,
      message: 'Do you want to delete this stock transfer?'.tr,
      onConfirm: () async {
        if (_closed || isSaving.value) return;
        isSaving.value = true;
        formError.value = '';
        try {
          await service.deleteProductTransfer(productTransferId);
        } catch (_) {
          if (!_closed) {
            formError.value =
                'Unable to delete stock transfer. Please try again.';
            isSaving.value = false;
          }
          return;
        }
        if (_closed) return;
        ++_listGeneration;
        ++_stockGeneration;
        stockTransfer.removeWhere((r) => r['id'] == productTransferId);
        searchStockTransfer(_query);
        await _refreshAfterWrite();
        if (_closed) return;
        isSaving.value = false;
        if (closeDetailOnSuccess &&
            context.mounted &&
            route?.isCurrent == true &&
            route?.settings.name == AppRoutes.stockTransferDetail &&
            navigator.canPop()) {
          navigator.pop();
        }
      },
      onCancel: () {},
    ).whenComplete(() => _confirmingDelete = false);
  }
}
