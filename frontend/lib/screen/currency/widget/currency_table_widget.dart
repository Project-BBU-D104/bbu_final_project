import 'package:flutter/material.dart';
import 'package:frontend/controllers/currency_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';

class CurrencyTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> currencies;

  const CurrencyTableWidget({super.key, required this.currencies});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<CurrencyController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 72,
              horizontalMargin: 16,
              columnSpacing: 24,
              dividerThickness: 0.7,
              headingRowColor: WidgetStatePropertyAll(
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
              columns: const [
                DataColumn(label: Text('Currency')),
                DataColumn(label: Text('Exchange rate'), numeric: true),
                DataColumn(label: Text('Default')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Created')),
                DataColumn(label: Text('Actions')),
              ],
              rows: currencies.map((currency) {
                final isDefault = currency['is_default'] == true;
                final isActive = currency['status'] == true;
                final currencyId = int.tryParse(
                  currency['id']?.toString() ?? '',
                );
                final createdAt = DateTime.tryParse(
                  currency['created_at']?.toString() ?? '',
                );

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 220,
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                currency['symbol']?.toString() ?? '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currency['name']?.toString() ?? '-',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    currency['code']?.toString() ?? '-',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(currency['exchange_rate']?.toString() ?? '-'),
                    ),
                    DataCell(Text(isDefault ? 'Yes' : 'No')),
                    DataCell(
                      StatusWidget(
                        text: isActive ? 'Active' : 'Inactive',
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    DataCell(Text(DateFormatter.formatDate(createdAt))),
                    DataCell(
                      PopupMenuButton<String>(
                        tooltip: 'Actions'.tr,
                        onSelected: (action) {
                          if (currencyId == null) return;
                          if (action == 'edit') {
                            controller.editCurrency(context, currencyId);
                          } else if (action == 'delete') {
                            controller.onDeleteCurrency(context, currencyId);
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
