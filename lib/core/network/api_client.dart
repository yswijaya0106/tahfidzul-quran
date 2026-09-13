import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../error/app_exception.dart';
import '../storage/secure_token_storage.dart';
import 'app_config.dart';
import 'interceptors/debug_api_interceptor.dart';

/// Thin wrapper around Dio that injects the access token, transparently
/// retries once after a refresh on 401, and normalizes every failure into
/// [AppException]. Widgets must never construct Dio directly (CLAUDE.md:
/// "Widgets must not call HTTP clients or SQL directly").
class ApiClient {
  final Dio _dio;
  final Dio _uploadDio;
  final SecureTokenStorage _tokenStorage;
  Completer<bool>? _refreshInFlight;

  ApiClient({Dio? dio, SecureTokenStorage? tokenStorage})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl)),
      _uploadDio = Dio(),
      _tokenStorage = tokenStorage ?? SecureTokenStorage() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null && !options.path.contains('/auth/login')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isAuthEndpoint = error.requestOptions.path.contains('/auth/');
          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            final refreshed = await _refreshTokens();
            if (refreshed) {
              try {
                final response = await _retry(error.requestOptions);
                handler.resolve(response);
                return;
              } catch (_) {
                // fall through to the original error below
              }
            }
          }
          handler.next(error);
        },
      ),
    );
    if (AppConstants.isDebugMode) {
      _dio.interceptors.add(DebugApiInterceptor());
    }
  }

  Future<bool> _refreshTokens() async {
    if (_refreshInFlight != null) return _refreshInFlight!.future;
    final completer = Completer<bool>();
    _refreshInFlight = completer;

    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null) {
        completer.complete(false);
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      await _tokenStorage.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      completer.complete(true);
      return true;
    } catch (_) {
      await _tokenStorage.clear();
      completer.complete(false);
      return false;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _tokenStorage.readAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    if (token != null) options.headers!['Authorization'] = 'Bearer $token';

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return _unwrap(() => _dio.get(path, queryParameters: query));
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    return _unwrap(() => _dio.post(path, data: data));
  }

  Future<Map<String, dynamic>> patch(String path, {Object? data}) async {
    return _unwrap(() => _dio.patch(path, data: data));
  }

  Future<void> delete(String path) async {
    await _unwrapVoid(() => _dio.delete(path));
  }

  /// Uploads raw bytes to a presigned storage URL (S3-compatible). Uses a
  /// bare Dio instance with no base URL and no auth interceptor: the
  /// presigned URL carries its own signature/expiry, and our app's access
  /// token has no business being sent to the storage provider.
  Future<void> uploadBytes(
    String presignedUrl,
    List<int> bytes, {
    required String mimeType,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      await _uploadDio.put(
        presignedUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            Headers.contentTypeHeader: mimeType,
            Headers.contentLengthHeader: bytes.length,
          },
        ),
        onSendProgress: onProgress,
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<Map<String, dynamic>> _unwrap(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      if (response.data == null) return const {};
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<void> _unwrapVoid(Future<Response<dynamic>> Function() request) async {
    try {
      await request();
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  AppException _mapError(DioException error) {
    final response = error.response;
    if (response == null) {
      return AppException.network();
    }

    final body = response.data;
    if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
      final errorBody = body['error'] as Map<String, dynamic>;
      final rawFields = errorBody['fields'] as Map<String, dynamic>?;
      return AppException(
        code: errorBody['code'] as String? ?? 'UNKNOWN_ERROR',
        message:
            errorBody['message'] as String? ?? 'An unexpected error occurred.',
        fields: rawFields?.map((key, value) => MapEntry(key, value.toString())),
        requestId: errorBody['requestId'] as String?,
        statusCode: response.statusCode,
      );
    }

    return AppException.unknown(
      'Unexpected server response (${response.statusCode}).',
    );
  }
}
