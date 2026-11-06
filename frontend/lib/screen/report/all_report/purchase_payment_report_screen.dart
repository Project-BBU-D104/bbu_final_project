import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class PurchasePaymentReportScreen extends StatelessWidget {
  const PurchasePaymentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Purchase Payment Report",
      ),
      body: Center(child: Text("Purchase Payment Report")),
    );
  }
}