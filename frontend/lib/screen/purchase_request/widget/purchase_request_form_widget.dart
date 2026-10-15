import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:get/get.dart';

class PurchaseRequestFormWidget extends StatelessWidget {
  const PurchaseRequestFormWidget({super.key, this.requestId});

  final int? requestId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PurchaseRequestController>();

    Future<void> pickDate(bool approved) async {
      final current = approved
          ? controller.approvedDate.value
          : controller.requestDate.value;
      final picked = await showDatePicker(
        context: context,
        initialDate: current,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked == null || !context.mounted) return;
      if (approved) {
        controller.approvedDate.value = picked;
      } else {
        controller.requestDate.value = picked;
      }
    }

    Widget dateField(String label, bool approved) => Obx(() {
      final date = approved
          ? controller.approvedDate.value
          : controller.requestDate.value;
      final text =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      return InkWell(
        onTap: () => pickDate(approved),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label.tr,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_month_outlined),
          ),
          child: Text(text),
        ),
      );
    });

    Widget itemLine(PurchaseRequestLine line, int index) => Container(
      key: ValueKey(line),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Item ${index + 1}".tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: "Remove item".tr,
                onPressed: controller.itemLines.length == 1
                    ? null
                    : () => controller.removeItemLine(line),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          Obx(() {
            if (controller.productController.isLoading.value) {
              return const LinearProgressIndicator();
            }
            final selectedId = int.tryParse(
              line.selectedProduct.value?["id"].toString() ?? "",
            );
            final productItems = controller.productController.products
                .map((product) {
                  final id = int.tryParse(product["id"].toString());
                  if (id == null) return null;
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(product["name"]?.toString() ?? "Product $id"),
                  );
                })
                .whereType<DropdownMenuItem<int>>()
                .toList();

            return DropdownButtonFormField<int>(
              initialValue: selectedId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Product".tr,
                border: const OutlineInputBorder(),
              ),
              items: productItems,
              onChanged: (productId) {
                if (productId == null) return;
                final selectedProduct = controller.productController.products
                    .firstWhere(
                      (product) =>
                          int.tryParse(product["id"].toString()) == productId,
                    );
                line.selectedProduct.value = selectedProduct;
                final productUnit = selectedProduct["unit"];
                line.unitController.text = productUnit is Map
                    ? productUnit["name"]?.toString() ?? ""
                    : selectedProduct["unit_name"]?.toString() ?? "";
              },
              validator: (value) =>
                  value == null ? "Select a product".tr : null,
            );
          }),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: line.quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Quantity".tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (int.tryParse(value?.trim() ?? "") ?? 0) <= 0
                      ? "Enter a quantity greater than zero".tr
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: line.unitController,
                  decoration: InputDecoration(
                    labelText: "Unit".tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Enter a unit".tr
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        requestId == null
                            ? "New Purchase Request".tr
                            : "Edit Purchase Request".tr,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: "Close".tr,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.requestTypeController,
                  decoration: InputDecoration(
                    labelText: "Request Type".tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Request type is required".tr
                      : null,
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (controller.warehouseController.isLoading.value) {
                    return const LinearProgressIndicator();
                  }
                  final warehouseItems = controller
                      .warehouseController
                      .warehouseList
                      .map((warehouse) {
                        final id = int.tryParse(warehouse["id"].toString());
                        if (id == null) return null;
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(warehouse["name"]?.toString() ?? ""),
                        );
                      })
                      .whereType<DropdownMenuItem<int>>()
                      .toList();
                  return DropdownButtonFormField<int>(
                    initialValue: controller.selectedWarehouseId.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Warehouse".tr,
                      border: const OutlineInputBorder(),
                    ),
                    items: warehouseItems,
                    onChanged: (value) =>
                        controller.selectedWarehouseId.value = value,
                    validator: (value) =>
                        value == null ? "Select a warehouse".tr : null,
                  );
                }),
                const SizedBox(height: 10),
                TextFormField(
                  controller: controller.requestedByController,
                  decoration: InputDecoration(
                    labelText: "Requested By".tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Requester is required".tr
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: controller.approvedByController,
                  decoration: InputDecoration(
                    labelText: "Approved By".tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Approver is required".tr
                      : null,
                ),
                const SizedBox(height: 10),
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: controller.requestStatus.value,
                    decoration: InputDecoration(
                      labelText: "Status".tr,
                      border: const OutlineInputBorder(),
                    ),
                    items: ["pending", "approved", "rejected"]
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status.tr),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) controller.requestStatus.value = value;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                dateField("Request Date", false),
                const SizedBox(height: 10),
                dateField("Approved Date", true),
                const SizedBox(height: 10),
                TextFormField(
                  controller: controller.reasonController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Reason".tr,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Reason is required".tr
                      : null,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Requested Items".tr,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: controller.addItemLine,
                      icon: const Icon(Icons.add),
                      label: Text("Add Item".tr),
                    ),
                  ],
                ),
                Obx(
                  () => Column(
                    children: controller.itemLines
                        .asMap()
                        .entries
                        .map((entry) => itemLine(entry.value, entry.key))
                        .toList(),
                  ),
                ),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: controller.isSaving.value
                          ? null
                          : () => requestId == null
                                ? controller.savePurchaseRequest(context)
                                : controller.updatePurchaseRequest(
                                    context,
                                    requestId!,
                                  ),
                      icon: controller.isSaving.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        controller.isSaving.value
                            ? "Saving...".tr
                            : requestId == null
                            ? "Create Request".tr
                            : "Save Changes".tr,
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
}
