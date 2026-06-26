import 'package:flutter/material.dart';
import 'package:frontend/controllers/home_controller.dart';
import 'package:frontend/widget/card_feature_widget.dart';
import 'package:get/get.dart';
class QuickActionWidget extends StatelessWidget {
  QuickActionWidget({super.key});

  final ctr = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Action",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10,),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 1.3,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CardFeatureWidget(
                onTap: (){
                  ctr.gotoSale();
                },
                icon: Icons.category_outlined,
                title: "Sale",
                subtitle: "Go to Sale",
              ),
              CardFeatureWidget(
                onTap: (){
                  ctr.gotoCategory();
                },
                icon: Icons.category_outlined,
                title: "Category List",
                subtitle: "Category Management",
              ),
              CardFeatureWidget(
                onTap: (){
                  ctr.gotoProduct();
                },
                icon: Icons.category_outlined,
                title: "Product List",
                subtitle: "Product Management",
              ),
              CardFeatureWidget(
                onTap: (){
                  ctr.gotoSupplier();
                },
                icon: Icons.category_outlined,
                title: "Supplier List",
                subtitle: "Supplier Management",
              ),
               
            ],
          )
        ],
      )
    );
  }
}