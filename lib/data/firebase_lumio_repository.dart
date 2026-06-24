import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/lumio_models.dart';

class DatabaseSyncResult {
  const DatabaseSyncResult({
    required this.ok,
    required this.message,
    this.snapshot,
  });

  final bool ok;
  final String message;
  final LumioSnapshot? snapshot;
}

class FirebaseLumioRepository {
  FirebaseLumioRepository({
    String baseUrl = 'https://lumio-27641-default-rtdb.firebaseio.com/',
    http.Client? client,
  }) : _baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
       _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<DatabaseSyncResult> loadSnapshot() async {
    try {
      final response = await _client
          .get(_uri('lumio.json'))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.isNotEmpty) {
          final data = Map<String, dynamic>.from(decoded);
          final snapshot = LumioSnapshot.fromJson(data);
          if (snapshot.users.isNotEmpty && snapshot.courses.isNotEmpty) {
            return DatabaseSyncResult(
              ok: true,
              message: 'Connected to Firebase Realtime Database',
              snapshot: snapshot,
            );
          }
        }
        return const DatabaseSyncResult(
          ok: false,
          message: 'Firebase is reachable, but no Lumio dataset is stored yet',
        );
      }
      return DatabaseSyncResult(
        ok: false,
        message:
            'Firebase read failed (${response.statusCode}): ${_trim(response.body)}',
      );
    } catch (error) {
      return DatabaseSyncResult(
        ok: false,
        message: 'Firebase unavailable: $error',
      );
    }
  }

  Future<DatabaseSyncResult> saveSnapshot(LumioSnapshot snapshot) async {
    try {
      final response = await _client
          .put(
            _uri('lumio.json'),
            headers: const {'content-type': 'application/json'},
            body: jsonEncode(snapshot.toJson()),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const DatabaseSyncResult(
          ok: true,
          message: 'Synced latest Lumio state to Firebase',
        );
      }
      return DatabaseSyncResult(
        ok: false,
        message:
            'Firebase write failed (${response.statusCode}): ${_trim(response.body)}',
      );
    } catch (error) {
      return DatabaseSyncResult(
        ok: false,
        message: 'Firebase write unavailable: $error',
      );
    }
  }

  static String _trim(String value) {
    final compact = value.replaceAll('\n', ' ').trim();
    if (compact.length <= 110) return compact;
    return '${compact.substring(0, 110)}...';
  }
}
