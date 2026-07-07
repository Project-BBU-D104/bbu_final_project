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
        child:   Column(
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
                    padding: const EdgeInsets.only(bottom: 70),
                    itemBuilder:(context,index){
                      return Padding(
                        padding: const EdgeInsetsGeometry.only(
                          left: 10,
                          right: 10,
                          bottom: 0,
                          top: 0,
                        ),
                        child: SupplierCardWidget(
                         item: controller.suppliers[index]
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.addSupplier(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}