import 'package:flutter/material.dart';
import 'package:frontend/controllers/search_feature_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ManageController extends GetxController{

  final searchCtr = Get.put(SearchFeatureController());
  final RxList<Map<String, dynamic>> filteredSections =
      <Map<String, dynamic>>[].obs;

  static const Map<String, Set<String>> _routeRoles = {
    AppRoutes.supplier: {'stock manager'},
    AppRoutes.unit: {},
    AppRoutes.category: {'cashier', 'stock manager'},
    AppRoutes.product: {'cashier', 'stock manager'},
    AppRoutes.warehouse: {'stock manager'},
    AppRoutes.warehouseStock: {'stock manager'},
    AppRoutes.stockAdjustment: {'stock manager'},
    AppRoutes.stockTransfer: {'stock manager'},
    AppRoutes.purchase: {'stock manager'},
    AppRoutes.purchaseReqest: {'stock manager'},
    AppRoutes.purchasePayment: {'stock manager'},
    AppRoutes.saleList: {'cashier'},
    AppRoutes.sale: {'cashier'},
    AppRoutes.role: {},
    AppRoutes.user: {},
    AppRoutes.systemConfiguration: {},
    AppRoutes.currency: {},
    AppRoutes.paymentType: {},
  };


  final List<Map<String, dynamic>> sections = [
    {
      "title": "Supplier Management",
      "items": [
        {
          "title": "Supplier",
          "subtitle": "Supplier Management",
          "icon": Icons.local_shipping_outlined,
          "route": AppRoutes.supplier,
        },
        // {
        //   "title": "Customer",
        //   "subtitle": "Customer",
        //   "icon": Icons.people_outline,
        //   "route": AppRoutes.customer,
        // },
      ]
    },

    {
      "title": "Product Management",
      "items": [
        {
          "title": "Unit",
          "subtitle": "Unit Management",
          "icon": Icons.keyboard_command_key_outlined,
          "route": AppRoutes.unit,
        },
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
        }
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
          "title": "System Configuration",
          "subtitle": "System Configuration",
          "icon": Icons.settings_outlined,
          "route": AppRoutes.systemConfiguration,
        },
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
    // {
    //   "title": "History Management",
    //   "items": [
    //     {
    //       "title": "Audit Logs",
    //       "subtitle": "Audit Logs",
    //       "icon": Icons.history_outlined,
    //       "route": AppRoutes.auditLogs,
    //     },
    //   ]
    // },
  ];

  bool canAccessRoute(String route) {
    final role = storage.currentUserRole.trim().toLowerCase();
    if (role == 'admin' || role == 'owner') return true;

    return _routeRoles[route]?.contains(role) ?? false;
  }

  List<Map<String, dynamic>> get accessibleSections {
    return sections
        .map((section) {
          final items = (section['items'] as List)
              .where((item) => canAccessRoute(item['route'] as String))
              .toList();
          if (items.isEmpty) return null;

          return {...section, 'items': items};
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

   @override
  void onInit() {
    super.onInit();

    filteredSections.assignAll(accessibleSections);

    ever(searchCtr.keyword, (_) {
      _filter();
    });
  }

  void _filter() {
    final keyword = searchCtr.keyword.value.trim().toLowerCase();

    if (keyword.isEmpty) {
      filteredSections.assignAll(accessibleSections);
      return;
    }

    final result = accessibleSections
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
    if (!canAccessRoute(route)) {
      Get.snackbar('Access denied', 'Your role cannot access this section');
      return;
    }

    Get.toNamed(route);
  }
}