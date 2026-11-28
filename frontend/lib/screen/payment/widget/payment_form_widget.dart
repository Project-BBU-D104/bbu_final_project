import 'package:flutter/material.dart';
import 'package:frontend/controllers/payment_controller.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/screen/sale/sale_presentation.dart';
import 'package:get/get.dart';

class PaymentFormWidget extends StatefulWidget {
  const PaymentFormWidget({super.key});
  @override
  State<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final ctr = Get.find<PaymentController>();
  final _saleKey = GlobalKey<FormFieldState<int>>();
  final _amountKey = GlobalKey<FormFieldState<String>>();
  final _methodKey = GlobalKey<FormFieldState<String>>();
  final _referenceKey = GlobalKey<FormFieldState<String>>();
  final _saleFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _methodFocus = FocusNode();
  final _referenceFocus = FocusNode();
  List<({String label, GlobalKey key, FocusNode focus})> _errors = [];

  @override
  void dispose() {
    for (final node in [
      _saleFocus,
      _amountFocus,
      _methodFocus,
      _referenceFocus,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _focusError(
    ({String label, GlobalKey key, FocusNode focus}) error,
  ) async {
    error.focus.requestFocus();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final fieldContext = error.key.currentContext;
    if (fieldContext != null && fieldContext.mounted) {
      await Scrollable.ensureVisible(fieldContext);
    }
  }

  Future<void> _submit() async {
    if (ctr.isSaving.value) return;
    if (!(ctr.formKey.currentState?.validate() ?? false)) {
      final fields = [
        if (!ctr.isEditing)
          (label: 'Select Sale', key: _saleKey, focus: _saleFocus),
        (label: 'Amount', key: _amountKey, focus: _amountFocus),
        (label: 'Payment Method', key: _methodKey, focus: _methodFocus),
        (label: 'Reference No', key: _referenceKey, focus: _referenceFocus),
      ];
      final invalid = fields.where((field) {
        final state = field.key.currentState;
        return state?.hasError ?? false;
      }).toList();
      setState(() => _errors = invalid);
      if (invalid.isNotEmpty) await _focusError(invalid.first);
      return;
    }
    setState(() => _errors = []);
    FocusScope.of(context).unfocus();
    await ctr.onSavePayment(context);
  }

  Future<void> _pickDate() async {
    final first = DateTime(2020), last = DateTime(2100, 12, 31);
    final draft = ctr.paymentDate.value;
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.isBefore(first)
          ? first
          : draft.isAfter(last)
          ? last
          : draft,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null && mounted && !ctr.isSaving.value) {
      ctr.pickPaymentDate(picked);
    }
  }

  Widget _pair(Widget first, Widget second) => LayoutBuilder(
    builder: (context, bounds) {
      final largeText =
          MediaQuery.textScalerOf(context).scale(
            Theme.of(context).textTheme.bodyMedium?.fontSize ?? AppSpacing.lg,
          ) >
          AppTokens.tableMaxScaledBodySize;
      if (bounds.maxWidth >= AppTokens.bpFormPair && !largeText) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: second),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          first,
          const SizedBox(height: AppSpacing.lg),
          second,
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) => Obx(() {
    final busy = ctr.isSaving.value;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final verticalPadding =
        keyboard > 0 &&
            MediaQuery.sizeOf(context).height - keyboard <
                3 * AppTokens.controlHeight
        ? AppSpacing.sm
        : AppSpacing.lg;
    return PopScope(
      canPop: !busy,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: verticalPadding,
            bottom: keyboard + verticalPadding,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: ctr.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFormSection(
                    title: ctr.isEditing ? 'Edit Payment' : 'Add Payment',
                    children: [
                      if (ctr.formError.value.isNotEmpty)
                        Semantics(
                          liveRegion: true,
                          child: Text(ctr.formError.value.tr),
                        ),
                      if (_errors.length > 1)
                        Semantics(
                          liveRegion: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Please correct the highlighted fields.'.tr),
                              Wrap(
                                children: [
                                  for (final error in _errors)
                                    TextButton(
                                      onPressed: busy
                                          ? null
                                          : () => _focusError(error),
                                      child: Text(error.label.tr),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (ctr.isEditing)
                        InputDecorator(
                          decoration: InputDecoration(labelText: 'Sale'.tr),
                          child: Text(
                            saleText(
                              saleMap(
                                ctr.originalPayment?['sale'],
                              )['invoice_no'],
                            ),
                          ),
                        )
                      else ...[
                        if (ctr.salesWithDue.isEmpty)
                          Text('No sale with outstanding balance'.tr),
                        DropdownButtonFormField<int>(
                          key: _saleKey,
                          focusNode: _saleFocus,
                          initialValue: ctr.selectedSaleId.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Select Sale'.tr,
                          ),
                          errorBuilder: (context, error) => Text(error),
                          items: [
                            for (final sale in ctr.salesWithDue)
                              DropdownMenuItem(
                                value: int.tryParse(sale['id'].toString()),
                                child: Text(
                                  '${saleText(sale['invoice_no'])} (${'Due'.tr}: ${formatSaleAmount(sale['due_amount'], currency: saleCurrency(sale))})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: busy
                              ? null
                              : (value) => ctr.selectedSaleId.value = value,
                          validator: (_) => ctr.selectedSaleId.value == null
                              ? 'Please select a sale'.tr
                              : null,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      _pair(
                        AppFormField(
                          fieldKey: _amountKey,
                          focusNode: _amountFocus,
                          label: 'Amount',
                          controller: ctr.amountCtrl,
                          enabled: !busy,
                          wrapErrors: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');
                            if (amount == null ||
                                !amount.isFinite ||
                                amount <= 0) {
                              return 'Enter a valid amount'.tr;
                            }
                            if (!ctr.maxAmount.isFinite ||
                                amount > ctr.maxAmount) {
                              return 'Amount cannot exceed sale due'.tr;
                            }
                            return null;
                          },
                        ),
                        AppFormField(
                          fieldKey: _methodKey,
                          focusNode: _methodFocus,
                          label: 'Payment Method',
                          controller: ctr.methodCtrl,
                          enabled: !busy,
                          wrapErrors: true,
                          validator: (value) => (value?.isEmpty ?? true)
                              ? 'Payment method is required'.tr
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _pair(
                        AppFormField(
                          fieldKey: _referenceKey,
                          focusNode: _referenceFocus,
                          label: 'Reference No',
                          controller: ctr.referenceCtrl,
                          enabled: !busy,
                          wrapErrors: true,
                          validator: (value) => (value?.isEmpty ?? true)
                              ? 'Reference is required'.tr
                              : null,
                        ),
                        OutlinedButton(
                          onPressed: busy ? null : _pickDate,
                          child: Text(
                            '${'Payment Date'.tr}: ${formatSaleDate(ctr.paymentDate.value)}',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppFormField(
                        label: 'Note',
                        controller: ctr.noteCtrl,
                        enabled: !busy,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppFormActions(
                    saving: busy,
                    saveLabel: ctr.isEditing ? 'Update' : 'Save',
                    onCancel: () => Navigator.pop(context),
                    onSave: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  });
}
