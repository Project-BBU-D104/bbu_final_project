import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class SupplierFormWidget extends StatefulWidget {
  const SupplierFormWidget({
    super.key,
    required this.controller,
    required this.title,
    required this.onSubmit,
    this.showStatus = false,
  });
  final SupplierController controller;
  final String title;
  final Future<void> Function(BuildContext) onSubmit;
  final bool showStatus;
  @override
  State<SupplierFormWidget> createState() => _SupplierFormWidgetState();
}

class _SupplierFormWidgetState extends State<SupplierFormWidget> {
  bool _picking = false;
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _phoneKey = GlobalKey<FormFieldState<String>>();
  final _emailKey = GlobalKey<FormFieldState<String>>();

  Future<void> _pick() async {
    if (_picking || widget.controller.isSaving.value) return;
    setState(() => _picking = true);
    try {
      await openSupplierMap(context, widget.controller.supplierMapController);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _submit() async {
    if (widget.controller.isSaving.value || _picking) return;
    if (!widget.controller.formKey.currentState!.validate()) {
      for (final key in [_nameKey, _phoneKey, _emailKey]) {
        if (key.currentState?.hasError == true) {
          await Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 150),
          );
          if (mounted && key.currentContext != null) {
            FocusScope.of(context).requestFocus(_focusFor(key));
          }
          break;
        }
      }
      return;
    }
    FocusScope.of(context).unfocus();
    await widget.onSubmit(context);
  }

  final _nameFocus = FocusNode(),
      _phoneFocus = FocusNode(),
      _emailFocus = FocusNode();
  FocusNode _focusFor(GlobalKey<FormFieldState<String>> key) => key == _nameKey
      ? _nameFocus
      : key == _phoneKey
      ? _phoneFocus
      : _emailFocus;
  @override
  void dispose() {
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Obx(() {
      final busy = c.isSaving.value;
      final error = c.formError.value;
      final phone = AppFormField(
        fieldKey: _phoneKey,
        focusNode: _phoneFocus,
        controller: c.supplierPhoneNumberController,
        enabled: !busy,
        keyboardType: TextInputType.phone,
        label: 'Phone Number',
        validator: (value) => (value ?? '').isEmpty
            ? 'Phone number is required'.tr
            : null,
      );
      final email = AppFormField(
        fieldKey: _emailKey,
        focusNode: _emailFocus,
        controller: c.supplierEmailController,
        enabled: !busy,
        keyboardType: TextInputType.emailAddress,
        label: 'Email',
        validator: (value) =>
            (value ?? '').isEmpty ? 'Email is required'.tr : null,
      );
      return PopScope(
        canPop: !busy && !_picking,
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
                  key: c.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AppTokens.radiusControl,
                              ),
                            ),
                            child: Icon(
                              Icons.business_outlined,
                              color: theme.brightness == Brightness.light
                                  ? colors.primaryContainer
                                  : colors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.title.tr,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close'.tr,
                            onPressed: busy || _picking
                                ? null
                                : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 20),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(height: 1),
                      ),
                      AppFormSection(
                        title: 'Contact details',
                        children: [
                          AppFormField(
                            fieldKey: _nameKey,
                            focusNode: _nameFocus,
                            controller: c.supplierNameController,
                            enabled: !busy,
                            keyboardType: TextInputType.name,
                            label: 'Supplier Name',
                            validator: (value) => (value ?? '').isEmpty
                                ? 'Supplier name is required'.tr
                                : null,
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) => Wrap(
                              spacing: 16,
                              runSpacing: 20,
                              children: [
                                for (final item in [phone, email])
                                  SizedBox(
                                    width:
                                        constraints.maxWidth >=
                                            AppTokens.bpFormPair
                                        ? (constraints.maxWidth - 16) / 2
                                        : constraints.maxWidth,
                                    child: item,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                      AppFormSection(
                        title: 'Location details',
                        children: [
                          AppFormField(
                            controller: c.supplierMapController,
                            readOnly: true,
                            enabled: !busy && !_picking,
                            onTap: _pick,
                            label: 'Map',
                            hint: 'Pick Location',
                            suffix: IconButton(
                              tooltip: 'Pick Location'.tr,
                              onPressed: busy || _picking ? null : _pick,
                              icon: const Icon(
                                Icons.location_on_outlined,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppFormField(
                            controller: c.supplierAddressController,
                            enabled: !busy,
                            minLines: 2,
                            maxLines: 4,
                            label: 'Address',
                          ),
                        ],
                      ),
                      if (widget.showStatus)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Active'.tr,
                              style: theme.textTheme.bodyMedium,
                            ),
                            value: c.status.value,
                            onChanged: busy
                                ? null
                                : (value) => c.status.value = value,
                          ),
                        ),
                      if (error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              error,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.error,
                              ),
                            ),
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(height: 1),
                      ),
                      AppFormActions(
                        saving: busy,
                        onCancel: busy || _picking
                            ? null
                            : () => Navigator.of(context).pop(),
                        onSave: busy || _picking ? null : _submit,
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
