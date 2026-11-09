import 'package:flutter/material.dart';
import 'package:frontend/constants/constant.dart';
import 'package:frontend/controllers/login_controller.dart';
import 'package:frontend/screen/auth/widget/input_login_widget.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final LoginController controller = Get.isRegistered<LoginController>()
      ? Get.find<LoginController>()
      : Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final compact = constraints.maxWidth < 600;
            final form = Container(
              width: double.infinity,
              padding: EdgeInsets.all(compact ? 0 : 32),
              decoration: compact
                  ? null
                  : BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.outlineVariant),
                    ),
              child: _LoginForm(controller: controller, formKey: _formKey),
            );
            final content = Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  wide
                      ? 48
                      : compact
                      ? 20
                      : 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!wide) ...[
                        const _BrandIdentity(),
                        const SizedBox(height: 32),
                      ],
                      form,
                    ],
                  ),
                ),
              ),
            );
            if (!wide) return content;
            return Row(
              children: [
                Expanded(
                  flex: 5,
                  child: ColoredBox(
                    color: colors.primaryContainer,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        child: _BrandIdentity(panel: true),
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 6, child: content),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.controller, required this.formKey});
  final LoginController controller;
  final GlobalKey<FormState> formKey;
  void _submit() {
    if (controller.isLoading.value) return;
    controller.submitted.value = true;
    if (formKey.currentState?.validate() != true) {
      (controller.usernameController.text.trim().isEmpty
              ? controller.usernameFocus
              : controller.passwordFocus)
          .requestFocus();
      return;
    }
    controller.onLogin();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AutofillGroup(
      onDisposeAction: AutofillContextAction.cancel,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back'.tr,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                height: 34 / 28,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to manage your inventory.'.tr,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Obx(
              () => InputLoginWidget(
                controller: controller.usernameController,
                focusNode: controller.usernameFocus,
                label: 'Username'.tr,
                hint: 'Enter your username'.tr,
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => controller.passwordFocus.requestFocus(),
                autofillHints: const [AutofillHints.username],
                autovalidateMode: controller.submitted.value
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Enter your username'.tr
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => InputLoginWidget(
                controller: controller.passwordController,
                focusNode: controller.passwordFocus,
                label: 'Password'.tr,
                hint: 'Enter your password'.tr,
                icon: Icons.lock_outline,
                obscureText: controller.obscurePassword.value,
                onTogglePassword: controller.togglePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                autovalidateMode: controller.submitted.value
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                validator: (value) =>
                    (value ?? '').isEmpty ? 'Enter your password'.tr : null,
                onSubmitted: (_) => _submit(),
              ),
            ),
            Obx(
              () => controller.errorMessage.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Semantics(
                        liveRegion: true,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExcludeSemantics(
                                child: Icon(
                                  Icons.error_outline,
                                  color: colors.onErrorContainer,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value.tr,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colors.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final busy = controller.isLoading.value;
              return Semantics(
                liveRegion: true,
                child: FilledButton(
                  onPressed: busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    minimumSize: const Size(48, 52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: theme.textTheme.titleMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (busy) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Text(
                          (busy ? 'Signing in…' : 'Sign in').tr,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            Text(
              'Need access? Contact your administrator.'.tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandIdentity extends StatelessWidget {
  const _BrandIdentity({this.panel = false});
  final bool panel;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = panel ? colors.onPrimaryContainer : colors.onSurface;
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'InventoryFlow',
          style: theme.textTheme.titleLarge?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inventory Management'.tr,
          style: theme.textTheme.bodyLarge?.copyWith(color: foreground),
        ),
      ],
    );
    final logo = ClipOval(
      child: Image.asset(
        logoPath,
        width: panel ? 80 : 56,
        height: panel ? 80 : 56,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
    );
    if (!panel) {
      return Row(
        children: [
          logo,
          const SizedBox(width: 16),
          Expanded(child: identity),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        logo,
        const SizedBox(height: 32),
        identity,
        const SizedBox(height: 24),
        Text(
          'Manage stock, sales, and purchases in one place.'.tr,
          style: theme.textTheme.bodyLarge?.copyWith(color: foreground),
        ),
      ],
    );
  }
}
