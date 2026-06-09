import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class Helper {
  late final encrypt.Key key;
  late final encrypt.IV iv;

   Helper() {
    key = encrypt.Key.fromUtf8(dotenv.get("AES_KEY"));
    iv = encrypt.IV.fromUtf8(dotenv.get("AES_IV"));
  }

  /// AES Decrypt method
  String onDecrypted(String encrypted) {
    try {
      if (encrypted.trim().isEmpty) {
        return "";
      }
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      return encrypter.decrypt64(encrypted, iv: iv);
    } on Exception catch (_) {
      return "";
    }
  }

  /// AES Encrypt method
  String onEcrypted(String plainText) {
    try {
      if (plainText.trim().isEmpty) {
        return "";
      }

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      return encrypted.base64;
    } on Exception catch (_) {
      return "";
    }
  }

  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return email; // too short to mask safely
    }

    final first = name[0];
    final last = name[name.length - 1];
    final masked = '*' * (name.length - 2);

    return '$first$masked$last@$domain';
  }

  Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  List asList(dynamic value) {
    if (value is List) return value;
    if (value is Map) return value.values.toList();
    return [];
  }

  String asText(dynamic value, {String fallback = ""}) {
    final text = value?.toString().trim() ?? "";
    return text.isEmpty ? fallback : text;
  }

  num toNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? "") ?? 0;
  }

  int toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }

  DateTime? toDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? "");
  }

  String formatDuration(Duration duration) {
    final totalMinutes = duration.inMinutes;
    if (totalMinutes <= 0) return "0m";

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours <= 0) return "${minutes}m";
    if (minutes <= 0) return "${hours}h";
    return "${hours}h ${minutes}m";
  }
 
}

extension EnumFileName on Enum {
  String toFileName() {
    return name
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}')
        .replaceAllMapped(
            RegExp(r'_([A-Z]+)$'), (m) => '.${m[1]!.toLowerCase()}')
        .toLowerCase();
  }
}

Map<String, dynamic> getRouteArguments(dynamic arguments) {
  if (arguments is Map<String, dynamic>) return arguments;
  if (arguments is Map) {
    return arguments.map((key, value) => MapEntry(key.toString(), value));
  }
  return {};
}
