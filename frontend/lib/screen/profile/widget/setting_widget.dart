import 'package:flutter/material.dart';
import 'package:frontend/controllers/theme_controller.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:frontend/ui/app_tokens.dart';
import 'package:frontend/widget/dailog_select_language_widget.dart';
import 'package:get/get.dart';

class SettingWidget extends StatelessWidget {
  SettingWidget({super.key, this.onChangePassword});
  final VoidCallback? onChangePassword;
  final themeController = Get.isRegistered<ThemeController>()
      ? Get.find<ThemeController>()
      : Get.put(ThemeController());

  Widget _columnSetting({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) => Row(
    children: [
      Expanded(child: Text(label.tr)),
      const SizedBox(width: AppSpacing.md),
      Semantics(
        label: label.tr,
        child: DropdownButton<int>(
          key: ValueKey(label),
          value: value,
          items: [
            for (
              var count = ThemeController.minDirectoryColumns;
              count <= ThemeController.maxDirectoryColumns;
              count++
            )
              DropdownMenuItem(value: count, child: Text('$count')),
          ],
          onChanged: (count) {
            if (count != null) onChanged(count);
          },
        ),
      ),
    ],
  );

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
        const Divider(height: AppSpacing.xxl),
        Row(
          children: [
            const ExcludeSemantics(child: Icon(Icons.format_size)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Text('Font Size'.tr)),
            Obx(
              () => Text('${(themeController.fontScale.value * 100).round()}%'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Obx(
          () => Slider(
            value: themeController.fontScale.value,
            min: ThemeController.minFontScale,
            max: ThemeController.maxFontScale,
            divisions: 40,
            label: '${(themeController.fontScale.value * 100).round()}%',
            semanticFormatterCallback: (value) =>
                '${'Font Size'.tr}: ${(value * 100).round()}%',
            onChanged: themeController.setFontScale,
          ),
        ),
        if (MediaQuery.sizeOf(context).width >= AppTokens.bpPageGutter) ...[
          const Divider(height: AppSpacing.xxl),
          Obx(
            () => _columnSetting(
              label: 'Manage columns',
              value: themeController.manageColumns.value,
              onChanged: themeController.setManageColumns,
            ),
          ),
          Obx(
            () => _columnSetting(
              label: 'Report columns',
              value: themeController.reportColumns.value,
              onChanged: themeController.setReportColumns,
            ),
          ),
        ],
        const Divider(height: AppSpacing.xxl),
        TextButton(
          onPressed: onChangePassword,
          child: Row(
            children: [
              const ExcludeSemantics(child: Icon(Icons.lock_outline)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: Text('Change Password'.tr)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        const Divider(height: AppSpacing.xxl),
        TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text('About'.tr),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ePOS App',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Inventory Management'.tr),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Close'.tr),
                ),
              ],
            ),
          ),
          child: Row(
            children: [
              const ExcludeSemantics(child: Icon(Icons.info_outline)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: Text('About'.tr)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ],
    ),
  );
}
