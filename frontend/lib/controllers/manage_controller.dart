import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ManageController extends GetxController{

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
          "title": "Purchase",
          "subtitle": "Purchase Management",
          "icon": Icons.shopping_cart_outlined,
          "route": AppRoutes.purchase,
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
        // {
        //   "title": "Stock Movement",
        //   "subtitle": "Stock Movement",
        //   "icon": Icons.swap_horiz,
        //   "route": AppRoutes.stockMovement,
        // },
        {
          "title": "Audit Logs",
          "subtitle": "Audit Logs",
          "icon": Icons.history_outlined,
          "route": AppRoutes.auditLogs,
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
        {
          "title": "Warehouse",
          "subtitle": "Warehouse",
          "icon": Icons.warehouse_outlined,
          "route": AppRoutes.warehouse,
        },
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
        {
          "title": "Sale Payment",
          "subtitle": "Payments",
          "icon": Icons.payments_outlined,
          "route": AppRoutes.salePayment,
        },
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
  ];

  void goTo(String route) {
    Get.toNamed(route);
  }
}