import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Currency"),
      body: Text("Currency Screen"),
    );
  }
}