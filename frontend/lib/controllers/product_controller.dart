import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/services/main_service/product_service.dart';
import 'package:frontend/widget/toast_widget.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {

  final ProductService service = ProductService();

  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var filterCategory = 'All'.obs;
  var selectedStatus = 'All'.obs;
  var selectedRecency = 'All'.obs;

  var selectedCategory = RxnString();
  var selectedSupplier = RxnString();
  var selectedUnit = RxnString();

  var scannedProduct = Rxn<Map<String, dynamic>>();
  var scanResultText = ''.obs;

  final RxList<Map<String, dynamic>> _masterList =
      <Map<String, dynamic>>[].obs;

    
    @override
    void onInit() {
      super.onInit();
      getProducts();
    }

    Future<void> getProducts() async {
      try {
        isLoading.value = true;
        final resp = await service.getProducts();
        if (resp is List) {
          _masterList.value = List<Map<String, dynamic>>.from(resp);
        }

        print(_masterList);
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

  void gotoProductDetail(Map<String, dynamic> product) {
    Get.toNamed(
      AppRoutes.productCardDetail,
      arguments: product,
    );
  }

  void onEditProduct(Map<String, dynamic> product) {
    Get.toNamed(
      AppRoutes.editProduct,
      arguments: product,
    );
  }

  void onDeleteProduct(Map<String, dynamic> product) {
    print('Delete product: ${product['name']}');
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