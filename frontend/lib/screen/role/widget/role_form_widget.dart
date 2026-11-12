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
    return Obx(
      () => PopScope(
        canPop: !ctr.isLoading.value,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 28,
          ),
          child: SingleChildScrollView(
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
                  TextFormField(
                    controller: ctr.roleNameController,
                    decoration: InputDecoration(
                      labelText: 'Role Name'.tr,
                      hintText: 'Enter Role Name'.tr,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter role name'.tr
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: ctr.roleDescriptionController,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Description'.tr,
                      hintText: 'Enter Description'.tr,
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
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
    );
  }
}
