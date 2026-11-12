import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/screen/purchases/widget/add_purchase_widget.dart';
import 'package:frontend/screen/purchases/widget/edit_purchase_widget.dart';
import 'package:frontend/screen/purchases/widget/purchase_item_form.dart';
import 'package:frontend/services/main_service/purchase/purchase_service.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:frontend/controllers/search_controller.dart';
import 'package:get/get.dart';

class PurchaseController extends GetxController {
  PurchaseController({PurchaseService? service})
    : service = service ?? PurchaseService();

  final PurchaseService service;

  var isLoading = false.obs;
  final purchaseList = <Map<String, dynamic>>[].obs;
  final RxnInt selectedSupplier = RxnInt();
  final RxnInt selectedProduct = RxnInt();
  final RxnInt selectedWarehouse = RxnInt();
  final formKey = GlobalKey<FormState>();
  final invoiceCtrl = TextEditingController();
  final taxCtrl = TextEditingController(text: '0');
  final discountCtrl = TextEditingController(text: '0');
  final paidCtrl = TextEditingController(text: '0');
  final Rx<DateTime> purchaseDate = DateTime.now().obs;
  final Rxn<Map<String, dynamic>> editingPurchase = Rxn<Map<String, dynamic>>();
  final RxInt editingPurchaseId = 0.obs;
  final RxList<PurchaseItemForm> items = <PurchaseItemForm>[].obs;
  final searchPurchaseList = <Map<String, dynamic>>[].obs;

  final RxDouble tax = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble paid = 0.0.obs;

  var isSaving = false.obs;
  final loadError = ''.obs;
  final formError = ''.obs;
  final isOpeningEdit = false.obs;

  bool _formOpen = false;
  bool _confirmingDelete = false;
  int _dataRevision = 0;
  String _query = '';
  Worker? _searchWorker;

  double get itemsSubtotal =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get total =>
      (itemsSubtotal + tax.value - discount.value).clamp(0, double.infinity);
  double get due => (total - paid.value).clamp(0, double.infinity);

  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  void _listeners() {
    taxCtrl.addListener(() => tax.value = double.tryParse(taxCtrl.text) ?? 0);
    discountCtrl.addListener(
      () => discount.value = double.tryParse(discountCtrl.text) ?? 0,
    );
    paidCtrl.addListener(
      () => paid.value = double.tryParse(paidCtrl.text) ?? 0,
    );
  }

  void resetForm() {
    invoiceCtrl.clear();
    taxCtrl.text = '0';
    discountCtrl.text = '0';
    paidCtrl.text = '0';
    tax.value = 0;
    discount.value = 0;
    paid.value = 0;
    selectedSupplier.value = null;
    selectedProduct.value = null;
    selectedWarehouse.value = null;
    purchaseDate.value = DateTime.now();

    for (final i in items) {
      i.dispose();
    }
    items
      ..clear()
      ..add(PurchaseItemForm());
  }

  void pickPurchaseDate(DateTime date) {
    purchaseDate.value = date;
  }

  void addItemRow() {
    items.add(PurchaseItemForm());
  }

  void removeItemRow(PurchaseItemForm item) {
    if (items.length == 1) return;
    item.dispose();
    items.remove(item);
  }

  @override
  void onInit() {
    super.onInit();
    _listeners();

    final products = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
    products.getProducts();
    final warehouses = Get.isRegistered<WarehouseController>()
        ? Get.find<WarehouseController>()
        : Get.put(WarehouseController());
    warehouses.getWarehouses();
    final search = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());
    _query = search.keyword.value.trim().toLowerCase();
    _searchWorker = ever(search.keyword, searchPurchase);

    if (_hasFreshCache) {
      purchaseList.assignAll(_cache);
      searchPurchase(_query);
    } else {
      onGetPurchaseList();
    }
  }

  Future<void> onRefresh() => onGetPurchaseList();

  Future<void> onGetPurchaseList() async {
    if (isLoading.value || isClosed) return;
    isLoading.value = true;
    loadError.value = '';
    final revision = _dataRevision;
    try {
      final resp = await service.getPurchases();
      if (isClosed || revision != _dataRevision) return;
      if (resp is! List) throw const FormatException('Expected purchase list');
      purchaseList.assignAll(List<Map<String, dynamic>>.from(resp));
      searchPurchase(_query);
      _cache
        ..clear()
        ..addAll(purchaseList);
      _cachedAt = DateTime.now();
    } catch (_) {
      if (!isClosed) {
        loadError.value = 'Unable to load purchases. Please try again.'.tr;
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void searchPurchase(String keyword) {
    _query = keyword.trim().toLowerCase();
    if (_query.isEmpty) {
      searchPurchaseList.assignAll(purchaseList);
      return;
    }
    searchPurchaseList.assignAll(
      purchaseList.where((purchase) {
        final invoiceNo = (purchase['invoice_no'] ?? '')
            .toString()
            .toLowerCase();
        final supplier = purchase['supplier'];
        final supplierName = supplier is Map
            ? (supplier['name'] ?? '').toString().toLowerCase()
            : '';
        return invoiceNo.contains(_query) || supplierName.contains(_query);
      }),
    );
  }

  void addPurchase(BuildContext context) {
    if (_formOpen || isSaving.value || isOpeningEdit.value || isClosed) return;
    resetForm();
    formError.value = '';
    _showForm(context, AddPurchaseWidget());
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

  void gotoPurchaseDetail(Map<String, dynamic> purchase) {
    Get.toNamed(AppRoutes.purchaseDetail, arguments: purchase);
  }

  Future<void> editPurchase(BuildContext context, int purchaseId) async {
    if (_formOpen || isOpeningEdit.value || isSaving.value || isClosed) return;
    final route = ModalRoute.of(context);
    isOpeningEdit.value = true;
    formError.value = '';
    try {
      final response = await service.getPurchaseById(purchaseId);
      if (isClosed || !context.mounted || route?.isCurrent != true) return;
      if (response is! Map) throw const FormatException('Expected purchase');
      final purchase = Map<String, dynamic>.from(response);

      editingPurchaseId.value = purchaseId;
      editingPurchase.value = purchase;
      invoiceCtrl.text = purchase['invoice_no'] ?? '';
      taxCtrl.text = (purchase['tax_amount'] ?? 0).toString();
      discountCtrl.text = (purchase['discount_amount'] ?? 0).toString();
      paidCtrl.text = (purchase['paid_amount'] ?? 0).toString();
      final supplier = purchase['supplier'];
      selectedSupplier.value = supplier is Map ? supplier['id'] : null;
      final warehouse = purchase['warehouse'];
      selectedWarehouse.value = warehouse is Map ? warehouse['id'] : null;
      if (purchase['purchase_date'] != null) {
        purchaseDate.value =
            DateTime.tryParse(purchase['purchase_date'].toString()) ??
            DateTime.now();
      }

      for (final item in items) {
        item.dispose();
      }
      items.clear();

      final purchaseItems = purchase['purchase_items'];
      for (final data in purchaseItems is List ? purchaseItems : const []) {
        if (data is! Map) continue;
        final record = Map<String, dynamic>.from(data);
        final row = PurchaseItemForm();
        final product = record['product'];
        final productId = product is Map ? product['id'] : null;
        row.product.value = Get.find<ProductController>().products.firstWhere(
          (p) => p['id'] == productId,
          orElse: () =>
              product is Map<String, dynamic> ? product : <String, dynamic>{},
        );
        final qty = double.tryParse(record['qty'].toString()) ?? 0;
        row.qty.value = qty;
        row.qtyCtrl.text = qty.toString();
        final cost = double.tryParse(record['cost_price'].toString()) ?? 0;
        row.cost.value = cost;
        row.costCtrl.text = cost.toString();
        items.add(row);
      }
      if (items.isEmpty) items.add(PurchaseItemForm());

      _showForm(context, EditPurchaseWidget());
    } catch (_) {
      if (!isClosed) {
        ToastWidget.show(
          message: 'Unable to open purchase. Please try again.'.tr,
          type: ToastType.error,
        );
      }
    } finally {
      if (!isClosed) isOpeningEdit.value = false;
    }
  }

  Future<void> createPurchase(BuildContext context) => _save(context);

  Future<void> onUpdatePurchase(BuildContext context) =>
      _save(context, purchaseId: editingPurchaseId.value);

  Future<void> _save(BuildContext context, {int? purchaseId}) async {
    if (isSaving.value || isClosed) return;
    formError.value = '';
    if (!formKey.currentState!.validate()) return;
    if (purchaseId != null && purchaseId == 0) {
      formError.value = 'Unable to save purchase. Please try again.'.tr;
      return;
    }
    if (selectedWarehouse.value == null) {
      formError.value = 'Please select a warehouse'.tr;
      return;
    }
    if (selectedSupplier.value == null) {
      formError.value = 'Please select a supplier'.tr;
      return;
    }
    final invalidRow = items.any(
      (i) => i.product.value == null || i.qty.value <= 0 || i.cost.value <= 0,
    );
    if (invalidRow) {
      formError.value = 'Choose a product, quantity and cost for each item'.tr;
      return;
    }

    final payload = <String, dynamic>{
      'supplier_id': selectedSupplier.value,
      'warehouse_id': selectedWarehouse.value,
      'invoice_no': invoiceCtrl.text.trim(),
      if (purchaseId == null)
        'user_id': storage.lastUserLoginRead['user']['id'],
      'purchase_date': purchaseDate.value.toIso8601String(),
      'subtotal': itemsSubtotal,
      'tax_amount': tax.value,
      'discount_amount': discount.value,
      'total_amount': total,
      'paid_amount': paid.value,
      'due_amount': due,
      'payment_status': due <= 0
          ? 'paid'
          : (paid.value > 0 ? 'partial' : 'unpaid'),
      'items': items
          .map(
            (i) => {
              'product_id': i.product.value!['id'],
              'qty': i.qty.value,
              'cost_price': i.cost.value,
              'subtotal': i.subtotal,
            },
          )
          .toList(),
    };

    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    isSaving.value = true;
    dynamic response;
    try {
      response = purchaseId == null
          ? await service.createPurchase(payload)
          : await service.updatePurchase(purchaseId, payload);
    } catch (_) {
      if (!isClosed) {
        formError.value = 'Unable to save purchase. Please try again.'.tr;
      }
      return;
    } finally {
      if (!isClosed) isSaving.value = false;
    }
    if (isClosed) return;

    _dataRevision++;
    if (response is Map) {
      final record = Map<String, dynamic>.from(response);
      final index = purchaseList.indexWhere((p) => p['id'] == record['id']);
      if (index < 0) {
        purchaseList.add(record);
      } else {
        purchaseList[index] = record;
      }
      _cache
        ..clear()
        ..addAll(purchaseList);
      _cachedAt = DateTime.now();
    }
    searchPurchase(_query);
    if (context.mounted && route is PopupRoute && route.isCurrent) {
      navigator.pop();
    }
    ToastWidget.show(
      message:
          (purchaseId == null
                  ? 'Purchase created successfully'
                  : 'Purchase updated successfully')
              .tr,
      type: ToastType.success,
    );
    await onGetPurchaseList();
  }

  Future<void> deletePurchase({
    required BuildContext context,
    required int purchaseId,
    VoidCallback? onDeleted,
  }) async {
    if (isClosed ||
        isSaving.value ||
        _confirmingDelete ||
        _formOpen ||
        isOpeningEdit.value) {
      return;
    }
    _confirmingDelete = true;
    formError.value = '';
    try {
      await showConfirmDialog(
        context: context,
        title: 'Confirm'.tr,
        cancelText: 'Cancel'.tr,
        confirmText: 'Ok'.tr,
        message: 'Do you want to delete this purchase?'.tr,
        onConfirm: () async {
          if (isClosed || !context.mounted) return;
          isSaving.value = true;
          try {
            await service.deletePurchase(purchaseId);
          } catch (_) {
            if (!isClosed) {
              formError.value =
                  'Unable to delete purchase. Please try again.'.tr;
            }
            return;
          } finally {
            if (!isClosed) isSaving.value = false;
          }
          if (isClosed) return;
          _dataRevision++;
          purchaseList.removeWhere((p) => p['id'] == purchaseId);
          searchPurchase(_query);
          _cache
            ..clear()
            ..addAll(purchaseList);
          _cachedAt = DateTime.now();
          onDeleted?.call();
          ToastWidget.show(
            message: 'Purchase deleted successfully'.tr,
            type: ToastType.success,
          );
          await onGetPurchaseList();
        },
        onCancel: () {},
      );
    } finally {
      _confirmingDelete = false;
    }
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    invoiceCtrl.dispose();
    taxCtrl.dispose();
    discountCtrl.dispose();
    paidCtrl.dispose();
    for (final i in items) {
      i.dispose();
    }
    super.onClose();
  }
}
