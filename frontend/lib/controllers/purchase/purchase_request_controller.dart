import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
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
  final PurchaseRequestService service = PurchaseRequestService();
  final WarehouseController warehouseController = Get.put(
    WarehouseController(),
  );
  final ProductController productController = Get.put(ProductController());

  final isLoading = false.obs;
  final isSaving = false.obs;
  final requestList = <Map<String, dynamic>>[].obs;
  final searchQuery = "".obs;
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

  List<Map<String, dynamic>> get filteredRequests {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return requestList;

    return requestList.where((request) {
      final fields = [
        request["request_no"],
        request["request_type"],
        request["requested_by"],
        request["approved_by"],
        request["status"],
        request["reason"],
      ];
      return fields.any(
        (field) => field.toString().toLowerCase().contains(query),
      );
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    final loggedInUser = storage.lastUserLoginRead["user"];
    if (loggedInUser is Map) {
      requestedByController.text = loggedInUser["name"]?.toString() ?? "";
    }
    itemLines.add(PurchaseRequestLine());
    warehouseController.getWarehouses();
    productController.getProducts();
    onGetPurchaseRequests();
  }

  Future<void> onGetPurchaseRequests() async {
    try {
      isLoading.value = true;
      final responses = await Future.wait([
        service.getPurchaseRequests(),
        service.getPurchaseRequestItems(),
      ]);
      final requests = responses[0];
      final items = responses[1];

      if (requests is List) {
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
      }
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String value) => searchQuery.value = value;

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

  Future<void> addPurchaseRequest(BuildContext context) async {
    _clearForm();
    await _loadLookups();
    if (!context.mounted) return;
    AppBottomSheets.show(context, child: const AddPurchaseRequestWidget());
  }

  Future<void> editPurchaseRequest(BuildContext context, int requestId) async {
    try {
      isLoading.value = true;
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
      requestStatus.value = request["status"]?.toString() ?? "pending";
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

      if (!context.mounted) return;
      AppBottomSheets.show(
        context,
        child: EditPurchaseRequestWidget(requestId: requestId),
      );
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    } finally {
      isLoading.value = false;
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
    if (itemLines.isEmpty) return false;
    for (final line in itemLines) {
      if (line.selectedProduct.value == null ||
          line.unitController.text.trim().isEmpty ||
          (int.tryParse(line.quantityController.text.trim()) ?? 0) <= 0) {
        ToastWidget.show(
          message:
              "Choose a product and enter a unit and quantity for each item".tr,
          type: ToastType.error,
        );
        return false;
      }
    }
    return true;
  }

  Future<void> savePurchaseRequest(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false) || !_validateLines()) {
      return;
    }
    final warehouseId = selectedWarehouseId.value;
    if (warehouseId == null) return;

    try {
      isSaving.value = true;
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
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updatePurchaseRequest(
    BuildContext context,
    int requestId,
  ) async {
    if (!(formKey.currentState?.validate() ?? false) || !_validateLines()) {
      return;
    }
    final warehouseId = selectedWarehouseId.value;
    if (warehouseId == null) return;

    try {
      isSaving.value = true;
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
    } catch (error) {
      ToastWidget.show(message: error.toString(), type: ToastType.error);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePurchaseRequest(
    BuildContext context,
    int requestId,
  ) async {
    showConfirmDialog(
      context: context,
      message: "Delete this purchase request?".tr,
      onConfirm: () async {
        try {
          await service.deletePurchaseRequest(requestId);
          await onGetPurchaseRequests();
          ToastWidget.show(
            message: "Purchase request deleted successfully".tr,
            type: ToastType.success,
          );
        } catch (error) {
          ToastWidget.show(message: error.toString(), type: ToastType.error);
        }
      },
      onCancel: () {},
    );
  }

  @override
  void onClose() {
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
