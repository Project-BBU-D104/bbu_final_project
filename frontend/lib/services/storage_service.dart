import 'package:frontend/constants/enum.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/utils/helper.dart';

final _box = GetStorage(".appsettings");
final _helper = Helper();

abstract class IStorageService {
  T? readStorage<T>(StorageKey key);
  Future<void> writeStorage(StorageKey key, dynamic value);
  Future<void> removeStorage(StorageKey key);
  Future<void> removeStorageMultiple(List<StorageKey> keys);
  //startup route
  Future<void> appStartUpWrite({required String route});
  String get appStartUpRead;

  //current user login
  Future<void> lastUserLoginWrite({required Map<String, dynamic> data});
  Future<void> lastUserLoginRemove();
  Map<String, dynamic> get lastUserLoginRead;
  String get currentUserRole;
  bool hasRole(String role);
}

class StorageService implements IStorageService {
  static late SharedPreferences _preferences;
  static Map<String, dynamic> _pending = {};

  static Future<void> loadPendingCheckouts() async {
    _preferences = await SharedPreferences.getInstance();
    final raw = _preferences.getString(StorageKey.pendingCheckouts.name);
    _pending = raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
  }

  ///method get storage value
  @override
  T? readStorage<T>(StorageKey key) {
    if (key == StorageKey.pendingCheckouts) return _pending as T;
    final vkey = key.toString().split('.').last; // Output: active
    if (_box.hasData(vkey)) {
      return _box.read<T>(vkey);
    }
    return null;
  }

  ///method write storage value
  @override
  Future<void> writeStorage(StorageKey key, dynamic value) async {
    final vkey = key.toString().split('.').last; // Output: active
    if (key == StorageKey.pendingCheckouts) {
      // GetStorage.write completes before its queued flush reaches the platform.
      if (!await _preferences.setString(key.name, jsonEncode(value))) {
        throw StateError('Unable to persist checkout');
      }
      _pending = Map<String, dynamic>.from(value);
      return;
    }
    await _box.write(vkey, value);
  }

  ///method remove storage key
  @override
  Future<void> removeStorage(StorageKey key) async {
    _removeStorage(key);
  }

  ///method remove multiple storage keys
  @override
  Future<void> removeStorageMultiple(List<StorageKey> keys) async {
    for (var k in keys) {
      await _removeStorage(k);
    }
  }

  ///method remove storage key
  Future<void> _removeStorage(StorageKey key) async {
    final vkey = key.toString().split('.').last; // Output: active
    _box.remove(vkey);
  }

  @override
  Future<void> appStartUpWrite({required String route}) async {
    await writeStorage(StorageKey.appStartUp, route);
  }

  @override
  String get appStartUpRead {
    String? route = readStorage<String>(StorageKey.appStartUp);
    return route ?? "";
  }

  //Last user login
  @override
  Future<void> lastUserLoginWrite({required Map<String, dynamic> data}) async {
    var encryptData = _helper.onEncrypted(jsonEncode(data));

    await writeStorage(StorageKey.lastUserLogin, encryptData);
  }

  @override
  Future<void> lastUserLoginRemove() async {
    await removeStorage(StorageKey.lastUserLogin);
  }

  @override
  Map<String, dynamic> get lastUserLoginRead {
    var data = readStorage<String>(StorageKey.lastUserLogin);
    if (data != null) {
      Map<String, dynamic> result = jsonDecode(_helper.onDecrypted(data));
      return result;
    }
    return {};
  }

  @override
  String get currentUserRole {
    final user = lastUserLoginRead['user'];
    if (user is Map) {
      return user['role']?.toString() ?? '';
    }
    return '';
  }

  @override
  bool hasRole(String role) =>
      currentUserRole.trim().toLowerCase() == role.trim().toLowerCase();
}
