import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:get/get.dart';

class AddPurchasePaymentWidget extends StatelessWidget {
  AddPurchasePaymentWidget({super.key});

  final ctr = Get.find<PurchasePaymentController>();

  Future<void> pickDate(BuildContext context) async {
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
                    "Purchase Payment".tr,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),
 
              Text(
                "Select Purchase".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              Obx(() {
                if (ctr.purchaseCtr.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (ctr.purchaseCtr.purchaseList.isEmpty) {
                  return Center(child: Text("No Purchase Found".tr));
                }

                // Filter purchases that still have an outstanding balance
                final selectDuePurchase = ctr.purchaseCtr.purchaseList
                    .where(
                      (purchase) =>
                          (double.tryParse(purchase['due_amount'].toString()) ??
                              0) >
                          0,
                    )
                    .toList();

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

                  items: selectDuePurchase.map((purchase) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(purchase['id'].toString()),
                      child: Text(
                        "${purchase['invoice_no']} - Due: ${purchase['due_amount']}",
                      ),
                    );
                  }).toList(),

                  onChanged: (value) {
                    ctr.selectedPurchaseId.value = value;
                  },
                  validator: (value) =>
                      value == null ? "Please select a purchase".tr : null,
                );
              }),

              const SizedBox(height: 10),

              Text(
                "Select Payment Date".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Obx(
                () => InkWell(
                  onTap: () => pickDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      "${ctr.purchaseDate.value.year}-"
                      "${ctr.purchaseDate.value.month.toString().padLeft(2, '0')}-"
                      "${ctr.purchaseDate.value.day.toString().padLeft(2, '0')}",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Select Payment Type".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

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
              Text(
                "Select Currency".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
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

              Text(
                "Amount".tr,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              SizedBox(height: 5),
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
                  final amount = double.tryParse(value?.trim() ?? "");
                  if (amount == null || amount <= 0) {
                    return "Enter a valid amount".tr;
                  }
                  if (amount > ctr.selectedPurchaseDue) {
                    return "Amount cannot exceed purchase due".tr;
                  }
                  return null;
                },
              ),
 
              const SizedBox(height: 10),

              Text(
                "Note".tr,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: ctr.noteCtrl,
                maxLines: 8,
                minLines: 3,
                // controller: ctr.descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter Note".tr,
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: ctr.isSaving.value
                      ? null
                      : () => ctr.onSavePurchasePayment(context),
                  child: Text(
                    ctr.isSaving.value ? "Saving...".tr : "Save".tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
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
}
