import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class CustomerTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> customers;

  CustomerTableWidget({super.key, required this.customers});

  final ctr = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: titleColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth,
            child: DataTable(
              dataRowMinHeight: 65,
              dataRowMaxHeight: 90,
              horizontalMargin: 16,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Photo')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Address')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Created Date')),
                DataColumn(label: Text('Actions')),
              ],
              rows: customers.map((customer) {
                return DataRow(
                  cells: [
                    // Photo
                    DataCell(
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          customer['photo'] != null &&
                                  customer['photo'].toString().isNotEmpty
                              ? customer['photo'].toString()
                              : 'https://i.pravatar.cc/150?img=12',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 45);
                          },
                        ),
                      ),
                    ),

                    // Name
                    DataCell(
                      SizedBox(
                        width: 140,
                        child: Text(
                          customer['name']?.toString() ?? 'Unknown Customer',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    // Phone
                    DataCell(
                      Text(customer['phone']?.toString() ?? 'Unknown Phone'),
                    ),

                    // Address
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Text(
                          customer['address']?.toString() ?? 'Unknown Address',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Status
                    DataCell(
                      StatusWidget(
                        text: customer['is_active'] == true
                            ? 'Active'
                            : 'Inactive',
                      ),
                    ),

                    // Created date
                    DataCell(
                      Text(
                        DateFormatter.formatDate(
                          DateTime.tryParse(
                            customer['created_at']?.toString() ?? '',
                          ),
                        ),
                      ),
                    ),

                    // Actions
                    DataCell(
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            ctr.editCustomer(context, customer['id']);
                          } else if (value == 'delete') {
                            ctr.onDeleteCustomer(customer['id'], context);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 20),
                                const SizedBox(width: 10),
                                Text('Edit'.tr),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Delete'.tr,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
