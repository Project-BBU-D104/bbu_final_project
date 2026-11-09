import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/global.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  LoginController({AuthService? authService, IStorageService? sessionStorage})
    : authService = authService ?? AuthService(),
      sessionStorage = sessionStorage ?? storage;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameFocus = FocusNode();
  final passwordFocus = FocusNode();
  final AuthService authService;
  final IStorageService sessionStorage;
  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final submitted = false.obs;

  void togglePassword() => obscurePassword.toggle();

  Future<void> onLogin() async {
    if (isLoading.value) return;
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await authService.login(
        name: usernameController.text.trim(),
        password: passwordController.text,
      );
      await sessionStorage.lastUserLoginWrite(
        data: {
          'token': response['access_token'],
          'token_type': response['token_type'],
          'user': response['user'],
        },
      );
      await sessionStorage.appStartUpWrite(route: '/home');
      TextInput.finishAutofillContext();
      Get.offAllNamed('/home');
    } on ApiException catch (error) {
      errorMessage.value = error.statusCode == 401 || error.statusCode == 403
          ? 'Username or password is incorrect.'
          : 'Unable to sign in. Please try again.';
    } on http.ClientException catch (_) {
      errorMessage.value =
          'Unable to connect. Check your connection and try again.';
    } on SocketException catch (_) {
      errorMessage.value =
          'Unable to connect. Check your connection and try again.';
    } on TimeoutException catch (_) {
      errorMessage.value =
          'Unable to connect. Check your connection and try again.';
    } catch (_) {
      errorMessage.value = 'Unable to sign in. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    usernameFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
