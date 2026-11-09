import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:frontend/screen/home/widget/home_tab_layout.dart';
import 'package:get/get.dart';

class CardPersonalInfoWidget extends StatelessWidget {
  CardPersonalInfoWidget({super.key});
  final ctr = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) => HomeSectionCard(
    title: 'Personal information',
    child: Obx(() {
      final details = [
        (label: 'Full Name', value: ctr.username.value),
        (label: 'Email Address', value: ctr.email.value),
        if (ctr.phone.value.isNotEmpty)
          (label: 'Phone Number', value: ctr.phone.value),
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < details.length; i++) ...[
            if (i > 0) const Divider(height: 32),
            Text(
              details[i].label.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              details[i].value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ],
      );
    }),
  );
}
