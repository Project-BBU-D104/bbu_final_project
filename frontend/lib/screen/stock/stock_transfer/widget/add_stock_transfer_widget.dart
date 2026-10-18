import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/product_transfer_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:get/get.dart';

class AddStockTransferWidget extends StatelessWidget {
  AddStockTransferWidget({super.key, this.isEditing = false});

  final bool isEditing;
  final ctr = Get.find<ProductTransferController>();
  final warehouseCtr = Get.find<WarehouseController>();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing
                            ? 'Edit Stock Transfer'.tr
                            : 'Add Stock Transfer'.tr,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _label('From warehouse'),
                const SizedBox(height: 6),
                Obx(() {
                  if (warehouseCtr.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField<int>(
                    key: ValueKey(ctr.selectedFromWarehouse.value),
                    initialValue: ctr.selectedFromWarehouse.value,
                    decoration: const InputDecoration(
                      hintText: 'Select source warehouse',
                      border: OutlineInputBorder(),
                    ),
                    items: warehouseCtr.warehouseList
                        .map((warehouse) {
                          return DropdownMenuItem<int>(
                            value: int.tryParse(warehouse['id'].toString()),
                            child: Text(warehouse['name']?.toString() ?? ''),
                          );
                        })
                        .where((item) => item.value != null)
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Select a source warehouse' : null,
                    onChanged: ctr.selectFromWarehouse,
                  );
                }),
                const SizedBox(height: 14),
                _label('To warehouse'),
                const SizedBox(height: 6),
                Obx(() {
                  if (warehouseCtr.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField<int>(
                    key: ValueKey(ctr.selectedToWarehouse.value),
                    initialValue: ctr.selectedToWarehouse.value,
                    decoration: const InputDecoration(
                      hintText: 'Select destination warehouse',
                      border: OutlineInputBorder(),
                    ),
                    items: warehouseCtr.warehouseList
                        .map((warehouse) {
                          return DropdownMenuItem<int>(
                            value: int.tryParse(warehouse['id'].toString()),
                            child: Text(warehouse['name']?.toString() ?? ''),
                          );
                        })
                        .where((item) => item.value != null)
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Select a destination warehouse' : null,
                    onChanged: (value) => ctr.selectedToWarehouse.value = value,
                  );
                }),
                const SizedBox(height: 14),
                _label('Reference number'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: ctr.productTransferRefController,
                  decoration: const InputDecoration(
                    hintText: 'Leave blank to generate automatically',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                _label('Product in source warehouse'),
                const SizedBox(height: 6),
                Obx(() {
                  if (ctr.isStockLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final availableProducts = ctr.availableProducts;
                  return DropdownButtonFormField<int>(
                    key: ValueKey(ctr.selectedProduct.value),
                    initialValue: ctr.selectedProduct.value,
                    decoration: InputDecoration(
                      hintText: ctr.selectedFromWarehouse.value == null
                          ? 'Select a source warehouse first'
                          : availableProducts.isEmpty
                          ? 'No available stock in this warehouse'
                          : 'Select product',
                      border: const OutlineInputBorder(),
                    ),
                    items: availableProducts
                        .map((stock) {
                          final product = Map<String, dynamic>.from(
                            stock['product'] as Map,
                          );
                          final productId = int.tryParse(
                            product['id'].toString(),
                          );
                          if (productId == null) return null;
                          return DropdownMenuItem<int>(
                            value: productId,
                            child: Text(
                              '${product['name'] ?? 'Product'} · ${ctr.availableQtyFor(productId)} available',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                        .whereType<DropdownMenuItem<int>>()
                        .toList(),
                    onChanged: availableProducts.isEmpty
                        ? null
                        : (value) => ctr.selectedProduct.value = value,
                  );
                }),
                const SizedBox(height: 14),
                _label('Quantity'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: ctr.quantityController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      ctr.quantity.value = int.tryParse(value),
                  decoration: const InputDecoration(
                    hintText: 'Enter quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: ctr.addDraftItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add item'),
                  ),
                ),
                Obx(() {
                  if (ctr.transferItems.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Add at least one product to this transfer.'),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          'Items: ${ctr.transferItems.length} product lines · ${ctr.totalDraftQuantity} total units',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      for (
                        var index = 0;
                        index < ctr.transferItems.length;
                        index++
                      )
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            ctr.transferItems[index]['product']?['name']
                                    ?.toString() ??
                                'Product',
                          ),
                          subtitle: Text(
                            'Quantity: ${ctr.transferItems[index]['qty']}',
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove item',
                            onPressed: () => ctr.removeDraftItem(index),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 8),
                _label('Transfer date'),
                const SizedBox(height: 6),
                Obx(
                  () => InkWell(
                    onTap: () => ctr.pickDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(ctr.formattedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: successColor,
                        foregroundColor: titleColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: ctr.isSaving.value
                          ? null
                          : () => _submit(context),
                      icon: ctr.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        isEditing ? 'Update transfer' : 'Create transfer',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String value) =>
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600));

  void _submit(BuildContext context) {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (ctr.selectedFromWarehouse.value == ctr.selectedToWarehouse.value) {
      Get.snackbar(
        'Invalid warehouses',
        'Source and destination must be different.',
      );
      return;
    }
    if (ctr.transferItems.isEmpty) {
      Get.snackbar(
        'Missing items',
        'Add at least one product to the transfer.',
      );
      return;
    }

    if (isEditing) {
      final transfer = ctr.editingTransfer.value;
      if (transfer != null) {
        ctr.onUpdate(context, transfer);
      }
    } else {
      ctr.onSaveStockTransfer(context);
    }
  }
}
