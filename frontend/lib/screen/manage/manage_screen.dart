import 'package:flutter/material.dart';
import 'package:frontend/controllers/manage_controller.dart';
import 'package:frontend/screen/manage/widget/card_feature_widget.dart';
import 'package:get/get.dart';

class ManageScreen extends StatelessWidget {
  ManageScreen({super.key});
  final controller = Get.put(ManageController()); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
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
      ),
    );
  }
}