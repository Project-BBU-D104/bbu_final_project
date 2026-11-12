import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/screen/purchase_request/widget/card_purchase_request_detail_widget.dart';
import 'package:get/get.dart';

class PurchaseRequestTableWidget extends StatelessWidget {
  const PurchaseRequestTableWidget({super.key, required this.requests});

  final List<Map<String, dynamic>> requests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final controller = Get.find<PurchaseRequestController>();
    final line = colors.onSurface.withValues(alpha: 0.08);

    Widget heading(String label) => Flexible(
      child: Text(label.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
    );

    return LayoutBuilder(
      builder: (context, constraints) => Card(
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
              dataRowMinHeight: 64,
              dataRowMaxHeight: 72,
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
                  label: heading('Request No'),
                  columnWidth: const FlexColumnWidth(),
                ),
                DataColumn(
                  label: heading('Request Type'),
                  columnWidth: const FixedColumnWidth(140),
                ),
                DataColumn(
                  label: heading('Warehouse'),
                  columnWidth: const FixedColumnWidth(160),
                ),
                DataColumn(
                  label: heading('Requested By'),
                  columnWidth: const FixedColumnWidth(160),
                ),
                DataColumn(
                  label: heading('Status'),
                  columnWidth: const FixedColumnWidth(120),
                ),
                DataColumn(
                  label: heading('Date'),
                  columnWidth: const FixedColumnWidth(130),
                ),
                DataColumn(
                  label: heading('Actions'),
                  columnWidth: const FixedColumnWidth(80),
                ),
              ],
              rows: [
                for (final request in requests)
                  if (request['id'] is int)
                    DataRow(
                      onSelectChanged: (_) => Get.to(
                        () => CardPurchaseRequestDetailWidget(
                          purchaseRequest: request,
                        ),
                      ),
                      cells: [
                        DataCell(
                          Text(
                            _value(request['request_no']),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text(
                            _value(request['request_type']),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Obx(
                            () => Text(
                              _warehouseName(
                                controller,
                                request['warehouse_id'],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _value(request['requested_by']),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          _StatusChip(
                            status: request['status']?.toString() ?? 'pending',
                          ),
                        ),
                        DataCell(Text(_date(request['request_date']))),
                        DataCell(
                          PopupMenuButton<String>(
                            tooltip: 'Actions'.tr,
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'edit') {
                                controller.editPurchaseRequest(
                                  context,
                                  request['id'] as int,
                                );
                              }
                              if (value == 'delete') {
                                controller.deletePurchaseRequest(
                                  context,
                                  request['id'] as int,
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'.tr),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'.tr),
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
    );
  }

  String _value(dynamic value) {
    final text = value?.toString().trim() ?? "";
    return text.isEmpty ? '-' : text;
  }

  String _warehouseName(PurchaseRequestController controller, dynamic value) {
    final warehouses = controller.warehouseController.warehouseList.toList();
    final id = int.tryParse(value?.toString() ?? "");
    if (id == null) return '-';
    final warehouse = warehouses
        .where((item) => int.tryParse(item["id"].toString()) == id)
        .firstOrNull;
    final name = warehouse?["name"]?.toString().trim() ?? "";
    return name.isEmpty ? '-' : name;
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? "");
    if (date == null) return "-";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      "approved" => colors.primary,
      "rejected" => colors.error,
      _ => colors.onSurfaceVariant,
    };
    final background = switch (normalized) {
      "approved" => colors.primary.withValues(alpha: .1),
      "rejected" => colors.error.withValues(alpha: .1),
      _ => colors.onSurface.withValues(alpha: .06),
    };
    final label = status.isEmpty
        ? '-'
        : (status[0].toUpperCase() + status.substring(1).toLowerCase()).tr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
