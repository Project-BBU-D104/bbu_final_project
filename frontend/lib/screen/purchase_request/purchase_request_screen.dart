import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class PurchaseRequestScreen extends StatelessWidget {
  const PurchaseRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Purchase Request"),
      body: Text("Purchase Request Screen"),
    );
  }
}