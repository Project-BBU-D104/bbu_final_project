import 'package:flutter/material.dart';
import 'package:frontend/controllers/search_feature_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ReportController extends GetxController {
  final searchCtr = Get.put(SearchFeatureController(), tag: 'report-search');
  late final Worker _searchWorker;
  final RxList<Map<String, dynamic>> filteredSections =
      <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> sections = [
    {
      "title": "Sale Report",
      "items": [
        {
          "title": "Sale Report",
          "subtitle": "Sale Report",
          "icon": Icons.receipt_long_outlined,
          "route": AppRoutes.saleReport,
        },
        {
          "title": "Sale Payment Report",
          "subtitle": "Sale Payment Report",
          "icon": Icons.payments_outlined,
          "route": AppRoutes.salePaymentReport,
        },
      ],
    },
    {
      "title": "Purchase Report",
      "items": [
        {
          "title": "Purchase Report",
          "subtitle": "Purchase Report",
          "icon": Icons.shopping_bag_outlined,
          "route": AppRoutes.purchaseReport,
        },
        {
          "title": "Purchase Payment Report",
          "subtitle": "Purchase Payment Report",
          "icon": Icons.account_balance_wallet_outlined,
          "route": AppRoutes.purchasePaymentReport,
        },
      ],
    },
    {
      "title": "Stock Ledger Report",
      "items": [
        {
          "title": "Stock Ledger Report",
          "subtitle": "Stock Ledger Report",
          "icon": Icons.inventory_2_outlined,
          "route": AppRoutes.stockLedgerReport,
        },
      ],
    },
    {
      "title": "Profit and Loss Report",
      "items": [
        {
          "title": "Profit and Loss Report",
          "subtitle": "Profit and Loss Report",
          "icon": Icons.insights_outlined,
          "route": AppRoutes.profitAndLossReport,
        },
      ],
    },
  ];

  @override
  void onInit() {
    super.onInit();

    filteredSections.assignAll(sections);

    _searchWorker = ever(searchCtr.keyword, (_) {
      _filter();
    });
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    Get.delete<SearchFeatureController>(tag: 'report-search');
    super.onClose();
  }

  void _filter() {
    final keyword = searchCtr.keyword.value.trim().toLowerCase();

    if (keyword.isEmpty) {
      filteredSections.assignAll(sections);
      return;
    }

    final result = sections
        .map((section) {
          final items = (section["items"] as List).where((item) {
            return item["title"].toString().tr.toLowerCase().contains(
                  keyword,
                ) ||
                item["subtitle"].toString().tr.toLowerCase().contains(keyword);
          }).toList();

          if (items.isEmpty) return null;

          return {"title": section["title"], "items": items};
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    filteredSections.assignAll(result);
  }

  void goTo(String route) {
    Get.toNamed(route);
  }
}
