import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/screen/stock/warehouse/widget/warehouse_card_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class WarehouseScreen extends StatelessWidget {
    WarehouseScreen({super.key});

  final ctr = Get.put(WarehouseController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Warehouse Screen")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
              WarehouseCardWidget(),
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