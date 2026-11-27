import 'package:flutter/material.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/ui/app_empty_state.dart';
import 'package:frontend/ui/app_page.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'stock_adjustment_card_widget.dart';

class StockAdjustmentDetailWidget extends StatelessWidget {
  StockAdjustmentDetailWidget({super.key});
  final ctr = Get.find<StockAdjustmentController>();
  String _date(dynamic value) {
    final date = DateTime.tryParse('$value');
    return date == null
        ? '-'
        : DateFormat.yMMMd().add_jm().format(date.toLocal());
  }

  Widget _value(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Text('${label.tr}: $value'),
  );
  @override
  Widget build(BuildContext context) {
    final argument = Get.arguments;
    final original = argument is Map<String, dynamic> ? argument : null;
    final id = int.tryParse('${original?['id']}');
    final desktop = DesktopAppShell.isVisible(context);
    return Obx(() {
      final records = ctr.stockAdjustmentList.toList();
      final data = records.firstWhereOrNull((e) => e['id'] == id) ?? original;
      final error = ctr.formError.value;
      // Keep action state reactive even when record metadata does not change.
      final busy = ctr.isSaving.value || ctr.isOpeningEdit.value;
      return Scaffold(
        appBar: desktop
            ? null
            : CustomAppBar(
                title: 'Stock Adjustment Detail',
                actions: [
                  if (data != null && id != null && id > 0)
                    StockAdjustmentActions(id: id, closeDetailOnSuccess: true),
                ],
              ),
        body: AppPage(
          child: data == null || id == null || id <= 0
              ? Column(
                  children: [
                    const AppEmptyState(
                      message: 'Stock adjustment unavailable',
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text('Back'.tr),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppPageHeader(
                        title: 'Stock Adjustment Detail',
                        leading: desktop
                            ? IconButton(
                                tooltip: 'Back'.tr,
                                onPressed: busy
                                    ? null
                                    : () => Navigator.of(context).maybePop(),
                                icon: const Icon(Icons.arrow_back),
                              )
                            : null,
                        actions: desktop
                            ? StockAdjustmentActions(
                                id: id,
                                closeDetailOnSuccess: true,
                              )
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      if (error.isNotEmpty) ...[
                        Semantics(liveRegion: true, child: Text(error.tr)),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      HomeSectionCard(
                        title: 'Stock Change',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              adjustmentChange(data),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _value(
                              'Previous Stock',
                              adjustmentValue(data['previous_qty']),
                            ),
                            _value(
                              'New Quantity',
                              adjustmentValue(data['new_qty']),
                            ),
                            _value(
                              'Reference NO',
                              adjustmentValue(data['reference_no']),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      HomeSectionCard(
                        title: 'Product and warehouse',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _value(
                              'Product',
                              adjustmentRelation(data, 'product'),
                            ),
                            _value(
                              'Barcode',
                              adjustmentRelation(data, 'product', 'barcode'),
                            ),
                            _value(
                              'Warehouse',
                              adjustmentRelation(data, 'warehouse'),
                            ),
                            _value(
                              'Location',
                              adjustmentRelation(data, 'warehouse', 'location'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      HomeSectionCard(
                        title: 'Reference and reason',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _value('Reason', adjustmentValue(data['reason'])),
                            _value('User', adjustmentRelation(data, 'user')),
                            _value('Created at', _date(data['created_at'])),
                            _value('Updated at', _date(data['updated_at'])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }
}
