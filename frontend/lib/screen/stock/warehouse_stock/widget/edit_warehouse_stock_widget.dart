import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_stock_controller.dart';
import 'package:get/get.dart';

class EditWarehouseStockWidget extends StatelessWidget {
  EditWarehouseStockWidget({super.key});

  final ctr = Get.find<WarehouseStockController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Edit Warehouse Stock",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Warehouse
            const Text(
              "Warehouse",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Obx(
              () => DropdownButtonFormField<String>(
                value: ctr.selectedWarehouse.value,
                decoration: InputDecoration(
                  hintText: "Select Warehouse",
                  prefixIcon: const Icon(Icons.warehouse_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "warehouse1",
                    child: Text("Warehouse 1"),
                  ),
                  DropdownMenuItem(
                    value: "warehouse2",
                    child: Text("Warehouse 2"),
                  ),
                  DropdownMenuItem(
                    value: "warehouse3",
                    child: Text("Warehouse 3"),
                  ),
                ],
                onChanged: (value) {
                  ctr.selectedWarehouse.value = value;
                },
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Products",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            /// Product List
            Obx(
              () => Column(
                children: List.generate(
                  ctr.productRows.length,
                  (index) {
                    final row = ctr.productRows[index];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: (row["product"] as RxnString).value,
                              decoration: InputDecoration(
                                labelText: "Product",
                                prefixIcon: const Icon(Icons.inventory_2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "product1",
                                  child: Text("Product 1"),
                                ),
                                DropdownMenuItem(
                                  value: "product2",
                                  child: Text("Product 2"),
                                ),
                                DropdownMenuItem(
                                  value: "product3",
                                  child: Text("Product 3"),
                                ),
                              ],
                              onChanged: (value) {
                                (row["product"] as RxnString).value = value;
                              },
                            ),

                            const SizedBox(height: 12),

                            TextField(
                              controller: row["qty"],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Quantity",
                                prefixIcon: const Icon(Icons.numbers),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (ctr.productRows.length > 1)
                                  IconButton(
                                    tooltip: "Delete",
                                    onPressed: () =>
                                        ctr.removeProductRow(index),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),

                                if (index == ctr.productRows.length - 1)
                                  IconButton(
                                    tooltip: "Add Product",
                                    onPressed: ctr.addProductRow,
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ctr.onSaveWarehouseStock();
                },
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}