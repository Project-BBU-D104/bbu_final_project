import 'package:flutter/material.dart';
import 'package:frontend/widget/custom_app_bar.dart';

class SalePaymentReportScreen extends StatelessWidget {
  const SalePaymentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Sale Payment Report",
        showBack: true,
        onBack: () => Navigator.pop(context),
        onRefresh: (){
          // 
        },
        actions: [
          IconButton(
            onPressed: () {
              // 
            },
            icon: const Icon(Icons.filter_alt_outlined),
          ),
        ],
      ),
      body: Center(child: Text("Sale Payment Report")),
    );
  }
}