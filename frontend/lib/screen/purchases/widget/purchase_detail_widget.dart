import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class PurchaseDetailWidget extends StatelessWidget {
  const PurchaseDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Purchase Detail",
      ),
      body: Text("Purchase Detail Widget"),
    );
  }
}