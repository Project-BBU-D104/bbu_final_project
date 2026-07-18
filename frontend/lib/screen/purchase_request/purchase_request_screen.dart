import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class PurchaseRequestScreen extends StatelessWidget {
  PurchaseRequestScreen({super.key});

  final ctr = Get.find<PurchaseRequestController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Purchase Request"),
      body: Text("Purchase Request Screen"),
    );
  }
}