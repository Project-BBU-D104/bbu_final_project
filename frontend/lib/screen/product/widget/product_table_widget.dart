import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:get/get.dart';

class ProductTableWidget extends StatelessWidget {
  const ProductTableWidget({super.key, required this.items});
  final List<Map<String, dynamic>> items;

  void _open(Map<String, dynamic> product) =>
      Get.find<ProductController>().gotoProductDetail(product);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final line = colors.onSurface.withValues(alpha: 0.08);
    Widget heading(String label) => Expanded(
      child: Text(label.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    Widget value(String? text, {bool secondary = false}) => Tooltip(
      message: (text ?? '').isEmpty ? '-' : text!,
      child: Text(
        (text ?? '').isEmpty ? '-' : text!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: secondary ? 12 : 14,
          color: secondary ? colors.onSurfaceVariant : colors.onSurface,
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
                    label: heading('Product'),
                    columnWidth: const FlexColumnWidth(),
                  ),
                  DataColumn(
                    label: heading('Barcode'),
                    columnWidth: const FlexColumnWidth(),
                  ),
                  DataColumn(
                    label: heading('Price'),
                    columnWidth: const FixedColumnWidth(140),
                  ),
                  DataColumn(
                    label: heading('Created'),
                    columnWidth: const FixedColumnWidth(160),
                  ),
                  DataColumn(
                    label: heading('Actions'),
                    columnWidth: const FixedColumnWidth(96),
                  ),
                ],
                rows: [
                  for (final product in items)
                    DataRow(
                      onSelectChanged: (_) => _open(product),
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AppCachedImage(
                                  url: product['photo']?.toString(),
                                  width: 40,
                                  height: 40,
                                  fallbackIcon: Icons.inventory_2_outlined,
                                  fallbackIconSize: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Tooltip(
                                  message: product['name']?.toString() ?? '-',
                                  child: Text(
                                    product['name']?.toString() ?? '-',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(value(product['barcode']?.toString())),
                        DataCell(
                          Text(
                            CurrencyFormatter.format(
                              double.tryParse(
                                    product['sale_price']?.toString() ?? '',
                                  ) ??
                                  0,
                              product['currency'] as Map<String, dynamic>?,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        DataCell(
                          value(
                            DateFormatter.formatDate(
                              DateTime.tryParse(
                                product['created_at']?.toString() ?? '',
                              ),
                            ),
                            secondary: true,
                          ),
                        ),
                        DataCell(
                          IconButton(
                            tooltip: 'View details'.tr,
                            onPressed: () => _open(product),
                            icon: const Icon(Icons.chevron_right, size: 20),
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
