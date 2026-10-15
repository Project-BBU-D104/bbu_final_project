import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:get/get.dart';

class CardPurchaseRequestDetailWidget extends StatelessWidget {
  const CardPurchaseRequestDetailWidget({
    super.key,
    required this.purchaseRequest,
  });

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

    return Scaffold(
      appBar: AppBar(
        title: Text(purchaseRequest["request_no"]?.toString() ?? "Request"),
        actions: [
          IconButton(
            tooltip: "Edit request".tr,
            onPressed: requestId == null
                ? null
                : () => controller.editPurchaseRequest(context, requestId),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  purchaseRequest["request_type"]?.toString() ?? "",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.tr,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if ((purchaseRequest["reason"]?.toString() ?? "").isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(purchaseRequest["reason"].toString()),
          ],
          const SizedBox(height: 20),
          Text(
            "Request Details".tr,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _infoRow(
            context,
            "Warehouse".tr,
            warehouse?["name"]?.toString() ?? "Warehouse $warehouseId",
          ),
          _infoRow(
            context,
            "Requested By".tr,
            purchaseRequest["requested_by"]?.toString() ?? "-",
          ),
          _infoRow(
            context,
            "Approved By".tr,
            purchaseRequest["approved_by"]?.toString() ?? "-",
          ),
          _infoRow(
            context,
            "Request Date".tr,
            _formatDate(purchaseRequest["request_date"]),
          ),
          _infoRow(
            context,
            "Approved Date".tr,
            _formatDate(purchaseRequest["approved_date"]),
          ),
          const SizedBox(height: 20),
          Text(
            "Requested Items (${items.length})".tr,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text("No items in this request".tr),
            )
          else
            ...items.map((item) {
              final productId = int.tryParse(item["product_id"].toString());
              final product = controller.productController.products
                  .where(
                    (product) =>
                        int.tryParse(product["id"].toString()) == productId,
                  )
                  .firstOrNull;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(
                  product?["name"]?.toString() ?? "Product $productId",
                ),
                subtitle: Text("${item["qty"]} ${item["unit"]}"),
              );
            }),
        ],
      ),
      bottomNavigationBar: requestId == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () =>
                      controller.editPurchaseRequest(context, requestId),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text("Edit Request".tr),
                ),
              ),
            ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? "");
    if (date == null) return "-";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
