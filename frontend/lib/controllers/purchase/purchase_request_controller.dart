import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/screen/purchase_request/widget/add_purchase_request_widget.dart';
import 'package:frontend/screen/purchase_request/widget/edit_purchase_request_widget.dart';
import 'package:frontend/services/main_service/purchase/purchase_request_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class PurchaseRequestLine {
  final Rxn<Map<String, dynamic>> selectedProduct = Rxn<Map<String, dynamic>>();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(
    text: "1",
  );
  int? itemId;

  void dispose() {
    unitController.dispose();
    quantityController.dispose();
  }
}

class PurchaseRequestController extends GetxController {
  PurchaseRequestController({
    PurchaseRequestService? service,
    WarehouseController? warehouses,
    ProductController? products,
  }) : service = service ?? PurchaseRequestService(),
       _warehouses = warehouses,
       _products = products;

  final PurchaseRequestService service;
  final WarehouseController? _warehouses;
  final ProductController? _products;

  late final WarehouseController warehouseController =
      _warehouses ?? Get.put(WarehouseController());
  late final ProductController productController =
      _products ?? Get.put(ProductController());

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isOpeningEdit = false.obs;
  final loadError = ''.obs;
  final formError = ''.obs;
  final requestList = <Map<String, dynamic>>[].obs;
  final searchRequestList = <Map<String, dynamic>>[].obs;
  final selectedWarehouseId = RxnInt();
  final requestStatus = "pending".obs;
  final requestDate = DateTime.now().obs;
  final approvedDate = DateTime.now().obs;
  final editingRequestId = RxnInt();
  final itemLines = <PurchaseRequestLine>[].obs;
  final removedItemIds = <int>[];
  final formKey = GlobalKey<FormState>();

  final requestTypeController = TextEditingController(text: "purchase");
  final requestedByController = TextEditingController();
  final approvedByController = TextEditingController(text: "Pending");
  final reasonController = TextEditingController();

  bool _formOpen = false;
  Worker? _searchWorker;
  String _query = '';

  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  @override
  void onInit() {
    super.onInit();
    final loggedInUser = storage.lastUserLoginRead["user"];
    if (loggedInUser is Map) {
      requestedByController.text = loggedInUser["name"]?.toString() ?? "";
    }
    itemLines.add(PurchaseRequestLine());

    final search = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    _query = search.keyword.value.trim().toLowerCase();
    _searchWorker = ever(search.keyword, searchRequests);

    warehouseController.getWarehouses();
    productController.getProducts();

    if (_hasFreshCache) {
      requestList.assignAll(_cache);
      searchRequests(_query);
    } else {
      onGetPurchaseRequests();
    }
  }

  Future<void> onGetPurchaseRequests() async {
    if (isLoading.value || isClosed) return;
    isLoading.value = true;
    loadError.value = '';
    try {
      final responses = await Future.wait([
        service.getPurchaseRequests(),
        service.getPurchaseRequestItems(),
      ]);
      final requests = responses[0];
      final items = responses[1];
      if (requests is! List) {
        throw const FormatException('Expected purchase request list');
      }

      final itemRows = items is List
          ? List<Map<String, dynamic>>.from(items)
          : <Map<String, dynamic>>[];
      requestList.assignAll(
        List<Map<String, dynamic>>.from(requests).map((request) {
          final requestId = int.tryParse(request["id"].toString());
          return {
            ...request,
            "items": itemRows
                .where(
                  (item) =>
                      int.tryParse(item["stock_request_id"].toString()) ==
                      requestId,
                )
                .toList(),
          };
        }),
      );
      searchRequests(_query);

      _cache
        ..clear()
        ..addAll(requestList);
      _cachedAt = DateTime.now();
    } catch (_) {
      if (!isClosed) {
        loadError.value =
            'Unable to load purchase requests. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> onRefresh() => onGetPurchaseRequests();

  void searchRequests(String keyword) {
    _query = keyword.trim().toLowerCase();
    if (_query.isEmpty) {
      searchRequestList.assignAll(requestList);
      return;
    }

    searchRequestList.assignAll(
      requestList.where((request) {
        final fields = [
          request["request_no"],
          request["request_type"],
          request["requested_by"],
          request["approved_by"],
          request["status"],
          request["reason"],
        ];
        return fields.any(
          (field) => field.toString().toLowerCase().contains(_query),
        );
      }),
    );
  }

  void addItemLine() => itemLines.add(PurchaseRequestLine());

  void removeItemLine(PurchaseRequestLine line) {
    if (itemLines.length == 1) return;
    if (line.itemId != null) removedItemIds.add(line.itemId!);
    line.dispose();
    itemLines.remove(line);
  }

  void _clearForm() {
    requestTypeController.text = "purchase";
    final loggedInUser = storage.lastUserLoginRead["user"];
    requestedByController.text = loggedInUser is Map
        ? loggedInUser["name"]?.toString() ?? ""
        : "";
    approvedByController.text = "Pending";
    reasonController.clear();
    selectedWarehouseId.value = null;
    requestStatus.value = "pending";
    requestDate.value = DateTime.now();
    approvedDate.value = DateTime.now();
    editingRequestId.value = null;
    removedItemIds.clear();
    for (final line in itemLines) {
      line.dispose();
    }
    itemLines
      ..clear()
      ..add(PurchaseRequestLine());
  }

  Future<void> _loadLookups() async {
    await Future.wait([
      warehouseController.getWarehouses(),
      productController.getProducts(),
    ]);
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

  Future<void> addPurchaseRequest(BuildContext context) async {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    _clearForm();
    formError.value = '';
    await _loadLookups();
    if (!context.mounted || isClosed) return;
    await _showForm(context, const AddPurchaseRequestWidget());
  }

  Future<void> editPurchaseRequest(BuildContext context, int requestId) async {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    isOpeningEdit.value = true;
    formError.value = '';
    try {
      await _loadLookups();
      final responses = await Future.wait([
        service.getPurchaseRequestById(requestId),
        service.getPurchaseRequestItems(),
      ]);
      final request = Map<String, dynamic>.from(responses[0] as Map);
      final allItems = List<Map<String, dynamic>>.from(responses[1] as List);
      final requestItems = allItems
          .where(
            (item) =>
                int.tryParse(item["stock_request_id"].toString()) == requestId,
          )
          .toList();

      _clearForm();
      editingRequestId.value = requestId;
      requestTypeController.text = request["request_type"]?.toString() ?? "";
      requestedByController.text = request["requested_by"]?.toString() ?? "";
      approvedByController.text = request["approved_by"]?.toString() ?? "";
      reasonController.text = request["reason"]?.toString() ?? "";
      selectedWarehouseId.value = int.tryParse(
        request["warehouse_id"].toString(),
      );
      final status = request["status"]?.toString().trim().toLowerCase();
      requestStatus.value = const ["pending", "approved", "rejected"].contains(
        status,
      )
          ? status!
          : "pending";
      requestDate.value =
          DateTime.tryParse(request["request_date"].toString()) ??
          DateTime.now();
      approvedDate.value =
          DateTime.tryParse(request["approved_date"].toString()) ??
          DateTime.now();

      for (final line in itemLines) {
        line.dispose();
      }
      itemLines.clear();
      for (final item in requestItems) {
        final line = PurchaseRequestLine()
          ..itemId = int.tryParse(item["id"].toString())
          ..unitController.text = item["unit"]?.toString() ?? ""
          ..quantityController.text = item["qty"]?.toString() ?? "1";
        final productId = int.tryParse(item["product_id"].toString());
        if (productId != null) {
          line.selectedProduct.value = productController.products.firstWhere(
            (product) => int.tryParse(product["id"].toString()) == productId,
            orElse: () => {"id": productId, "name": "Product $productId"},
          );
        }
        itemLines.add(line);
      }
      if (itemLines.isEmpty) itemLines.add(PurchaseRequestLine());

      if (!context.mounted || isClosed) return;
      await _showForm(context, EditPurchaseRequestWidget(requestId: requestId));
    } catch (_) {
      if (!isClosed) {
        ToastWidget.show(
          message: 'Unable to open purchase request. Please try again.'.tr,
          type: ToastType.error,
        );
      }
    } finally {
      if (!isClosed) isOpeningEdit.value = false;
    }
  }

  Map<String, dynamic> _requestPayload() => {
    "request_type": requestTypeController.text.trim(),
    "warehouse_id": selectedWarehouseId.value,
    "requested_by": requestedByController.text.trim(),
    "approved_by": approvedByController.text.trim(),
    "status": requestStatus.value,
    "reason": reasonController.text.trim(),
    "request_date": requestDate.value.toIso8601String(),
    "approved_date": approvedDate.value.toIso8601String(),
  };

  Map<String, dynamic> _itemPayload(PurchaseRequestLine line, int requestId) =>
      {
        "stock_request_id": requestId,
        "product_id": int.parse(line.selectedProduct.value!["id"].toString()),
        "unit": line.unitController.text.trim(),
        "qty": int.parse(line.quantityController.text.trim()),
      };

  bool _validateLines() {
    if (itemLines.isEmpty) {
      formError.value =
          'Choose a product and enter a unit and quantity for each item'.tr;
      return false;
    }
    for (final line in itemLines) {
      if (line.selectedProduct.value == null ||
          line.unitController.text.trim().isEmpty ||
          (int.tryParse(line.quantityController.text.trim()) ?? 0) <= 0) {
        formError.value =
            'Choose a product and enter a unit and quantity for each item'.tr;
        return false;
      }
    }
    return true;
  }

  Future<void> savePurchaseRequest(BuildContext context) async {
    if (isSaving.value || isClosed) return;
    formError.value = '';
    if (!(formKey.currentState?.validate() ?? false) || !_validateLines()) {
      return;
    }
    final warehouseId = selectedWarehouseId.value;
    if (warehouseId == null) return;

    isSaving.value = true;
    try {
      final response = await service.createPurchaseRequest(_requestPayload());
      final requestId = int.tryParse(response["id"].toString());
      if (requestId == null) {
        throw Exception("Created request ID was not returned");
      }

      try {
        for (final line in itemLines) {
          final item = await service.createPurchaseRequestItem(
            _itemPayload(line, requestId),
          );
          line.itemId = int.tryParse(item["id"].toString());
        }
      } catch (_) {
        await service.deletePurchaseRequest(requestId);
        rethrow;
      }

      await onGetPurchaseRequests();
      if (!context.mounted) return;
      Navigator.pop(context);
      ToastWidget.show(
        message: "Purchase request created successfully".tr,
        type: ToastType.success,
      );
    } catch (_) {
      if (!isClosed) {
        formError.value =
            'Unable to save purchase request. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  Future<void> updatePurchaseRequest(
    BuildContext context,
    int requestId,
  ) async {
    if (isSaving.value || isClosed) return;
    formError.value = '';
    if (!(formKey.currentState?.validate() ?? false) || !_validateLines()) {
      return;
    }
    final warehouseId = selectedWarehouseId.value;
    if (warehouseId == null) return;

    isSaving.value = true;
    try {
      await service.updatePurchaseRequest(requestId, _requestPayload());
      for (final itemId in removedItemIds) {
        await service.deletePurchaseRequestItem(itemId);
      }
      for (final line in itemLines) {
        final payload = _itemPayload(line, requestId);
        if (line.itemId == null) {
          final response = await service.createPurchaseRequestItem(payload);
          line.itemId = int.tryParse(response["id"].toString());
        } else {
          await service.updatePurchaseRequestItem(line.itemId!, payload);
        }
      }

      removedItemIds.clear();
      await onGetPurchaseRequests();
      if (!context.mounted) return;
      Navigator.pop(context);
      ToastWidget.show(
        message: "Purchase request updated successfully".tr,
        type: ToastType.success,
      );
    } catch (_) {
      if (!isClosed) {
        formError.value =
            'Unable to save purchase request. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  Future<void> deletePurchaseRequest(
    BuildContext context,
    int requestId, {
    VoidCallback? onDeleted,
  }) async {
    if (isSaving.value || isClosed) return;
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this purchase request?".tr,
      onConfirm: () async {
        if (isSaving.value || isClosed) return;
        isSaving.value = true;
        formError.value = '';
        try {
          await service.deletePurchaseRequest(requestId);
          await onGetPurchaseRequests();
          onDeleted?.call();
          ToastWidget.show(
            message: "Purchase request deleted successfully".tr,
            type: ToastType.success,
          );
        } catch (_) {
          if (!isClosed) {
            ToastWidget.show(
              message:
                  'Unable to delete purchase request. Please try again.'.tr,
              type: ToastType.error,
            );
          }
        } finally {
          if (!isClosed) isSaving.value = false;
        }
      },
      onCancel: () {},
    );
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    requestTypeController.dispose();
    requestedByController.dispose();
    approvedByController.dispose();
    reasonController.dispose();
    for (final line in itemLines) {
      line.dispose();
    }
    super.onClose();
  }
}
