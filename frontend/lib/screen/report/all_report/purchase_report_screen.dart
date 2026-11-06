import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class PurchaseReportScreen extends StatelessWidget {
  const PurchaseReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Purchase Report",
      ),
      body: Center(child: Text("Purchase Report")),
    );
  }
}