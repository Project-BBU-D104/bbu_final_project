import 'package:flutter/material.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:frontend/screen/system_configuration/widget/edit_system_configuration_widget.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class CardSystemConfigurationDetailWidget extends StatelessWidget {
  CardSystemConfigurationDetailWidget({super.key, required this.configuration});

  final Map<String, dynamic> configuration;
  final ctr = Get.find<SystemConfigurationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'System Configuration Details'),
      body: Container(
        color: const Color(0xFFF4F7F6),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE6ECE9)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8FAF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.business_rounded,
                          color: Color(0xFF00A878),
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          configuration['company_name']?.toString() ?? '-',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detail('Address', configuration['company_address']),
                  _detail('Phone', configuration['phone']),
                  _detail('Email', configuration['email']),
                  _detail('Logo', configuration['logo']),
                  _detail(
                    'Default currency ID',
                    configuration['default_currency_id'],
                  ),
                  _detail(
                    'Default warehouse ID',
                    configuration['default_warehouse_id'],
                  ),
                  _detail(
                    'Default payment type ID',
                    configuration['default_payment_type_id'],
                  ),
                  _detail(
                    'Allow discount',
                    _yesNo(configuration['allow_discount']),
                  ),
                  _detail('Tax enabled', _yesNo(configuration['tax_enabled'])),
                  _detail(
                    'Low stock warning',
                    configuration['low_stock_warning'],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ctr.deleteSystemConfiguration(context, configuration),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => AppBottomSheets.show<void>(
                    context,
                    child: EditSystemConfigurationWidget(
                      configuration: configuration,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, Object? value) {
    final text = value == null || value.toString().trim().isEmpty
        ? 'Not set'
        : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _yesNo(Object? value) => value == true ? 'Yes' : 'No';
}
