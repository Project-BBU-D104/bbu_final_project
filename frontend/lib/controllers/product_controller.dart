import 'package:flutter/material.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  var searchQuery = ''.obs;
  var filterCategory = 'All'.obs;
  var selectedStatus = 'All'.obs;
  var selectedRecency = 'All'.obs;

  var selectedCategory = RxnString();
  var selectedSupplier = RxnString();
  var selectedUnit = RxnString();

  var scannedProduct = Rxn<ProductModel>();
  var scanResultText = ''.obs;

  final List<ProductModel> _masterList = [
    ProductModel(
      id: 1,
      categoryId: "1",
      supplierId: "1",
      name: "Energy Drink",
      barcode: "123456789",
      unit: "pcs",
      qty: 45,
      costPrice: "2.00",
      salePrice: "3.00",
    ),
    ProductModel(
      id: 2,
      categoryId: "2",
      supplierId: "1",
      name: "Sting",
      barcode: "2456789",
      unit: "pcs",
      qty: 3,
      costPrice: "1.50",
      salePrice: "2.00",
    ),
    ProductModel(
      id: 3,
      categoryId: "3",
      supplierId: "1",
      name: "CocaCola",
      barcode: "6789",
      unit: "pcs",
      qty: 12,
      costPrice: "2.50",
      salePrice: "3.00",
    ),
  ];

  List<ProductModel> get filteredItems {
    return _masterList.where((item) {
      final queryMatch = item.name.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );

      final catMatch =
          filterCategory.value == 'All' ||
          filterCategory.value == 'All' ||
          item.categoryId == filterCategory.value;
          item.categoryId == filterCategory.value;

      // final statusMatch =
      //     selectedStatus.value == 'All' || item.status == selectedStatus.value;

      // final recencyMatch =
      //     selectedRecency.value == 'All' ||
      //     item.recency == selectedRecency.value;

      return queryMatch && catMatch;
      // return queryMatch && catMatch && statusMatch && recencyMatch;
    }).toList();
  }

  void gotoAddProduct(){
    Get.toNamed(AppRoutes.addProduct);
  }

  void gotoProductDetail(ProductModel product) {
    Get.toNamed(AppRoutes.productCardDetail, arguments: product);
  }

  void onEditProduct(ProductModel product) {
    Get.toNamed(AppRoutes.editProduct, arguments: product);
  }

  void onDeleteProduct(ProductModel product) {
    print('Delete product: ${product.name}');
  }

  ProductModel? findByBarcode(String code) {
  try {
    return _masterList.firstWhere(
      (p) => p.barcode == code,
    );
  } catch (e) {
    return null;
  }
}

void onBarcodeScanned(String code) {
  final product = findByBarcode(code);

  if (product != null) {
    scannedProduct.value = product;
    scanResultText.value = product.name;

    Get.snackbar("Found", product.name);

    gotoProductDetail(product);
  } else {
    scannedProduct.value = null;
    scanResultText.value = "Not Found";

    Get.snackbar("Error", "Product not found");
  }
}
}
