import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:frontend/screen/stock/warehouse_stock/widget/warehouse_stock_card_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
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
        child: 
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  SearchWidget(title: "Search Warehouse Stock"),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ChipWidget(title: "All"),
                      ChipWidget(title: "Active"),
                      ChipWidget(title: "Inactive"),
                    ]
                  ),
                  SizedBox(height: 10),
              
                  Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctr.warehouseStockList.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsetsGeometry.only(
                        bottom: 8.0
                      ),
                      child: WarehouseStockCardWidget(warehouseStock: ctr.warehouseStockList[index],),
                    ),
                  ),),
              
              
                ],
              ),
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.addWarehouseStock(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}