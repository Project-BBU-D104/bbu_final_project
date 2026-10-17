import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/screen/purchase_request/widget/card_purchase_request_detail_widget.dart';
import 'package:get/get.dart';

class CardPurchaseRequestWidget extends StatelessWidget {
  const CardPurchaseRequestWidget({super.key, required this.purchaseRequest});

  final Map<String, dynamic> purchaseRequest;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PurchaseRequestController>();
    final requestId = int.tryParse(purchaseRequest["id"].toString());
    final status = purchaseRequest["status"]?.toString() ?? "pending";
    final statusColor = switch (status.toLowerCase()) {
      "approved" => Colors.green,
      "rejected" => Colors.red,
      _ => Colors.orange,
    };
    final warehouseId = int.tryParse(
      purchaseRequest["warehouse_id"].toString(),
    );
    final warehouse = controller.warehouseController.warehouseList
        .where((item) => int.tryParse(item["id"].toString()) == warehouseId)
        .firstOrNull;
    final items = purchaseRequest["items"] is List
        ? List<Map<String, dynamic>>.from(purchaseRequest["items"])
        : <Map<String, dynamic>>[];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Get.to(
          () =>
              CardPurchaseRequestDetailWidget(purchaseRequest: purchaseRequest),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      purchaseRequest["request_no"]?.toString() ?? "Request",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.tr,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: "Edit request".tr,
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
                    tooltip: "Delete request".tr,
                    onPressed: requestId == null
                        ? null
                        : () => controller.deletePurchaseRequest(
                            context,
                            requestId,
                          ),
                    color: Colors.red,
                    icon: const Icon(Icons.delete_outline, size: 19),
                  ),
                ],
              ),
              Text(
                "${purchaseRequest["request_type"] ?? ""}  ·  ${warehouse?["name"]?.toString() ?? "Warehouse $warehouseId"}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              _detail(
                context,
                Icons.person_outline,
                "${purchaseRequest["requested_by"] ?? ""}  ·  ${purchaseRequest["approved_by"] ?? ""}",
              ),
              if ((purchaseRequest["reason"]?.toString() ?? "").isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    purchaseRequest["reason"].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
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

  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? "");
    if (date == null) return "-";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
