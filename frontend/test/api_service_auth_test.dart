import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/constants/enum.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeStorage implements IStorageService {
  @override
  Map<String, dynamic> lastUserLoginRead = {};

  @override
  String get appStartUpRead => '';

  @override
  String get currentUserRole => '';

  @override
  bool hasRole(String role) => false;

  @override
  Future<void> appStartUpWrite({required String route}) async {}

  @override
  Future<void> lastUserLoginRemove() async {}

  @override
  Future<void> lastUserLoginWrite({required Map<String, dynamic> data}) async {}

  @override
  T? readStorage<T>(StorageKey key) => null;

  @override
  Future<void> removeStorage(StorageKey key) async {}

  @override
  Future<void> removeStorageMultiple(List<StorageKey> keys) async {}

  @override
  Future<void> writeStorage(StorageKey key, dynamic value) async {}
}

ApiService _apiReturning(
  int statusCode,
  String body, {
  void Function()? onUnauthorized,
}) {
  return ApiService(
    baseUrl: 'http://localhost:8000',
    onUnauthorized: onUnauthorized,
    client: MockClient((request) async {
      return http.Response(body, statusCode);
    }),
  );
}

void main() {
  setUpAll(() {
    if (locator.isRegistered<IStorageService>()) {
      locator.unregister<IStorageService>();
    }
    locator.registerSingleton<IStorageService>(_FakeStorage());
  });

  test('a 401 response invokes the unauthorized handler and throws', () async {
    var handled = false;
    final api = _apiReturning(
      401,
      jsonEncode({'detail': 'Invalid token'}),
      onUnauthorized: () => handled = true,
    );

    await expectLater(
      api.get('product'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(handled, isTrue);
  });

  test('a 401 from the login endpoint does not trigger a redirect', () async {
    var handled = false;
    final api = _apiReturning(
      401,
      jsonEncode({'detail': 'Invalid credentials'}),
      onUnauthorized: () => handled = true,
    );

    await expectLater(
      api.post('auth/login', {}),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Invalid credentials'),
        ),
      ),
    );
    expect(handled, isFalse);
  });

  test('login preserves endpoint, payload and token persistence', () async {
    SharedPreferences.setMockInitialValues({});
    final api = ApiService(
      baseUrl: 'http://localhost:8000',
      client: MockClient((request) async {
        expect(request.url.path, '/auth/login/');
        expect(jsonDecode(request.body), {
          'name': 'staff',
          'password': ' pass ',
        });
        return http.Response(jsonEncode({'access_token': 'token'}), 200);
      }),
    );
    await AuthService(api: api).login(name: 'staff', password: ' pass ');
    expect((await SharedPreferences.getInstance()).getString('token'), 'token');
  });

  test('login rejects a successful response with no access token', () async {
    await expectLater(
      AuthService(
        api: _apiReturning(200, '{}'),
      ).login(name: 'staff', password: 'pass'),
      throwsFormatException,
    );
  });

  test('a successful response is decoded normally', () async {
    final api = _apiReturning(
      200,
      jsonEncode([
        {'id': 1, 'name': 'Water'},
      ]),
    );

    final response = await api.get('product');

    expect(response, isA<List>());
    expect(response.first['name'], 'Water');
  });
}
