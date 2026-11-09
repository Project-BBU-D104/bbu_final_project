import 'package:flutter/material.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:frontend/widget/dailog_select_language_widget.dart';
import 'package:frontend/widget/info_card_widget.dart';
import 'package:get/get.dart';

class SettingWidget extends StatelessWidget {
  SettingWidget({super.key});

  final themeController = Get.isRegistered<ThemeController>()
      ? Get.find<ThemeController>()
      : Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.settings_outlined),
                SizedBox(width: 10,),
                Text("App Preferences".tr, style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            Divider(),
            Obx(
              () => InfoCardWidget(
                active: themeController.isDark.value,
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode".tr,
                onSwitch: (value) {
                  themeController.toggleTheme();
                },
              ),
            ),
            SizedBox(height: 5,),
            InfoCardWidget(
              icon: Icons.language_outlined,
              title: "Language".tr,
              onTap: () {
                Get.dialog(
                  const DialogSelectLanguageWidget(),
                );
              },
            ),
          ],
        ),
      )
    );
  }
}
