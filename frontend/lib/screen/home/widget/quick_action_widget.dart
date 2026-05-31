import 'package:flutter/material.dart';
import 'package:frontend/controllers/home_controller.dart';
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
          Text("Quick Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 10,),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 1.6,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              cardQuickAction(
                onTab: (){
                  ctr.gotoCategory();
                },
                icon: Icons.category_outlined,
                title: "Category List",
                subtitle: "Category Management",
              ),
              cardQuickAction(
                onTab: (){
                  ctr.gotoProduct();
                },
                icon: Icons.category_outlined,
                title: "Product List",
                subtitle: "Product Management",
              ),
              cardQuickAction(
                onTab: (){
                  ctr.gotoSupplier();
                },
                icon: Icons.category_outlined,
                title: "Supplier List",
                subtitle: "Supplier Management",
              ),
              cardQuickAction(
                onTab: (){
                  ctr.gotoStock();
                },
                icon: Icons.category_outlined,
                title: "Stock List",
                subtitle: "Stock Management",
              ),
            ],
          )
        ],
      )
    );
  }
}

Widget cardQuickAction(
  {
    required IconData icon,
    required String title,
    required String subtitle,

    VoidCallback? onTab
  }
){
  return InkWell(
    onTap: onTab,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 10,),
            Text(title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              )
            ),
            Text(subtitle),
          ],
        ),
      )
    ),
  );
}