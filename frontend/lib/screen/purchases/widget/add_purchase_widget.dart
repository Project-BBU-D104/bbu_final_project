import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase_controller.dart';
import 'package:frontend/screen/purchases/widget/purchase_item_form.dart';
import 'package:frontend/screen/purchases/widget/purchase_item_row_widget.dart';
import 'package:frontend/screen/purchases/widget/summary_row_widget.dart';
// import 'package:frontend/controllers/product_controller.dart';
// import 'package:frontend/controllers/supplier_controller.dart';
import 'package:get/get.dart';

class AddPurchaseWidget extends StatelessWidget {
  AddPurchaseWidget({super.key});
  final ctr = Get.find<PurchaseController>();
  // final productCtr = Get.find<ProductController>();
  // final supplierCtr = Get.find<SupplierController>();

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ctr.purchaseDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) ctr.pickPurchaseDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: ctr.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Purchase",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Invoice No ---
              _label("Invoice Number"),
              TextFormField(
                controller: ctr.invoiceCtrl,
                decoration: const InputDecoration(
                  hintText: "e.g. INV-0001",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // --- Supplier ---
              _label("Supplier"),
              Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
                    value: ctr.selectedSupplier.value,
                    items: const [
                      // supplierCtr.suppliers
                      //   .map((s) => DropdownMenuItem(value: s, child: Text(s['name'])))
                      //   .toList(),
                    ],
                    onChanged: (v) => ctr.selectedSupplier.value = v,
                    decoration: const InputDecoration(
                      hintText: "Select supplier",
                      border: OutlineInputBorder(),
                    ),
                  )),
              const SizedBox(height: 12),

              // --- Purchase Date ---
              _label("Purchase Date"),
              Obx(() => InkWell(
                    onTap: () => _pickDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      child: Text(
                        "${ctr.purchaseDate.value.year}-"
                        "${ctr.purchaseDate.value.month.toString().padLeft(2, '0')}-"
                        "${ctr.purchaseDate.value.day.toString().padLeft(2, '0')}",
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              // --- Purchase Items ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label("Purchase Items"),
                  TextButton.icon(
                    onPressed: ctr.addItemRow,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Item"),
                  ),
                ],
              ),
              Obx(() => Column(
                    children: ctr.items
                        .map((item) => PurchaseItemRowWidget(
                              key: item.id,
                              item: item,
                              canRemove: ctr.items.length > 1,
                              onRemove: () => ctr.removeItemRow(item),
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 16),

              // --- Tax / Discount ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Tax"),
                        TextFormField(
                          controller: ctr.taxCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label("Discount"),
                        TextFormField(
                          controller: ctr.discountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _label("Paid Amount"),
              TextFormField(
                controller: ctr.paidCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              // --- Totals summary ---
              Obx(() => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        SummaryRowWidget( label: "Subtotal", value:ctr.itemsSubtotal),
                        SummaryRowWidget(label:"Tax", value:ctr.tax.value),
                        SummaryRowWidget(label:"Discount", value:-ctr.discount.value),
                        const Divider(),
                        SummaryRowWidget(label:"Total", value:ctr.total, bold: true),
                        SummaryRowWidget(label:"Paid", value:ctr.paid.value),
                        SummaryRowWidget(
                          label: "Due",
                          value:ctr.due,
                          bold: true,
                          color: ctr.due > 0 ? Colors.red : Colors.green,
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),

              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ctr.isSaving.value
                          ? null
                          : () => ctr.createPurchase(context),
                      child: ctr.isSaving.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Save"),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 5, top: 4),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      );
}