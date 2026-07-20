import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class UnitScreen extends StatelessWidget {
  const UnitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Unit"),
      body: Text("Unit Screen"),
    );
  }
}