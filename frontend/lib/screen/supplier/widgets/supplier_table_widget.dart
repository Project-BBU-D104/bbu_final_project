import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/models/supplier_model.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/utils/location_utils.dart';
import 'package:get/get.dart';

class SupplierTableWidget extends StatelessWidget {
  const SupplierTableWidget({super.key, required this.items});
  final List<SupplierModel> items;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget value(String? text) => SizedBox(
      width: 160,
      child: Tooltip(
        message: text ?? '-',
        child: Text(
          (text ?? '').isEmpty ? '-' : text!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    return Card(
      color: theme.cardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1000),
          child: DataTable(
            dataRowMinHeight: 72,
            dataRowMaxHeight: 88,
            columnSpacing: 24,
            headingRowColor: WidgetStatePropertyAll(
              theme.colorScheme.surfaceContainerHighest,
            ),
            columns: [
              for (final label in [
                'Supplier',
                'Email',
                'Phone',
                'Status',
                'Created At',
                'Actions',
              ])
                DataColumn(label: Text(label.tr)),
            ],
            rows: [
              for (final item in items)
                DataRow(
                  cells: [
                    DataCell(
                      value(item.name),
                      onTap: () => Get.find<SupplierController>()
                          .gotoSupplierDetail(item),
                    ),
                    DataCell(value(item.email)),
                    DataCell(Text(item.phone)),
                    DataCell(
                      Text(
                        (item.status == true ? 'Active' : 'Inactive').tr,
                        style: TextStyle(
                          color: item.status == true
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.createdAt == null
                            ? '-'
                            : DateFormatter.formatDate(item.createdAt),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Call supplier'.tr,
                            onPressed: item.phone.trim().isEmpty
                                ? null
                                : () => callPhone(item.phone),
                            icon: const Icon(Icons.phone_outlined),
                          ),
                          IconButton(
                            tooltip: 'Email supplier'.tr,
                            onPressed: (item.email ?? '').trim().isEmpty
                                ? null
                                : () => openEmail(item.email!),
                            icon: const Icon(Icons.email_outlined),
                          ),
                          IconButton(
                            tooltip: 'Open location'.tr,
                            onPressed: usableMapValue(item.map) == null
                                ? null
                                : () => openGoogleMap(item.map!),
                            icon: const Icon(Icons.location_on_outlined),
                          ),
                          IconButton(
                            tooltip: 'View details'.tr,
                            onPressed: () => Get.find<SupplierController>()
                                .gotoSupplierDetail(item),
                            icon: const Icon(Icons.visibility_outlined),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
