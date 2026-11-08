import 'package:flutter/material.dart';
import 'package:frontend/controllers/profile_controller.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardProfileWidget(),

                SizedBox(height: 10,),
                
                CardPersonalInfoWidget(),

                SizedBox(height: 10,),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => ctr.openEditProfile(context),
                        label: Text("Edit Profile".tr),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.lock_outline),
                        onPressed: () => ctr.openChangePassword(context),
                        label: Text("Change Password".tr),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10,),

                SettingWidget(),
                

                SizedBox(height: 10,),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    onPressed: (){
                      ctr.onLogoutPress();
                    },
                    label: Text("Logout".tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 251, 158, 151),
                      foregroundColor: const Color.fromARGB(255, 112, 39, 39),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ),
          )
        )
      ),
    );
  }
}