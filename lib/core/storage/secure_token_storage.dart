import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores access/refresh tokens in the platform secure store (Keychain /
/// Keystore). Never log these values — see CLAUDE.md logging rules.
class SecureTokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userProfileKey = 'user_profile';

  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveUserProfileJson(String json) =>
      _storage.write(key: _userProfileKey, value: json);
  Future<String?> readUserProfileJson() => _storage.read(key: _userProfileKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userProfileKey);
  }
}
