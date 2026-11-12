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

  Widget _actions(
    BuildContext context,
    PurchaseRequestController controller,
    int? requestId,
  ) => Obx(() {
    final busy = controller.isSaving.value || controller.isOpeningEdit.value;
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: busy || requestId == null
              ? null
              : () => controller.deletePurchaseRequest(
                  context,
                  requestId,
                  onDeleted: () => Get.back(),
                ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(100, 48),
            foregroundColor: colors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text('Delete'.tr),
        ),
        FilledButton.icon(
          onPressed: busy || requestId == null
              ? null
              : () => controller.editPurchaseRequest(context, requestId),
          style: FilledButton.styleFrom(
            minimumSize: const Size(100, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text('Edit'.tr),
        ),
      ],
    );
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PurchaseRequestController>();
    final requestId = int.tryParse(purchaseRequest["id"].toString());
    final status = purchaseRequest["status"]?.toString() ?? "pending";
    final items = purchaseRequest["items"] is List
        ? List<Map<String, dynamic>>.from(purchaseRequest["items"])
        : <Map<String, dynamic>>[];
    final reason = (purchaseRequest["reason"]?.toString() ?? "").trim();
    final desktop = DesktopAppShell.isVisible(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final active = theme.brightness == Brightness.light
        ? colors.primaryContainer
        : colors.primary;

    Widget info(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    return Theme(
      data: theme.copyWith(
        dividerColor: colors.onSurface.withValues(alpha: 0.08),
        dividerTheme: DividerThemeData(
          color: colors.onSurface.withValues(alpha: 0.08),
          thickness: 1,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            side: BorderSide(color: colors.onSurface.withValues(alpha: 0.12)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: desktop
            ? null
            : const CustomAppBar(
                title: 'Purchase Request Detail',
                useTheme: true,
              ),
        body: Obx(() {
          final error = controller.formError.value;
          final summary = HomeSectionCard(
            title: 'Request details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        size: 24,
                        color: active,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 24),
                info('Request Type', _value(purchaseRequest["request_type"])),
                info(
                  'Warehouse',
                  _warehouseName(controller, purchaseRequest["warehouse_id"]),
                ),
                info('Requested By', _value(purchaseRequest["requested_by"])),
                info('Approved By', _value(purchaseRequest["approved_by"])),
                info('Request Date', _date(purchaseRequest["request_date"])),
                info('Approved Date', _date(purchaseRequest["approved_date"])),
                if (reason.isNotEmpty) info('Reason', reason),
              ],
            ),
          );
          final itemsCard = HomeSectionCard(
            title: 'Requested Items',
            child: items.isEmpty
                ? Text(
                    "No items in this request".tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  )
                : Column(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.inventory_2_outlined),
                            title: Text(_productName(controller, item)),
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
          );
          return HomeTabLayout(
            translateTitle: false,
            title: _value(purchaseRequest["request_no"]),
            subtitle: 'Purchase Request Detail',
            leading: desktop
                ? IconButton.outlined(
                    tooltip: 'Back'.tr,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, size: 20),
                  )
                : null,
            action: desktop ? _actions(context, controller, requestId) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(error, style: TextStyle(color: colors.error)),
                    ),
                  ),
                LayoutBuilder(
                  builder: (context, constraints) => constraints.maxWidth >= 900
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: summary),
                            const SizedBox(width: 24),
                            Expanded(child: itemsCard),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            summary,
                            const SizedBox(height: 24),
                            itemsCard,
                          ],
                        ),
                ),
              ],
            ),
          );
        }),
        bottomNavigationBar: desktop
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _actions(context, controller, requestId),
                ),
              ),
      ),
    );
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

  String _productName(
    PurchaseRequestController controller,
    Map<String, dynamic> item,
  ) {
    final productId = int.tryParse(item["product_id"].toString());
    final product = controller.productController.products
        .where((product) => int.tryParse(product["id"].toString()) == productId)
        .firstOrNull;
    final name = product?["name"]?.toString().trim() ?? "";
    if (name.isNotEmpty) return name;
    return productId == null ? '-' : 'Product $productId';
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
