import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class PurchasePaymentScreen extends StatelessWidget {
  const PurchasePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Purchase Payment"),
      body: Text("Purchase Payment Screen"),
    );
  }
}