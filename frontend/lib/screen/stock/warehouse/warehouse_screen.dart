import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/screen/stock/warehouse/widget/warehouse_card_widget.dart';
import 'package:frontend/screen/stock/warehouse/widget/warehouse_table_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class WarehouseScreen extends StatelessWidget {
  WarehouseScreen({super.key});

  final ctr = Get.find<WarehouseController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Warehouse"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SearchWidget(title: "Search Warehouse"),
              
              SizedBox(height: 15),

              Obx(() {
                if (ctr.isLoading.value) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (ctr.warehouseList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(child: Text("No Warehouse Found".tr)),
                  );
                }
                if (ctr.searchWarehouseList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(child: Text("Search Result Not Found".tr)),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final warehouses = ctr.searchWarehouseList.toList();
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: warehouses.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: WarehouseCardWidget(
                            warehouse: warehouses[index],
                          ),
                        ),
                      );
                    }

                    return WarehouseTableWidget(warehouses: warehouses);
                  },
                );
              }),

              SizedBox(height: 70),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ctr.addWarehouse(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
