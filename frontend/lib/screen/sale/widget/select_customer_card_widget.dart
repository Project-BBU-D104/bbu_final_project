import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class SelectCustomerCardWidget extends StatelessWidget {
  SelectCustomerCardWidget({super.key, this.enabled = true});
  final bool enabled;

  final SaleController ctr = Get.find<SaleController>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !enabled
          ? null
          : () => AppBottomSheets.show<void>(
              context,
              child: _CustomerPicker(controller: ctr),
            ),
      child: Obx(() {
        final customer = ctr.selectedCustomer.value;
        return Row(
          children: [
            CircleAvatar(
              child: ClipOval(
                child: AppCachedImage(
                  url: customer?['photo']?.toString(),
                  width: AppTokens.controlHeight,
                  height: AppTokens.controlHeight,
                  fallbackIcon: Icons.person_outline,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer?['name']?.toString() ?? 'Select Customer'.tr),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    customer?['phone']?.toString() ??
                        'Please select a customer for this sale.'.tr,
                  ),
                ],
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        );
      }),
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
    final controller = widget.controller;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * AppTokens.formMaxHeightFactor,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: const AppFormSection(
                    title: 'Select Customer',
                    children: [],
                  ),
                ),
                IconButton(
                  tooltip: 'Close'.tr,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Customers'.tr,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
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
                        const SizedBox(height: AppSpacing.sm),
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
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final isSelected =
                        controller.selectedCustomer.value?['id'] ==
                        customer['id'];
                    return ListTile(
                      leading: CircleAvatar(
                        child: ClipOval(
                          child: AppCachedImage(
                            url: customer['photo']?.toString(),
                            width: AppTokens.controlHeight,
                            height: AppTokens.controlHeight,
                            fallbackIcon: Icons.person_outline,
                          ),
                        ),
                      ),
                      title: Text(
                        customer['name']?.toString() ?? 'Customer'.tr,
                      ),
                      subtitle: Text(customer['phone']?.toString() ?? ''),
                      trailing: isSelected ? const Icon(Icons.check) : null,
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
