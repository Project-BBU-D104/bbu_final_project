import 'package:flutter/material.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class SystemConfigurationScreen extends StatelessWidget {
  SystemConfigurationScreen({super.key});
  final ctr = Get.put(SystemConfigurationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'System Configuration',
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('System Configuration Content'),
      ),
    );
  }
}