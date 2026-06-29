import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class Product {
  final String name;
  final String sku;
  final int stock;
  final double price;
  final String status;
  final Color statusColor;
  final String category;
  final String recency;
  final String asset;

  Product({
    required this.name,
    required this.sku,
    required this.stock,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.category,
    required this.recency,
    required this.asset,
  });
}

class ProductController extends GetxController {
  var searchQuery = ''.obs;
  var filterCategory = 'All'.obs;
  var selectedStatus = 'All'.obs;
  var selectedRecency = 'All'.obs;

var selectedCategory = RxnString();
var selectedSupplier = RxnString();
var selectedUnit = RxnString();

  final List<Product> _masterList = [
    Product(
      name: 'Energy Drink',
      sku: 'ED-001',
      stock: 45,
      price: 2.00,
      status: 'IN STOCK',
      statusColor: const Color(0xFF1DB584),
      category: 'Energy Drinks',
      asset: 'assets/icon/EnergyDrink.jpg',
      recency: 'Newest',
    ),
    Product(
      name: 'Sting',
      sku: 'ST-001',
      stock: 3,
      price: 1.50,
      status: 'LOW STOCK',
      statusColor: const Color(0xFF8B6447),
      category: 'Sting',
      asset: 'assets/icon/Sting.jpg',
      recency: 'Oldest',
    ),
    Product(
      name: 'Ize',
      sku: 'IZ-001',
      stock: 0,
      price: 1.25,
      status: 'OUT OF STOCK',
      statusColor: const Color(0xFFB3B3B3),
      category: 'Ize',
      asset: 'assets/icon/Ize.jpg',
      recency: 'Oldest',
    ),
    Product(
      name: 'Cocacola',
      sku: 'CC-001',
      stock: 12,
      price: 3.00,
      status: 'IN STOCK',
      statusColor: const Color(0xFF1DB584),
      category: 'Cocacola',
      asset: 'assets/icon/Cocacola.jpg',
      recency: 'Newest',
    ),
  ];

  List<Product> get filteredItems {
    return _masterList.where((item) {
      final queryMatch = item.name.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );

      final catMatch =
          filterCategory.value == 'All' ||
          filterCategory.value == 'All' ||
          item.category == filterCategory.value;
          item.category == filterCategory.value;

      final statusMatch =
          selectedStatus.value == 'All' || item.status == selectedStatus.value;

      final recencyMatch =
          selectedRecency.value == 'All' ||
          item.recency == selectedRecency.value;

      return queryMatch && catMatch && statusMatch && recencyMatch;
    }).toList();
  }

  void gotoAddProduct(){
    Get.toNamed(AppRoutes.addProduct);
  }
}
