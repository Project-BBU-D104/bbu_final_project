import 'package:flutter/material.dart';
import 'package:frontend/controllers/search_feature_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class ReportController extends GetxController{
final searchCtr = Get.put(SearchFeatureController());
  final RxList<Map<String, dynamic>> filteredSections =
      <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> sections = [   
    {
      "title": "Sale Report",
      "items": [
        {
          "title": "Sale Report",
          "subtitle": "Sale Report",
          "icon": Icons.access_time_outlined,
          "route": AppRoutes.saleReport,
        },
        {
          "title": "Sale Payment Report",
          "subtitle": "Sale Payment Report",
          "icon": Icons.access_time_outlined,
          "route": AppRoutes.salePaymentReport,
        },
      ]
    },
    {
      "title": "Purchase Report",
      "items": [
        {
          "title": "Purchase Report",
          "subtitle": "Purchase Report",
          "icon": Icons.access_time_outlined,
          "route": AppRoutes.saleReport,
        },
        {
          "title": "Purchase Payment Report",
          "subtitle": "Purchase Payment Report",
          "icon": Icons.access_time_outlined,
          "route": AppRoutes.saleReport,
        },
      ]
    },
    {
      "title": "Stock Ledger Report",
      "items": [
        {
          "title": "Stock Ledger Report",
          "subtitle": "Stock Ledger Report",
          "icon": Icons.access_time_outlined,
          "route": AppRoutes.saleReport,
        },
      ]
    },
    {
      "title": "Profit and Loss Report",
      "items": [
        {
          "title": "Profit and Loss Report",
          "subtitle": "Profit and Loss Report",
          "icon": Icons.access_time_outlined,
          "route": AppRoutes.saleReport,
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