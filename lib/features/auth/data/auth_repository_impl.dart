import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureTokenStorage _tokenStorage;

  AuthRepositoryImpl({required this._apiClient, required this._tokenStorage});

  @override
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'identifier': identifier, 'password': password},
    );
    final data = response['data'] as Map<String, dynamic>;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);

    await _tokenStorage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    await _tokenStorage.saveUserProfileJson(jsonEncode(data['user']));

    return user;
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _apiClient.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {
        // Best-effort server-side revocation; always clear local tokens below.
      }
    }
    await _tokenStorage.clear();
  }

  @override
  Future<void> logoutAllDevices() async {
    try {
      await _apiClient.post('/auth/logout-all');
    } finally {
      await _tokenStorage.clear();
    }
  }

  @override
  Future<AppUser?> restoreSession() async {
    final accessToken = await _tokenStorage.readAccessToken();
    final profileJson = await _tokenStorage.readUserProfileJson();
    if (accessToken == null || profileJson == null) return null;

    try {
      return AppUser.fromJson(jsonDecode(profileJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
