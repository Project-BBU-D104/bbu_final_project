import 'package:flutter/material.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/screen/user/widget/kpi_user_widget.dart';
import 'package:frontend/screen/user/widget/user_card_list_widget.dart';
import 'package:frontend/screen/user/widget/user_table_list_widget.dart';
import 'package:frontend/widget/custom_app_bar.dart';
import 'package:frontend/widget/search_widget.dart';
import 'package:get/get.dart';

class UserScreen extends StatelessWidget {
  UserScreen({super.key});

  final ctr = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(title: "User"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Users'.tr,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: ctr.getUserList,
                    icon: const Icon(Icons.refresh),
                    label: Text('Refresh'.tr),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => ctr.addUser(context),
                    icon: const Icon(Icons.add),
                    label: Text('Add User'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SearchWidget(title: "Search User...".tr),
              ),
              SizedBox(height: 12),
              Obx(() {
                final activeUsers = ctr.userList
                    .where((user) => user["is_active"] == true)
                    .length;
                final inactiveUsers = ctr.userList.length - activeUsers;

                return SizedBox(
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: KpiUserWidget(
                          title: "Active Users",
                          value: activeUsers,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: KpiUserWidget(
                          value: inactiveUsers,
                          title: "Inactive Users",
                        ),
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: 15),
              SizedBox(height: 15),

              Obx(
                () => ctr.isListLoading.value
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : ctr.loadError.value != null && ctr.userList.isEmpty
                    ? _errorState(context)
                    : ctr.loadError.value != null
                    ? Column(
                        children: [
                          Text(
                            'Unable to refresh users'.tr,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          TextButton.icon(
                            onPressed: ctr.getUserList,
                            icon: const Icon(Icons.refresh),
                            label: Text('Retry'.tr),
                          ),
                          _userResults(context),
                        ],
                      )
                    : ctr.userList.isEmpty
                    ? Center(child: Text("No User Found".tr))
                    : ctr.searchUserList.isEmpty
                    ? Center(child: Text("No User Found for search".tr))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final users = ctr.searchUserList.toList();
                          final isMobile =
                              constraints.maxWidth < 800 ||
                              MediaQuery.textScalerOf(context).scale(1) > 1.3;

                          if (isMobile) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: users.length,
                              itemBuilder: (context, index) =>
                                  UserCardListWidget(user: users[index]),
                            );
                          }

                          return UserTableListWidget(users: users);
                        },
                      ),
              ),
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
            Text('Unable to load users'.tr),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: ctr.getUserList,
              icon: const Icon(Icons.refresh),
              label: Text('Retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userResults(BuildContext context) {
    final users = ctr.searchUserList.toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) =>
                UserCardListWidget(user: users[index]),
          );
        }
        return UserTableListWidget(users: users);
      },
    );
  }
}
