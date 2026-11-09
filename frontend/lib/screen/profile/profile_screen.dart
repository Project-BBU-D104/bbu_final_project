import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/screen/profile/widget/card_personal_info_widget.dart';
import 'package:frontend/screen/profile/widget/card_profile_widget.dart';
import 'package:frontend/screen/profile/widget/setting_widget.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final ctr = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

  @override
  Widget build(BuildContext context) => SafeArea(
    child: HomeTabLayout(
      title: 'Profile',
      subtitle: 'Manage your account and make this workspace yours.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = CardProfileWidget();
          final access = HomeSectionCard(
            title: 'Account access',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Sign out of this workspace on this device.'.tr),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  onPressed: ctr.onLogoutPress,
                  label: Text('Logout'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardPersonalInfoWidget(),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => ctr.openEditProfile(context),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text('Edit Profile'.tr),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => ctr.openChangePassword(context),
                    icon: const Icon(Icons.lock_outline),
                    label: Text('Change Password'.tr),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SettingWidget(),
            ],
          );
          if (constraints.maxWidth < 900) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                const SizedBox(height: 24),
                details,
                const SizedBox(height: 24),
                access,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 300,
                child: Column(
                  children: [summary, const SizedBox(height: 24), access],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(child: details),
            ],
          );
        },
      ),
    ),
  );
}
