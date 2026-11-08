import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/main_service/profile_service.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class FakeStorageService implements IStorageService {
  @override
  Map<String, dynamic> get lastUserLoginRead => {
        'token': 'token-123',
        'user': {'id': 5},
      };

  @override
  String get currentUserRole => '';

  @override
  bool hasRole(String role) => false;

  @override
  T? readStorage<T>(StorageKey key) => null;

  @override
  Future<void> writeStorage(StorageKey key, dynamic value) async {}

  @override
  Future<void> removeStorage(StorageKey key) async {}

  @override
  Future<void> removeStorageMultiple(List<StorageKey> keys) async {}

  @override
  Future<void> appStartUpWrite({required String route}) async {}

  @override
  String get appStartUpRead => '';

  @override
  Future<void> lastUserLoginWrite({required Map<String, dynamic> data}) async {}

  @override
  Future<void> lastUserLoginRemove() async {}
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_URL=http://localhost:8000');
    if (!locator.isRegistered<IStorageService>()) {
      locator.registerSingleton<IStorageService>(FakeStorageService());
    }
  });

  test('updateProfile sends PUT /profile/me with the bearer token', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'id': 5,
          'name': 'New',
          'email': 'new@example.com',
          'phone': '012',
          'photo': 'new.png',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = ProfileService(
      api: ApiService(
        client: client,
        baseUrl: 'http://test',
        onUnauthorized: () {},
      ),
    );

    final result = await service.updateProfile({
      'name': 'New',
      'email': 'new@example.com',
      'phone': '012',
      'photo': 'new.png',
    });

    expect(captured.method, 'PUT');
    expect(captured.url.toString(), 'http://test/profile/me');
    expect(
      captured.headers.entries
          .firstWhere((entry) => entry.key.toLowerCase() == 'authorization')
          .value,
      'Bearer token-123',
    );
    expect(jsonDecode(captured.body), {
      'name': 'New',
      'email': 'new@example.com',
      'phone': '012',
      'photo': 'new.png',
    });
    expect(result['name'], 'New');
  });

  test('changePassword sends POST /profile/change-password/', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({'message': 'Password changed successfully.'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = ProfileService(
      api: ApiService(
        client: client,
        baseUrl: 'http://test',
        onUnauthorized: () {},
      ),
    );

    final result = await service.changePassword({
      'current_password': 'secret123',
      'new_password': 'newpass123',
    });

    expect(captured.method, 'POST');
    expect(
      captured.url.toString(),
      'http://test/profile/change-password/',
    );
    expect(jsonDecode(captured.body), {
      'current_password': 'secret123',
      'new_password': 'newpass123',
    });
    expect(result['message'], 'Password changed successfully.');
  });
}
