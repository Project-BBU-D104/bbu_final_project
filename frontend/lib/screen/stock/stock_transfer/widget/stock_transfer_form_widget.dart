import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class StockTransferFormWidget extends StatefulWidget {
  const StockTransferFormWidget({super.key, this.stockTransfer});
  final Map<String, dynamic>? stockTransfer;
  @override
  State<StockTransferFormWidget> createState() => _StockTransferFormState();
}

class _StockTransferFormState extends State<StockTransferFormWidget> {
  final c = Get.find<ProductTransferController>();
  final warehouses = Get.find<WarehouseController>();
  final form = GlobalKey<FormState>();
  final sourceKey = GlobalKey<FormFieldState<int>>();
  final destinationKey = GlobalKey<FormFieldState<int>>();
  final sourceFocus = FocusNode();
  final destinationFocus = FocusNode();
  final scroll = ScrollController();

  @override
  void dispose() {
    sourceFocus.dispose();
    destinationFocus.dispose();
    scroll.dispose();
    super.dispose();
  }

  Widget pair(Widget first, Widget second) => LayoutBuilder(
    builder: (context, size) {
      if (size.maxWidth < AppTokens.bpFormPair) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            first,
            const SizedBox(height: AppSpacing.lg),
            second,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: second),
        ],
      );
    },
  );

  Widget warehouseField(bool source, bool saving) {
    final selected = source
        ? c.selectedFromWarehouse.value
        : c.selectedToWarehouse.value;
    final rows = <int, String>{};
    for (final row in warehouses.warehouseList) {
      final id = int.tryParse(row['id'].toString());
      if (id != null) rows[id] = row['name']?.toString() ?? '-';
    }
    // Keep an existing selection visible when its relation is no longer returned.
    if (selected != null) {
      rows.putIfAbsent(
        selected,
        () => '${'Unavailable warehouse'.tr} #$selected',
      );
    }
    return DropdownButtonFormField<int>(
      key: source ? sourceKey : destinationKey,
      focusNode: source ? sourceFocus : destinationFocus,
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: (source ? 'From warehouse' : 'To warehouse').tr,
      ),
      errorBuilder: (_, error) => Text(error),
      items: rows.entries
          .map(
            (e) => DropdownMenuItem(
              value: e.key,
              child: Text(e.value, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      validator: (value) => value == null
          ? 'Please select a warehouse'.tr
          : (!source && value == c.selectedFromWarehouse.value
                ? 'Choose different warehouses'.tr
                : null),
      onChanged: saving
          ? null
          : (value) {
              if (source) {
                c.selectFromWarehouse(value);
              } else {
                c.selectedToWarehouse.value = value;
              }
            },
    );
  }

  void submit() {
    final validFields = form.currentState!.validate();
    final validDraft = c.validateDraft();
    if (!validFields) {
      final invalid = sourceKey.currentState?.hasError == true
          ? sourceKey
          : destinationKey;
      (invalid == sourceKey ? sourceFocus : destinationFocus).requestFocus();
      if (invalid.currentContext != null) {
        Scrollable.ensureVisible(invalid.currentContext!);
      }
      return;
    }
    if (!validDraft) {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: kThemeAnimationDuration,
          curve: Curves.easeInOut,
        );
      }
      return;
    }
    if (widget.stockTransfer == null) {
      c.onSaveStockTransfer(context);
    } else {
      c.onUpdate(context, widget.stockTransfer!);
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final saving = c.isSaving.value;
    final products = <int, Map<String, dynamic>>{};
    for (final row in c.availableProducts) {
      final id = int.tryParse(row['product']?['id']?.toString() ?? '');
      if (id != null) products[id] = row;
    }
    final selected = c.selectedProduct.value;
    final items = c.transferItems.toList();
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.sizeOf(context).height *
                  AppTokens.formMaxHeightFactor,
            ),
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    (widget.stockTransfer == null
                            ? 'Add Stock Transfer'
                            : 'Edit Stock Transfer')
                        .tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Flexible(
                    child: SingleChildScrollView(
                      controller: scroll,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppFormSection(
                            title: 'Warehouses',
                            children: [
                              if (warehouses.isLoading.value)
                                const LinearProgressIndicator(),
                              pair(
                                warehouseField(true, saving),
                                warehouseField(false, saving),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          AppFormSection(
                            title: 'Transfer Information',
                            children: [
                              pair(
                                AppFormField(
                                  label: 'Reference number',
                                  controller: c.productTransferRefController,
                                  enabled: !saving,
                                  hint: 'Leave blank to generate automatically',
                                ),
                                TextFormField(
                                  key: ValueKey(c.formattedDate),
                                  initialValue: c.formattedDate,
                                  enabled: !saving,
                                  readOnly: true,
                                  onTap: () => c.pickDate(context),
                                  decoration: InputDecoration(
                                    labelText: 'Transfer date'.tr,
                                    suffixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          AppFormSection(
                            title: 'Product in source warehouse',
                            children: [
                              if (c.isStockLoading.value)
                                const LinearProgressIndicator(),
                              if (c.stockError.isNotEmpty) ...[
                                Text(c.stockError.value.tr),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: TextButton(
                                    onPressed: saving || c.isStockLoading.value
                                        ? null
                                        : c.onGetWarehouseStock,
                                    child: Text('Retry'.tr),
                                  ),
                                ),
                              ],
                              pair(
                                DropdownButtonFormField<int>(
                                  key: ValueKey(
                                    'product-$selected-${products.keys.join(',')}',
                                  ),
                                  initialValue: products.containsKey(selected)
                                      ? selected
                                      : null,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Product'.tr,
                                    helperText:
                                        (c.selectedFromWarehouse.value == null
                                                ? 'Select a source warehouse first'
                                                : products.isEmpty
                                                ? 'No available stock in this warehouse'
                                                : 'Available quantity')
                                            .tr,
                                  ),
                                  items: products.entries
                                      .map(
                                        (e) => DropdownMenuItem<int>(
                                          value: e.key,
                                          child: Text(
                                            '${e.value['product']['name'] ?? 'Product'.tr} · ${c.availableQtyFor(e.key)}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged:
                                      saving ||
                                          c.isStockLoading.value ||
                                          c.stockError.isNotEmpty
                                      ? null
                                      : (value) =>
                                            c.selectedProduct.value = value,
                                ),
                                AppFormField(
                                  label: 'Quantity',
                                  controller: c.quantityController,
                                  enabled: !saving,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: TextButton.icon(
                                  onPressed:
                                      saving ||
                                          c.isStockLoading.value ||
                                          c.stockError.isNotEmpty
                                      ? null
                                      : c.addDraftItem,
                                  icon: const Icon(Icons.add),
                                  label: Text('Add item'.tr),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          AppFormSection(
                            title: 'Transferred items',
                            children: [
                              Text(
                                '${'Product lines'.tr}: ${items.length} · ${'Total quantity'.tr}: ${c.totalDraftQuantity}',
                              ),
                              for (var i = 0; i < items.length; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              items[i]['product']?['name']
                                                      ?.toString() ??
                                                  '${'Product'.tr} #${items[i]['product_id'] ?? '-'}',
                                            ),
                                            Text(
                                              '${'Quantity'.tr}: ${items[i]['qty']} · ${'Available quantity'.tr}: ${c.availableQtyFor(items[i]['product_id'] is int ? items[i]['product_id'] : -1)}',
                                            ),
                                            if (items[i]['product_id']
                                                    is! int ||
                                                (int.tryParse(
                                                          items[i]['qty']
                                                              .toString(),
                                                        ) ??
                                                        0) >
                                                    c.availableQtyFor(
                                                      items[i]['product_id'],
                                                    ))
                                              Text(
                                                'Quantity exceeds available stock.'
                                                    .tr,
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Remove item'.tr,
                                        onPressed: saving
                                            ? null
                                            : () => c.removeDraftItem(i),
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (c.draftError.isNotEmpty)
                                Text(c.draftError.value.tr),
                              if (c.formError.isNotEmpty)
                                Text(c.formError.value.tr),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppFormActions(
                    saving: saving,
                    onCancel: () => Navigator.of(context).pop(),
                    onSave: c.stockError.isNotEmpty || c.isStockLoading.value
                        ? null
                        : submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  });
}
