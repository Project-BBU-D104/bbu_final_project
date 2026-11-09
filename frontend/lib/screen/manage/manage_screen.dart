import 'package:flutter/material.dart';
import 'package:frontend/controllers/manage_controller.dart';
import 'package:frontend/screen/home/widget/feature_directory_widget.dart';
import 'package:get/get.dart';

class ManageScreen extends StatelessWidget {
  ManageScreen({super.key});
  final controller = Get.isRegistered<ManageController>()
      ? Get.find<ManageController>()
      : Get.put(ManageController());

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Obx(
      () => FeatureDirectoryWidget(
        title: 'Manage',
        subtitle: 'Your tools for day-to-day operations.',
        searchTitle: 'Search Function',
        searchController: controller.searchCtr,
        sections: controller.filteredSections.toList(),
        onNavigate: controller.goTo,
      ),
    ),
  );
}
