import 'package:flutter/material.dart';
import 'package:frontend/controllers/login_controller.dart';
import 'package:get/get.dart';

class InputLoginWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
    bool obscureText = false;
  VoidCallback? onTogglePassword;
  InputLoginWidget({super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.onTogglePassword,});

  final LoginController controllers = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
    ),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: Colors.black26,
          size: 20,
        ),
        suffixIcon: onTogglePassword != null
            ? IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black45,
                ),
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
      ),
    ),
  );
  }
}