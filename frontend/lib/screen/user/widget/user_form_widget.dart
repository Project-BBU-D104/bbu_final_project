import 'package:flutter/material.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/image_upload_widget.dart';
import 'package:get/get.dart';

class UserFormWidget extends StatelessWidget {
  UserFormWidget({super.key, this.userId});

  final int? userId;
  final UserController ctr = Get.find<UserController>();
  final RoleController roleCtr = Get.put(RoleController());

  bool get isEdit => userId != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final saving = ctr.isLoading.value;
      return PopScope(
        canPop: !saving,
        child: Material(
          color: theme.cardColor,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Form(
                  key: ctr.key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _header(context),
                      const Divider(height: AppSpacing.xxl),
                      AppFormSection(
                        title: 'Account details',
                        children: [
                          ImageUploadWidget(
                            bucket: 'user',
                            folder: 'users',
                            imageUrl: ctr.userPhotoController.text,
                            onUploaded: (url) =>
                                ctr.userPhotoController.text = url,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppFormField(
                            label: 'Username',
                            controller: ctr.userNameController,
                            hint: 'Enter Username',
                            enabled: !saving,
                            maxLines: 1,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please enter username'.tr
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _pair(
                            AppFormField(
                              label: 'Email',
                              controller: ctr.userEmailController,
                              hint: 'Enter Email',
                              keyboardType: TextInputType.emailAddress,
                              enabled: !saving,
                              maxLines: 1,
                            ),
                            AppFormField(
                              label: 'Phone Number',
                              controller: ctr.userPhoneController,
                              hint: 'Enter Phone Number',
                              keyboardType: TextInputType.phone,
                              enabled: !saving,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppFormField(
                            label: 'Password',
                            controller: ctr.userPasswordController,
                            hint: 'Enter Password',
                            obscureText: true,
                            enabled: !saving,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppFormSection(
                        title: 'Access',
                        children: [
                          _pair(_roleField(), _configurationField()),
                          Obx(
                            () => CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: ctr.isChecked.value,
                              onChanged: ctr.isLoading.value
                                  ? null
                                  : (value) =>
                                        ctr.isChecked.value = value ?? false,
                              title: Text('Disable User'.tr),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppFormActions(
                        saving: saving,
                        saveLabel: isEdit ? 'Update' : 'Save',
                        onCancel: () => Navigator.of(context).pop(),
                        onSave: () => _submit(context),
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

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            isEdit ? 'Edit User'.tr : 'Add User'.tr,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          tooltip: 'Close'.tr,
          onPressed: ctr.isLoading.value ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _pair(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: [
          for (final field in [first, second])
            SizedBox(
              width: constraints.maxWidth >= AppTokens.bpFormPair
                  ? (constraints.maxWidth - AppSpacing.lg) / 2
                  : constraints.maxWidth,
              child: field,
            ),
        ],
      ),
    );
  }

  Widget _roleField() {
    return Obx(
      () => DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue:
            roleCtr.roleList.any(
              (role) => role['id'].toString() == ctr.selectedRole.value,
            )
            ? ctr.selectedRole.value
            : null,
        decoration: InputDecoration(
          labelText: 'Role'.tr,
          hintText: 'Select Role'.tr,
        ),
        items: roleCtr.roleList
            .map(
              (role) => DropdownMenuItem<String>(
                value: role['id'].toString(),
                child: Text(role['name']?.toString() ?? '-'),
              ),
            )
            .toList(),
        onChanged: ctr.isLoading.value
            ? null
            : (value) => ctr.selectedRole.value = value,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please select a role'.tr : null,
      ),
    );
  }

  Widget _configurationField() {
    return Obx(
      () => DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue:
            ctr.systemConfigurationCtr.systemConfigurationList.any(
              (configuration) =>
                  configuration['id'].toString() ==
                  ctr.selectedSystemConfiguration.value,
            )
            ? ctr.selectedSystemConfiguration.value
            : null,
        decoration: InputDecoration(
          labelText: 'System Configuration'.tr,
          hintText: 'Select System Configuration'.tr,
        ),
        items: ctr.systemConfigurationCtr.systemConfigurationList
            .map(
              (configuration) => DropdownMenuItem<String>(
                value: configuration['id'].toString(),
                child: Text(configuration['company_name']?.toString() ?? '-'),
              ),
            )
            .toList(),
        onChanged: ctr.isLoading.value
            ? null
            : (value) => ctr.selectedSystemConfiguration.value = value,
        validator: (value) => value == null || value.isEmpty
            ? 'Please select a system configuration'.tr
            : null,
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!(ctr.key.currentState?.validate() ?? false)) return;
    if (isEdit) {
      ctr.onUpdateUser(userId!, context);
    } else {
      ctr.onSaveUser(context);
    }
  }
}
