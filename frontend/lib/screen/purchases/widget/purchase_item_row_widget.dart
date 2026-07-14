import 'package:flutter/material.dart';
import 'package:frontend/screen/purchases/widget/purchase_item_form.dart';
import 'package:get/get.dart';

class PurchaseItemRowWidget extends StatelessWidget {
  final PurchaseItemForm item;
  final VoidCallback onRemove;
  final bool canRemove;
  const PurchaseItemRowWidget({super.key, required this.item, required this.onRemove, this.canRemove = true});

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
                  flex: 3,
                  child: Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                        value: item.product.value,
                        items: const [
                          // productCtr.products
                          //   .map((p) => DropdownMenuItem(value: p, child: Text(p['name'])))
                          //   .toList(),
                        ],
                        onChanged: (v) => item.product.value = v,
                        decoration: const InputDecoration(
                          labelText: 'Product',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      )),
                ),
                if (canRemove)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: item.costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cost Price',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          item.subtotal.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}