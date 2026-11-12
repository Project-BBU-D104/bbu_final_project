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

  InputDecoration _decoration(
    BuildContext context,
    String label, {
    String? hint,
    Widget? suffix,
    bool alignLabel = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return InputDecoration(
      labelText: label.tr,
      hintText: hint?.tr,
      suffixIcon: suffix,
      alignLabelWithHint: alignLabel,
      filled: true,
      fillColor: Color.alphaBlend(
        colors.onSurface.withValues(alpha: 0.025),
        theme.cardColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.onSurface.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
  }

  Widget _heading(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        header: true,
        child: Text(
          text.tr,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.payments_outlined,
                              color: theme.brightness == Brightness.light
                                  ? colors.primaryContainer
                                  : colors.primary,
                              size: 22,
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
                            tooltip: 'Close'.tr,
                            onPressed: busy
                                ? null
                                : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 20),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Divider(
                          height: 1,
                          color: colors.onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      _heading(context, 'Payment details'),
                      if (editing) ...[
                        ..._readOnlyIdentity(context),
                        const SizedBox(height: 20),
                      ] else ...[
                        _purchaseDropdown(context, busy),
                        const SizedBox(height: 20),
                      ],
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          spacing: 16,
                          runSpacing: 20,
                          children: [
                            for (final field in [
                              _paymentTypeDropdown(context, busy),
                              _currencyDropdown(context, busy),
                            ])
                              SizedBox(
                                width: constraints.maxWidth >= 560
                                    ? (constraints.maxWidth - 16) / 2
                                    : constraints.maxWidth,
                                child: field,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: ctr.amountCtrl,
                        enabled: !busy,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _decoration(
                          context,
                          'Amount',
                          hint: 'Enter Amount',
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
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: busy ? null : () => _pickDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: _decoration(
                            context,
                            'Payment Date',
                            suffix: Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          child: Text(
                            DateFormat(
                              'yyyy-MM-dd',
                            ).format(ctr.purchaseDate.value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: ctr.noteCtrl,
                        enabled: !busy,
                        minLines: 2,
                        maxLines: 4,
                        decoration: _decoration(
                          context,
                          'Note',
                          hint: 'Enter Note',
                          alignLabel: true,
                        ),
                      ),
                      if (error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              error,
                              key: const Key('purchase-payment-form-error'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.error,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Divider(
                          height: 1,
                          color: colors.onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(100, 48),
                              side: BorderSide(
                                color: colors.onSurface.withValues(alpha: 0.12),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                              minimumSize: const Size(112, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: busy
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Saving...'.tr),
                                    ],
                                  )
                                : Text((editing ? 'Update' : 'Save').tr),
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

  List<Widget> _readOnlyIdentity(BuildContext context) {
    final purchase = ctr.originalPayment?['purchase'];

    return [
      InputDecorator(
        decoration: _decoration(context, 'Purchase'),
        child: Text(
          "${purchase?['invoice_no'] ?? ''} - Due: ${purchase?['due_amount'] ?? ''}",
        ),
      ),
      const SizedBox(height: 20),
      InputDecorator(
        decoration: _decoration(context, 'Payment No'),
        child: Text(ctr.paymentNoCtrl.text),
      ),
    ];
  }

  Widget _purchaseDropdown(BuildContext context, bool busy) {
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
        decoration: _decoration(context, 'Select Purchase'),
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

  Widget _paymentTypeDropdown(BuildContext context, bool busy) {
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
        decoration: _decoration(context, 'Select Payment Type'),
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

  Widget _currencyDropdown(BuildContext context, bool busy) {
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
        decoration: _decoration(context, 'Select Currency'),
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
