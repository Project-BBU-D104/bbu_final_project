import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

class SupplierTableWidget extends StatelessWidget {
  final List<SupplierModel> items;

  const SupplierTableWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: constraints.maxWidth,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Colors.grey.shade100,
                  ),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 70,
                  columnSpacing: 24,
                  horizontalMargin: 16,
                  columns: const [
                    DataColumn(label: Text('Supplier')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Created At')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: items.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.teal.shade50,
                                child: Text(
                                  item.name.isNotEmpty
                                      ? item.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Colors.teal.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(item.email ?? '-'),
                          onTap: () {
                            final email = item.email ?? '';
                            if (email.isNotEmpty) {
                              openEmail(email);
                            }
                          },
                        ),
                        DataCell(Text(item.phone)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: item.status == true
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status == true ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: item.status == true
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(DateFormatter.formatDate(item.createdAt)),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Call supplier',
                                onPressed: () => callPhone(item.phone),
                                icon: const Icon(
                                  Icons.phone_outlined,
                                  color: Colors.teal,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Open location',
                                onPressed: () => openGoogleMap(item.map ?? ''),
                                icon: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.orange,
                                ),
                              ),
                              IconButton(
                                tooltip: 'View details',
                                onPressed: () {
                                  Get.find<SupplierController>()
                                      .gotoSupplierDetail(item);
                                },
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  color: Colors.blue,
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
        ),
      ),
    );
  }
}
