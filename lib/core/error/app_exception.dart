/// Mirrors the backend's `{ error: { code, message, fields, requestId } }`
/// shape so the UI can map field-level validation errors back onto forms.
class AppException implements Exception {
  final String code;
  final String message;
  final Map<String, String>? fields;
  final String? requestId;
  final int? statusCode;

  const AppException({
    required this.code,
    required this.message,
    this.fields,
    this.requestId,
    this.statusCode,
  });

  factory AppException.network() => const AppException(
    code: 'NETWORK_ERROR',
    message: 'Could not reach the server. Check your connection and try again.',
  );

  factory AppException.unknown([String? message]) => AppException(
    code: 'UNKNOWN_ERROR',
    message: message ?? 'Something went wrong. Please try again.',
  );

  bool get isUnauthenticated => code == 'UNAUTHENTICATED' || statusCode == 401;
  bool get isForbidden => code == 'FORBIDDEN' || statusCode == 403;
  bool get isValidation =>
      code == 'VALIDATION_ERROR' || code == 'UNPROCESSABLE';

  @override
  String toString() => 'AppException($code: $message)';
}
