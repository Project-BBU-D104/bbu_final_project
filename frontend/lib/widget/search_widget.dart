import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:get/get.dart';

class SearchWidget extends StatelessWidget {
  final String title;
  SearchWidget({super.key, required this.title});

  final ctr = Get.put(SearchController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: darkColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        // controller: _searchController,
        style: TextStyle(
          color: darkColor.shade100,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: title.tr,
          hintStyle: TextStyle(
            color: darkColor.shade100,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: darkColor.shade100,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}