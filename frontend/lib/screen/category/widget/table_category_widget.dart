import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/category_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

class TableCategoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const TableCategoryWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: titleColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(Colors.grey.shade100),
              headingTextStyle: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              dataRowMinHeight: 64,
              dataRowMaxHeight: 76,
              horizontalMargin: 16,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('CATEGORY')),
                DataColumn(label: Text('DESCRIPTION')),
                DataColumn(label: Text('CREATED')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: categories.map((category) {
                final createdAt = DateTime.tryParse(
                  category['created_at']?.toString() ?? '',
                );

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.category_outlined,
                                color: primaryColor,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                category['name']?.toString() ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 280,
                        child: Text(
                          category['description']?.toString() ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        DateFormatter.formatDate(createdAt),
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    DataCell(
                      PopupMenuButton<String>(
                        tooltip: 'Category actions',
                        icon: const Icon(Icons.more_horiz),
                        onSelected: (value) {
                          if (value == 'edit') {
                            controller.onEditCategory(category['id'], context);
                          } else if (value == 'delete') {
                            controller.onDeleteCategory(
                              category['id'],
                              context,
                            );
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
