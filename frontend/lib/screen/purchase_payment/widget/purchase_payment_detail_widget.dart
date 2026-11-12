import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class PurchasePaymentDetailWidget extends StatelessWidget {
  const PurchasePaymentDetailWidget({super.key, required this.payment});

  final Map<String, dynamic> payment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Purchase Payment"),
      body: Text("Purchase Payment Card Widget"),
    );
  }
}
