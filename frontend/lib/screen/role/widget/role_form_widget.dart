import 'package:flutter/material.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class RoleFormWidget extends StatelessWidget {
  RoleFormWidget({super.key, this.roleId});

  final int? roleId;
  final RoleController ctr = Get.find<RoleController>();

  @override
  Widget build(BuildContext context) {
    final editing = roleId != null;
    final theme = Theme.of(context);
    return Obx(() {
      final saving = ctr.isLoading.value;
      void close() => Navigator.of(context).pop();

      return PopScope(
        canPop: !saving,
        child: Material(
          color: theme.cardColor,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
                MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
              ),
              child: Form(
                key: ctr.key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            editing ? 'Edit Role'.tr : 'Add Role'.tr,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close'.tr,
                          onPressed: saving ? null : close,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(height: AppSpacing.xxl),
                    AppFormSection(
                      title: 'Role details',
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final available = constraints.maxWidth;
                            final width = available >= AppTokens.bpFormPair
                                ? (available - AppSpacing.lg) / 2
                                : available;
                            return Wrap(
                              spacing: AppSpacing.lg,
                              runSpacing: AppSpacing.lg,
                              children: [
                                SizedBox(
                                  width: width,
                                  child: AppFormField(
                                    controller: ctr.roleNameController,
                                    label: 'Role Name',
                                    hint: 'Enter Role Name',
                                    enabled: !saving,
                                    maxLines: 1,
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'Please enter role name'.tr
                                        : null,
                                  ),
                                ),
                                SizedBox(
                                  width: width,
                                  child: InputDecorationTheme(
                                    data: theme.inputDecorationTheme.copyWith(
                                      alignLabelWithHint: true,
                                    ),
                                    child: AppFormField(
                                      controller: ctr.roleDescriptionController,
                                      label: 'Description',
                                      hint: 'Enter Description',
                                      enabled: !saving,
                                      minLines: 3,
                                      maxLines: 6,
                                      textInputAction: TextInputAction.newline,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: ctr.isActive.value,
                          onChanged: saving
                              ? null
                              : (value) => ctr.isActive.value = value ?? false,
                          title: Text('Status'.tr),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppFormActions(
                      saving: saving,
                      saveLabel: editing ? 'Update' : 'Save',
                      onCancel: close,
                      onSave: () {
                        if (!(ctr.key.currentState?.validate() ?? false)) {
                          return;
                        }
                        if (editing) {
                          ctr.updateRole(roleId!, context);
                        } else {
                          ctr.onSaveRole();
                        }
                      },
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
}
