import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

class CategoryTableWidget extends StatelessWidget {
  const CategoryTableWidget({super.key, required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final line = colors.onSurface.withValues(alpha: 0.08);
    final controller = Get.find<CategoryController>();
    Widget heading(String label) => Text(
      label.tr,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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
                    label: heading('Category'),
                    columnWidth: const FlexColumnWidth(),
                  ),
                  DataColumn(
                    label: heading('Description'),
                    columnWidth: const FlexColumnWidth(),
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
                            controller.onEditCategory(item['id'], context),
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                ExcludeSemantics(
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: colors.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    foregroundColor: colors.primary,
                                    child: const Icon(
                                      Icons.category_outlined,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Tooltip(
                                    message:
                                        (item['name'] ?? '').toString().trim(),
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
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            value(
                              (item['description'] ?? '')
                                      .toString()
                                      .trim()
                                      .isEmpty
                                  ? '-'
                                  : item['description'].toString().trim(),
                            ),
                          ),
                          DataCell(
                            Text(
                              DateTime.tryParse(
                                        (item['created_at'] ?? '')
                                            .toString(),
                                      ) ==
                                      null
                                  ? '-'
                                  : DateFormatter.formatDate(
                                      DateTime.tryParse(
                                        item['created_at'].toString(),
                                      ),
                                    ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Edit'.tr,
                                  onPressed: () => controller.onEditCategory(
                                    item['id'],
                                    context,
                                  ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete'.tr,
                                  color: colors.error,
                                  onPressed: () => controller.onDeleteCategory(
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
                      )
                    else
                      DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                ExcludeSemantics(
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: colors.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    foregroundColor: colors.primary,
                                    child: const Icon(
                                      Icons.category_outlined,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    (item['name'] ?? '').toString().trim().isEmpty
                                        ? '-'
                                        : item['name'].toString().trim(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            value(
                              (item['description'] ?? '')
                                      .toString()
                                      .trim()
                                      .isEmpty
                                  ? '-'
                                  : item['description'].toString().trim(),
                            ),
                          ),
                          DataCell(Text('-')),
                          const DataCell(SizedBox.shrink()),
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