import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/screen/profile/widget/profile_form_layout.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});
  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  final ctr = Get.find<ProfileController>();
  final _keys = List.generate(4, (_) => GlobalKey<FormFieldState<String>>());
  final _focus = List.generate(4, (_) => FocusNode());
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    for (final node in _focus) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (ctr.isSaving.value) return;
    if (!(ctr.profileFormKey.currentState?.validate() ?? false)) {
      final first = _keys.indexWhere(
        (key) => key.currentState?.hasError ?? false,
      );
      if (first >= 0) {
        _focus[first].requestFocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Scrollable.ensureVisible(_keys[first].currentContext!);
        });
      }
      return;
    }
    FocusScope.of(context).unfocus();
    await ctr.onUpdateProfile(context);
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final saving = ctr.isSaving.value;
    final email = AppFormField(
      label: 'Email Address',
      controller: ctr.emailCtrl,
      fieldKey: _keys[2],
      focusNode: _focus[2],
      enabled: !saving,
      keyboardType: TextInputType.emailAddress,
      validator: (value) =>
          _emailPattern.hasMatch(value ?? '') ? null : 'Enter a valid email'.tr,
    );
    final phone = AppFormField(
      label: 'Phone Number',
      controller: ctr.phoneCtrl,
      fieldKey: _keys[3],
      focusNode: _focus[3],
      enabled: !saving,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
    );
    return ProfileFormLayout(
      title: 'Edit Profile',
      subtitle: 'Update your personal and contact information.',
      formKey: ctr.profileFormKey,
      saving: saving,
      onSubmit: _submit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFormSection(
            title: 'Personal information',
            children: [
              AppFormField(
                label: 'Full Name',
                controller: ctr.nameCtrl,
                fieldKey: _keys[0],
                focusNode: _focus[0],
                enabled: !saving,
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Name is required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppFormField(
                label: 'Photo URL',
                controller: ctr.photoCtrl,
                fieldKey: _keys[1],
                focusNode: _focus[1],
                enabled: !saving,
                keyboardType: TextInputType.url,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppFormSection(
            title: 'Contact details',
            children: [
              LayoutBuilder(
                builder: (context, constraints) =>
                    constraints.maxWidth >= AppTokens.bpFormPair
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: email),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: phone),
                        ],
                      )
                    : Column(
                        children: [
                          email,
                          const SizedBox(height: AppSpacing.lg),
                          phone,
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  });
}
