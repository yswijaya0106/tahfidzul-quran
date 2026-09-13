import 'package:dio/dio.dart';

import '../debug_api_log_service.dart';

class DebugApiInterceptor extends Interceptor {
  static const _kStartTime = '_debug_start_time';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_kStartTime] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _record(
      options: response.requestOptions,
      statusCode: response.statusCode,
      responseBody: response.data,
      isError: false,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _record(
      options: err.requestOptions,
      statusCode: err.response?.statusCode,
      responseBody: err.response?.data,
      errorMessage: err.message,
      isError: true,
    );
    handler.next(err);
  }

  void _record({
    required RequestOptions options,
    required bool isError,
    int? statusCode,
    dynamic responseBody,
    String? errorMessage,
  }) {
    final start = options.extra[_kStartTime] as DateTime?;
    final duration = start != null
        ? DateTime.now().difference(start)
        : Duration.zero;

    DebugApiLogService.instance.add(
      DebugApiEntry(
        time: DateTime.now(),
        method: options.method,
        url: options.uri.toString(),
        requestHeaders: options.headers,
        requestBody: options.data,
        statusCode: statusCode,
        responseBody: responseBody,
        errorMessage: errorMessage,
        duration: duration,
        isError: isError,
      ),
    );
  }
}
