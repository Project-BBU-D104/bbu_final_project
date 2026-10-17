import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/sale/sale_controller.dart';
import 'package:frontend/widget/bottom_sheets.dart';
import 'package:get/get.dart';

class SelectCustomerCardWidget extends StatelessWidget {
  SelectCustomerCardWidget({super.key});

  final SaleController ctr = Get.find<SaleController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: titleColor,
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
                  backgroundColor: Colors.white,
                  backgroundImage: customer?['photo'] != null &&
                          customer!['photo'].toString().isNotEmpty
                      ? NetworkImage(customer['photo'].toString())
                      : null,
                  child: customer?['photo'] == null ||
                          customer!['photo'].toString().isEmpty
                      ? const Icon(Icons.person_outline)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer?['name']?.toString() ?? 'Select Customer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer?['phone']?.toString() ??
                            'Please select a customer for this sale.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

class _CustomerPicker extends StatelessWidget {
  const _CustomerPicker({required this.controller});

  final SaleController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.65,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Customer', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isCustomersLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.customers.isEmpty) {
                  return const Center(child: Text('No customers found'));
                }

                return ListView.separated(
                  itemCount: controller.customers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final customer = controller.customers[index];
                    final isSelected =
                        controller.selectedCustomer.value?['id'] ==
                        customer['id'];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: customer['photo'] != null &&
                                customer['photo'].toString().isNotEmpty
                            ? NetworkImage(customer['photo'].toString())
                            : null,
                        child: customer['photo'] == null ||
                                customer['photo'].toString().isEmpty
                            ? const Icon(Icons.person_outline)
                            : null,
                      ),
                      title: Text(customer['name']?.toString() ?? 'Customer'),
                      subtitle: Text(customer['phone']?.toString() ?? ''),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
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