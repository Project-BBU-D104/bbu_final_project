import 'package:flutter/material.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/helper/confirm_dialog_helper.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {

  final ProductService service = ProductService();

    final CategoryController categoryCtr = Get.find<CategoryController>();
    final SupplierController supplierCtr = Get.find<SupplierController>();

@override
    void onInit() {
      super.onInit();
      getProducts();

      categoryCtr.getCategory();
      supplierCtr.getSuppliers();
    }

  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var filterCategory = 'All'.obs;
  var selectedStatus = 'All'.obs;
  var selectedRecency = 'All'.obs;

  final selectedCategory = RxnString();
  final selectedSupplier = RxnString();
  final selectedUnit = RxnString();

  var scannedProduct = Rxn<Map<String, dynamic>>();
  var scanResultText = ''.obs;


  final productPhotoController = TextEditingController();
  final productNameController = TextEditingController();
  final productBarcodeController = TextEditingController();
  final productCostPriceController = TextEditingController();
  final productSalePriceController = TextEditingController();
  final productQuantityController = TextEditingController();
  final productDescriptionController = TextEditingController();

  final RxList<Map<String, dynamic>> _masterList =
      <Map<String, dynamic>>[].obs;

    

    Future<void> getProducts() async {
      try {
        isLoading.value = true;
        final resp = await service.getProducts();
        if (resp is List) {
          _masterList.value = List<Map<String, dynamic>>.from(resp);
        }
      } catch (e) {
        ToastWidget.show(
          message: e.toString(),
          type: ToastType.error,
        );
      } finally {
        isLoading.value = false;
      }
    }

  List<Map<String, dynamic>> get products => _masterList;

  /// Set data from API
  void setProducts(List<Map<String, dynamic>> data) {
    _masterList.assignAll(data);

      print(_masterList);
  }

  List<Map<String, dynamic>> get filteredItems {
    return _masterList.where((item) {
      final queryMatch =
          (item['name'] ?? '')
              .toString()
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

      final catMatch =
          filterCategory.value == 'All' ||
          (item['category']?['name'] ?? '') == filterCategory.value;

      return queryMatch && catMatch;
    }).toList();
  }

  void gotoAddProduct() {
    Get.toNamed(AppRoutes.addProduct);
  }

  Future<void> onSaveProduct(BuildContext context) async{
    try{
      isLoading .value = true;

      final data = {
        'name': productNameController.text,
        'category_id': selectedCategory.value,
        'supplier_id': selectedSupplier.value,
        'unit': selectedUnit.value,
        'barcode': productBarcodeController.text,
        'cost_price': productCostPriceController.text,
        'sale_price': productSalePriceController.text,
        'qty': productQuantityController.text,
        'description': productDescriptionController.text,
        'photo': productPhotoController.text,
        'allow_insert_qty': true
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
      productPhotoController.clear();
      productNameController.clear();
      productBarcodeController.clear();
      productCostPriceController.clear();
      productSalePriceController.clear();
      productQuantityController.clear();
      productDescriptionController.clear();

      selectedCategory.value = null;
      selectedSupplier.value = null;
      selectedUnit.value = null;

    }catch(e){
      // 
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

    // print(product);

    productPhotoController.text = product["photo"] ?? "";
    productNameController.text = product["name"] ?? "";
    productDescriptionController.text = product["description"] ?? "";
    productBarcodeController.text = product["barcode"] ?? "";
    productCostPriceController.text = product["cost_price"].toString();
    productSalePriceController.text = product["sale_price"].toString();
    productQuantityController.text = product["qty"].toString();

    selectedCategory.value =
        product["category"] is Map
            ? product["category"]["id"].toString()
            : product["category"].toString();

    selectedSupplier.value =
        product["supplier"] is Map
            ? product["supplier"]["id"].toString()
            : product["supplier"].toString();
        selectedUnit.value = product["unit"];

    Get.toNamed(
      AppRoutes.editProduct,
      arguments: productId,
    );
  } catch (e) {
    print(e);
  }
}

  Future<void> onUpdateProduct(int productId, BuildContext context) async {
    try{
      final data = {
        "name": productNameController.text.trim(),
        "description": productDescriptionController.text.trim(),
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
    selectedSupplier.value = null;
    selectedUnit.value = null;
  }
}