import 'package:flutter/material.dart';
import 'package:frontend/screen/home/widget/quick_action_widget.dart';
import 'package:frontend/screen/home/widget/recent_purchase_order_widget.dart';
import 'package:frontend/screen/home/widget/recent_sale_widget.dart';
import 'package:frontend/screen/home/widget/welcome_widget.dart';
import 'package:frontend/widget/test_product_scanner_page.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                SizedBox(
                  width: double.infinity,
                  child: WelcomeWidget()
                ),

                ElevatedButton(
                  onPressed: () async {
                    final code = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TestProductScannerPage(),
                      ),
                    );

                    if (code != null) {
                      print(code);

                      // Search your database
                      // searchProduct(code);
                    }
                  },
                  child: const Text("Scan Product"),
                ),

                SizedBox(height: 15,),
                QuickActionWidget(),
                SizedBox(height: 15,),
                RecentStockInWidget(),
                RecentStockOutWidget(),
              ]
            ),
          )
        )
      )
    );
  }
}