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
      body: Obx(() {
        if (ctr.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (ctr.systemConfigurationList.isEmpty) {
          return const Center(
            child: Text('No system configuration found'),
          );
        }

        return RefreshIndicator(
          onRefresh: ctr.getSystemConfigurations,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ctr.systemConfigurationList.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final configuration =
                  ctr.systemConfigurationList[index];

              return CardSystemConfigurationWidget(
                configuration: configuration, 
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ctr.addSystemConfiguration(context),
        child: const Icon(Icons.edit),
      ),
    );
  }
}