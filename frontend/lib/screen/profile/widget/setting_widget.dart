import 'package:flutter/material.dart';

class SettingWidget extends StatelessWidget {
  const SettingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.settings_outlined),
                SizedBox(width: 10,),
                Text("App Preferences", style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            Divider(),
            cardInfo(
              active: false,
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
            ),
            SizedBox(height: 5,),
            cardInfo(
              icon: Icons.language_outlined,
              title: "Language",
            ),
            SizedBox(height: 5,),
            cardInfo(
              active: true,
              icon: Icons.lock_outlined,
              title: "Push Notifications",
            ),
          ],
        ),
      )
    );
  }
}

Widget cardInfo({
  required IconData icon,
  required String title,

  bool? active,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: Row(
      children: [
        Icon(icon),
        SizedBox(width: 10,),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (active != null)
          Switch(
            value: active,
            onChanged: (value) {},
          ),

        // Show arrow when active is null
        if (active == null)
          const Icon(Icons.chevron_right),
      ],
    ),
  );
}