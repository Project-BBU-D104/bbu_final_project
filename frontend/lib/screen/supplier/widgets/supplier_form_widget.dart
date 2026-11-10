import 'package:flutter/material.dart';
import 'package:frontend/controllers/supplier_controller.dart';
import 'package:frontend/global.dart';
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
    InputDecoration decoration(
      String label, {
      Widget? suffix,
      String? hint,
    }) => InputDecoration(
      labelText: label.tr,
      hintText: hint?.tr,
      suffixIcon: suffix,
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
    Widget heading(String text) => Padding(
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
    return Obx(() {
      final busy = c.isSaving.value;
      final error = c.formError.value;
      Widget field(
        String label,
        TextEditingController text,
        GlobalKey<FormFieldState<String>> key,
        FocusNode focus,
        String message,
        TextInputType type,
      ) => TextFormField(
        key: key,
        focusNode: focus,
        controller: text,
        enabled: !busy,
        keyboardType: type,
        textInputAction: TextInputAction.next,
        decoration: decoration(label),
        validator: (value) => (value ?? '').trim().isEmpty ? message.tr : null,
      );
      final phone = field(
        'Phone Number',
        c.supplierPhoneNumberController,
        _phoneKey,
        _phoneFocus,
        'Phone number is required',
        TextInputType.phone,
      );
      final email = field(
        'Email',
        c.supplierEmailController,
        _emailKey,
        _emailFocus,
        'Email is required',
        TextInputType.emailAddress,
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
                              borderRadius: BorderRadius.circular(12),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Divider(
                          height: 1,
                          color: colors.onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      heading('Contact details'),
                      field(
                        'Supplier Name',
                        c.supplierNameController,
                        _nameKey,
                        _nameFocus,
                        'Supplier name is required',
                        TextInputType.name,
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          spacing: 16,
                          runSpacing: 20,
                          children: [
                            for (final item in [phone, email])
                              SizedBox(
                                width: constraints.maxWidth >= 560
                                    ? (constraints.maxWidth - 16) / 2
                                    : constraints.maxWidth,
                                child: item,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      heading('Location details'),
                      TextFormField(
                        controller: c.supplierMapController,
                        readOnly: true,
                        enabled: !busy && !_picking,
                        onTap: _pick,
                        decoration: decoration(
                          'Map',
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
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: c.supplierAddressController,
                        enabled: !busy,
                        minLines: 2,
                        maxLines: 4,
                        decoration: decoration('Address'),
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
                            onPressed: busy || _picking
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
                            onPressed: busy || _picking ? null : _submit,
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
                                : Text('Save'.tr),
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
