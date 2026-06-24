import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:get/get.dart';

class SearchWidget extends StatelessWidget {
  final String title;
  SearchWidget({super.key, required this.title});

  final ctr = Get.put(SearchController());

  @override
  Widget build(BuildContext context) {
    return TextField(
      // controller: _searchController,
      style: TextStyle(
        color: darkColor.shade100,
        fontSize: 13,
      ),
      decoration:   InputDecoration(
        hintText: title,
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
    );
  }
}