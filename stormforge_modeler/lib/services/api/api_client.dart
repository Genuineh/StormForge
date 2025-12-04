import 'dart:convert';
import 'package:http/http.dart' as http;

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
  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Makes a POST request.
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Makes a PUT request.
  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Makes a DELETE request.
  Future<Map<String, dynamic>> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
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
