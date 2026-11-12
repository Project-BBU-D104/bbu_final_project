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
    final warehouseId = int.tryParse(
      purchaseRequest["warehouse_id"].toString(),
    );
    final warehouse = controller.warehouseController.warehouseList
        .where((item) => int.tryParse(item["id"].toString()) == warehouseId)
        .firstOrNull;
    final warehouseName = warehouse?["name"]?.toString().trim() ?? "";
    final reason = (purchaseRequest["reason"]?.toString() ?? "").trim();

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
                children: [
                  Expanded(
                    child: Text(
                      _value(purchaseRequest["request_no"]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _StatusChip(status: status),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Edit Request'.tr,
                    onPressed: requestId == null
                        ? null
                        : () => controller.editPurchaseRequest(
                            context,
                            requestId,
                          ),
                    icon: const Icon(Icons.edit_outlined, size: 19),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Delete request'.tr,
                    onPressed: requestId == null
                        ? null
                        : () => controller.deletePurchaseRequest(
                            context,
                            requestId,
                          ),
                    color: colors.error,
                    icon: const Icon(Icons.delete_outline, size: 19),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _value(purchaseRequest["request_type"]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                warehouseName.isEmpty ? '-' : warehouseName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
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
