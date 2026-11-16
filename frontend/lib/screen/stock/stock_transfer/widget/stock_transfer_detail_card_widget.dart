import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/stock/stock_transfer/widget/stock_transfer_card_widget.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/ui/app_list_card.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';

class StockDetailCardWidget extends StatelessWidget {
  StockDetailCardWidget({super.key});
  final ctr = Get.find<ProductTransferController>();
  final dynamic argument = Get.arguments;

  Map<String, dynamic>? get _record {
    final records = ctr.stockTransfer.toList();
    if (argument is! Map<String, dynamic> ||
        (int.tryParse('${argument['id']}') ?? 0) <= 0) {
      return null;
    }
    final fallback = Map<String, dynamic>.from(argument as Map);
    return records.firstWhereOrNull(
          (r) => '${r['id']}' == '${fallback['id']}',
        ) ??
        fallback;
  }

  Widget _actions(BuildContext context, Map<String, dynamic> record) {
    final busy = ctr.isSaving.value || ctr.isOpeningEdit.value;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: busy
              ? null
              : () => ctr.onDeleteStockTransfer(
                  context,
                  record['id'],
                  closeDetailOnSuccess: true,
                ),
          icon: const Icon(Icons.delete_outline),
          label: Text('Delete'.tr),
        ),
        FilledButton.icon(
          onPressed: busy ? null : () => ctr.editStockTransfer(context, record),
          icon: const Icon(Icons.edit_outlined),
          label: Text('Edit'.tr),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DesktopAppShell.isVisible(context)
        ? null
        : const CustomAppBar(title: 'Stock Transfer Detail'),
    bottomNavigationBar: DesktopAppShell.isVisible(context)
        ? null
        : Obx(() {
            final record = _record;
            return record == null
                ? const SizedBox.shrink()
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: _actions(context, record),
                    ),
                  );
          }),
    body: AppPage(
      child: Obx(() {
        final record = _record;
        if (record == null) {
          return Column(
            children: [
              const AppEmptyState(message: 'Stock transfer unavailable'),
              TextButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                label: Text('Back'.tr),
              ),
            ],
          );
        }
        final items = transferRows(record);
        final saving = ctr.isSaving.value;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    title: 'Stock Transfer Detail',
                    leading: DesktopAppShell.isVisible(context)
                        ? IconButton(
                            tooltip: 'Back'.tr,
                            onPressed: saving ? null : () => Get.back(),
                            icon: const Icon(Icons.arrow_back),
                          )
                        : null,
                    actions: DesktopAppShell.isVisible(context)
                        ? _actions(context, record)
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (ctr.formError.isNotEmpty) Text(ctr.formError.value.tr),
                  HomeSectionCard(
                    title: 'Transfer Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(record['reference_no']?.toString() ?? '-'),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '${'From warehouse'.tr}: ${transferWarehouse(record, 'from_warehouse')}',
                        ),
                        Text(
                          '${'To warehouse'.tr}: ${transferWarehouse(record, 'to_warehouse')}',
                        ),
                        Text('${'Transfer date'.tr}: ${transferDate(record)}'),
                        Text('${'Product lines'.tr}: ${items.length}'),
                        Text(
                          '${'Total quantity'.tr}: ${transferTotal(record)}',
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Transferred items'.tr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (items.isEmpty) Text('No transfer items recorded.'.tr),
                ],
              ),
            ),
            SliverList.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => AppListCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      items[i]['product']?['name']?.toString() ??
                          '${'Product'.tr} #${items[i]['product_id'] ?? '-'}',
                    ),
                    Text('${'Quantity'.tr}: ${items[i]['qty'] ?? 0}'),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    ),
  );
}
