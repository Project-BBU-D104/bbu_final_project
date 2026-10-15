import 'package:flutter/material.dart';

class TableSystemConfigurationWidget extends StatelessWidget {
  final List<Map<String, dynamic>> configurations;

  const TableSystemConfigurationWidget({
    super.key,
    required this.configurations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              columnSpacing: 32,
              dividerThickness: 0.7,
              headingRowColor: WidgetStatePropertyAll(
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
              columns: const [
                DataColumn(label: Text('Company')),
                DataColumn(label: Text('Address')),
                DataColumn(label: Text('Phone')),
              ],
              rows: configurations.map((configuration) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          configuration['company_name']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 300,
                        child: Text(
                          configuration['company_address']?.toString() ??
                              'Not set',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(configuration['phone']?.toString() ?? 'Not set'),
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
