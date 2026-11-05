import 'dart:convert';

/// Helpers for reading a JWT without verifying its signature.
///
/// The backend is still the only authority on whether a token is valid. This
/// is used to avoid sending an already-expired token and to send the user back
/// to the login screen instead of showing empty data.
class TokenUtils {
  /// Treat tokens that expire within this window as expired so a request is
  /// not sent just as the server-side expiry is reached.
  static const int _clockSkewSeconds = 30;

  /// Whether the stored login data contains a token that can still be used.
  static bool hasValidSession(Map<String, dynamic>? loginData) {
    if (loginData == null || loginData.isEmpty) return false;

    return !isExpired(loginData['token']?.toString());
  }

  static bool isExpired(String? token) {
    if (token == null || token.trim().isEmpty) return true;

    final parts = token.split('.');
    if (parts.length < 2) return true;

    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      if (payload is! Map) return true;

      final rawExpiry = payload['exp'];
      final expirySeconds = rawExpiry is int
          ? rawExpiry
          : int.tryParse(rawExpiry?.toString() ?? '');

      if (expirySeconds == null) return true;

      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return nowSeconds >= expirySeconds - _clockSkewSeconds;
    } catch (_) {
      return true;
    }
  }
}
