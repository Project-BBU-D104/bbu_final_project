import 'package:flutter/material.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/screen/system_configuration/widget/card_system_configuration_widget.dart';
import 'package:frontend/screen/system_configuration/widget/table_system_configuration_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class SystemConfigurationScreen extends StatelessWidget {
  SystemConfigurationScreen({super.key});

  final ctr = Get.put(SystemConfigurationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'System Configuration'),
      body: Obx(() {
        if (ctr.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctr.systemConfigurationList.isEmpty) {
          return const Center(child: Text('No system configuration found'));
        }

        return RefreshIndicator(
          onRefresh: ctr.getSystemConfigurations,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final configurations = ctr.systemConfigurationList.toList();
              final isMobile = constraints.maxWidth < 600;

              if (isMobile) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: configurations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      CardSystemConfigurationWidget(
                        configuration: configurations[index],
                        onTap: () => ctr.openDetail(configurations[index]),
                      ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TableSystemConfigurationWidget(
                    configurations: configurations,
                  ),
                ],
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
