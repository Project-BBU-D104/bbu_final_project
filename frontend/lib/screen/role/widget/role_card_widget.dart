import 'package:flutter/material.dart';
import 'package:frontend/widget/status_widget.dart';

class RoleCardWidget extends StatelessWidget {
  const RoleCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Admin",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                StatusWidget(
                  text: "Active",
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// Description
            const Text(
              "Responsible for overall inventory accuracy, staff scheduling, and shipping/receiving oversight.",
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 14),

            /// Footer
            Row(
              children: const [
                Icon(Icons.verified_user, size: 16, color: Colors.black45),
                SizedBox(width: 6),
                Text(
                  "System Role",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}