import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/stock/warehouse/widget/add_warehouse_widget.dart';
import 'package:frontend/screen/stock/warehouse/widget/edit_warehouse_widget.dart';
import 'package:frontend/services/main_service/warehouse_service.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:get/get.dart';

class WarehouseController extends GetxController {
  WarehouseController({WarehouseService? service})
    : service = service ?? WarehouseService();
  final WarehouseService service;
  final isLoading = false.obs, isSaving = false.obs, isOpeningEdit = false.obs;
  final loadError = ''.obs, formError = ''.obs, searchQuery = ''.obs;
  final warehouseList = <Map<String, dynamic>>[].obs;
  final searchWarehouseList = <Map<String, dynamic>>[].obs;
  final warehouseNameController = TextEditingController();
  final warehouseReferenceNoController = TextEditingController();
  final warehouseLocationController = TextEditingController();
  final warehouseNoteController = TextEditingController();
  final key = GlobalKey<FormState>();
  Worker? _searchWorker;
  int _loadGeneration = 0, _writeRevision = 0, _editGeneration = 0;
  bool _closed = false, _formOpen = false, _confirmingDelete = false;

  @override
  void onInit() {
    super.onInit();
    final search = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    searchWarehouse(search.keyword.value);
    _searchWorker = ever<String>(search.keyword, searchWarehouse);
    getWarehouses();
  }

  Future<void> getWarehouses() async {
    if (_closed) return;
    final generation = ++_loadGeneration, revision = _writeRevision;
    isLoading.value = true;
    loadError.value = '';
    try {
      final response = await service.getWarehouses();
      if (_closed ||
          generation != _loadGeneration ||
          revision != _writeRevision) {
        return;
      }
      if (response is! List) throw const FormatException();
      final records = List<Map<String, dynamic>>.from(response);
      warehouseList.assignAll(records);
      _filter();
    } catch (_) {
      if (!_closed &&
          generation == _loadGeneration &&
          revision == _writeRevision) {
        loadError.value = 'Unable to load warehouses. Please try again.';
      }
    } finally {
      if (!_closed && generation == _loadGeneration) isLoading.value = false;
    }
  }

  Future<void> onRefresh() => getWarehouses();
  void searchWarehouse(String keyword) {
    if (_closed) return;
    searchQuery.value = keyword;
    _filter();
  }

  void _filter() {
    final query = searchQuery.value.trim().toLowerCase();
    searchWarehouseList.assignAll(
      warehouseList.where(
        (row) => ['name', 'reference_no', 'location'].any(
          (key) => (row[key] ?? '').toString().toLowerCase().contains(query),
        ),
      ),
    );
  }

  void onClearWarehouse() {
    warehouseNameController.clear();
    warehouseReferenceNoController.clear();
    warehouseLocationController.clear();
    warehouseNoteController.clear();
    formError.value = '';
  }

  void gotoWarehouseDetail(Map<String, dynamic> warehouse) =>
      Get.toNamed(AppRoutes.warehouseDetail, arguments: warehouse);

  Future<void> addWarehouse(BuildContext context) async {
    if (_closed || _formOpen || isSaving.value || isOpeningEdit.value) return;
    _formOpen = true;
    onClearWarehouse();
    try {
      await AppFormShell.show(context, AddWarehouseWidget());
    } finally {
      _formOpen = false;
    }
  }

  Future<void> editWarehouse(BuildContext context, int warehouseId) async {
    if (_closed || _formOpen || isSaving.value || isOpeningEdit.value) return;
    final route = ModalRoute.of(context);
    final generation = ++_editGeneration;
    isOpeningEdit.value = true;
    formError.value = '';
    try {
      final row = await service.getWarehouseById(warehouseId);
      if (_closed ||
          generation != _editGeneration ||
          !context.mounted ||
          route?.isCurrent != true) {
        return;
      }
      if (row is! Map) throw const FormatException();
      warehouseNameController.text = (row['name'] ?? '').toString();
      warehouseReferenceNoController.text = (row['reference_no'] ?? '')
          .toString();
      warehouseLocationController.text = (row['location'] ?? '').toString();
      warehouseNoteController.text = (row['note'] ?? '').toString();
      _formOpen = true;
      isOpeningEdit.value = false;
      await AppFormShell.show(
        context,
        EditWarehouseWidget(warehouseId: warehouseId),
      );
    } catch (_) {
      if (!_closed && context.mounted && route?.isCurrent == true) {
        _feedback(context, 'Unable to open warehouse. Please try again.');
      }
    } finally {
      _formOpen = false;
      if (!_closed) isOpeningEdit.value = false;
    }
  }

  Map<String, dynamic> _payload() => {
    'name': warehouseNameController.text.trim(),
    'reference_no': warehouseReferenceNoController.text.trim(),
    'location': warehouseLocationController.text.trim(),
    'note': warehouseNoteController.text.trim(),
  };
  Future<void> onSaveWarehouse(BuildContext context) => _save(context);
  Future<void> onUpdateWarehouse(BuildContext context, int warehouseId) =>
      _save(context, warehouseId);
  Future<void> _save(BuildContext context, [int? id]) async {
    if (_closed || isSaving.value) return;
    final data = _payload();
    if (data['name'] == '' || data['location'] == '') return;
    final navigator = Navigator.of(context), route = ModalRoute.of(context);
    isSaving.value = true;
    formError.value = '';
    try {
      if (id == null) {
        await service.createWarehouse(data);
      } else {
        await service.updateWarehouse(id, data);
      }
    } catch (_) {
      if (!_closed) {
        formError.value = 'Unable to save warehouse. Please try again.';
        isSaving.value = false;
      }
      return;
    }
    if (_closed) return;
    // The write committed. Invalidate pre-write reads, even if readback fails.
    _writeRevision++;
    _loadGeneration++;
    if (id != null) {
      final index = warehouseList.indexWhere((r) => r['id'] == id);
      if (index >= 0) warehouseList[index] = {...warehouseList[index], ...data};
    }
    _filter();
    isSaving.value = false;
    if (context.mounted && route?.isCurrent == true && navigator.canPop()) {
      navigator.pop();
    }
    onClearWarehouse();
    await getWarehouses();
  }

  Future<void> deleteWarehouse(
    BuildContext context,
    int warehouseId, {
    bool closeDetailOnSuccess = false,
  }) async {
    if (_closed ||
        isSaving.value ||
        _confirmingDelete ||
        isOpeningEdit.value ||
        _formOpen) {
      return;
    }
    final navigator = Navigator.of(context), route = ModalRoute.of(context);
    _confirmingDelete = true;
    Future<void>? write;
    await showConfirmDialog(
      context: context,
      message: 'Do you want to delete this warehouse?'.tr,
      onConfirm: () {
        write = _delete(
          context,
          navigator,
          route,
          warehouseId,
          closeDetailOnSuccess,
        );
      },
    );
    if (write != null) await write;
    _confirmingDelete = false;
  }

  Future<void> _delete(
    BuildContext context,
    NavigatorState navigator,
    ModalRoute<dynamic>? route,
    int id,
    bool closeDetail,
  ) async {
    if (_closed || isSaving.value) return;
    isSaving.value = true;
    try {
      await service.deleteWarehouse(id);
    } catch (_) {
      if (!_closed) {
        isSaving.value = false;
        if (context.mounted) {
          _feedback(context, 'Unable to delete warehouse. Please try again.');
        }
      }
      return;
    }
    if (_closed) return;
    _writeRevision++;
    _loadGeneration++;
    warehouseList.removeWhere((row) => row['id'] == id);
    _filter();
    isSaving.value = false;
    if (closeDetail &&
        context.mounted &&
        route?.isCurrent == true &&
        navigator.canPop()) {
      navigator.pop();
    }
    await getWarehouses();
  }

  void _feedback(BuildContext context, String key) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(key.tr)));
  }

  @override
  void onClose() {
    _closed = true;
    _loadGeneration++;
    _editGeneration++;
    _searchWorker?.dispose();
    warehouseNameController.dispose();
    warehouseReferenceNoController.dispose();
    warehouseLocationController.dispose();
    warehouseNoteController.dispose();
    super.onClose();
  }
}
