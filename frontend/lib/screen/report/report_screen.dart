import 'package:flutter/material.dart';
import 'package:frontend/controllers/report_controller.dart';
import 'package:frontend/screen/home/widget/feature_directory_widget.dart';
import 'package:get/get.dart';

class ReportScreen extends StatelessWidget {
  ReportScreen({super.key});
  final controller = Get.isRegistered<ReportController>()
      ? Get.find<ReportController>()
      : Get.put(ReportController());

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Obx(
      () => FeatureDirectoryWidget(
        title: 'Report',
        subtitle: 'Explore sales, purchases, and inventory performance.',
        searchTitle: 'Search Report',
        searchController: controller.searchCtr,
        sections: controller.filteredSections.toList(),
        onNavigate: controller.goTo,
      ),
    ),
  );
}
