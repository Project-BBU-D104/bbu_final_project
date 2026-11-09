import 'package:flutter/material.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/widget/dailog_select_language_widget.dart';
import 'package:get/get.dart';

class SettingWidget extends StatelessWidget {
  SettingWidget({super.key});
  final themeController = Get.isRegistered<ThemeController>()
      ? Get.find<ThemeController>()
      : Get.put(ThemeController());

  @override
  Widget build(BuildContext context) => HomeSectionCard(
    title: 'App Preferences',
    child: Column(
      children: [
        Row(
          children: [
            const ExcludeSemantics(child: Icon(Icons.dark_mode_outlined)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Dark Mode'.tr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 12),
            Obx(
              () => Semantics(
                label: 'Dark Mode'.tr,
                child: Switch(
                  value: themeController.isDark.value,
                  onChanged: (_) => themeController.toggleTheme(),
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 32),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => Get.dialog(const DialogSelectLanguageWidget()),
          child: Row(
            children: [
              const ExcludeSemantics(child: Icon(Icons.language_outlined)),
              const SizedBox(width: 16),
              Expanded(child: Text('Language'.tr)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ],
    ),
  );
}
