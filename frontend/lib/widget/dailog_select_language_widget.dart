import 'package:flutter/material.dart';
import 'package:frontend/controllers/language_controller.dart';
import 'package:get/get.dart';

class DialogSelectLanguageWidget extends StatelessWidget {
  const DialogSelectLanguageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LanguageController>();
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_outlined,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 16),
              Text(
                'Select Language'.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your preferred language'.tr,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              for (final language in [
                (code: 'km', name: 'ខ្មែរ'),
                (code: 'en', name: 'English'),
              ]) ...[
                Obx(
                  () => Semantics(
                    selected:
                        controller.locale.value.languageCode == language.code,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        padding: const EdgeInsets.all(16),
                      ),
                      onPressed: () {
                        controller.changeLanguage(language.code);
                        Get.back();
                      },
                      child: Row(
                        children: [
                          Expanded(child: Text(language.name)),
                          if (controller.locale.value.languageCode ==
                              language.code)
                            const Icon(Icons.check),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
