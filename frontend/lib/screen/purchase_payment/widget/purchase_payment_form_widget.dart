import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:frontend/utils/sales_report_utils.dart';
import 'package:get/get.dart';

class PurchasePaymentFormWidget extends StatelessWidget {
  PurchasePaymentFormWidget({super.key});

  final ctr = Get.find<PurchasePaymentController>();

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
    final editing = ctr.isEditing;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
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
                  Text(
                    editing ? "Edit Purchase Payment".tr : "Purchase Payment".tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (editing) ..._readOnlyIdentity() else _purchaseDropdown(),
              const SizedBox(height: 10),
              _sectionLabel("Select Payment Type"),
              const SizedBox(height: 5),
              Obx(() {
                if (ctr.paymentTypeCtr.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButtonFormField<int>(
                  initialValue: ctr.selectedPaymentTypeId.value,
                  decoration: InputDecoration(
                    labelText: "Select Payment Type".tr,
                    border: const OutlineInputBorder(),
                  ),
                  items: ctr.paymentTypeCtr.paymentTypeList.map((paymentType) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(paymentType["id"].toString()),
                      child: Text(paymentType["name"]?.toString() ?? ""),
                    );
                  }).toList(),
                  onChanged: (value) => ctr.selectedPaymentTypeId.value = value,
                  validator: (value) =>
                      value == null ? "Please select a payment type".tr : null,
                );
              }),
              const SizedBox(height: 10),
              _sectionLabel("Select Currency"),
              const SizedBox(height: 5),
              Obx(() {
                if (ctr.currencyCtr.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButtonFormField<int>(
                  initialValue: ctr.selectedCurrencyId.value,
                  decoration: InputDecoration(
                    labelText: "Select Currency".tr,
                    border: const OutlineInputBorder(),
                  ),
                  items: ctr.currencyCtr.currencyList.map((currency) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(currency["id"].toString()),
                      child: Text(currency["name"]?.toString() ?? ""),
                    );
                  }).toList(),
                  onChanged: (value) => ctr.selectedCurrencyId.value = value,
                  validator: (value) =>
                      value == null ? "Please select a currency".tr : null,
                );
              }),
              const SizedBox(height: 10),
              _sectionLabel("Amount"),
              const SizedBox(height: 5),
              TextFormField(
                controller: ctr.amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: "Enter Amount".tr,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0) {
                    return "Enter a valid amount".tr;
                  }
                  if (amount > ctr.maxAmount) {
                    return "Amount cannot exceed purchase balance".tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _sectionLabel("Select Payment Date"),
              const SizedBox(height: 5),
              Obx(
                () => InkWell(
                  onTap: () => _pickDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormatter.formatDate(ctr.purchaseDate.value),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _sectionLabel("Note"),
              const SizedBox(height: 5),
              TextFormField(
                controller: ctr.noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter Note".tr,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 15),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: ctr.isSaving.value
                        ? null
                        : () => editing
                            ? ctr.onUpdatePurchasePayment(context)
                            : ctr.onSavePurchasePayment(context),
                    child: Text(
                      ctr.isSaving.value
                          ? "Saving...".tr
                          : (editing ? "Update".tr : "Save".tr),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.tr,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  List<Widget> _readOnlyIdentity() {
    final purchase = ctr.originalPayment?['purchase'];

    return [
      InputDecorator(
        decoration: InputDecoration(
          labelText: "Purchase".tr,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          "${purchase?['invoice_no'] ?? ''} - Due: ${purchase?['due_amount'] ?? ''}",
        ),
      ),
      const SizedBox(height: 10),
      InputDecorator(
        decoration: InputDecoration(
          labelText: "Payment No".tr,
          border: const OutlineInputBorder(),
        ),
        child: Text(ctr.paymentNoCtrl.text),
      ),
    ];
  }

  Widget _purchaseDropdown() {
    return Obx(() {
      if (ctr.purchaseCtr.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final purchases = ctr.purchaseCtr.purchaseList
          .where((purchase) => parseAmount(purchase['due_amount']) > 0)
          .toList();

      if (purchases.isEmpty) {
        return Center(child: Text("No Purchase Found".tr));
      }

      return DropdownButtonFormField<int>(
        initialValue: ctr.selectedPurchaseId.value,
        decoration: InputDecoration(
          labelText: "Select Purchase".tr,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        items: purchases.map((purchase) {
          return DropdownMenuItem<int>(
            value: int.tryParse(purchase['id'].toString()),
            child: Text(
              "${purchase['invoice_no']} - Due: ${purchase['due_amount']}",
            ),
          );
        }).toList(),
        onChanged: (value) => ctr.selectedPurchaseId.value = value,
        validator: (value) =>
            value == null ? "Please select a purchase".tr : null,
      );
    });
  }
}
