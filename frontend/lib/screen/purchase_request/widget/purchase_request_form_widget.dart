import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_request_controller.dart';
import 'package:get/get.dart';

class PurchaseRequestFormWidget extends StatelessWidget {
  const PurchaseRequestFormWidget({super.key, this.requestId});

  final int? requestId;

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<PurchaseRequestController>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    InputDecoration decoration(String label) => InputDecoration(
      labelText: label.tr,
      filled: true,
      fillColor: Color.alphaBlend(
        colors.onSurface.withValues(alpha: .025),
        theme.cardColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.onSurface.withValues(alpha: .1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );

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

    Future<void> pickDate(bool approved) async {
      final current = approved ? ctr.approvedDate.value : ctr.requestDate.value;
      final picked = await showDatePicker(
        context: context,
        initialDate: current,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked == null || !context.mounted) return;
      if (approved) {
        ctr.approvedDate.value = picked;
      } else {
        ctr.requestDate.value = picked;
      }
    }

    Widget dateField(String label, bool approved, bool busy) => Obx(() {
      final date = approved ? ctr.approvedDate.value : ctr.requestDate.value;
      final text =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      return InkWell(
        onTap: busy ? null : () => pickDate(approved),
        child: InputDecorator(
          decoration: decoration(
            label,
          ).copyWith(suffixIcon: const Icon(Icons.calendar_month_outlined)),
          child: Text(text),
        ),
      );
    });

    Widget itemLine(
      PurchaseRequestLine line,
      int index,
      bool busy,
    ) => Container(
      key: ValueKey(line),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${'Item'.tr} ${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: "Remove item".tr,
                onPressed: busy || ctr.itemLines.length == 1
                    ? null
                    : () => ctr.removeItemLine(line),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          Obx(() {
            final selectedId = int.tryParse(
              line.selectedProduct.value?["id"].toString() ?? "",
            );
            final productItems = ctr.productController.products
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
              key: ValueKey('product-${identityHashCode(line)}-$selectedId'),
              initialValue: productItems.any((item) => item.value == selectedId)
                  ? selectedId
                  : null,
              isExpanded: true,
              decoration: decoration("Product"),
              items: productItems,
              onChanged: busy
                  ? null
                  : (productId) {
                      if (productId == null) return;
                      final selectedProduct = ctr.productController.products
                          .firstWhere(
                            (product) =>
                                int.tryParse(product["id"].toString()) ==
                                productId,
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
                  enabled: !busy,
                  keyboardType: TextInputType.number,
                  decoration: decoration("Quantity"),
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
                  enabled: !busy,
                  decoration: decoration("Unit"),
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

    return Obx(() {
      final busy = ctr.isSaving.value;
      final error = ctr.formError.value;
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
                              Icons.assignment_outlined,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (requestId == null
                                      ? 'Add Purchase Request'
                                      : 'Edit Purchase Request')
                                  .tr,
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
                      if (error.isNotEmpty)
                        Container(
                          key: const Key('purchase-request-form-error'),
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.error.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.error.withValues(alpha: .3),
                            ),
                          ),
                          child: Text(
                            error,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.error,
                            ),
                          ),
                        ),
                      heading('Request details'),
                      TextFormField(
                        controller: ctr.requestTypeController,
                        enabled: !busy,
                        decoration: decoration("Request Type"),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? "Request type is required".tr
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        if (ctr.warehouseController.isLoading.value) {
                          return const LinearProgressIndicator();
                        }
                        final selected = ctr.selectedWarehouseId.value;
                        final warehouseItems = ctr
                            .warehouseController
                            .warehouseList
                            .map((warehouse) {
                              final id = int.tryParse(
                                warehouse["id"].toString(),
                              );
                              if (id == null) return null;
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  warehouse["name"]?.toString() ?? "",
                                ),
                              );
                            })
                            .whereType<DropdownMenuItem<int>>()
                            .toList();
                        return DropdownButtonFormField<int>(
                          key: ValueKey('warehouse-$selected'),
                          initialValue:
                              warehouseItems.any(
                                (item) => item.value == selected,
                              )
                              ? selected
                              : null,
                          isExpanded: true,
                          decoration: decoration("Warehouse"),
                          items: warehouseItems,
                          onChanged: busy
                              ? null
                              : (value) =>
                                    ctr.selectedWarehouseId.value = value,
                          validator: (value) =>
                              value == null ? "Select a warehouse".tr : null,
                        );
                      }),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: ctr.requestedByController,
                        enabled: !busy,
                        decoration: decoration("Requested By"),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? "Requester is required".tr
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: ctr.approvedByController,
                        enabled: !busy,
                        decoration: decoration("Approved By"),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? "Approver is required".tr
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => DropdownButtonFormField<String>(
                          key: ValueKey('status-${ctr.requestStatus.value}'),
                          initialValue: ctr.requestStatus.value,
                          decoration: decoration("Status"),
                          items: ["pending", "approved", "rejected"]
                              .map(
                                (status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(
                                    (status[0].toUpperCase() +
                                            status.substring(1))
                                        .tr,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: busy
                              ? null
                              : (value) {
                                  if (value != null) {
                                    ctr.requestStatus.value = value;
                                  }
                                },
                        ),
                      ),
                      const SizedBox(height: 20),
                      dateField("Request Date", false, busy),
                      const SizedBox(height: 20),
                      dateField("Approved Date", true, busy),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: ctr.reasonController,
                        enabled: !busy,
                        minLines: 2,
                        maxLines: 4,
                        decoration: decoration(
                          "Reason",
                        ).copyWith(alignLabelWithHint: true),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? "Reason is required".tr
                            : null,
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          heading('Requested Items'),
                          TextButton.icon(
                            onPressed: busy ? null : ctr.addItemLine,
                            icon: const Icon(Icons.add),
                            label: Text("Add Item".tr),
                          ),
                        ],
                      ),
                      Obx(
                        () => Column(
                          children: ctr.itemLines
                              .asMap()
                              .entries
                              .map(
                                (entry) =>
                                    itemLine(entry.value, entry.key, busy),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 28),
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
                                : () => requestId == null
                                      ? ctr.savePurchaseRequest(context)
                                      : ctr.updatePurchaseRequest(
                                          context,
                                          requestId!,
                                        ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(112, 48),
                            ),
                            child: Text(
                              (busy
                                      ? 'Saving...'
                                      : requestId == null
                                      ? 'Create Request'
                                      : 'Save Changes')
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
