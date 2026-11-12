import 'package:flutter/material.dart';
import 'package:frontend/controllers/role_controller.dart';
import 'package:frontend/screen/role/widget/role_card_widget.dart';
import 'package:frontend/screen/role/widget/role_table_widget.dart';
import 'package:frontend/widget/app_cached_image.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class RoleScreen extends StatelessWidget {
  RoleScreen({super.key});

  final ctr = Get.find<RoleController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(title: "Role"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Roles'.tr,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: ctr.getRoles,
                      icon: const Icon(Icons.refresh),
                      label: Text('Refresh'.tr),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => ctr.addRole(context),
                      icon: const Icon(Icons.add),
                      label: Text('Add Role'.tr),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SearchWidget(title: "Search Role"),
              ),

              Obx(() {
                if (ctr.isLoading.value) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (ctr.loadError.value != null && ctr.roleList.isNotEmpty) {
                  return Column(
                    children: [
                      Text(
                        'Unable to refresh roles'.tr,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      TextButton.icon(
                        onPressed: ctr.getRoles,
                        icon: const Icon(Icons.refresh),
                        label: Text('Retry'.tr),
                      ),
                      _roleResults(context),
                    ],
                  );
                }

                if (ctr.loadError.value != null) {
                  return _errorState(context);
                }

                if (ctr.roleList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppCachedImage(
                            assetPath: 'assets/images/empty.png',
                            width: 120,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            "No roles found",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (ctr.searchRoleList.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text(
                        "Search result not found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final roles = ctr.searchRoleList.toList();
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: roles.length,
                        itemBuilder: (context, index) =>
                            RoleCardWidget(role: roles[index]),
                      );
                    }

                    return RoleTableWidget(roles: roles);
                  },
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .55,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Unable to load roles'.tr),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: ctr.getRoles,
              icon: const Icon(Icons.refresh),
              label: Text('Retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleResults(BuildContext context) {
    final roles = ctr.searchRoleList.toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: roles.length,
            itemBuilder: (context, index) => RoleCardWidget(role: roles[index]),
          );
        }
        return RoleTableWidget(roles: roles);
      },
    );
  }
}
