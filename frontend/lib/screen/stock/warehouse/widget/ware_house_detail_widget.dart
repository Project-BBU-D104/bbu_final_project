import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class WareHouseDetailWidget extends StatelessWidget {
  const WareHouseDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "WareHouse Detail"),
      body: Text("WareHouse Detail Widget"),
    );
  }
}