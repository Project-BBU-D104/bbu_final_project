import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/screen/stock/warehouse/widget/warehouse_card_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SearchWidget(title: "Search Warehouse"),
              SizedBox(height: 10,),
              Row(
                children: [
                  ChipWidget(title: "All"),
                  ChipWidget(title: "Active"),
                  ChipWidget(title: "Inactive"),
                ],
              ),
           SizedBox(height: 15,),

              Obx(() {
                if (ctr.isLoading.value) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                if (ctr.warehouseList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text("No Warehouse Found".tr),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ctr.warehouseList.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsetsGeometry.only(
                      bottom: 8.0
                    ),
                    child: WarehouseCardWidget( warehouse: ctr.warehouseList[index],),
                  ),
                );
              }),
              
              SizedBox(height: 70,)
            ],
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          ctr.addWarehouse(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}