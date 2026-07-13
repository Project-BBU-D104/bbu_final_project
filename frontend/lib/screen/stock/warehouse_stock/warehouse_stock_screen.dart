import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class WarehouseStockScreen extends StatelessWidget {
  const WarehouseStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Warehouse Stock"),
      body: SafeArea(
        child: 
          Column(
            children: [
              Text("Hello warehouse")
            ],
          )
      )
    );
  }
}