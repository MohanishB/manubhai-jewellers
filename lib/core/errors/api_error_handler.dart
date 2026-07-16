import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// A safe, user-facing exception. Technical details such as URLs, hosts,
/// stack traces and status codes must never be exposed through [message].
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Converts all transport, server and parsing errors into consistent,
/// user-friendly messages suitable for rendering in the UI.
abstract final class ApiErrorHandler {
  static const String noInternetMessage =
      'No internet connection. Please check your connection and try again.';
  static const String timeoutMessage =
      'The request took too long. Please try again.';
  static const String serverMessage =
      'The service is temporarily unavailable. Please try again later.';
  static const String invalidResponseMessage =
      'We could not process the server response. Please try again.';
  static const String fallbackMessage =
      'Something went wrong. Please try again.';

  static AppException exception(Object error) {
    return AppException(message(error));
  }

  static String message(Object error) {
    if (error is AppException) return error.message;

    if (error is SocketException || error is http.ClientException) {
      return noInternetMessage;
    }
    if (error is TimeoutException) return timeoutMessage;
    if (error is FormatException) return invalidResponseMessage;

    final raw = _clean(error.toString());
    final normalized = raw.toLowerCase();

    if (_containsAny(normalized, const [
      'socketexception',
      'clientexception',
      'failed host lookup',
      'no address associated with hostname',
      'network is unreachable',
      'connection refused',
      'connection reset',
      'software caused connection abort',
      'connection closed before full header',
    ])) {
      return noInternetMessage;
    }

    if (_containsAny(normalized, const [
      'timeoutexception',
      'timed out',
      'timeout',
    ])) {
      return timeoutMessage;
    }

    if (_containsAny(normalized, const [
      'formatexception',
      'invalid response',
      'unexpected character',
      'failed to decode',
    ])) {
      return invalidResponseMessage;
    }

    if (_containsAny(normalized, const [
      'http ',
      'http:',
      'statuscode',
      'status code',
      'network error',
      'server error',
      'bad gateway',
      'service unavailable',
      'internal server error',
    ])) {
      return serverMessage;
    }

    if (raw.isEmpty || _looksTechnical(raw)) return fallbackMessage;
    return raw;
  }

  static String _clean(String value) {
    var result = value
        .replaceFirst(RegExp(r'^(Exception|Error):\s*'), '')
        .trim();

    // Defensive redaction in case an unexpected error reaches this layer.
    result = result.replaceAll(
      RegExp(r'https?://\S+', caseSensitive: false),
      '',
    );
    result = result.replaceAll(
      RegExp(r'\b(OS Error|errno|uri|url|host):?[^,;\n]*',
          caseSensitive: false),
      '',
    );
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _looksTechnical(String value) {
    final normalized = value.toLowerCase();
    return _containsAny(normalized, const [
      'exception',
      'stack trace',
      'dart:',
      'package:',
      'statuscode',
      'status code',
      'errno',
      'socket',
      'clientexception',
      'uri=',
      'url=',
    ]);
  }

  static bool _containsAny(String value, List<String> terms) {
    return terms.any(value.contains);
  }
}
