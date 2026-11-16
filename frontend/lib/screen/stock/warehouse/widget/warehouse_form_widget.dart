import 'package:flutter/material.dart';
import 'package:frontend/controllers/warehouse_controller.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class WarehouseFormWidget extends StatefulWidget {
  const WarehouseFormWidget({super.key, this.warehouseId});
  final int? warehouseId;
  @override
  State<WarehouseFormWidget> createState() => _WarehouseFormWidgetState();
}

class _WarehouseFormWidgetState extends State<WarehouseFormWidget> {
  final _form = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _locationKey = GlobalKey<FormFieldState<String>>();
  final _nameFocus = FocusNode(), _locationFocus = FocusNode();
  late final c = Get.find<WarehouseController>();
  @override
  void dispose() {
    _nameFocus.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (c.isSaving.value) return;
    if (!_form.currentState!.validate()) {
      final nameInvalid = _nameKey.currentState?.hasError == true;
      final key = nameInvalid ? _nameKey : _locationKey;
      (nameInvalid ? _nameFocus : _locationFocus).requestFocus();
      await Scrollable.ensureVisible(key.currentContext!);
      return;
    }
    FocusScope.of(context).unfocus();
    if (widget.warehouseId == null) {
      await c.onSaveWarehouse(context);
    } else {
      await c.onUpdateWarehouse(context, widget.warehouseId!);
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final busy = c.isSaving.value;
    return PopScope(
      canPop: !busy,
      child: Material(
        color: Theme.of(context).cardColor,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.sizeOf(context).width < AppTokens.bpDesktop
                  ? MediaQuery.viewInsetsOf(context).bottom
                  : 0,
            ),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            (widget.warehouseId == null
                                    ? 'Add Warehouse'
                                    : 'Edit Warehouse')
                                .tr,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close'.tr,
                          onPressed: busy
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: AppFormSection(
                        title: 'Warehouse details',
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) => Wrap(
                              spacing: AppSpacing.lg,
                              runSpacing: AppSpacing.xl,
                              children: [
                                for (final field in [
                                  AppFormField(
                                    label: 'Warehouse Name',
                                    controller: c.warehouseNameController,
                                    fieldKey: _nameKey,
                                    focusNode: _nameFocus,
                                    enabled: !busy,
                                    wrapErrors: true,
                                    validator: (value) => value!.isEmpty
                                        ? 'Please enter warehouse name'.tr
                                        : null,
                                  ),
                                  AppFormField(
                                    label: 'Reference No',
                                    controller:
                                        c.warehouseReferenceNoController,
                                    enabled: !busy,
                                  ),
                                ])
                                  SizedBox(
                                    width:
                                        constraints.maxWidth >=
                                            AppTokens.bpFormPair
                                        ? (constraints.maxWidth -
                                                  AppSpacing.lg) /
                                              2
                                        : constraints.maxWidth,
                                    child: field,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppFormField(
                            label: 'Location',
                            controller: c.warehouseLocationController,
                            fieldKey: _locationKey,
                            focusNode: _locationFocus,
                            enabled: !busy,
                            wrapErrors: true,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter location'.tr
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppFormField(
                            label: 'Note',
                            controller: c.warehouseNoteController,
                            enabled: !busy,
                            minLines: 2,
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                          ),
                          if (c.formError.value.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.lg,
                              ),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(c.formError.value.tr),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                  if (busy) const LinearProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: AppFormActions(
                      // Keep the translated busy label wrapping at large text
                      // sizes; the shared spinner row has no flexible label.
                      saveLabel: busy ? 'Saving...' : 'Save',
                      onCancel: busy ? null : () => Navigator.of(context).pop(),
                      onSave: busy ? null : _submit,
                    ),
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
