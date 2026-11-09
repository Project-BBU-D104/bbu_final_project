import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:get/get.dart';

class CardProfileWidget extends StatelessWidget {
  CardProfileWidget({super.key});
  final ctr = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return HomeSectionCard(
      child: Obx(
        () => Column(
          children: [
            ExcludeSemantics(
              child: ClipOval(
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: ColoredBox(
                    color: colors.primary.withValues(alpha: 0.1),
                    child: ctr.photo.value.isEmpty
                        ? Icon(
                            Icons.person_outline,
                            size: 40,
                            color: colors.primary,
                          )
                        : Image.network(
                            ctr.photo.value,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.person_outline,
                              size: 40,
                              color: colors.primary,
                            ),
                            frameBuilder: (_, child, frame, synchronous) =>
                                synchronous || frame != null
                                ? child
                                : Icon(
                                    Icons.person_outline,
                                    size: 40,
                                    color: colors.primary,
                                  ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              ctr.username.value,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                ctr.role.value.tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
