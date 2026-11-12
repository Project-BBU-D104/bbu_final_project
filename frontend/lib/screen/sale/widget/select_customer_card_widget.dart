import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class SelectCustomerCardWidget extends StatelessWidget {
  SelectCustomerCardWidget({super.key});

  final SaleController ctr = Get.find<SaleController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => AppBottomSheets.show<void>(
          context,
          child: _CustomerPicker(controller: ctr),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Obx(() {
            final customer = ctr.selectedCustomer.value;
            return Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: ClipOval(
                    child: AppCachedImage(
                      url: customer?['photo']?.toString(),
                      width: 40,
                      height: 40,
                      fallbackIcon: Icons.person_outline,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer?['name']?.toString() ?? 'Select Customer'.tr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer?['phone']?.toString() ??
                            'Please select a customer for this sale.'.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CustomerPicker extends StatefulWidget {
  const _CustomerPicker({required this.controller});

  final SaleController controller;

  @override
  State<_CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends State<_CustomerPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.65,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Customer'.tr,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close'.tr,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Customers'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isCustomersLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final customers = controller.customers.where((customer) {
                  if (_query.isEmpty) return true;
                  final name = (customer['name'] ?? '')
                      .toString()
                      .toLowerCase();
                  final phone = (customer['phone'] ?? '')
                      .toString()
                      .toLowerCase();
                  return name.contains(_query) || phone.contains(_query);
                }).toList();
                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('No customers found'.tr),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => controller.loadCustomers(),
                          child: Text('Retry'.tr),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: customers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final isSelected =
                        controller.selectedCustomer.value?['id'] ==
                        customer['id'];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        child: ClipOval(
                          child: AppCachedImage(
                            url: customer['photo']?.toString(),
                            width: 40,
                            height: 40,
                            fallbackIcon: Icons.person_outline,
                          ),
                        ),
                      ),
                      title: Text(
                        customer['name']?.toString() ?? 'Customer'.tr,
                      ),
                      subtitle: Text(customer['phone']?.toString() ?? ''),
                      trailing: isSelected
                          ? Icon(Icons.check, color: theme.colorScheme.primary)
                          : null,
                      onTap: () {
                        controller.selectCustomer(customer);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
