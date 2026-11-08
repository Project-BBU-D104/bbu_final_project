import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/utils/date_formatter.dart';
import 'package:get/get.dart';

class PaymentFormWidget extends StatelessWidget {
  PaymentFormWidget({super.key, required this.isEditing});

  final bool isEditing;
  final ctr = Get.find<PaymentController>();

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ctr.paymentDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) ctr.pickPaymentDate(picked);
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
                    isEditing ? "Edit Payment".tr : "Add Payment".tr,
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
              if (isEditing) _readOnlySale() else _saleDropdown(),
              const SizedBox(height: 10),
              Text(
                "Amount".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: ctr.amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                    return "Amount cannot exceed sale due".tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Text(
                "Payment Method".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: ctr.methodCtrl,
                decoration: InputDecoration(
                  hintText: "Enter Payment Method".tr,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? "Payment method is required".tr
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                "Reference No".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: ctr.referenceCtrl,
                decoration: InputDecoration(
                  hintText: "Enter Reference No".tr,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? "Reference is required".tr
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                "Payment Date".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Obx(
                () => InkWell(
                  onTap: () => pickDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormatter.formatDate(ctr.paymentDate.value),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Note".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                        : () => ctr.onSavePayment(context),
                    child: Text(
                      ctr.isSaving.value
                          ? "Saving...".tr
                          : (isEditing ? "Update".tr : "Save".tr),
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

  Widget _saleDropdown() {
    return Obx(() {
      final sales = ctr.salesWithDue;
      if (sales.isEmpty) {
        return Text("No sale with outstanding balance".tr);
      }

      return DropdownButtonFormField<int>(
        initialValue: ctr.selectedSaleId.value,
        decoration: InputDecoration(
          labelText: "Select Sale".tr,
          border: const OutlineInputBorder(),
        ),
        items: sales.map((sale) {
          return DropdownMenuItem<int>(
            value: int.tryParse(sale['id'].toString()),
            child: Text(
              "${sale['invoice_no']} - Due: ${sale['due_amount']}",
            ),
          );
        }).toList(),
        onChanged: (value) => ctr.selectedSaleId.value = value,
        validator: (_) =>
            ctr.selectedSaleId.value == null ? "Please select a sale".tr : null,
      );
    });
  }

  Widget _readOnlySale() {
    final sale = ctr.originalPayment?['sale'];
    return InputDecorator(
      decoration: InputDecoration(
        labelText: "Sale".tr,
        border: const OutlineInputBorder(),
      ),
      child: Text(
        "${sale?['invoice_no'] ?? ''} - Due: ${sale?['due_amount'] ?? ''}",
      ),
    );
  }
}
