import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/controllers/user_controller.dart';
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
                        _header(context),
                        _section(
                          title: 'Account details'.tr,
                          children: [
                            ImageUploadWidget(
                              bucket: 'user',
                              folder: 'users',
                              imageUrl: ctr.userPhotoController.text,
                              onUploaded: (url) =>
                                  ctr.userPhotoController.text = url,
                            ),
                            _field(
                              context: context,
                              label: 'Username'.tr,
                              controller: ctr.userNameController,
                              hint: 'Enter Username'.tr,
                              required: true,
                            ),
                            LayoutBuilder(
                              builder: (context, constraints) => Wrap(
                                spacing: 16,
                                runSpacing: 20,
                                children: [
                                  for (final field in [
                                    _field(
                                      context: context,
                                      label: 'Email'.tr,
                                      controller: ctr.userEmailController,
                                      hint: 'Enter Email'.tr,
                                      keyboardType: TextInputType.emailAddress,
                                      bottomPadding: false,
                                    ),
                                    _field(
                                      context: context,
                                      label: 'Phone Number'.tr,
                                      controller: ctr.userPhoneController,
                                      hint: 'Enter Phone Number'.tr,
                                      keyboardType: TextInputType.phone,
                                      bottomPadding: false,
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
                            _field(
                              context: context,
                              label: 'Password'.tr,
                              controller: ctr.userPasswordController,
                              hint: 'Enter Password'.tr,
                              obscureText: true,
                            ),
                          ],
                        ),
                        _section(
                          title: 'Access'.tr,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) => Wrap(
                                spacing: 16,
                                runSpacing: 20,
                                children: [
                                  for (final field in [
                                    _roleField(context),
                                    _configurationField(context),
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
                            Obx(
                              () => CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                value: ctr.isChecked.value,
                                onChanged: ctr.isLoading.value
                                    ? null
                                    : (value) =>
                                          ctr.isChecked.value = value ?? false,
                                title: Text('Disable User'.tr),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: ctr.isLoading.value
                                ? null
                                : () => _submit(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: successColor,
                              foregroundColor: titleColor,
                            ),
                            child: Text(
                              isEdit ? 'Update'.tr : 'Save'.tr,
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

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            isEdit ? 'Edit User'.tr : 'Add User'.tr,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
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

  Widget _section({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _field({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
    bool required = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    bool bottomPadding = true,
  }) {
    final field = TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: _decoration(context, label, hint),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? 'Please enter username'.tr
                : null
          : null,
    );
    return bottomPadding
        ? Padding(padding: const EdgeInsets.only(bottom: 12), child: field)
        : field;
  }

  Widget _roleField(BuildContext context) {
    return Obx(
      () => DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue:
            roleCtr.roleList.any(
              (role) => role['id'].toString() == ctr.selectedRole.value,
            )
            ? ctr.selectedRole.value
            : null,
        decoration: _decoration(context, 'Role'.tr, 'Select Role'.tr),
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

  Widget _configurationField(BuildContext context) {
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
        decoration: _decoration(
          context,
          'System Configuration'.tr,
          'Select System Configuration'.tr,
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
