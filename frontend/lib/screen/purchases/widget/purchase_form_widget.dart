import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/screen/purchases/widget/purchase_item_row_widget.dart';
import 'package:get/get.dart';

class PurchaseFormWidget extends StatelessWidget {
  PurchaseFormWidget({super.key, required this.editing});
  final bool editing;
  final ctr = Get.find<PurchaseController>();
  final suppliers = Get.find<SupplierController>();
  final warehouses = Get.find<WarehouseController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    Widget heading(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        header: true,
        child: Text(
          title.tr,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    InputDecoration decoration(String label) => InputDecoration(
      labelText: label.tr,
      filled: true,
      fillColor: Color.alphaBlend(
        colors.onSurface.withValues(alpha: .025),
        theme.cardColor,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.onSurface.withValues(alpha: .1)),
      ),
    );
    Widget amount(String label, TextEditingController controller) =>
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: decoration(label),
        );
    return Obx(() {
      final busy = ctr.isSaving.value;
      return PopScope(
        canPop: !busy,
        child: Material(
          color: theme.cardColor,
          child: SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  MediaQuery.viewInsetsOf(context).bottom + 24,
                ),
                child: Form(
                  key: ctr.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (editing ? 'Edit Purchase' : 'Add Purchase').tr,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close'.tr,
                            onPressed: busy
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(height: 1),
                      ),
                      heading('Purchase details'),
                      if (warehouses.isLoading.value)
                        const LinearProgressIndicator()
                      else
                        DropdownButtonFormField<int>(
                          value:
                              warehouses.warehouseList.any(
                                (w) => w['id'] == ctr.selectedWarehouse.value,
                              )
                              ? ctr.selectedWarehouse.value
                              : null,
                          isExpanded: true,
                          decoration: decoration('Warehouse'),
                          items: warehouses.warehouseList
                              .map(
                                (w) => DropdownMenuItem<int>(
                                  value: w['id'] as int,
                                  child: Text(w['name'] ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: busy
                              ? null
                              : (v) => ctr.selectedWarehouse.value = v,
                          validator: (v) =>
                              v == null ? 'Please select a warehouse'.tr : null,
                        ),
                      const SizedBox(height: 20),
                      if (suppliers.isLoading.value)
                        const LinearProgressIndicator()
                      else
                        DropdownButtonFormField<int>(
                          value:
                              suppliers.suppliers.any(
                                (s) =>
                                    s.id == ctr.selectedSupplier.value &&
                                    (editing || s.status == true),
                              )
                              ? ctr.selectedSupplier.value
                              : null,
                          isExpanded: true,
                          decoration: decoration('Supplier'),
                          items: suppliers.suppliers
                              .where((s) => editing || s.status == true)
                              .map(
                                (s) => DropdownMenuItem<int>(
                                  value: s.id,
                                  child: Text(s.name),
                                ),
                              )
                              .toList(),
                          onChanged: busy
                              ? null
                              : (v) => ctr.selectedSupplier.value = v,
                          validator: (v) =>
                              v == null ? 'Please select a supplier'.tr : null,
                        ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: ctr.invoiceCtrl,
                        enabled: !busy,
                        decoration: decoration('Invoice Number'),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: busy
                            ? null
                            : () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: ctr.purchaseDate.value,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) ctr.pickPurchaseDate(date);
                              },
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          '${'Purchase Date'.tr}: ${ctr.purchaseDate.value.toIso8601String().split('T').first}',
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          heading('Purchase Items'),
                          TextButton.icon(
                            onPressed: busy ? null : ctr.addItemRow,
                            icon: const Icon(Icons.add),
                            label: Text('Add Item'.tr),
                          ),
                        ],
                      ),
                      ...ctr.items.map(
                        (item) => PurchaseItemRowWidget(
                          key: item.id,
                          item: item,
                          canRemove: !busy && ctr.items.length > 1,
                          onRemove: () => ctr.removeItemRow(item),
                        ),
                      ),
                      const SizedBox(height: 28),
                      heading('Payment details'),
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          spacing: 16,
                          runSpacing: 20,
                          children: [
                            for (final field in [
                              amount('Tax', ctr.taxCtrl),
                              amount('Discount', ctr.discountCtrl),
                              amount('Paid Amount', ctr.paidCtrl),
                            ])
                              SizedBox(
                                width: constraints.maxWidth >= 560
                                    ? (constraints.maxWidth - 32) / 3
                                    : constraints.maxWidth,
                                child: field,
                              ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(height: 1),
                      ),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(100, 48),
                            ),
                            child: Text('Cancel'.tr),
                          ),
                          FilledButton(
                            onPressed: busy
                                ? null
                                : () => editing
                                      ? ctr.onUpdatePurchase(context)
                                      : ctr.createPurchase(context),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(112, 48),
                            ),
                            child: Text(
                              (busy
                                      ? 'Saving...'
                                      : editing
                                      ? 'Update'
                                      : 'Save')
                                  .tr,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
