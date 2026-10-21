import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_card_widget.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_table_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class StockTransferScreen extends StatelessWidget {
  StockTransferScreen({super.key});

  final ctr = Get.find<ProductTransferController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Stock Transfer"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SearchWidget(title: "Search Stock Transfer".tr),
             
              SizedBox(height: 10),

              Obx(() {
                if (ctr.isLoading.value) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (ctr.stockTransfer.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text(
                        "No data found".tr,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                if (ctr.searchStockTransferList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text(
                        "No data found".tr,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final transfers = ctr.searchStockTransferList.toList();
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transfers.length,
                        padding: const EdgeInsets.only(bottom: 100),
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: StockTransferCardWidget(
                            stockTransfer: transfers[index],
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: StockTransferTableWidget(
                        stockTransfers: transfers,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ctr.addStockTransfer(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
