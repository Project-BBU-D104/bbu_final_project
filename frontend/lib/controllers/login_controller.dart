import 'package:flutter/material.dart';
import 'package:frontend/global.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final rememberMe = false.obs;
  final obscurePassword = true.obs;
  
    void togglePassword() {
    obscurePassword.toggle();
  }

  void toggleRemember(bool? value) {
    rememberMe.value = value ?? false;
  }


  Future<void> onLogin() async{
    await storage.lastUserLoginWrite(
      data: {
         "": "",
      },
    );

     
    Get.toNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  
}