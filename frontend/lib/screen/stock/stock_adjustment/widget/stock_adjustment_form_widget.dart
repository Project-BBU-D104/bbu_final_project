import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/controllers/stock_adjustment_controller.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class StockAdjustmentFormWidget extends StatefulWidget {
  const StockAdjustmentFormWidget({super.key, this.stockAdjustmentId});
  final int? stockAdjustmentId;
  @override
  State<StockAdjustmentFormWidget> createState() => _StockAdjustmentFormState();
}

class _StockAdjustmentFormState extends State<StockAdjustmentFormWidget> {
  final c = Get.find<StockAdjustmentController>();
  final warehouses = Get.find<WarehouseController>();
  final products = Get.find<ProductController>();
  final _form = GlobalKey<FormState>();
  final _fieldKeys = List.generate(4, (_) => GlobalKey<FormFieldState>());
  final _focus = List.generate(4, (_) => FocusNode());
  @override
  void dispose() {
    for (final node in _focus) {
      node.dispose();
    }
    super.dispose();
  }

  Widget _pair(Widget first, Widget second) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= AppTokens.bpFormPair &&
          MediaQuery.textScalerOf(context).scale(16) <=
              AppTokens.tableMaxScaledBodySize) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: second),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          first,
          const SizedBox(height: AppSpacing.lg),
          second,
        ],
      );
    },
  );
  Widget _dropdown({
    required int index,
    required String label,
    required String? value,
    required List<Map<String, dynamic>> options,
    required String error,
    required ValueChanged<String?> changed,
    required bool enabled,
  }) {
    final validValue = options.any((e) => '${e['id']}' == value) ? value : null;
    return DropdownButtonFormField<String>(
      key: _fieldKeys[index],
      initialValue: validValue,
      focusNode: _focus[index],
      isExpanded: true,
      decoration: InputDecoration(labelText: label.tr),
      errorBuilder: (context, error) => Text(error),
      items: options
          .map(
            (e) => DropdownMenuItem(
              value: '${e['id']}',
              child: Text(
                '${e['name'] ?? '-'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? changed : null,
      validator: (value) => value == null ? error.tr : null,
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) {
      for (var i = 0; i < _fieldKeys.length; i++) {
        final state = _fieldKeys[i].currentState;
        if (state?.hasError == true) {
          _focus[i].requestFocus();
          await Scrollable.ensureVisible(state!.context);
          break;
        }
      }
      return;
    }
    if (widget.stockAdjustmentId == null) {
      await c.onSaveStockAdjustment(context);
    } else {
      await c.onUpdateStockAdjustment(context, widget.stockAdjustmentId!);
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final saving = c.isSaving.value;
    final stockLoading = c.isStockLoading.value;
    final known = c.currentQtyKnown.value;
    final stockError = c.stockError.value;
    final error = c.formError.value;
    final warehouseOptions = warehouses.warehouseList.toList();
    final productOptions = products.products.toList();
    final loadingOptions =
        warehouses.isLoading.value || products.isLoading.value;
    return PopScope(
      canPop: !saving,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          (widget.stockAdjustmentId == null
                                  ? 'Add Stock Adjustment'
                                  : 'Edit Stock Adjustment')
                              .tr,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        if (loadingOptions) const LinearProgressIndicator(),
                        AppFormSection(
                          title: 'Product and warehouse',
                          children: [
                            _pair(
                              _dropdown(
                                index: 0,
                                label: 'Warehouse',
                                value: c.selectedWarehouse.value,
                                options: warehouseOptions,
                                error: 'Please select a warehouse',
                                enabled: !saving && !loadingOptions,
                                changed: (value) {
                                  c.selectedWarehouse.value = value;
                                  c.loadCurrentQty();
                                },
                              ),
                              _dropdown(
                                index: 1,
                                label: 'Product',
                                value: c.selectedProduct.value,
                                options: productOptions,
                                error: 'Select a product',
                                enabled: !saving && !loadingOptions,
                                changed: (value) {
                                  c.selectedProduct.value = value;
                                  c.loadCurrentQty();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppFormSection(
                          title: 'Adjustment type and quantity',
                          children: [
                            _pair(
                              _dropdown(
                                index: 2,
                                label: 'Adjustment Type',
                                value: c.selectedAdjustmentType.value,
                                options: [
                                  {'id': 'increase', 'name': 'Increase'.tr},
                                  {'id': 'decrease', 'name': 'Decrease'.tr},
                                ],
                                error: 'Please select an adjustment type',
                                enabled: !saving,
                                changed: (value) {
                                  c.selectedAdjustmentType.value = value;
                                },
                              ),
                              AppFormField(
                                label: 'Adjusted Quantity',
                                fieldKey: _fieldKeys[3],
                                focusNode: _focus[3],
                                controller: c.adjustmentQtyController,
                                enabled: !saving,
                                wrapErrors: true,
                                keyboardType: TextInputType.number,
                                validator: (_) =>
                                    c.draftQty == null || c.draftQty! <= 0
                                    ? 'Enter a whole quantity greater than zero'
                                          .tr
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppFormSection(
                          title: 'Current and resulting stock',
                          children: [
                            if (widget.stockAdjustmentId != null)
                              Text(
                                'Preview reverses the original movement before applying your changes.'
                                    .tr,
                              ),
                            const SizedBox(height: AppSpacing.lg),
                            if (stockLoading) const LinearProgressIndicator(),
                            if (!known && !stockLoading)
                              Text('Current stock unknown'.tr),
                            if (stockError.isNotEmpty) ...[
                              Text(stockError.tr),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: saving ? null : c.loadCurrentQty,
                                  child: Text('Retry'.tr),
                                ),
                              ),
                            ],
                            _pair(
                              AppFormField(
                                label: 'Previous Stock',
                                controller: c.currentQtyController,
                                readOnly: true,
                              ),
                              AppFormField(
                                label: 'New Quantity',
                                controller: c.newQtyController,
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppFormSection(
                          title: 'Reference and reason',
                          children: [
                            AppFormField(
                              label: 'Reference NO',
                              controller: c.referenceController,
                              enabled: !saving,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppFormField(
                              label: 'Reason',
                              controller: c.reasonController,
                              enabled: !saving,
                              minLines: 2,
                              maxLines: 4,
                            ),
                          ],
                        ),
                        if (error.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Semantics(liveRegion: true, child: Text(error.tr)),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppFormActions(
                saving: saving,
                onCancel: () => Navigator.of(context).maybePop(),
                onSave: stockLoading || stockError.isNotEmpty ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  });
}
