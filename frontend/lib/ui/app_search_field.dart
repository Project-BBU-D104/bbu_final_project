import 'package:flutter/material.dart';
import 'package:frontend/widget/search_widget.dart';

/// Shared search field using the app theme for its surface and outline.
class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, required this.title, this.showScan = false});

  final String title;
  final bool showScan;

  @override
  Widget build(BuildContext context) {
    return SearchWidget(title: title, showScan: showScan);
  }
}
