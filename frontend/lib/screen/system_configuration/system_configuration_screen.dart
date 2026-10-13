import 'package:flutter/material.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/screen/system_configuration/widget/card_system_configuration_widget.dart';
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
      body: Center(
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CardSystemConfigurationWidget(),
            ]
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => ctr.addSystemConfiguration(
          context
        ),
      ),
    );
  }
}