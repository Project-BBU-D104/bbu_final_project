import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/screen/profile/widget/profile_form_layout.dart';
import 'package:frontend/ui/app_form.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:get/get.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key});
  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  final ctr = Get.find<ProfileController>();
  final _keys = List.generate(3, (_) => GlobalKey<FormFieldState<String>>());
  final _focus = List.generate(3, (_) => FocusNode());
  final _hidden = [true, true, true];

  @override
  void dispose() {
    for (final node in _focus) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (ctr.isSaving.value) return;
    if (!(ctr.passwordFormKey.currentState?.validate() ?? false)) {
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
    await ctr.onChangePassword(context);
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final saving = ctr.isSaving.value;
    final controllers = [
      ctr.currentPasswordCtrl,
      ctr.newPasswordCtrl,
      ctr.confirmPasswordCtrl,
    ];
    const labels = ['Current Password', 'New Password', 'Confirm New Password'];
    return ProfileFormLayout(
      title: 'Change Password',
      subtitle: 'Choose a new password for your account.',
      formKey: ctr.passwordFormKey,
      saving: saving,
      onSubmit: _submit,
      saveLabel: 'Update Password',
      child: AutofillGroup(
        child: AppFormSection(
          title: 'Password',
          children: [
            Text(
              'Password must be at least 8 characters'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < 3; i++) ...[
              AppFormField(
                label: labels[i],
                controller: controllers[i],
                fieldKey: _keys[i],
                focusNode: _focus[i],
                enabled: !saving,
                obscureText: _hidden[i],
                trimValue: false,
                maxLines: 1,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: [
                  i == 0 ? AutofillHints.password : AutofillHints.newPassword,
                ],
                textInputAction: i == 2
                    ? TextInputAction.done
                    : TextInputAction.next,
                onFieldSubmitted: (_) {
                  if (saving) return;
                  if (i == 2) {
                    _submit();
                  } else {
                    _focus[i + 1].requestFocus();
                  }
                },
                suffix: IconButton(
                  tooltip: (_hidden[i] ? 'Show password' : 'Hide password').tr,
                  onPressed: saving
                      ? null
                      : () => setState(() => _hidden[i] = !_hidden[i]),
                  icon: Icon(
                    _hidden[i]
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (value) {
                  if (i == 0) {
                    return (value?.isEmpty ?? true)
                        ? 'Current password is required'.tr
                        : null;
                  }
                  if (i == 1) {
                    return (value?.length ?? 0) < 8
                        ? 'Password must be at least 8 characters'.tr
                        : null;
                  }
                  return value != ctr.newPasswordCtrl.text
                      ? 'Passwords do not match'.tr
                      : null;
                },
              ),
              if (i < 2) const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  });
}
