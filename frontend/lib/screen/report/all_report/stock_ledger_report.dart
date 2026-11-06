import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class StockLedgerReport extends StatelessWidget {
  const StockLedgerReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Stock Ledger Report",
      ),
      body: const Center(child: Text("Stock ledger Report")),
    );
  }
}