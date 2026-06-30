import 'package:flutter/material.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatelessWidget {
 PaymentScreen({super.key});

  final ctr = Get.find<PaymentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Payment"),
      body: Center(child: Text("Payment Screen")),
    );
  }
}