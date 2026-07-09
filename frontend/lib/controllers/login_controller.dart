import 'package:flutter/material.dart';
import 'package:frontend/global.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController(text: "sabrey");
  final passwordController = TextEditingController(text:"123456");

  final authService = AuthService();

  final obscurePassword = true.obs;
  final isLoading = false.obs;

  void togglePassword() {
    obscurePassword.toggle();
  }

  Future<void> onLogin() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Username and password are required",
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await authService.login(
        name: usernameController.text.trim(),
        password: passwordController.text,
      );

      await storage.lastUserLoginWrite(
        data: {
          "token": response["access_token"],
          "user": response["user"],
        },
      );

      Get.offAllNamed("/home");
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}