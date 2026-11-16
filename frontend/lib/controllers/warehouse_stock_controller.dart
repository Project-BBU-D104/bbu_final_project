import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/utils/stock_refresh.dart' as stock_refresh;
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/services/main_service/warehouse_stock_service.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/screen/stock/warehouse_stock/widget/add_warehouse_stock_widget.dart';
import 'package:frontend/screen/stock/warehouse_stock/widget/edit_warehouse_stock_widget.dart';

class WarehouseStockController extends GetxController {
  WarehouseStockController({
    WarehouseStockService? service,
    Future<void> Function()? onStockChanged,
  }) : service = service ?? WarehouseStockService(),
       _onStockChanged = onStockChanged;
  final WarehouseStockService service;
  final Future<void> Function()? _onStockChanged;
  final isLoading = false.obs, isSaving = false.obs, isOpeningEdit = false.obs;
  final loadError = ''.obs, formError = ''.obs, searchQuery = ''.obs;
  final warehouseStockList = <Map<String, dynamic>>[].obs;
  final searchwarehouseStockList = <Map<String, dynamic>>[].obs;
  final selectedWarehouse = RxnString(), selectedProduct = RxnString();
  final editingStockId = RxnInt();
  final productRows = <Map<String, dynamic>>[].obs;
  final warehouseStockQtyController = TextEditingController();
  Worker? _searchWorker;
  int _request = 0, _entry = 0;
  bool _closed = false, _formOpen = false, _confirmingDelete = false;

  @override
  void onInit() {
    super.onInit();
    onClearWarehouseStock();
    final search = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    searchWarehouseStock(search.keyword.value);
    _searchWorker = ever(search.keyword, searchWarehouseStock);
    getWarehouseStock();
  }

  void _disposeRows() {
    for (final row in productRows) {
      (row['qty'] as TextEditingController).dispose();
    }
    productRows.clear();
  }

  void addProductRow() {
    if (isSaving.value || editingStockId.value != null) return;
    productRows.add({'product': RxnString(), 'qty': TextEditingController()});
  }

  void removeProductRow(int index) {
    if (isSaving.value ||
        editingStockId.value != null ||
        productRows.length <= 1 ||
        index < 0 ||
        index >= productRows.length) {
      return;
    }
    final row = productRows.removeAt(index);
    (row['qty'] as TextEditingController).dispose();
  }

  void onClearWarehouseStock() {
    if (isSaving.value) return;
    _disposeRows();
    editingStockId.value = null;
    selectedWarehouse.value = null;
    selectedProduct.value = null;
    warehouseStockQtyController.clear();
    formError.value = '';
    addProductRow();
  }

  Future<void> getWarehouseStock() async {
    final request = ++_request;
    isLoading.value = true;
    try {
      final response = await service.getWarehouseStock();
      if (_closed || request != _request) return;
      if (response is! List) throw const FormatException();
      warehouseStockList.assignAll(List<Map<String, dynamic>>.from(response));
      searchWarehouseStock(searchQuery.value);
      loadError.value = '';
    } catch (_) {
      if (!_closed && request == _request) {
        loadError.value =
            'Unable to load warehouse stock. Please try again.'.tr;
      }
    } finally {
      if (!_closed && request == _request) isLoading.value = false;
    }
  }

  Future<void> onRefresh() => getWarehouseStock();
  void searchWarehouseStock(String keyword) {
    searchQuery.value = keyword;
    final q = keyword.trim().toLowerCase();
    searchwarehouseStockList.assignAll(
      warehouseStockList.where(
        (r) =>
            q.isEmpty ||
            [
              'id',
              'warehouse_id',
              'product_id',
            ].any((k) => '${r[k] ?? ''}'.toLowerCase().contains(q)) ||
            ['warehouse', 'product'].any(
              (k) => '${r[k] is Map ? r[k]['name'] ?? '' : ''}'
                  .toLowerCase()
                  .contains(q),
            ),
      ),
    );
  }

  String? quantityError(String? text) =>
      RegExp(r'^\d+$').hasMatch((text ?? '').trim()) &&
          int.tryParse((text ?? '').trim()) != null
      ? null
      : 'Enter a whole quantity of zero or more'.tr;
  bool validateDraft() {
    String? error;
    if ((int.tryParse(selectedWarehouse.value ?? '') ?? 0) <= 0) {
      error = 'Please select a warehouse';
    }
    if (productRows.isEmpty ||
        (editingStockId.value != null && productRows.length != 1)) {
      error ??= 'Add at least one product';
    }
    final seen = <int>{};
    for (final row in productRows) {
      final id = int.tryParse((row['product'] as RxnString).value ?? '') ?? 0;
      if (id <= 0) {
        error ??= 'Select a product';
      } else if (!seen.add(id)) {
        error ??= 'Select each product only once';
      }
      if (quantityError((row['qty'] as TextEditingController).text) != null) {
        error ??= 'Enter a whole quantity of zero or more';
      }
    }
    formError.value = error?.tr ?? '';
    return error == null;
  }

  Map<String, dynamic> _payload() => {
    'warehouse_id': int.parse(selectedWarehouse.value!),
    'items': productRows
        .map(
          (r) => {
            'product_id': int.parse((r['product'] as RxnString).value!),
            'qty': int.parse((r['qty'] as TextEditingController).text.trim()),
          },
        )
        .toList(),
  };
  Future<void> refreshStockReadModels() =>
      stock_refresh.refreshStockReadModels();

  Future<void> _changed() async {
    try {
      await (_onStockChanged?.call() ?? refreshStockReadModels());
    } catch (_) {}
  }

  Future<void> addWarehouseStock(BuildContext context) async {
    if (_formOpen || isSaving.value || isOpeningEdit.value) return;
    ++_entry;
    onClearWarehouseStock();
    _formOpen = true;
    try {
      await AppFormShell.show(context, const AddWarehouseStockWidget());
    } finally {
      _formOpen = false;
    }
  }

  Future<void> editWarehouseStock(BuildContext context, int id) async {
    if (_formOpen || isSaving.value || isOpeningEdit.value) return;
    final entry = ++_entry;
    final route = ModalRoute.of(context);
    isOpeningEdit.value = true;
    try {
      final stock = await service.getWarehouseStockById(id);
      if (_closed ||
          entry != _entry ||
          !context.mounted ||
          (route != null && !route.isCurrent)) {
        return;
      }
      onClearWarehouseStock();
      editingStockId.value = id;
      selectedWarehouse.value = '${stock['warehouse_id']}';
      (productRows.single['product'] as RxnString).value =
          '${stock['product_id'] ?? stock['product']?['id']}';
      (productRows.single['qty'] as TextEditingController).text =
          '${stock['qty']}';
      _formOpen = true;
      await AppFormShell.show(
        context,
        EditWarehouseStockWidget(warehouseStockId: id),
      );
    } catch (_) {
      if (!_closed) {
        formError.value =
            'Unable to open warehouse stock. Please try again.'.tr;
      }
    } finally {
      _formOpen = false;
      if (!_closed) isOpeningEdit.value = false;
    }
  }

  Future<void> onSaveWarehouseStock(BuildContext context) => _save(context);
  Future<void> onUpdateWarehouseStock(int id, BuildContext context) =>
      _save(context, id: id);
  Future<void> _save(BuildContext context, {int? id}) async {
    if (_closed || isSaving.value || !context.mounted) return;
    final route = ModalRoute.of(context);
    if (route?.isCurrent != true) return;
    if (id != null && (productRows.length != 1 || editingStockId.value != id)) {
      formError.value = 'Add at least one product'.tr;
      return;
    }
    if (!validateDraft()) {
      return;
    }
    final navigator = Navigator.of(context);
    isSaving.value = true;
    final data = _payload();
    try {
      if (id == null) {
        await service.createWarehouseStock(data);
      } else {
        await service.updateWarehouseStock(id, data);
      }
    } catch (_) {
      if (!_closed) {
        formError.value =
            'Unable to save warehouse stock. Please try again.'.tr;
        isSaving.value = false;
      }
      return;
    }
    if (_closed) return;
    // A committed write remains successful even when a subsequent read fails.
    ++_request;
    if (id != null) {
      final index = warehouseStockList.indexWhere((row) => row['id'] == id);
      if (index >= 0) {
        final original = warehouseStockList[index];
        final item = (data['items'] as List).single as Map<String, dynamic>;
        warehouseStockList[index] = {
          ...original,
          'warehouse_id': data['warehouse_id'],
          ...item,
          if (original['warehouse_id'] != data['warehouse_id'])
            'warehouse': null,
          if (original['product_id'] != item['product_id']) 'product': null,
        };
        searchWarehouseStock(searchQuery.value);
      }
    }
    isSaving.value = false;
    if (context.mounted &&
        route != null &&
        route.isCurrent &&
        navigator.canPop()) {
      navigator.pop();
    }
    await Future.wait([getWarehouseStock(), _changed()]);
  }

  Future<void> onDeleteWarehouseStock(int id, BuildContext context) async {
    if (_closed ||
        isSaving.value ||
        isOpeningEdit.value ||
        _formOpen ||
        _confirmingDelete) {
      return;
    }
    _confirmingDelete = true;
    showConfirmDialog(
      context: context,
      message: 'Do you want to delete this warehouse stock?'.tr,
      onConfirm: () async {
        if (_closed || isSaving.value) return;
        isSaving.value = true;
        try {
          await service.deleteWarehouseStock(id);
        } catch (_) {
          formError.value =
              'Unable to delete warehouse stock. Please try again.'.tr;
          isSaving.value = false;
          return;
        }
        if (_closed) return;
        ++_request;
        warehouseStockList.removeWhere((r) => r['id'] == id);
        searchWarehouseStock(searchQuery.value);
        await Future.wait([getWarehouseStock(), _changed()]);
        if (!_closed) isSaving.value = false;
      },
      onCancel: () {},
    ).whenComplete(() => _confirmingDelete = false);
  }

  @override
  void onClose() {
    _closed = true;
    ++_request;
    ++_entry;
    _searchWorker?.dispose();
    _disposeRows();
    warehouseStockQtyController.dispose();
    super.onClose();
  }
}
