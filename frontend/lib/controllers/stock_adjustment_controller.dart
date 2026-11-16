import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/utils/stock_refresh.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/add_stock_adjustment_widget.dart';
import 'package:frontend/screen/stock/stock_adjustment/widget/edit_stock_adjustment_type_widget.dart';
import 'package:frontend/services/main_service/stock_adjustment_service.dart';
import 'package:frontend/services/main_service/warehouse_stock_service.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:get/get.dart';

class StockAdjustmentController extends GetxController {
  StockAdjustmentController({
    StockAdjustmentService? service,
    WarehouseStockService? warehouseStockService,
    int? Function()? currentUserId,
    Future<void> Function()? onStockChanged,
  }) : service = service ?? StockAdjustmentService(),
       warehouseStockService = warehouseStockService ?? WarehouseStockService(),
       _currentUserId = currentUserId ?? _storedUserId,
       _onStockChanged = onStockChanged ?? refreshStockReadModels {
    adjustmentQtyController.addListener(calculateNewQty);
    _workers.addAll([
      ever(selectedWarehouse, (_) => _selectionChanged()),
      ever(selectedProduct, (_) => _selectionChanged()),
      ever(selectedAdjustmentType, (_) => calculateNewQty()),
      ever(editingAdjustment, (_) => calculateNewQty()),
    ]);
  }
  final StockAdjustmentService service;
  final WarehouseStockService warehouseStockService;
  final int? Function() _currentUserId;
  final Future<void> Function() _onStockChanged;
  final isLoading = false.obs, isSaving = false.obs, isOpeningEdit = false.obs;
  final isStockLoading = false.obs, currentQtyKnown = false.obs;
  final loadError = ''.obs, formError = ''.obs, stockError = ''.obs;
  final selectedProduct = RxnString(),
      selectedWarehouse = RxnString(),
      selectedAdjustmentType = RxnString();
  final editingAdjustment = Rxn<Map<String, dynamic>>();
  final currentQty = 0.obs;
  final referenceController = TextEditingController(),
      adjustmentQtyController = TextEditingController(),
      reasonController = TextEditingController(),
      currentQtyController = TextEditingController(),
      newQtyController = TextEditingController();
  final stockAdjustmentList = <Map<String, dynamic>>[].obs,
      searchStockAdjustmentList = <Map<String, dynamic>>[].obs;
  final key = GlobalKey<FormState>();
  final _workers = <Worker>[];
  int _stockGeneration = 0,
      _listGeneration = 0,
      _revision = 0,
      _formGeneration = 0;
  int? _liveQty;
  String? _knownPair;
  String _query = '';
  bool _formOpen = false, _confirmingDelete = false, _disposed = false;
  static int? _storedUserId() {
    try {
      return int.tryParse(storage.lastUserLoginRead['user']['id'].toString());
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    final search = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    _query = search.keyword.value;
    _workers.add(ever(search.keyword, searchStockAdjustment));
    getStockAdjustments();
  }

  String get _pair => '${selectedWarehouse.value}/${selectedProduct.value}';
  static int? _id(dynamic value) {
    final id = int.tryParse('$value');
    return id != null && id > 0 ? id : null;
  }

  static dynamic _relationId(Map<String, dynamic> record, String name) =>
      record['${name}_id'] ?? (record[name] is Map ? record[name]['id'] : null);
  void _selectionChanged() {
    _stockGeneration++;
    _liveQty = null;
    _knownPair = null;
    currentQtyKnown.value = false;
    isStockLoading.value = false;
    stockError.value = '';
    currentQtyController.clear();
    newQtyController.clear();
    currentQty.value = 0;
  }

  void clearForm() {
    _formGeneration++;
    _selectionChanged();
    editingAdjustment.value = null;
    selectedProduct.value = null;
    selectedWarehouse.value = null;
    selectedAdjustmentType.value = null;
    referenceController.clear();
    adjustmentQtyController.clear();
    reasonController.clear();
    formError.value = '';
  }

  Future<void> loadCurrentQty() async {
    final generation = ++_stockGeneration;
    final pair = _pair;
    final warehouseId = _id(selectedWarehouse.value),
        productId = _id(selectedProduct.value);
    currentQtyKnown.value = false;
    stockError.value = '';
    _liveQty = null;
    _knownPair = null;
    currentQtyController.clear();
    newQtyController.clear();
    if (warehouseId == null || productId == null) {
      isStockLoading.value = false;
      return;
    }
    isStockLoading.value = true;
    try {
      final stock = await warehouseStockService.getProductStock(
        warehouseId: warehouseId,
        productId: productId,
      );
      if (_disposed || generation != _stockGeneration || pair != _pair) return;
      final qty = stock is Map ? stock['qty'] : null;
      if (qty is! int || qty < 0) throw const FormatException();
      _liveQty = qty;
      _knownPair = pair;
      currentQtyKnown.value = true;
      calculateNewQty();
    } catch (_) {
      if (!_disposed && generation == _stockGeneration && pair == _pair) {
        stockError.value = 'Unable to load current stock. Please try again.';
      }
    } finally {
      if (!_disposed && generation == _stockGeneration) {
        isStockLoading.value = false;
      }
    }
  }

  int? get _baseline {
    if (!currentQtyKnown.value || _knownPair != _pair || _liveQty == null) {
      return null;
    }
    var baseline = _liveQty!;
    final original = editingAdjustment.value;
    if (original != null &&
        '${_relationId(original, 'warehouse')}' == selectedWarehouse.value &&
        '${_relationId(original, 'product')}' == selectedProduct.value) {
      final qty = int.tryParse('${original['qty']}');
      if (qty == null ||
          qty <= 0 ||
          !['increase', 'decrease'].contains(original['adjustment_type'])) {
        return null;
      }
      baseline += original['adjustment_type'] == 'increase' ? -qty : qty;
    }
    return baseline;
  }

  int? get draftQty {
    final text = adjustmentQtyController.text.trim();
    return RegExp(r'^\d+$').hasMatch(text) ? int.tryParse(text) : null;
  }

  void calculateNewQty() {
    if (_disposed) return;
    final baseline = _baseline, qty = draftQty;
    if (baseline == null) {
      currentQtyController.clear();
      newQtyController.clear();
      return;
    }
    currentQty.value = baseline;
    currentQtyController.text = '$baseline';
    if (qty == null ||
        qty <= 0 ||
        !['increase', 'decrease'].contains(selectedAdjustmentType.value)) {
      newQtyController.clear();
      return;
    }
    newQtyController.text =
        '${baseline + (selectedAdjustmentType.value == 'increase' ? qty : -qty)}';
  }

  String? _inputError() {
    if (_id(selectedWarehouse.value) == null) {
      return 'Please select a warehouse';
    } else if (_id(selectedProduct.value) == null) {
      return 'Select a product';
    } else if (![
      'increase',
      'decrease',
    ].contains(selectedAdjustmentType.value)) {
      return 'Please select an adjustment type';
    } else if (draftQty == null || draftQty! <= 0) {
      return 'Enter a whole quantity greater than zero';
    }
    return null;
  }

  bool validateDraft() {
    String? error = _inputError();
    if (error != null) {
      formError.value = error;
      return false;
    }
    if (_baseline == null) {
      error = 'Unable to load current stock. Please try again.';
    } else if (_baseline! < 0 ||
        (selectedAdjustmentType.value == 'decrease' &&
            draftQty! > _baseline!)) {
      error = 'Quantity exceeds available stock.';
    }
    formError.value = error ?? '';
    return error == null;
  }

  Future<void> getStockAdjustments() async {
    if (_disposed) return;
    final generation = ++_listGeneration, revision = _revision;
    isLoading.value = true;
    loadError.value = '';
    try {
      final response = await service.getStockAdjustments();
      if (_disposed || generation != _listGeneration || revision != _revision) {
        return;
      }
      if (response is! List) throw const FormatException();
      stockAdjustmentList.assignAll(List<Map<String, dynamic>>.from(response));
      searchStockAdjustment(_query);
    } catch (_) {
      if (!_disposed &&
          generation == _listGeneration &&
          revision == _revision) {
        loadError.value = 'Unable to load stock adjustments. Please try again.';
      }
    } finally {
      if (!_disposed && generation == _listGeneration) isLoading.value = false;
    }
  }

  Future<void> onRefresh() => getStockAdjustments();
  void searchStockAdjustment(String keyword) {
    if (_disposed) return;
    _query = keyword;
    final query = keyword.trim().toLowerCase();
    searchStockAdjustmentList.assignAll(
      stockAdjustmentList.where(
        (record) =>
            [
              if (record['product'] is Map) record['product']['name'],
              if (record['warehouse'] is Map) record['warehouse']['name'],
              record['adjustment_type'],
              record['reference_no'],
            ].any(
              (value) => (value ?? '').toString().toLowerCase().contains(query),
            ),
      ),
    );
  }

  Future<void> _showForm(BuildContext context, Widget child) async {
    _formOpen = true;
    try {
      await AppFormShell.show(context, child);
    } finally {
      _formOpen = false;
      if (!_disposed && !isSaving.value) clearForm();
    }
  }

  Future<void> addStockAdjustment(BuildContext context) async {
    if (_disposed || _formOpen || isSaving.value || isOpeningEdit.value) return;
    clearForm();
    await _showForm(context, const AddStockAdjustmentWidget());
  }

  Future<void> editStockAdjustment(
    BuildContext context,
    int stockAdjustmentId,
  ) async {
    if (_disposed || _formOpen || isSaving.value || isOpeningEdit.value) return;
    final route = ModalRoute.of(context), generation = ++_formGeneration;
    isOpeningEdit.value = true;
    formError.value = '';
    try {
      final response = await service.getStockAdjustmentById(stockAdjustmentId);
      if (_disposed ||
          !context.mounted ||
          route?.isCurrent != true ||
          generation != _formGeneration) {
        return;
      }
      final record = Map<String, dynamic>.from(response);
      if (_id(record['id']) != stockAdjustmentId) throw const FormatException();
      clearForm();
      editingAdjustment.value = record;
      selectedProduct.value = _relationId(record, 'product')?.toString();
      selectedWarehouse.value = _relationId(record, 'warehouse')?.toString();
      selectedAdjustmentType.value = record['adjustment_type']?.toString();
      adjustmentQtyController.text = '${record['qty'] ?? ''}';
      referenceController.text = '${record['reference_no'] ?? ''}';
      reasonController.text = '${record['reason'] ?? ''}';
      loadCurrentQty();
      if (context.mounted) {
        _showForm(
          context,
          EditStockAdjustmentTypeWidget(stockAdjustmentId: stockAdjustmentId),
        );
      }
    } catch (_) {
      if (!_disposed) {
        formError.value = 'Unable to open stock adjustment. Please try again.';
      }
    } finally {
      if (!_disposed) isOpeningEdit.value = false;
    }
  }

  Future<void> onSaveStockAdjustment(BuildContext context) => _save(context);
  Future<void> onUpdateStockAdjustment(
    BuildContext context,
    int stockAdjustmentId,
  ) => _save(context, id: stockAdjustmentId);
  Future<void> _save(BuildContext context, {int? id}) async {
    if (_disposed || isSaving.value) return;
    formError.value = _inputError() ?? '';
    if (formError.isNotEmpty) return;
    if (!currentQtyKnown.value || _baseline == null) {
      validateDraft();
      return;
    }
    if (id != null && _id(editingAdjustment.value?['id']) != id) {
      formError.value = 'Unable to open stock adjustment. Please try again.';
      return;
    }
    final route = ModalRoute.of(context),
        navigator = Navigator.of(context),
        generation = _formGeneration;
    final pair = _pair;
    isSaving.value = true;
    try {
      // The write guard includes the fresh preflight lookup.
      await loadCurrentQty();
      if (_disposed ||
          !context.mounted ||
          route?.isCurrent != true ||
          generation != _formGeneration ||
          pair != _pair ||
          !validateDraft()) {
        return;
      }
      int? userId;
      try {
        userId = _currentUserId();
      } catch (_) {
        userId = null;
      }
      if (userId == null || userId <= 0) {
        formError.value = 'Sign in again to save this adjustment.';
        return;
      }
      final data = <String, dynamic>{
        'product_id': _id(selectedProduct.value)!,
        'warehouse_id': _id(selectedWarehouse.value)!,
        'adjustment_type': selectedAdjustmentType.value,
        'user_id': userId,
        'qty': draftQty!,
        'reason': reasonController.text.trim(),
        'reference_no': referenceController.text.trim(),
      };
      dynamic response;
      try {
        response = id == null
            ? await service.createStockAdjustment(data)
            : await service.updateStockAdjustment(id, data);
      } catch (_) {
        if (!_disposed) {
          formError.value =
              'Unable to save stock adjustment. Please try again.';
        }
        return;
      }
      if (_disposed) return;
      _revision++;
      ++_listGeneration;
      if (response is Map && _id(response['id']) != null) {
        final record = Map<String, dynamic>.from(response);
        final index = stockAdjustmentList.indexWhere(
          (e) => e['id'] == record['id'],
        );
        if (index < 0) {
          stockAdjustmentList.add(record);
        } else {
          stockAdjustmentList[index] = record;
        }
        searchStockAdjustment(_query);
      }
      // A committed write must never become a retryable form error.
      if (context.mounted && route is PopupRoute && route.isCurrent) {
        navigator.pop();
      }
      clearForm();
      await _afterStockChanged();
    } finally {
      if (!_disposed) isSaving.value = false;
    }
  }

  Future<void> _afterStockChanged() async {
    await Future.wait([
      getStockAdjustments(),
      () async {
        try {
          await _onStockChanged();
          if (Get.isRegistered<WarehouseStockController>() &&
              !Get.isPrepared<WarehouseStockController>()) {
            await Get.find<WarehouseStockController>().getWarehouseStock();
          }
        } catch (_) {
          /* Never retry a committed movement. */
        }
      }(),
    ]);
  }

  Future<void> onDeleteStockAdjustment(
    int stockAdjustmentId,
    BuildContext context, {
    bool closeDetailOnSuccess = false,
  }) async {
    if (_disposed ||
        isSaving.value ||
        _confirmingDelete ||
        _formOpen ||
        isOpeningEdit.value) {
      return;
    }
    final route = ModalRoute.of(context), navigator = Navigator.of(context);
    _confirmingDelete = true;
    try {
      var confirmed = false;
      await showConfirmDialog(
        context: context,
        title: 'Confirm'.tr,
        cancelText: 'Cancel'.tr,
        confirmText: 'Ok'.tr,
        message: 'Do you want to delete this stock adjustment?'.tr,
        onConfirm: () {
          confirmed = true;
        },
      );
      if (!confirmed ||
          _disposed ||
          !context.mounted ||
          route?.isCurrent != true) {
        return;
      }
      isSaving.value = true;
      formError.value = '';
      try {
        await service.deleteStockAdjustment(stockAdjustmentId);
      } catch (_) {
        if (!_disposed) {
          formError.value =
              'Unable to delete stock adjustment. Please try again.';
        }
        return;
      }
      if (_disposed) return;
      _revision++;
      ++_listGeneration;
      stockAdjustmentList.removeWhere((e) => e['id'] == stockAdjustmentId);
      searchStockAdjustment(_query);
      if (closeDetailOnSuccess &&
          context.mounted &&
          route?.isCurrent == true &&
          route?.settings.name == AppRoutes.stockAdjustmentDetail) {
        navigator.pop();
      }
      await _afterStockChanged();
    } finally {
      _confirmingDelete = false;
      if (!_disposed) isSaving.value = false;
    }
  }

  void gotoStockAdjustmentDetailScreen(Map<String, dynamic> stockAdjustment) =>
      Get.toNamed(AppRoutes.stockAdjustmentDetail, arguments: stockAdjustment);
  @override
  void onClose() {
    if (_disposed) return;
    _disposed = true;
    _stockGeneration++;
    _listGeneration++;
    _formGeneration++;
    for (final worker in _workers) {
      worker.dispose();
    }
    adjustmentQtyController.removeListener(calculateNewQty);
    for (final controller in [
      referenceController,
      adjustmentQtyController,
      reasonController,
      currentQtyController,
      newQtyController,
    ]) {
      controller.dispose();
    }
    super.onClose();
  }
}
