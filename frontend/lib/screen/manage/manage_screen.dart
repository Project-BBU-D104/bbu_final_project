import 'package:flutter/material.dart';
import 'package:frontend/controllers/manage_controller.dart';
import 'package:frontend/widget/card_feature_widget.dart';
import 'package:get/get.dart';

class ManageScreen extends StatelessWidget {
  ManageScreen({super.key});
  final controller = Get.put(ManageController()); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Product & Category Management"
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,
                  children: [
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToCategory(),
                      },
                      icon: Icons.category_outlined,
                      title: "Category",
                      subtitle: "Category Management",
                    ),
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToProduct(),
                      },
                      icon: Icons.category_outlined,
                      title: "Product",
                      subtitle: "Product Management",
                    ),
                  ],
                ),
                Text(
                  "Supplier Management"
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToSupplier(),
                      },
                      icon: Icons.category_outlined,
                      title: "Supplier",
                      subtitle: "Supplier Management",
                    ),
                  ],
                ),
                Text(
                  "Stock Management"
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToStock(),
                      },
                      icon: Icons.category_outlined,
                      title: "Stock Movement",
                      subtitle: "Stock Movement",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}