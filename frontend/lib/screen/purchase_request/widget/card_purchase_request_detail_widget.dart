import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class CardPurchaseRequestDetailWidget extends StatelessWidget {
  const CardPurchaseRequestDetailWidget({
    super.key,
    required this.purchaseRequest,
  });

  final Map<String, dynamic> purchaseRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
    final items = purchaseRequest["items"] is List
        ? List<Map<String, dynamic>>.from(purchaseRequest["items"])
        : <Map<String, dynamic>>[];
    final reason = (purchaseRequest["reason"]?.toString() ?? "").trim();
    final desktop = DesktopAppShell.isVisible(context);

    return Scaffold(
      appBar: desktop
          ? null
          : const CustomAppBar(
              title: 'Purchase Request Detail',
              useTheme: true,
            ),
      body: HomeTabLayout(
        title: _value(purchaseRequest["request_no"]),
        translateTitle: false,
        subtitle: 'Purchase Request Detail',
        leading: desktop
            ? IconButton.outlined(
                tooltip: 'Back'.tr,
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _value(purchaseRequest["request_no"]),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _StatusChip(status: status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _value(purchaseRequest["request_type"]),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(reason, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${_date(purchaseRequest["request_date"])}  ·  ${_date(purchaseRequest["approved_date"])}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            HomeSectionCard(
              child: Column(
                children: [
                  _infoRow(
                    context,
                    "Warehouse",
                    warehouseName.isEmpty ? '-' : warehouseName,
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    context,
                    "Requested By",
                    _value(purchaseRequest["requested_by"]),
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    context,
                    "Approved By",
                    _value(purchaseRequest["approved_by"]),
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    context,
                    "Request Date",
                    _date(purchaseRequest["request_date"]),
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    context,
                    "Approved Date",
                    _date(purchaseRequest["approved_date"]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Requested Items (${items.length})".tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            HomeSectionCard(
              child: items.isEmpty
                  ? Text(
                      "No items in this request".tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Column(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final productId = int.tryParse(
                          item["product_id"].toString(),
                        );
                        final product = controller.productController.products
                            .where(
                              (product) =>
                                  int.tryParse(product["id"].toString()) ==
                                  productId,
                            )
                            .firstOrNull;
                        final productName =
                            product?["name"]?.toString().trim() ?? "";
                        final name = productName.isEmpty
                            ? (productId == null ? '-' : 'Product $productId')
                            : productName;
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.inventory_2_outlined),
                              title: Text(name),
                              subtitle: Text(
                                "${_value(item["qty"])} ${_value(item["unit"])}",
                              ),
                            ),
                            if (index != items.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      }),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: theme.cardColor,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: requestId == null
                      ? null
                      : () => controller.deletePurchaseRequest(
                          context,
                          requestId,
                          onDeleted: () => Get.back(),
                        ),
                  icon: const Icon(Icons.delete_outline),
                  label: Text("Delete".tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: requestId == null
                      ? null
                      : () =>
                            controller.editPurchaseRequest(context, requestId),
                  icon: const Icon(Icons.edit),
                  label: Text("Edit".tr),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
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
