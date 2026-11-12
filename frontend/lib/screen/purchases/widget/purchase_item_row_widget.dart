import 'package:flutter/material.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/screen/purchases/widget/purchase_item_form.dart';
import 'package:get/get.dart';

class PurchaseItemRowWidget extends StatelessWidget {
  PurchaseItemRowWidget({
    super.key,
    required this.item,
    required this.onRemove,
    this.canRemove = true,
    this.enabled = true,
  });

  final PurchaseItemForm item;
  final VoidCallback onRemove;
  final bool canRemove;
  final bool enabled;

  final productCtr = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<int>(
                      key: ValueKey(item.product.value?["id"]),
                      value: item.product.value?["id"],
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Product'.tr,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: productCtr.products
                          .map(
                            (product) => DropdownMenuItem<int>(
                              value: product["id"],
                              child: Text(product["name"] ?? ""),
                            ),
                          )
                          .toList(),
                      onChanged: enabled
                          ? (value) {
                              if (value == null) {
                                item.product.value = null;
                                return;
                              }
                              final product = productCtr.products.firstWhere(
                                (p) => p["id"] == value,
                              );
                              item.product.value = product;
                              item.costCtrl.text = (product["cost_price"] ?? 0)
                                  .toString();
                            }
                          : null,
                      validator: (value) =>
                          value == null ? 'Select a product'.tr : null,
                    ),
                  ),
                ),
                if (canRemove)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete'.tr,
                    onPressed: enabled ? onRemove : null,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.qtyCtrl,
                    enabled: enabled,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Qty'.tr,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) {
                      final qty = double.tryParse(value ?? '');
                      return qty == null || qty <= 0
                          ? 'Enter a quantity greater than zero'.tr
                          : null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: item.costCtrl,
                    enabled: enabled,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Cost Price'.tr,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) {
                      final cost = double.tryParse(value ?? '');
                      return cost == null || cost <= 0
                          ? 'Enter a cost greater than zero'.tr
                          : null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => Text(
                      item.subtotal.toStringAsFixed(2),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
