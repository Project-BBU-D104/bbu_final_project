import 'package:flutter/material.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/screen/home/desktop_app_shell.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/status_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserDetailCardWidget extends StatelessWidget {
  UserDetailCardWidget({super.key})
    : user = Get.arguments is Map
          ? Map<String, dynamic>.from(Get.arguments as Map)
          : <String, dynamic>{};

  final Map<String, dynamic> user;
  final ctr = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final desktop = DesktopAppShell.isVisible(context);
    final role = user['role'] is Map
        ? Map<String, dynamic>.from(user['role'] as Map)
        : <String, dynamic>{};
    final id = int.tryParse(user['id']?.toString() ?? '');
    final active = user['is_active'] == true;
    final created = DateTime.tryParse(user['created_at']?.toString() ?? '');

    Widget info(String label, String? value) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            (value ?? '').trim().isEmpty ? '-' : value!,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    final account = HomeSectionCard(
      title: 'Account details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: (user['photo']?.toString() ?? '').isNotEmpty
                    ? NetworkImage(user['photo'].toString())
                    : const AssetImage('assets/images/default_avatar.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user['name']?.toString().trim().isNotEmpty == true
                      ? user['name'].toString()
                      : '-',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusWidget(
                text: active ? 'Active'.tr : 'Inactive'.tr,
                color: active ? colors.primary : colors.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 24),
          info('Username', user['name']?.toString()),
          info('Email', user['email']?.toString()),
          info('Phone Number', user['phone']?.toString()),
          info('Role', role['name']?.toString()),
        ],
      ),
    );

    final system = HomeSectionCard(
      title: 'System details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          info('ID', user['id']?.toString()),
          info(
            'Created',
            created == null ? null : DateFormat('dd MMM yyyy').format(created),
          ),
          info(
            'System Configuration',
            user['system_configuration']?.toString(),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: desktop
          ? null
          : const CustomAppBar(title: 'User Detail', useTheme: true),
      body: user.isEmpty
          ? Center(child: Text('No user data found'.tr))
          : SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (desktop)
                          Row(
                            children: [
                              IconButton.outlined(
                                tooltip: 'Back'.tr,
                                onPressed: Get.back,
                                icon: const Icon(Icons.arrow_back),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'User Detail'.tr,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        if (desktop) const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) =>
                              constraints.maxWidth < 800
                              ? Column(
                                  children: [
                                    account,
                                    const SizedBox(height: 16),
                                    system,
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: account),
                                    const SizedBox(width: 16),
                                    Expanded(child: system),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: user.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: id == null
                          ? null
                          : () => ctr.deleteUser(id, context),
                      icon: const Icon(Icons.delete_outline),
                      label: Text('Delete'.tr),
                    ),
                    FilledButton.icon(
                      onPressed: id == null
                          ? null
                          : () => ctr.editUser(context, id),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text('Edit'.tr),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
