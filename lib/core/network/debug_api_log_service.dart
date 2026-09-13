import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

class DebugApiEntry {
  const DebugApiEntry({
    required this.time,
    required this.method,
    required this.url,
    required this.duration,
    required this.isError,
    this.requestHeaders,
    this.requestBody,
    this.statusCode,
    this.responseBody,
    this.errorMessage,
  });

  final DateTime time;
  final String method;
  final String url;
  final Duration duration;
  final bool isError;
  final dynamic requestHeaders;
  final dynamic requestBody;
  final int? statusCode;
  final dynamic responseBody;
  final String? errorMessage;

  String get prettyRequestBody => _prettyJson(requestBody);
  String get prettyResponseBody => _prettyJson(responseBody);
  String get prettyRequestHeaders => _prettyJson(_filteredHeaders);

  dynamic get _filteredHeaders {
    if (AppConstants.debugShowAuthHeader || requestHeaders is! Map) {
      return requestHeaders;
    }
    final filtered = Map<String, dynamic>.from(requestHeaders as Map)
      ..removeWhere((k, _) => k.toLowerCase() == 'authorization');
    return filtered;
  }

  String get copyAllText => [
    '=== REQUEST ===',
    '${method.toUpperCase()} $url',
    if (requestBody != null) ...['\n--- Body ---', prettyRequestBody],
    '\n--- Headers ---',
    prettyRequestHeaders,
    '\n=== RESPONSE${statusCode != null ? ' ($statusCode)' : ''} ===',
    prettyResponseBody,
  ].join('\n');

  static String _prettyJson(dynamic data) {
    if (data == null) return '—';
    if (data is FormData) return _prettyFormData(data);
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  /// `FormData` (multipart request) isn't JSON-encodable and doesn't
  /// override `toString()` — without this the debug log would just show
  /// `Instance of 'FormData'`. Render fields as-is plus file info
  /// (name/size/content-type) without dumping raw bytes.
  static String _prettyFormData(FormData data) {
    final buffer = StringBuffer();
    for (final field in data.fields) {
      buffer.writeln('${field.key}: ${field.value}');
    }
    for (final file in data.files) {
      final f = file.value;
      buffer.writeln(
        '${file.key}: <file> ${f.filename ?? '(no filename)'} '
        '(${f.length} bytes, ${f.contentType?.mimeType ?? 'unknown type'})',
      );
    }
    final result = buffer.toString().trimRight();
    return result.isEmpty ? '(empty FormData)' : result;
  }
}

/// Singleton that accumulates API call entries for the debug overlay.
class DebugApiLogService {
  DebugApiLogService._();
  static final DebugApiLogService instance = DebugApiLogService._();

  static const int _maxEntries = 200;

  final ValueNotifier<List<DebugApiEntry>> logs = ValueNotifier(const []);

  void add(DebugApiEntry entry) {
    final updated = [entry, ...logs.value];
    if (updated.length > _maxEntries) {
      logs.value = updated.sublist(0, _maxEntries);
    } else {
      logs.value = updated;
    }
  }

  void clear() => logs.value = const [];
}
