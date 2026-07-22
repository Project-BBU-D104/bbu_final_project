import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/product_controller.dart';
import 'package:frontend/controllers/purchase/purchase_controller.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/screen/purchases/widget/purchase_item_row_widget.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:get/get.dart';

class EditPurchaseWidget extends StatelessWidget {
  EditPurchaseWidget({super.key});
  final ctr = Get.find<PurchaseController>();
  final productCtr = Get.find<ProductController>();
  final supplierCtr = Get.find<SupplierController>();
  final warehouseCtr = Get.find<WarehouseController>();

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
                    "Edit Purchase",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Warehouse ---
              _label("Warehouse"),
               Obx(() {
                if (warehouseCtr.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return DropdownButtonFormField<int>(
                  value: ctr.selectedWarehouse.value,
                  decoration: const InputDecoration(
                    hintText: "Select Warehouse",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  items: warehouseCtr.warehouseList.map((warehouse) {
                    return DropdownMenuItem<int>(
                      value: warehouse["id"] as int,
                      child: Text(warehouse["name"] ?? ""),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ctr.selectedWarehouse.value = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a warehouse";
                    }
                    return null;
                  },
                );
              }),

              const SizedBox(height: 12),
              _label("Supplier"),
               Obx(() {
                if (supplierCtr.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return DropdownButtonFormField<int>(
                  value: ctr.selectedSupplier.value,
                  decoration: const InputDecoration(
                    hintText: "Select Supplier",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  items: supplierCtr.suppliers.map((supplier) {
                    return DropdownMenuItem<int>(
                      value: supplier.id,
                      child: Text(supplier.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ctr.selectedSupplier.value = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a supplier";
                    }
                    return null;
                  },
                );
              }),

              const SizedBox(height: 12),

              // --- Invoice No ---
              _label("Invoice Number"),
              TextField(
                controller: ctr.invoiceCtrl,
                decoration: const InputDecoration(
                  hintText: "e.g. INV-0001",
                  border: OutlineInputBorder(),
                ),
              ),
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

              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: successColor
                      ),
                      onPressed: ctr.isSaving.value
                          ? null
                          : () => ctr.onUpdatePurchase(context),
                      child: ctr.isSaving.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text("Update", style: TextStyle(
                              fontSize: 18,color: titleColor
                            )),
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