import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/controllers/customer_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:get/get.dart';

class CustomerTableWidget extends StatelessWidget {
  const CustomerTableWidget({super.key, required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final line = colors.onSurface.withValues(alpha: 0.08);
    final controller = Get.find<CustomerController>();
    Widget heading(String label) => Flexible(
      child: Text(label.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    Widget value(String text) => Tooltip(
      message: text,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
    Widget dateCell(DateTime? date) => Text(
      date == null ? '-' : DateFormatter.formatDate(date),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
    );
    Widget statusChip(bool active) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? colors.primary.withValues(alpha: 0.08)
            : colors.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active'.tr : 'Inactive'.tr,
        style: theme.textTheme.labelMedium?.copyWith(
          color: active ? colors.primary : colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) => Theme(
        data: theme.copyWith(
          dividerColor: line,
          dividerTheme: DividerThemeData(color: line, thickness: 1),
        ),
        child: Card(
          elevation: 0,
          color: theme.cardColor,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: line),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(960, constraints.maxWidth),
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 48,
                dataRowMinHeight: 72,
                dataRowMaxHeight: 76,
                columnSpacing: 20,
                horizontalMargin: 24,
                headingRowColor: WidgetStatePropertyAll(
                  Color.alphaBlend(
                    colors.onSurface.withValues(alpha: 0.025),
                    theme.cardColor,
                  ),
                ),
                headingTextStyle: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                dataRowColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered)
                      ? colors.primary.withValues(alpha: 0.035)
                      : null,
                ),
                columns: [
                  DataColumn(
                    label: heading('Customer'),
                    columnWidth: const FlexColumnWidth(),
                  ),
                  DataColumn(
                    label: heading('Address'),
                    columnWidth: const FixedColumnWidth(200),
                  ),
                  DataColumn(
                    label: heading('Status'),
                    columnWidth: const FixedColumnWidth(120),
                  ),
                  DataColumn(
                    label: heading('Created At'),
                    columnWidth: const FixedColumnWidth(160),
                  ),
                  DataColumn(
                    label: heading('Actions'),
                    columnWidth: const FixedColumnWidth(144),
                  ),
                ],
                rows: [
                  for (final item in items)
                    if (item['id'] is int)
                      DataRow(
                        onSelectChanged: (_) =>
                            controller.editCustomer(context, item['id']),
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                ExcludeSemantics(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: AppCachedImage(
                                      url:
                                          (item['photo'] ?? '')
                                              .toString()
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : item['photo'].toString().trim(),
                                      width: 36,
                                      height: 36,
                                      fallbackIcon: Icons.person_outline,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Tooltip(
                                        message: (item['name'] ?? '')
                                            .toString()
                                            .trim(),
                                        child: Text(
                                          (item['name'] ?? '')
                                                  .toString()
                                                  .trim()
                                                  .isEmpty
                                              ? '-'
                                              : item['name'].toString().trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        (item['phone'] ?? '')
                                                .toString()
                                                .trim()
                                                .isEmpty
                                            ? '-'
                                            : item['phone'].toString().trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            value(
                              (item['address'] ?? '').toString().trim().isEmpty
                                  ? '-'
                                  : item['address'].toString().trim(),
                            ),
                          ),
                          DataCell(statusChip(item['is_active'] == true)),
                          DataCell(
                            dateCell(
                              DateTime.tryParse(
                                (item['created_at'] ?? '').toString(),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Edit'.tr,
                                  onPressed: () => controller.editCustomer(
                                    context,
                                    item['id'],
                                  ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete'.tr,
                                  color: colors.error,
                                  onPressed: () => controller.onDeleteCustomer(
                                    item['id'],
                                    context,
                                  ),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
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
        ),
      ),
    );
  }
}
