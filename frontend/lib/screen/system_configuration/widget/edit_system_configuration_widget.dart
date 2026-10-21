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
  int? selectedCurrencyId;
  int? selectedWarehouseId;
  int? selectedPaymentTypeId;

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
    selectedCurrencyId =
        int.tryParse(config['default_currency_id']?.toString() ?? '');
    selectedWarehouseId =
        int.tryParse(config['default_warehouse_id']?.toString() ?? '');
    selectedPaymentTypeId =
        int.tryParse(config['default_payment_type_id']?.toString() ?? '');
    allowDiscount = config['allow_discount'] as bool? ?? true;
    taxEnabled = config['tax_enabled'] as bool? ?? false;
    ctr.loadConfigurationOptions();
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
            Obx(() {
              if (ctr.isOptionsLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final currencyIds = ctr.currencies.map(_id).whereType<int>().toSet();
              final warehouseIds =
                  ctr.warehouses.map(_id).whereType<int>().toSet();
              final paymentTypeIds =
                  ctr.paymentTypes.map(_id).whereType<int>().toSet();

              final currencyValue = currencyIds.contains(selectedCurrencyId)
                  ? selectedCurrencyId
                  : _firstId(ctr.currencies);
              final warehouseValue =
                  warehouseIds.contains(selectedWarehouseId)
                      ? selectedWarehouseId!
                      : -1;
              final paymentTypeValue =
                  paymentTypeIds.contains(selectedPaymentTypeId)
                      ? selectedPaymentTypeId!
                      : -1;

              return Column(
                children: [
                  _dropdownField(
                    label: 'Default currency',
                    child: DropdownButtonFormField<int>(
                      initialValue: currencyValue,
                      decoration: const InputDecoration(
                        hintText: 'Select currency',
                        border: OutlineInputBorder(),
                      ),
                      items: ctr.currencies
                          .map((currency) {
                            final id = _id(currency);
                            if (id == null) return null;
                            final name =
                                currency['name']?.toString() ?? 'Currency';
                            final code = currency['code']?.toString();
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                code == null || code.isEmpty
                                    ? name
                                    : '$name ($code)',
                              ),
                            );
                          })
                          .whereType<DropdownMenuItem<int>>()
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedCurrencyId = value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Default warehouse',
                    child: DropdownButtonFormField<int>(
                      initialValue: warehouseValue,
                      decoration: const InputDecoration(
                        hintText: 'Select warehouse',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: -1,
                          child: Text('Not set'),
                        ),
                        ...ctr.warehouses
                            .map((warehouse) {
                              final id = _id(warehouse);
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  warehouse['name']?.toString() ?? 'Warehouse',
                                ),
                              );
                            })
                            .where((item) => item.value != null),
                      ],
                      onChanged: (value) => setState(
                        () => selectedWarehouseId =
                            value == -1 ? null : value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Default payment type',
                    child: DropdownButtonFormField<int>(
                      initialValue: paymentTypeValue,
                      decoration: const InputDecoration(
                        hintText: 'Select payment type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: -1,
                          child: Text('Not set'),
                        ),
                        ...ctr.paymentTypes
                            .map((paymentType) {
                              final id = _id(paymentType);
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  paymentType['name']?.toString() ??
                                      'Payment type',
                                ),
                              );
                            })
                            .where((item) => item.value != null),
                      ],
                      onChanged: (value) => setState(
                        () => selectedPaymentTypeId =
                            value == -1 ? null : value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),
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

  Widget _dropdownField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  int? _id(Map<String, dynamic> item) =>
      int.tryParse(item['id']?.toString() ?? '');

  int? _firstId(List<Map<String, dynamic>> items) =>
      items.isEmpty ? null : _id(items.first);

  Future<void> _save() async {
    final companyName = companyNameController.text.trim();
    if (companyName.isEmpty) {
      Get.snackbar('Required', 'Company name is required');
      return;
    }

    final currencyId = selectedCurrencyId ?? _firstId(ctr.currencies);
    if (currencyId == null) {
      Get.snackbar('Required', 'A currency is required');
      return;
    }

    final updated = await ctr.updateSystemConfiguration(widget.configuration, {
      'company_name': companyName,
      'company_address': addressController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
      'logo': logoController.text.trim(),
      'default_currency_id': currencyId,
      'default_warehouse_id': selectedWarehouseId,
      'default_payment_type_id': selectedPaymentTypeId,
      'allow_discount': allowDiscount,
      'tax_enabled': taxEnabled,
      'low_stock_warning': int.tryParse(lowStockController.text.trim()),
    });
    if (updated && mounted) Navigator.pop(context);
  }
}
