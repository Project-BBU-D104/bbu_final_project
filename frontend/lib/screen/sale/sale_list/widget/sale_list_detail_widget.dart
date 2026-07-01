import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class SaleListDetailWidget extends StatelessWidget {
  const SaleListDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sale List Detail"),
      body: Text("Sale List Detail Widget"),
    );
  }
}