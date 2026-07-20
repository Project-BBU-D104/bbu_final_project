import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class PaymentTypeScreen extends StatelessWidget {
  const PaymentTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Payment Type"),
      body: Text("Payment Type Screen"),
    );
  }
}