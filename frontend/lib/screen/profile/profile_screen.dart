import 'package:flutter/material.dart';
import 'package:frontend/screen/profile/widget/card_personal_info_widget.dart';
import 'package:frontend/screen/profile/widget/card_profile_widget.dart';
import 'package:frontend/screen/profile/widget/setting_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardProfileWidget(),
                CardPersonalInfoWidget(),
                SettingWidget(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  onPressed: (){},
                  label: Text("Logout",)
                )
              ],
            ),
          )
        )
      ),
    );
  }
}