import 'dart:convert';

import 'package:crypto/crypto.dart';

class PasswordHasher {
  static String createSalt(String seed) {
    return sha256
        .convert(utf8.encode('lumio-salt::$seed'))
        .toString()
        .substring(0, 24);
  }

  static String hash(String password, String salt) {
    final normalized = password.trim();
    return sha256
        .convert(utf8.encode('$salt::$normalized::lumio-auth-v1'))
        .toString();
  }

  static bool verify({
    required String password,
    required String salt,
    required String expectedHash,
  }) {
    return hash(password, salt) == expectedHash;
  }
}
