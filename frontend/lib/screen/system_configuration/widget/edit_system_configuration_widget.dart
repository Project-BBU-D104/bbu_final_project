import 'package:flutter/material.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:get/get.dart';

class EditSystemConfigurationWidget extends StatefulWidget {
  const EditSystemConfigurationWidget({super.key, required this.configuration});

  final Map<String, dynamic> configuration;

  @override
  State<EditSystemConfigurationWidget> createState() =>
      _EditSystemConfigurationWidgetState();
}

class _EditSystemConfigurationWidgetState
    extends State<EditSystemConfigurationWidget> {
  final ctr = Get.find<SystemConfigurationController>();
  late final TextEditingController companyNameController;
  late final TextEditingController addressController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController logoController;
  late final TextEditingController lowStockController;
  late bool allowDiscount;
  late bool taxEnabled;

  @override
  void initState() {
    super.initState();
    final config = widget.configuration;
    companyNameController = TextEditingController(
      text: config['company_name']?.toString() ?? '',
    );
    addressController = TextEditingController(
      text: config['company_address']?.toString() ?? '',
    );
    phoneController = TextEditingController(
      text: config['phone']?.toString() ?? '',
    );
    emailController = TextEditingController(
      text: config['email']?.toString() ?? '',
    );
    logoController = TextEditingController(
      text: config['logo']?.toString() ?? '',
    );
    lowStockController = TextEditingController(
      text: config['low_stock_warning']?.toString() ?? '',
    );
    allowDiscount = config['allow_discount'] as bool? ?? true;
    taxEnabled = config['tax_enabled'] as bool? ?? false;
  }

  @override
  void dispose() {
    companyNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    logoController.dispose();
    lowStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit System Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _field('Company name', companyNameController, required: true),
            _field('Address', addressController),
            _field('Phone', phoneController, keyboardType: TextInputType.phone),
            _field(
              'Email',
              emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            _field('Logo URL', logoController),
            _field(
              'Low stock warning',
              lowStockController,
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Allow discount'),
              value: allowDiscount,
              onChanged: (value) => setState(() => allowDiscount = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tax enabled'),
              value: taxEnabled,
              onChanged: (value) => setState(() => taxEnabled = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: ctr.isSaving.value ? null : _save,
                  icon: ctr.isSaving.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save changes'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              required ? '$label *' : label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: 'Enter ${label.toLowerCase()}',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final companyName = companyNameController.text.trim();
    if (companyName.isEmpty) {
      Get.snackbar('Required', 'Company name is required');
      return;
    }

    final updated = await ctr.updateSystemConfiguration(widget.configuration, {
      'company_name': companyName,
      'company_address': addressController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
      'logo': logoController.text.trim(),
      'default_currency_id': widget.configuration['default_currency_id'],
      'default_warehouse_id': widget.configuration['default_warehouse_id'],
      'default_payment_type_id':
          widget.configuration['default_payment_type_id'],
      'allow_discount': allowDiscount,
      'tax_enabled': taxEnabled,
      'low_stock_warning': int.tryParse(lowStockController.text.trim()),
    });
    if (updated && mounted) Navigator.pop(context);
  }
}
