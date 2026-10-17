import 'package:flutter/material.dart';
import 'package:frontend/controllers/system_configuration_controller.dart';
import 'package:get/get.dart';

class AddSystemConfigurationWidget extends StatefulWidget {
  const AddSystemConfigurationWidget({super.key});

  @override
  State<AddSystemConfigurationWidget> createState() =>
      _AddSystemConfigurationWidgetState();
}

class _AddSystemConfigurationWidgetState
    extends State<AddSystemConfigurationWidget> {
  final ctr = Get.find<SystemConfigurationController>();
  final formKey = GlobalKey<FormState>();
  final companyNameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final logoController = TextEditingController();
  final lowStockController = TextEditingController();

  int? selectedCurrencyId;
  int? selectedWarehouseId;
  int? selectedPaymentTypeId;
  bool allowDiscount = true;
  bool taxEnabled = false;

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
    final currencyOptions = ctr.currencies;
    final firstCurrencyId = _firstId(currencyOptions);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add System Configuration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _textField(
                  controller: companyNameController,
                  label: 'Company name *',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Company name is required'
                      : null,
                ),
                _textField(controller: addressController, label: 'Address'),
                _textField(
                  controller: phoneController,
                  label: 'Phone',
                  keyboardType: TextInputType.phone,
                ),
                _textField(
                  controller: emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                _textField(controller: logoController, label: 'Logo URL'),
                Obx(() {
                  if (ctr.isOptionsLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Column(
                    children: [
                      _dropdownField(
                        label: 'Default currency *',
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedCurrencyId ?? firstCurrencyId,
                          decoration: const InputDecoration(
                            hintText: 'Select currency',
                            border: OutlineInputBorder(),
                          ),
                          items: currencyOptions
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
                          validator: (value) => value == null
                              ? 'Select a default currency'
                              : null,
                          onChanged: (value) =>
                              setState(() => selectedCurrencyId = value),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _dropdownField(
                        label: 'Default warehouse',
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedWarehouseId ?? -1,
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
                                      warehouse['name']?.toString() ??
                                          'Warehouse',
                                    ),
                                  );
                                })
                                .where((item) => item.value != null),
                          ],
                          onChanged: (value) => setState(
                            () => selectedWarehouseId = value == -1
                                ? null
                                : value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _dropdownField(
                        label: 'Default payment type',
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedPaymentTypeId ?? -1,
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
                            () => selectedPaymentTypeId = value == -1
                                ? null
                                : value,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                _textField(
                  controller: lowStockController,
                  label: 'Low stock warning',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final amount = int.tryParse(value.trim());
                    return amount == null || amount < 0
                        ? 'Enter a non-negative whole number'
                        : null;
                  },
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton.icon(
                      onPressed: ctr.isSaving.value ? null : _submit,
                      icon: ctr.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Create configuration'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: 'Enter ${label.replaceAll(' *', '').toLowerCase()}',
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
      children: [_fieldLabel(label), const SizedBox(height: 6), child],
    );
  }

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  int? _id(Map<String, dynamic> item) =>
      int.tryParse(item['id']?.toString() ?? '');

  int? _firstId(List<Map<String, dynamic>> items) =>
      items.isEmpty ? null : _id(items.first);

  Future<void> _submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final currencyId = selectedCurrencyId ?? _firstId(ctr.currencies);
    if (currencyId == null) {
      Get.snackbar(
        'Required',
        'A currency is required to create a configuration',
      );
      return;
    }

    final lowStockText = lowStockController.text.trim();
    await ctr.createSystemConfiguration({
      'company_name': companyNameController.text.trim(),
      'company_address': _nullableText(addressController.text),
      'phone': _nullableText(phoneController.text),
      'email': _nullableText(emailController.text),
      'logo': _nullableText(logoController.text),
      'default_currency_id': currencyId,
      'default_warehouse_id': selectedWarehouseId,
      'default_payment_type_id': selectedPaymentTypeId,
      'allow_discount': allowDiscount,
      'tax_enabled': taxEnabled,
      'low_stock_warning': lowStockText.isEmpty
          ? null
          : int.parse(lowStockText),
    }, context);
  }

  String? _nullableText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
