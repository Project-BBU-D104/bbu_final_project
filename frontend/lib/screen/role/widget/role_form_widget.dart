import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:get/get.dart';

class RoleFormWidget extends StatelessWidget {
  RoleFormWidget({super.key, this.roleId});

  final int? roleId;
  final RoleController ctr = Get.find<RoleController>();

  @override
  Widget build(BuildContext context) {
    final editing = roleId != null;
    final theme = Theme.of(context);
    return Obx(
      () => PopScope(
        canPop: !ctr.isLoading.value,
        child: Material(
          color: theme.cardColor,
          child: SafeArea(
            child: Center(
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
                    key: ctr.key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                editing ? 'Edit Role'.tr : 'Add Role'.tr,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close'.tr,
                              onPressed: ctr.isLoading.value
                                  ? null
                                  : () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) => Wrap(
                            spacing: 16,
                            runSpacing: 20,
                            children: [
                              for (final field in [
                                TextFormField(
                                  controller: ctr.roleNameController,
                                  decoration: _decoration(
                                    context,
                                    'Role Name'.tr,
                                    'Enter Role Name'.tr,
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                      ? 'Please enter role name'.tr
                                      : null,
                                ),
                                TextFormField(
                                  controller: ctr.roleDescriptionController,
                                  minLines: 3,
                                  maxLines: 6,
                                  decoration: _decoration(
                                    context,
                                    'Description'.tr,
                                    'Enter Description'.tr,
                                  ).copyWith(alignLabelWithHint: true),
                                ),
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
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: ctr.isActive.value,
                          onChanged: ctr.isLoading.value
                              ? null
                              : (value) => ctr.isActive.value = value ?? false,
                          title: Text('Status'.tr),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: ctr.isLoading.value
                                ? null
                                : () {
                                    if (!(ctr.key.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }
                                    if (editing) {
                                      ctr.updateRole(roleId!, context);
                                    } else {
                                      ctr.onSaveRole();
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: successColor,
                              foregroundColor: titleColor,
                            ),
                            child: Text(
                              editing ? 'Update'.tr : 'Save'.tr,
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(BuildContext context, String label, String hint) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Color.alphaBlend(
        colors.onSurface.withValues(alpha: 0.025),
        theme.cardColor,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
}
