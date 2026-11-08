import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
import 'package:get/get.dart';

class CardProfileWidget extends StatelessWidget {

  CardProfileWidget({super.key});
    final ctr = Get.find<ProfileController>(); 

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(  
        margin: const EdgeInsets.only(bottom: 10),
        color: Theme.of(context).cardColor,
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Obx(
                  () => CircleAvatar(
                    radius: 40,
                    backgroundImage: ctr.photo.value.isNotEmpty
                        ? NetworkImage(ctr.photo.value)
                        : null,
                    onBackgroundImageError:
                        ctr.photo.value.isNotEmpty ? (_, _) {} : null,
                    child: ctr.photo.value.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 5,),
                Obx(()=> Text(
                    ctr.username.value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23,   
                    ),
                  ),
                ),
                // Text(ctr.role.value, style: TextStyle(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 20,   
                //   ),),

                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ctr.role.value,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}