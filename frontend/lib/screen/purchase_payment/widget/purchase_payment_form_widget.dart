import 'package:flutter/material.dart';
import 'package:frontend/controllers/purchase/purchase_payment_controller.dart';
import 'package:frontend/utils/sales_report_utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  InputDecoration _decoration(String label) =>
      InputDecoration(labelText: label.tr, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final busy = ctr.isSaving.value;
      final error = ctr.formError.value;
      final editing = ctr.isEditing;

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
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Form(
                  key: ctr.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.payments_outlined,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (editing
                                      ? 'Edit Purchase Payment'
                                      : 'Add Purchase Payment')
                                  .tr,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Cancel'.tr,
                            onPressed: busy
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      if (error.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          key: const Key('purchase-payment-form-error'),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            error,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Payment details'.tr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (editing)
                        ..._readOnlyIdentity(busy)
                      else ...[
                        _purchaseDropdown(busy),
                        const SizedBox(height: 12),
                      ],
                      _paymentTypeDropdown(busy),
                      const SizedBox(height: 12),
                      _currencyDropdown(busy),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ctr.amountCtrl,
                        enabled: !busy,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Amount'.tr,
                          hintText: 'Enter Amount'.tr,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount'.tr;
                          }
                          if (amount > ctr.maxAmount) {
                            return 'Amount cannot exceed purchase balance'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: busy ? null : () => _pickDate(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          alignment: Alignment.centerLeft,
                        ),
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          '${'Payment Date'.tr}: '
                          '${DateFormat('yyyy-MM-dd').format(ctr.purchaseDate.value)}',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ctr.noteCtrl,
                        enabled: !busy,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Note'.tr,
                          hintText: 'Enter Note'.tr,
                          border: const OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                              minimumSize: const Size(0, 48),
                            ),
                            child: Text('Cancel'.tr),
                          ),
                          FilledButton(
                            onPressed: busy
                                ? null
                                : () => editing
                                      ? ctr.onUpdatePurchasePayment(context)
                                      : ctr.onSavePurchasePayment(context),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                            child: Text(
                              (busy
                                      ? 'Saving...'
                                      : editing
                                      ? 'Update'
                                      : 'Save')
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

  List<Widget> _readOnlyIdentity(bool busy) {
    final purchase = ctr.originalPayment?['purchase'];

    return [
      InputDecorator(
        decoration: _decoration('Purchase'),
        child: Text(
          "${purchase?['invoice_no'] ?? ''} - Due: ${purchase?['due_amount'] ?? ''}",
        ),
      ),
      const SizedBox(height: 12),
      InputDecorator(
        decoration: _decoration('Payment No'),
        child: Text(ctr.paymentNoCtrl.text),
      ),
    ];
  }

  Widget _purchaseDropdown(bool busy) {
    return Obx(() {
      if (ctr.purchaseCtr.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final purchases = ctr.purchaseCtr.purchaseList
          .where((purchase) => parseAmount(purchase['due_amount']) > 0)
          .toList();

      if (purchases.isEmpty) {
        return Text('No Purchase Found'.tr);
      }

      return DropdownButtonFormField<int>(
        key: ValueKey('purchase-${ctr.selectedPurchaseId.value}'),
        initialValue: ctr.selectedPurchaseId.value,
        decoration: _decoration('Select Purchase'),
        items: purchases.map((purchase) {
          return DropdownMenuItem<int>(
            value: int.tryParse(purchase['id'].toString()),
            child: Text(
              "${purchase['invoice_no']} - Due: ${purchase['due_amount']}",
            ),
          );
        }).toList(),
        onChanged: busy
            ? null
            : (value) => ctr.selectedPurchaseId.value = value,
        validator: (_) => ctr.selectedPurchaseId.value == null
            ? 'Please select a purchase'.tr
            : null,
      );
    });
  }

  Widget _paymentTypeDropdown(bool busy) {
    return Obx(() {
      if (ctr.paymentTypeCtr.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return DropdownButtonFormField<int>(
        key: ValueKey('payment-type-${ctr.selectedPaymentTypeId.value}'),
        initialValue: ctr.selectedPaymentTypeId.value,
        decoration: _decoration('Select Payment Type'),
        items: ctr.paymentTypeCtr.paymentTypeList.map((paymentType) {
          return DropdownMenuItem<int>(
            value: int.tryParse(paymentType["id"].toString()),
            child: Text(paymentType["name"]?.toString() ?? ""),
          );
        }).toList(),
        onChanged: busy
            ? null
            : (value) => ctr.selectedPaymentTypeId.value = value,
        validator: (_) => ctr.selectedPaymentTypeId.value == null
            ? 'Please select a payment type'.tr
            : null,
      );
    });
  }

  Widget _currencyDropdown(bool busy) {
    return Obx(() {
      if (ctr.currencyCtr.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return DropdownButtonFormField<int>(
        key: ValueKey('currency-${ctr.selectedCurrencyId.value}'),
        initialValue: ctr.selectedCurrencyId.value,
        decoration: _decoration('Select Currency'),
        items: ctr.currencyCtr.currencyList.map((currency) {
          return DropdownMenuItem<int>(
            value: int.tryParse(currency["id"].toString()),
            child: Text(currency["name"]?.toString() ?? ""),
          );
        }).toList(),
        onChanged: busy
            ? null
            : (value) => ctr.selectedCurrencyId.value = value,
        validator: (_) => ctr.selectedCurrencyId.value == null
            ? 'Please select a currency'.tr
            : null,
      );
    });
  }
}
