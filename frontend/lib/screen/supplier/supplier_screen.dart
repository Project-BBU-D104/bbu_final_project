import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/screen/supplier/widgets/supplier_card_widget.dart';
import 'package:frontend/widget/chip_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';


class SupplierScreen extends StatelessWidget {
  SupplierScreen({super.key});
  final controller = Get.find<SupplierController>();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(title: "Suppliers"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SearchWidget(
                title: "Search Suppliers",
              ),
              const SizedBox(height:16),
              Row(
                children: [
                  ChipWidget(
                    title: "All",
                  ),
                  ChipWidget(
                    title: "Verified",
                  ),
                  ChipWidget(
                    title: "Unverified",
                  ),
                  ChipWidget(
                    title: "Blocked",
                  ),
                   
                ],
              ),
              const SizedBox(height:16),
              Expanded(
                child: Obx(
                  ()=>ListView.builder(
                    itemCount: controller.suppliers.length,
                    itemBuilder:(context,index){
                      return SupplierCardWidget(
                       item: controller.suppliers[index]
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.addSupplier(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}