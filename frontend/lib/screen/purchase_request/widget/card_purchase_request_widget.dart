import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/screen/purchase_request/widget/card_purchase_request_detail_widget.dart';
import 'package:get/get.dart';

class CardPurchaseRequestWidget extends StatelessWidget {
  const CardPurchaseRequestWidget({super.key, required this.purchaseRequest});

  final Map<String, dynamic> purchaseRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final controller = Get.find<PurchaseRequestController>();
    final requestId = int.tryParse(purchaseRequest["id"].toString());
    final status = purchaseRequest["status"]?.toString() ?? "pending";
    final reason = (purchaseRequest["reason"]?.toString() ?? "").trim();
    final title = _value(purchaseRequest["request_no"]);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(
          () =>
              CardPurchaseRequestDetailWidget(purchaseRequest: purchaseRequest),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.assignment_outlined, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Tooltip(
                      message: title,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Actions'.tr,
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (requestId == null) return;
                      if (value == 'edit') {
                        controller.editPurchaseRequest(context, requestId);
                      } else if (value == 'delete') {
                        controller.deletePurchaseRequest(context, requestId);
                      }
                    },
                    itemBuilder: (_) => [
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
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: colors.error,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Delete'.tr,
                              style: TextStyle(color: colors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _StatusChip(status: status),
              const SizedBox(height: 10),
              Text(
                _value(purchaseRequest["request_type"]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Obx(
                () => Text(
                  _warehouseName(controller, purchaseRequest["warehouse_id"]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _detail(
                context,
                Icons.person_outline,
                "${_value(purchaseRequest["requested_by"])}  ·  ${_value(purchaseRequest["approved_by"])}",
              ),
              if (reason.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 8),
              _detail(
                context,
                Icons.calendar_today_outlined,
                _date(purchaseRequest["request_date"]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(BuildContext context, IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 7),
        Expanded(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    ),
  );

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

  String _value(dynamic value) {
    final text = value?.toString().trim() ?? "";
    return text.isEmpty ? '-' : text;
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
