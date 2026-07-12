import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/http/vt_http_request.dart';

class VTHttpClient {
  VTHttpClient({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  static const _maxAttempts = 3;
  static const _retryDelay = Duration(milliseconds: 300);

  final String baseUrl;
  final http.Client _client;

  Future<Result<VTError, Map<String, dynamic>>> get(VTHttpRequest request) async {
    final uri = Uri.parse('$baseUrl${request.path}').replace(queryParameters: request.queryParameters);
    try {
      final response = await _getWithRetry(uri);
      if (response.statusCode != 200) {
        return Failure(VTError(message: 'Request to $uri failed with status ${response.statusCode}'));
      }
      return Success(jsonDecode(response.body) as Map<String, dynamic>);
    } on Exception catch (error) {
      return Failure(VTError(message: 'Request to $uri failed', cause: error));
    }
  }

  Future<http.Response> _getWithRetry(Uri uri) async {
    for (var attempt = 1; ; attempt++) {
      final response = await _client.get(uri);
      if (response.statusCode < 500 || attempt >= _maxAttempts) {
        return response;
      }
      await Future.delayed(_retryDelay);
    }
  }
}
