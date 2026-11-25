import 'package:frontend/constants/enum.dart';
import 'package:frontend/global.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  ThemeController({IStorageService? storageService})
    : _storage = storageService ?? storage;

  final IStorageService _storage;

  final isDark = false.obs;
  static const minFontScale = 0.9;
  static const maxFontScale = 1.3;
  final fontScale = 1.0.obs;
  static const minDirectoryColumns = 2;
  static const maxDirectoryColumns = 5;
  final manageColumns = 3.obs;
  final reportColumns = 3.obs;

  @override
  void onInit() {
    super.onInit();

    final saved = _storage.readStorage<dynamic>(StorageKey.darkMode);
    isDark.value = saved is bool ? saved : false;
    final savedFontScale = _storage.readStorage<dynamic>(StorageKey.fontScale);
    final scale = savedFontScale is num ? savedFontScale.toDouble() : 1.0;
    fontScale.value = _validFontScale(scale) ? scale : 1.0;
    manageColumns.value = _readColumns(StorageKey.manageColumns);
    reportColumns.value = _readColumns(StorageKey.reportColumns);
  }

  Future<void> toggleTheme() async {
    isDark.value = !isDark.value;
    await _storage.writeStorage(StorageKey.darkMode, isDark.value);
  }

  Future<void> setFontScale(double scale) async {
    if (!_validFontScale(scale)) return;
    final rounded = (scale * 100).round() / 100;
    fontScale.value = rounded;
    await _storage.writeStorage(StorageKey.fontScale, rounded);
  }

  static bool _validFontScale(double scale) =>
      scale.isFinite && scale >= minFontScale && scale <= maxFontScale;

  int _readColumns(StorageKey key) {
    final value = _storage.readStorage<dynamic>(key);
    return value is int && _validColumns(value) ? value : 3;
  }

  static bool _validColumns(int value) =>
      value >= minDirectoryColumns && value <= maxDirectoryColumns;

  Future<void> setManageColumns(int value) async {
    if (!_validColumns(value)) return;
    manageColumns.value = value;
    await _storage.writeStorage(StorageKey.manageColumns, value);
  }

  Future<void> setReportColumns(int value) async {
    if (!_validColumns(value)) return;
    reportColumns.value = value;
    await _storage.writeStorage(StorageKey.reportColumns, value);
  }
}
