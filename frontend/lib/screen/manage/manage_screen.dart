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
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToPurchase(),
                      },
                      icon: Icons.category_outlined,
                      title: "Purchase",
                      subtitle: "Purchase Management",
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
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToCustomer(),
                      },
                      icon: Icons.category_outlined,
                      title: "Customer",
                      subtitle: "Customer",
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
                        controller.goToStockMovement(),
                      },
                      icon: Icons.category_outlined,
                      title: "Stock Movement",
                      subtitle: "Stock Movement",
                    ),
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToStockAdjustment(),
                      },
                      icon: Icons.category_outlined,
                      title: "Stock Adjustment",
                      subtitle: "Stock Adjustment",
                    ),
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToStockTransfer(),
                      },
                      icon: Icons.category_outlined,
                      title: "Stock Transfer",
                      subtitle: "Stock Transfer",
                    ),
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToWareHouse(),
                      },
                      icon: Icons.category_outlined,
                      title: "WareHouse",
                      subtitle: "WareHouse",
                    ),
                  ],
                ),
                Text(
                  "Sale Management"
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToSaleList(),
                      },
                      icon: Icons.category_outlined,
                      title: "Sale List",
                      subtitle: "View Sale Lists",
                    ),
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToSale(),
                      },
                      icon: Icons.category_outlined,
                      title: "Sale",
                      subtitle: "Go to Sale",
                    ),
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToSalePayment(),
                      },
                      icon: Icons.category_outlined,
                      title: "Sale Payment",
                      subtitle: "Go to Payment",
                    ),
                  ],
                ),
                Text(
                  "User & Role Management"
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToRole(),
                      },
                      icon: Icons.category_outlined,
                      title: "Role",
                      subtitle: "Go to Role",
                    ), 
                    CardFeatureWidget(
                      onTap: () => {
                        controller.goToUser(),
                      },
                      icon: Icons.category_outlined,
                      title: "User",
                      subtitle: "View User Lists",
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