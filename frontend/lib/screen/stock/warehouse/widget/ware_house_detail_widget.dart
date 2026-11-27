import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'warehouse_card_widget.dart';

class WareHouseDetailWidget extends StatelessWidget {
  WareHouseDetailWidget({super.key});
  final ctr = Get.find<WarehouseController>();
  final dynamic _argument = Get.arguments;
  @override
  Widget build(BuildContext context) {
    final desktop = DesktopAppShell.isVisible(context);
    final argument = _argument;
    if (argument is! Map<String, dynamic> || argument['id'] is! int) {
      return Scaffold(
        appBar: desktop ? null : const CustomAppBar(title: 'Warehouse Detail'),
        body: AppPage(
          child: ListView(
            children: [
              const AppEmptyState(
                message: 'Warehouse unavailable',
                icon: Icons.warehouse_outlined,
              ),
              TextButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
                label: Text('Back'.tr),
              ),
            ],
          ),
        ),
      );
    }
    return Obx(() {
      final theme = Theme.of(context);
      final warehouse = ctr.warehouseList.firstWhere(
        (r) => r['id'] == argument['id'],
        orElse: () => argument,
      );
      final raw = warehouse['warehouse_stock'];
      final stocks = raw is List ? raw.whereType<Map>().toList() : <Map>[];
      final busy = ctr.isSaving.value || ctr.isOpeningEdit.value;
      Widget detail(String label, dynamic value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(warehouseValue(value), style: theme.textTheme.bodyLarge),
        ],
      );
      final actions = Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        alignment: WrapAlignment.end,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: busy
                ? null
                : () => ctr.deleteWarehouse(
                    context,
                    warehouse['id'],
                    closeDetailOnSuccess: true,
                  ),
            icon: const Icon(Icons.delete_outline),
            label: Text('Delete'.tr),
          ),
          FilledButton.icon(
            onPressed: busy
                ? null
                : () => ctr.editWarehouse(context, warehouse['id']),
            icon: const Icon(Icons.edit_outlined),
            label: Text('Edit'.tr),
          ),
        ],
      );
      return Scaffold(
        appBar: desktop ? null : const CustomAppBar(title: 'Warehouse Detail'),
        bottomNavigationBar: desktop
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: actions,
                ),
              ),
        body: AppPage(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (desktop) ...[
                      AppPageHeader(
                        title: 'Warehouse Detail',
                        leading: IconButton.outlined(
                          tooltip: 'Back'.tr,
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        actions: actions,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                    HomeSectionCard(
                      title: 'Warehouse infor',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            warehouseValue(warehouse['name']),
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          detail('Reference No', warehouse['reference_no']),
                          const SizedBox(height: AppSpacing.lg),
                          detail('Location', warehouse['location']),
                          const SizedBox(height: AppSpacing.lg),
                          detail('Note', warehouse['note']),
                          const SizedBox(height: AppSpacing.lg),
                          detail('Products', stocks.length),
                          const SizedBox(height: AppSpacing.lg),
                          const Divider(),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: detail(
                                  'Created At',
                                  _date(warehouse['created_at']),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: detail(
                                  'Updated At',
                                  _date(warehouse['updated_at']),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (stocks.isEmpty)
                      const AppEmptyState(
                        message: 'No warehouse stock yet',
                        icon: Icons.inventory_2_outlined,
                      ),
                  ],
                ),
              ),
              SliverList.builder(
                itemCount: stocks.length,
                itemBuilder: (context, index) {
                  final stock = stocks[index];
                  final product = stock['product'] is Map
                      ? stock['product'] as Map
                      : <dynamic, dynamic>{};
                  final category = product['category'] is Map
                      ? product['category'] as Map
                      : <dynamic, dynamic>{};
                  return AppListCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          warehouseValue(product['name']),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _info('Category', category['name']),
                        _info('Barcode', product['barcode']),
                        _info('Quantity', stock['qty']),
                        _info('Cost Price', product['cost_price']),
                        _info('Sale', product['sale_price']),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  static String? _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date == null ? null : DateFormatter.formatDate(date);
  }

  static Widget _info(String label, dynamic value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Text('${label.tr}: ${warehouseValue(value)}'),
  );
}
