import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/currency_controller.dart';
import 'package:frontend/controllers/unit_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers/search_controller.dart';

class ProductController extends GetxController {

  final ProductService service = ProductService();

  final CategoryController categoryCtr = Get.put(CategoryController());
  final UnitController unitCtr = Get.put(UnitController());
  final CurrencyController currencyCtr = Get.put(CurrencyController());
  final WarehouseController warehouseCtr = Get.put(WarehouseController());

  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var filterCategory = 'All'.obs;
  var selectedStatus = 'All'.obs;
  var selectedRecency = 'All'.obs;

  final selectedCategory = RxnString();
  final selectedUnit = RxnString();
  final selectedCurrency = RxnString();
  final selectedWarehouse = RxnString();

  var scannedProduct = Rxn<Map<String, dynamic>>();
  var scanResultText = ''.obs;

  final productPhotoController = TextEditingController();
  final productNameController = TextEditingController();
  final productBarcodeController = TextEditingController();
  final productCostPriceController = TextEditingController();
  final productSalePriceController = TextEditingController();
  final productDescriptionController = TextEditingController();

  static final List<Map<String, dynamic>> _cache = [];
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  static bool get _hasFreshCache =>
      _cachedAt != null &&
      DateTime.now().difference(_cachedAt!) < _cacheTtl;

  final RxList<Map<String, dynamic>> _masterList = <Map<String, dynamic>>[].obs;

  final searchProductList = <Map<String, dynamic>>[].obs;

   List<Map<String, dynamic>> get products => _masterList;

  @override
  void onInit() {
    super.onInit();

    if(_hasFreshCache){
      _masterList.value = List<Map<String, dynamic>>.from(_cache);
      searchProductList.value = _masterList;
    }else{
      getProducts();
    }
   
    final search = Get.put(SearchController());

    ever(
      search.keyword,
      (keyword) {
        searchProduct(keyword);
      },
    );
 
  }

  Future<void> getProducts() async {
  try {
    isLoading.value = true;

    final resp = await service.getProducts();

  if (resp is List) {
    _masterList.assignAll(
      List<Map<String, dynamic>>.from(resp),
    );
    searchProductList.assignAll(_masterList);

    // Update the shared cache so the next visit reuses this data.
    _cache
      ..clear()
      ..addAll(_masterList);
    _cachedAt = DateTime.now();
  }} catch (e) {
    ToastWidget.show(
      message: e.toString(),
      type: ToastType.error,
    );
  } finally {
    isLoading.value = false;
  }
}

  // search
void searchProduct(String keyword) {
  final search = keyword.trim().toLowerCase();

  // Keep ProductController searchQuery in sync
  searchQuery.value = search;

  if (search.isEmpty) {
    searchProductList.assignAll(_masterList);
    return;
  }

  searchProductList.assignAll(
    _masterList.where((product) {
      final name =
          (product['name'] ?? '').toString().toLowerCase();

      final barcode =
          (product['barcode'] ?? '').toString().toLowerCase();

      return name.contains(search) || barcode.contains(search);
    }).toList(),
  );
}

  /// Set data from API
  void setProducts(List<Map<String, dynamic>> data) {
    _masterList.assignAll(data);
  }

  void clearProducts() {
    productNameController.clear();
    productBarcodeController.clear();
    productCostPriceController.clear();
    productSalePriceController.clear();
    productDescriptionController.clear();
    productPhotoController.clear();
    selectedCategory.value = null;
    selectedUnit.value = null;
    selectedCurrency.value = null;
    selectedWarehouse.value = null;
  }

 List<Map<String, dynamic>> get filteredItems {
  return _masterList.where((item) {
    // Category filter
    final catMatch =
        filterCategory.value == 'All' ||
        (item['category']?['name'] ?? '') ==
            filterCategory.value;

    // Status filter
    bool statusMatch = true;

    if (selectedStatus.value != 'All') {
      final stockQty = item['stock_qty'] ?? 0;

      if (selectedStatus.value == 'IN STOCK') {
        statusMatch = stockQty > 0;
      } else if (selectedStatus.value == 'LOW STOCK') {
        statusMatch = stockQty > 0 && stockQty <= 10;
      } else if (selectedStatus.value == 'OUT OF STOCK') {
        statusMatch = stockQty <= 0;
      }
    }

    return catMatch && statusMatch;
  }).toList();
}

  void gotoAddProduct() {
    clearProducts();
    Get.toNamed(AppRoutes.addProduct);
  }

  Future<void> onSaveProduct(BuildContext context) async{
    try{
      isLoading .value = true;

      final data = {
        'name': productNameController.text,
        'category_id': selectedCategory.value,
        'unit_id': selectedUnit.value,
        'currency_id': selectedCurrency.value,
        'barcode': productBarcodeController.text,
        'cost_price': productCostPriceController.text,
        'sale_price': productSalePriceController.text,
        'description': productDescriptionController.text,
        'photo': productPhotoController.text,
        'warehouse_id': selectedWarehouse.value == null
            ? null
            : int.parse(selectedWarehouse.value!),
      };
      await service.createProduct(data);

      ToastWidget.show(
        message: "Product created successfully",
        type: ToastType.success,
      );
      // Reload Category
      await getProducts();

      Navigator.pop(context);

      // Clear textfields
      clearProducts();

    }catch(e){
      ToastWidget.show(
        message: e.toString(),
        type: ToastType.error,
      );
    }
    finally{
      isLoading.value = false;
    }
  }

  void gotoProductDetail(Map<String, dynamic> product) {
    Get.toNamed(
      AppRoutes.productCardDetail,
      arguments: product,
    );
  }

  Future<void> onEditProduct(int productId, BuildContext context) async {
    try {
      final product = await service.getProductById(productId);
      productPhotoController.text = product["photo"] ?? "";
      productNameController.text = product["name"] ?? "";
      productDescriptionController.text = product["description"] ?? "";
      productBarcodeController.text = product["barcode"] ?? "";
      productCostPriceController.text = product["cost_price"].toString();
      productSalePriceController.text = product["sale_price"].toString();

      selectedCategory.value =
          product["category"] is Map
              ? product["category"]["id"].toString()
              : product["category"].toString();
      
      selectedUnit.value = product["unit"] is Map
          ? product["unit"]["id"].toString()
          : product["unit"].toString();

      selectedCurrency.value =
          product["currency"] is Map
              ? product["currency"]["id"].toString()
              : product["currency"].toString();

      selectedWarehouse.value = product["warehouse"] is Map
          ? product["warehouse"]["id"].toString()
          : null;

      Get.toNamed(
        AppRoutes.editProduct,
        arguments: productId,
      );
    } catch (e) {
      // print(e);
    }
  }

  Future<void> onUpdateProduct(int productId, BuildContext context) async {
    try{
      final data = {
        "name": productNameController.text.trim(),
        "category_id": selectedCategory.value,
        "currency_id": selectedCurrency.value,
        "unit_id": selectedUnit.value,
        "barcode": productBarcodeController.text.trim(),
        "cost_price": double.tryParse(productCostPriceController.text) ?? 0,
        "sale_price": double.tryParse(productSalePriceController.text) ?? 0,
        "description": productDescriptionController.text.trim(),
        "photo": productPhotoController.text,
        "warehouse_id": selectedWarehouse.value == null
            ? null
            : int.parse(selectedWarehouse.value!),
      };

      await service.updateProduct(productId, data);

      // Reload Product
      await getProducts();

      Navigator.pop(context);

      ToastWidget.show(
        message: "Product updated successfully",
        type: ToastType.success,
      );
    }catch(e){
      // Do nothing
    }
  }

  void onDeleteProduct(int productId, BuildContext context) async {
    showConfirmDialog(
      context: context,
      message: "Do you want to delete this product?".tr,
      onConfirm: () async {
        try{
          await service.deleteProduct(productId);
          // Refresh category list
          await getProducts();

          Get.back();

          ToastWidget.show(
            message: "Product deleted successfully".tr,
            type: ToastType.success,
          );

        }catch(e){
          ToastWidget.show(
            message: e.toString(),
            type: ToastType.error,
          );
        }
      },
      onCancel: () {
        // Do nothing
      },
    );
  }

  Map<String, dynamic>? findByBarcode(String code) {
    try {
      return _masterList.firstWhere(
        (p) => (p['barcode'] ?? '').toString() == code,
      );
    } catch (_) {
      return null;
    }
  }

  void onBarcodeScanned(String code) {
    final product = findByBarcode(code);

    if (product != null) {
      scannedProduct.value = product;
      scanResultText.value = product['name'] ?? '';

      Get.snackbar(
        'Found',
        product['name'] ?? '',
      );

      gotoProductDetail(product);
    } else {
      scannedProduct.value = null;
      scanResultText.value = 'Not Found';

      Get.snackbar(
        'Error',
        'Product not found',
      );
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    filterCategory.value = 'All';
    selectedStatus.value = 'All';
    selectedRecency.value = 'All';
    selectedCategory.value = null;
    selectedUnit.value = null;
    selectedCurrency.value = null;
  }
}