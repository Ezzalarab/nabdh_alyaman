import 'package:dio/dio.dart';

import '../error/failures.dart';

/// Maps API error JSON and transport errors to [Failure].
Failure mapDioExceptionToFailure(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError) {
    return NetworkFailure();
  }

  final response = e.response;
  if (response == null) {
    if (e.type == DioExceptionType.cancel) {
      return UnknownFailure();
    }
    return NetworkFailure();
  }

  final status = response.statusCode ?? 0;
  final data = response.data;
  String? message;
  String? code;
  if (data is Map) {
    message = data['message'] as String?;
    code = data['code'] as String?;
  }

  switch (status) {
    case 400:
      return ValidationFailure(message: message);
    case 401:
      return UnauthorizedFailure(message: message);
    case 403:
      return ForbiddenFailure(message: message, apiCode: code);
    case 429:
      final retryAfter = response.headers.value('retry-after');
      final seconds = retryAfter != null ? int.tryParse(retryAfter) : null;
      return ThrottledFailure(message: message, retryAfterSeconds: seconds);
    default:
      if (status >= 500) {
        return ServerFailure();
      }
      return UnknownFailure();
  }
}
