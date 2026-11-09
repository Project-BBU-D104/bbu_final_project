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
        decoration: InputDecoration(
          labelText: label.tr,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => (value ?? '').trim().isEmpty ? message.tr : null,
      );
      final name = field(
        'Supplier Name',
        c.supplierNameController,
        _nameKey,
        _nameFocus,
        'Supplier name is required',
        TextInputType.name,
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
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
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
                          Expanded(
                            child: Text(
                              widget.title.tr,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close'.tr,
                            onPressed: busy || _picking
                                ? null
                                : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          spacing: 16,
                          runSpacing: 20,
                          children: [
                            for (final item in [name, phone, email])
                              SizedBox(
                                width: constraints.maxWidth < 640
                                    ? constraints.maxWidth
                                    : (constraints.maxWidth - 16) / 2,
                                child: item,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: c.supplierMapController,
                        readOnly: true,
                        enabled: !busy && !_picking,
                        onTap: _pick,
                        decoration: InputDecoration(
                          labelText: 'Map'.tr,
                          hintText: 'Pick Location'.tr,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: 'Pick Location'.tr,
                            onPressed: busy || _picking ? null : _pick,
                            icon: const Icon(Icons.location_on_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: c.supplierAddressController,
                        enabled: !busy,
                        minLines: 3,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'Address'.tr,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (widget.showStatus)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Active'.tr),
                          value: c.status.value,
                          onChanged: busy
                              ? null
                              : (value) => c.status.value = value ?? false,
                        ),
                      if (error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              error,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
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
                              minimumSize: const Size(96, 48),
                            ),
                            child: Text('Cancel'.tr),
                          ),
                          FilledButton(
                            onPressed: busy || _picking ? null : _submit,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(96, 48),
                            ),
                            child: busy
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
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
