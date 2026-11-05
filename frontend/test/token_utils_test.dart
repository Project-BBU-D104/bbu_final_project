import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/token_utils.dart';

String _tokenWithPayload(Map<String, dynamic> payload) {
  String encode(Map<String, dynamic> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${encode(payload)}.'
      'signature';
}

void main() {
  group('TokenUtils.isExpired', () {
    test('returns false for a token that expires in the future', () {
      final exp =
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000;

      expect(TokenUtils.isExpired(_tokenWithPayload({'exp': exp})), isFalse);
    });

    test('returns true for a token whose expiry has passed', () {
      final exp =
          DateTime.now()
              .subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch ~/
          1000;

      expect(TokenUtils.isExpired(_tokenWithPayload({'exp': exp})), isTrue);
    });

    test('treats a token expiring within the clock-skew window as expired', () {
      final exp =
          DateTime.now()
              .add(const Duration(seconds: 5))
              .millisecondsSinceEpoch ~/
          1000;

      expect(TokenUtils.isExpired(_tokenWithPayload({'exp': exp})), isTrue);
    });

    test('returns true for empty, malformed, and exp-less tokens', () {
      expect(TokenUtils.isExpired(null), isTrue);
      expect(TokenUtils.isExpired(''), isTrue);
      expect(TokenUtils.isExpired('not-a-jwt'), isTrue);
      expect(TokenUtils.isExpired(_tokenWithPayload({'sub': '1'})), isTrue);
    });
  });

  group('TokenUtils.hasValidSession', () {
    test('returns true only when login data has a usable token', () {
      final exp =
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000;

      expect(TokenUtils.hasValidSession(null), isFalse);
      expect(TokenUtils.hasValidSession({}), isFalse);
      expect(
        TokenUtils.hasValidSession({
          'user': {'id': 1},
        }),
        isFalse,
      );
      expect(
        TokenUtils.hasValidSession({
          'token': _tokenWithPayload({'exp': exp}),
        }),
        isTrue,
      );
      expect(
        TokenUtils.hasValidSession({
          'token': _tokenWithPayload({
            'exp':
                DateTime.now()
                    .subtract(const Duration(hours: 1))
                    .millisecondsSinceEpoch ~/
                1000,
          }),
        }),
        isFalse,
      );
    });
  });
}
