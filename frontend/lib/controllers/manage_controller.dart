import 'package:flutter/material.dart';
import 'package:frontend/controllers/search_feature_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ManageController extends GetxController{

  final searchCtr = Get.put(SearchFeatureController());
  final RxList<Map<String, dynamic>> filteredSections =
      <Map<String, dynamic>>[].obs;


  final List<Map<String, dynamic>> sections = [
    {
      "title": "Product & Category Management",
      "items": [
        {
          "title": "Category",
          "subtitle": "Category Management",
          "icon": Icons.category_outlined,
          "route": AppRoutes.category,
        },
        {
          "title": "Product",
          "subtitle": "Product Management",
          "icon": Icons.inventory_2_outlined,
          "route": AppRoutes.product,
        },
        {
          "title": "Unit",
          "subtitle": "Unit Management",
          "icon": Icons.keyboard_command_key_outlined,
          "route": AppRoutes.unit,
        },
      ]
    },

    {
      "title": "Supplier & Customer Management",
      "items": [
        {
          "title": "Supplier",
          "subtitle": "Supplier Management",
          "icon": Icons.local_shipping_outlined,
          "route": AppRoutes.supplier,
        },
        {
          "title": "Customer",
          "subtitle": "Customer",
          "icon": Icons.people_outline,
          "route": AppRoutes.customer,
        },
      ]
    },

    {
      "title": "Stock Management",
      "items": [
        {
          "title": "Warehouse",
          "subtitle": "Warehouse",
          "icon": Icons.warehouse_outlined,
          "route": AppRoutes.warehouse,
        },
        {
          "title": "Warehouse Stock",
          "subtitle": "Warehouse Stock",
          "icon": Icons.warehouse_outlined,
          "route": AppRoutes.warehouseStock,
        },
        {
          "title": "Stock Adjustment",
          "subtitle": "Stock Adjustment",
          "icon": Icons.tune,
          "route": AppRoutes.stockAdjustment,
        },
        {
          "title": "Stock Transfer",
          "subtitle": "Stock Transfer",
          "icon": Icons.compare_arrows,
          "route": AppRoutes.stockTransfer,
        },
      ]
    },
    {
      "title": "Purchase Management",
      "items": [
        {
          "title": "Purchase",
          "subtitle": "Purchase Management",
          "icon": Icons.shopping_cart_outlined,
          "route": AppRoutes.purchase,
        },
        {
          "title": "Purchase Request",
          "subtitle": "Purchase Request",
          "icon": Icons.shopping_cart_outlined,
          "route": AppRoutes.purchaseReqest,
        },
        {
          "title": "Purchase Payment",
          "subtitle": "Purchase Payment Management",
          "icon": Icons.shopping_cart_outlined,
          "route": AppRoutes.purchasePayment,
        }
      ]
    },

    {
      "title": "Sale Management",
      "items": [
        {
          "title": "Sale List",
          "subtitle": "View Sales",
          "icon": Icons.receipt_long_outlined,
          "route": AppRoutes.saleList,
        },
        {
          "title": "Sale",
          "subtitle": "Go to Sale",
          "icon": Icons.point_of_sale_outlined,
          "route": AppRoutes.sale,
        },
        // {
        //   "title": "Sale Payment",
        //   "subtitle": "Payments",
        //   "icon": Icons.payments_outlined,
        //   "route": AppRoutes.salePayment,
        // },
      ]
    },

    {
      "title": "User & Role Management",
      "items": [
        {
          "title": "Role",
          "subtitle": "Role Management",
          "icon": Icons.admin_panel_settings_outlined,
          "route": AppRoutes.role,
        },
        {
          "title": "User",
          "subtitle": "User Management",
          "icon": Icons.person_outline,
          "route": AppRoutes.user,
        },
      ]
    },
    {
      "title": "Configuration Management",
      "items": [
        {
          "title": "Currency",
          "subtitle": "Currency Management",
          "icon": Icons.attach_money_outlined,
          "route": AppRoutes.currency,
        },
        {
          "title": "Payment Type",
          "subtitle": "Payment Type Management",
          "icon": Icons.payment_sharp,
          "route": AppRoutes.paymentType,
        },
      ]
    },
    {
      "title": "History Management",
      "items": [
        {
          "title": "Audit Logs",
          "subtitle": "Audit Logs",
          "icon": Icons.history_outlined,
          "route": AppRoutes.auditLogs,
        },
      ]
    },
  ];

   @override
  void onInit() {
    super.onInit();

    filteredSections.assignAll(sections);

    ever(searchCtr.keyword, (_) {
      _filter();
    });
  }

  void _filter() {
    final keyword = searchCtr.keyword.value.trim().toLowerCase();

    if (keyword.isEmpty) {
      filteredSections.assignAll(sections);
      return;
    }

    final result = sections
        .map((section) {
          final items = (section["items"] as List)
              .where((item) {
                return item["title"]
                        .toString()
                        .toLowerCase()
                        .contains(keyword) ||
                    item["subtitle"]
                        .toString()
                        .toLowerCase()
                        .contains(keyword);
              })
              .toList();

          if (items.isEmpty) return null;

          return {
            "title": section["title"],
            "items": items,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    filteredSections.assignAll(result);
  }

  void goTo(String route) {
    Get.toNamed(route);
  }
}