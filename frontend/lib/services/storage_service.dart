import 'dart:convert';

import 'package:frontend/constants/enum.dart';
import 'package:frontend/utils/helper.dart';
import 'package:get_storage/get_storage.dart';

final _box = GetStorage(".appsettings");
final _helper = Helper();

abstract class IStorageService {
  T? readStorage<T>(StorageKey key);
  Future<void> writeStorage(StorageKey key, dynamic value);
  Future<void> removeStorage(StorageKey key);
  Future<void> removeStorageMultiple(List<StorageKey> keys);

  //current POS Profile
  Future<void> changeMenuLanguageWrite({required Map<String, dynamic> data});
  Future<void> changeMenuLanguageRemove();
  Map<String, dynamic> get changeMenuLanguageRead;
 
}

class StorageService implements IStorageService {
  ///method get storage value
  @override
  T? readStorage<T>(StorageKey key) {
    final vkey = key.toString().split('.').last; // Output: active
    if (_box.hasData(vkey)) {
      return _box.read<T>(vkey);
    }
    return null as T?;
  }

  @override
  Future<void> writeStorage(StorageKey key, dynamic value) async {
    final vkey = key.toString().split('.').last; // Output: active
    await _box.write(vkey, value);
  }

  @override
  Future<void> removeStorage(StorageKey key) async {
    final vkey = key.toString().split('.').last; // Output: active
    await _box.remove(vkey);
  }

  @override
  Future<void> removeStorageMultiple(List<StorageKey> keys) async {
    for (var key in keys) {
      await removeStorage(key);
    }
  }

  //change menu language
  @override
  Future<void> changeMenuLanguageWrite({
    required Map<String, dynamic> data,
  }) async {
    var encryptData = _helper.onEcrypted(jsonEncode(data));

    await writeStorage(StorageKey.changeMenuLanguage, encryptData);
  }

  @override
  Future<void> changeMenuLanguageRemove() async {
    await removeStorage(StorageKey.changeMenuLanguage);
  }

  @override
  Map<String, dynamic> get changeMenuLanguageRead {
    var data = readStorage<String>(StorageKey.changeMenuLanguage);
    if (data != null) {
      Map<String, dynamic> result = jsonDecode(_helper.onDecrypted(data));
      return result;
    }
    return {};
  }
}
