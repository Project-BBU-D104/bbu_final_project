import 'package:flutter/material.dart' hide SearchController;
import 'package:frontend/controllers/search_controller.dart';
import 'package:frontend/widget/search_widget.dart';

/// Shared search field using the app theme for its surface and outline.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.title,
    this.showScan = false,
    this.searchController,
    this.barcodeScanner,
  });

  final String title;
  final bool showScan;
  final SearchController? searchController;
  final Future<String?> Function()? barcodeScanner;

  @override
  Widget build(BuildContext context) {
    return SearchWidget(
      title: title,
      showScan: showScan,
      searchController: searchController,
      barcodeScanner: barcodeScanner,
    );
  }
}
