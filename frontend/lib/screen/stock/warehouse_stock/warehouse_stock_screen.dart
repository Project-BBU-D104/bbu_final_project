import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/screen/stock/warehouse_stock/widget/warehouse_stock_card_widget.dart';
import 'package:frontend/screen/stock/warehouse_stock/widget/warehouse_stock_table_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class WarehouseStockScreen extends StatelessWidget {
  WarehouseStockScreen({super.key});

  final ctr = Get.find<WarehouseStockController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Warehouse Stock"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                SizedBox(height: 4),

                SearchWidget(title: "Search Warehouse Stock"),
                
                SizedBox(height: 10),
                 
                Obx(() {
                  if (ctr.isLoading.value) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (ctr.warehouseStockList.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(child: Text("No Data Found".tr)),
                    );
                  }

                  if (ctr.searchwarehouseStockList.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(child: Text("Search Data Not Found".tr)),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final stocks = ctr.searchwarehouseStockList
                          .map(
                            (stock) => Map<String, dynamic>.from(stock as Map),
                          )
                          .toList();
                      final isMobile = constraints.maxWidth < 600;

                      if (isMobile) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stocks.length,
                          padding: const EdgeInsets.only(bottom: 70),
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: WarehouseStockCardWidget(
                              warehouseStock: stocks[index],
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 70),
                        child: WarehouseStockTableWidget(
                          warehouseStocks: stocks,
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ctr.addWarehouseStock(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
