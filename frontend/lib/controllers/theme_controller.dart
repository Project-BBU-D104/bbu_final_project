import 'package:flutter/material.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/global.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  ThemeController({IStorageService? storageService})
      : _storage = storageService ?? storage;

  final IStorageService _storage;

  final isDark = false.obs;

  @override
  void onInit() {
    super.onInit();

    final saved = _storage.readStorage<dynamic>(StorageKey.darkMode);
    isDark.value = saved is bool ? saved : false;
  }

  Future<void> toggleTheme() async {
    isDark.value = !isDark.value;

    Get.changeThemeMode(
      isDark.value ? ThemeMode.dark : ThemeMode.light,
    );

    await _storage.writeStorage(StorageKey.darkMode, isDark.value);
  }
}
