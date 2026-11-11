import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/unit/widget/add_unit_widget.dart';
import 'package:frontend/screen/unit/widget/edit_unit_widget.dart';
import 'package:frontend/services/main_service/unit_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class UnitController extends GetxController {
  UnitController({UnitService? service}) : service = service ?? UnitService();

  final UnitService service;

  // Shared cache so re-opening the screen does not re-fetch every time.
  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  final unitList = <Map<String, dynamic>>[].obs;
  final searchUnitList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  final loadError = ''.obs;
  final isSaving = false.obs;
  final isOpeningEdit = false.obs;
  final formError = ''.obs;
  final unitNameController = TextEditingController();
  final unitShortNameController = TextEditingController();
  final unitDescriptionController = TextEditingController();
  final isActive = false.obs;
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
    _searchWorker = ever(search.keyword, searchUnit);

    if (_hasFreshCache) {
      unitList.assignAll(_cache);
      searchUnit(_query);
    } else {
      getUnitList();
    }
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    unitNameController.dispose();
    unitShortNameController.dispose();
    unitDescriptionController.dispose();
    super.onClose();
  }

  Future<void> getUnitList() async {
    if (isLoading.value || isClosed) return;
    isLoading.value = true;
    loadError.value = '';
    final revision = _dataRevision;
    try {
      final resp = await service.getUnits();
      if (isClosed || revision != _dataRevision) return;
      if (resp is! List) throw const FormatException('Expected unit list');
      unitList.assignAll(
        resp.map((item) => Map<String, dynamic>.from(item as Map)),
      );
      searchUnit(_query);
      _cache
        ..clear()
        ..addAll(unitList);
      _cachedAt = DateTime.now();
    } catch (_) {
      if (!isClosed) {
        loadError.value = 'Unable to load units. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> onRefresh() => getUnitList();

  void searchUnit(String keyword) {
    _query = keyword.trim().toLowerCase();
    searchUnitList.assignAll(
      _query.isEmpty
          ? unitList
          : unitList.where((unit) {
              final name = (unit['name'] ?? '').toString().toLowerCase();
              final shortName = (unit['short_name'] ?? '')
                  .toString()
                  .toLowerCase();
              return name.contains(_query) || shortName.contains(_query);
            }),
    );
  }

  void clearUnit() {
    unitNameController.clear();
    unitShortNameController.clear();
    unitDescriptionController.clear();
    isActive.value = false;
  }

  void addUnit(BuildContext context) {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    clearUnit();
    formError.value = '';
    _showForm(context, AddUnitWidget());
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

  Future<void> onEditUnit(int unitId, BuildContext context) async {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    final route = ModalRoute.of(context);
    isOpeningEdit.value = true;
    formError.value = '';
    try {
      final unit = await service.getUnitById(unitId);
      if (isClosed || !context.mounted || route?.isCurrent != true) return;
      final data = Map<String, dynamic>.from(unit as Map);
      unitNameController.text = (data['name'] ?? '').toString();
      unitShortNameController.text = (data['short_name'] ?? '').toString();
      unitDescriptionController.text = (data['description'] ?? '').toString();
      isActive.value = data['status'] == true;
      _showForm(context, EditUnitWidget(unitId: unitId));
    } catch (_) {
      if (!isClosed) {
        ToastWidget.show(
          message: 'Unable to open unit. Please try again.'.tr,
          type: ToastType.error,
        );
      }
    } finally {
      if (!isClosed) isOpeningEdit.value = false;
    }
  }

  Future<void> onSaveUnit(BuildContext context) => _save(context);

  Future<void> onUpdateUnit(int unitId, BuildContext context) =>
      _save(context, unitId: unitId);

  Future<void> _save(BuildContext context, {int? unitId}) async {
    if (isSaving.value || isClosed) return;
    formError.value = '';
    final name = unitNameController.text.trim();
    if (name.isEmpty) {
      formError.value = 'Unit name is required'.tr;
      return;
    }
    final shortName = unitShortNameController.text.trim();
    if (shortName.isEmpty) {
      formError.value = 'Short name is required'.tr;
      return;
    }
    final data = <String, dynamic>{
      'name': name,
      'short_name': shortName,
      'description': unitDescriptionController.text.trim(),
      'status': isActive.value,
    };
    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    isSaving.value = true;
    dynamic response;
    try {
      response = unitId == null
          ? await service.createUnit(data)
          : await service.updateUnit(unitId, data);
    } catch (_) {
      if (!isClosed) {
        formError.value = 'Unable to save unit. Please try again.'.tr;
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
      final index = unitList.indexWhere((unit) => unit['id'] == record['id']);
      if (index < 0) {
        unitList.add(record);
      } else {
        unitList[index] = record;
      }
      _updateCache();
    } catch (_) {
      _cachedAt = null;
    }
    searchUnit(_query);
    if (context.mounted && route is PopupRoute && route.isCurrent) {
      navigator.pop();
    }
    await getUnitList();
    if (!isClosed) {
      ToastWidget.show(
        message:
            (unitId == null
                    ? 'Unit created successfully'
                    : 'Unit updated successfully')
                .tr,
        type: ToastType.success,
      );
    }
  }

  Future<void> onDeleteUnit(int unitId, BuildContext context) async {
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
        message: 'Do you want to delete this unit?'.tr,
        onConfirm: () async {
          if (isClosed || !context.mounted || route?.isCurrent != true) return;
          isSaving.value = true;
          formError.value = '';
          try {
            await service.deleteUnit(unitId);
            _cachedAt = null;
            if (isClosed) return;
            _dataRevision++;
            unitList.removeWhere((unit) => unit['id'] == unitId);
            _updateCache();
            searchUnit(_query);
            ToastWidget.show(
              message: 'Unit deleted successfully'.tr,
              type: ToastType.success,
            );
          } catch (_) {
            if (!isClosed) {
              ToastWidget.show(
                message: 'Unable to delete unit. Please try again.'.tr,
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
      ..addAll(unitList);
    _cachedAt = DateTime.now();
  }
}
