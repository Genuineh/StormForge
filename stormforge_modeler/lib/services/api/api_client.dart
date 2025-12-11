import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Base API client for communicating with StormForge backend.
class ApiClient {
  /// Creates an API client.
  ApiClient({
    String? baseUrl,
    this.token,
  }) : baseUrl = baseUrl ?? 'http://localhost:3000';

  /// The base URL for API requests.
  final String baseUrl;

  /// The JWT authentication token.
  String? token;

  final Logger _logger = Logger();

  /// Common headers for all requests.
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Makes a GET request.
  Future<dynamic> get(String path) async {
    _logger.d('Making GET request to $baseUrl$path');
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Makes a POST request.
  Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    _logger.d('Making POST request to $baseUrl$path with body: $body');
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Makes a PUT request.
  Future<dynamic> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    _logger.d('Making PUT request to $baseUrl$path with body: $body');
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Makes a DELETE request.
  Future<dynamic> delete(String path) async {
    _logger.d('Making DELETE request to $baseUrl$path');
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    _logger.d('Response status: ${response.statusCode}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        _logger.d('Response body is empty');
        return {};
      }
      final decoded = jsonDecode(response.body);
      _logger.d('Response body: ${response.body}');
      return decoded;
    } else {
      _logger.e('API error: ${response.statusCode} - ${response.body}');
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body.isNotEmpty
            ? response.body
            : 'Request failed with status ${response.statusCode}',
      );
    }
  }
}

/// Exception thrown when an API request fails.
class ApiException implements Exception {
  /// Creates an API exception.
  ApiException({
    required this.statusCode,
    required this.message,
  });

  /// The HTTP status code.
  final int statusCode;

  /// The error message.
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
