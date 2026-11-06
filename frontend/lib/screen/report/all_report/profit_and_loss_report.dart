import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class ProfitAndLossReport extends StatelessWidget {
  const ProfitAndLossReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Profit And Loss Report",
      ),
      body: const Center(child: Text("Profit And Loss Report")),
    );
  }
}