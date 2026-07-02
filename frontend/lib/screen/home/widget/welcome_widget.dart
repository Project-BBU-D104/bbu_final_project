import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF7C3AED),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 27,
              backgroundImage: const NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRu3-_TbUInL975rAfMjR83kQAjePhVRRJFfw&s',
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good Morning 👋".tr,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Lim Sabrey",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Welcome Back".tr,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}