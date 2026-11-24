import 'dart:convert';

import 'package:http/http.dart' as http;

import 'http_client_factory.dart';

/// Exception thrown when an API request fails.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
    this.detail,
  });

  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;
  final String? detail;

  factory ApiException.fromResponse(http.Response response) {
    final statusCode = response.statusCode;
    var message = 'Terjadi kesalahan pada server ($statusCode).';
    Map<String, dynamic>? errors;
    String? detail;

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['detail'] is String) {
          detail = decoded['detail'] as String;
          message = detail;
        } else if (decoded['errors'] is Map<String, dynamic>) {
          errors = decoded['errors'] as Map<String, dynamic>;
          final messages = <String>[];

          for (final entry in errors.entries) {
            final field = entry.key;
            final val = entry.value;
            if (val is List && val.isNotEmpty) {
              for (final item in val) {
                if (item is Map && item['message'] != null) {
                  messages.add('$field: ${item['message']}');
                } else if (item is String) {
                  messages.add('$field: $item');
                }
              }
            } else if (val is String) {
              messages.add('$field: $val');
            }
          }

          if (messages.isNotEmpty) {
            message = messages.join('\n');
          }
        }
      }
    } catch (_) {
      // Fallback message by status code if JSON parsing fails
      if (statusCode == 401) {
        message = 'Username atau kata sandi tidak valid.';
      } else if (statusCode == 403) {
        message = 'Akses ditolak atau token CSRF tidak valid.';
      } else if (statusCode == 404) {
        message = 'Data yang diminta tidak ditemukan.';
      } else if (statusCode >= 500) {
        message = 'Server mengalami masalah internal ($statusCode).';
      }
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      errors: errors,
      detail: detail,
    );
  }

  @override
  String toString() => message;
}

/// HTTP client tailored for Django REST Framework with session auth and CSRF protection.
/// Supports Flutter Web cross-origin cookies via BrowserClient with credentials enabled.
class ApiClient {
  ApiClient({
    this.baseUrl = 'http://localhost:8000',
    http.Client? client,
  }) : _client = client ?? createClient();

  String baseUrl;
  final http.Client _client;
  String? _csrfToken;

  String? get csrfToken => _csrfToken;

  /// Update or store a known CSRF token (e.g. from login/register response).
  void updateCsrfToken(String? token) {
    if (token != null && token.isNotEmpty) {
      _csrfToken = token;
    }
  }

  /// Clear the stored CSRF token (e.g. on logout).
  void clearCsrfToken() {
    _csrfToken = null;
  }

  Uri _buildUri(String path) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanBase$cleanPath');
  }

  /// Fetch a CSRF token from the backend bootstrap endpoint `/api/auth/csrf/`.
  Future<String> fetchCsrfToken({bool force = false}) async {
    if (_csrfToken != null && !force) {
      return _csrfToken!;
    }

    final uri = _buildUri('/api/auth/csrf/');
    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['csrf_token'] is String) {
        _csrfToken = decoded['csrf_token'] as String;
        return _csrfToken!;
      }
    }

    throw ApiException.fromResponse(response);
  }

  void _extractCsrfFromResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['csrf_token'] is String) {
        _csrfToken = decoded['csrf_token'] as String;
      }
    } catch (_) {
      // Body may not be JSON, ignore.
    }
  }

  /// Perform a GET request.
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final mergedHeaders = {
      'Accept': 'application/json',
      ...?headers,
    };

    return _client.get(uri, headers: mergedHeaders);
  }

  /// Perform a POST request. Automatically retrieves and attaches `X-CSRFToken`
  /// when [requireCsrf] is true, and updates the stored CSRF token if returned.
  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
    bool requireCsrf = true,
  }) async {
    final uri = _buildUri(path);

    String? token;
    if (requireCsrf) {
      token = await fetchCsrfToken();
    }

    final mergedHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'X-CSRFToken': ?token,
      ...?headers,
    };

    final payload = body is String || body == null ? body as String? : jsonEncode(body);
    final response = await _client.post(uri, headers: mergedHeaders, body: payload);

    _extractCsrfFromResponse(response);
    return response;
  }

  /// Submit regular form fields as Django `request.POST` data with CSRF support.
  Future<http.Response> postForm(
    String path, {
    required Map<String, String> fields,
    Map<String, String>? headers,
    bool requireCsrf = true,
  }) async {
    final uri = _buildUri(path);
    var token = requireCsrf ? await fetchCsrfToken() : null;

    Future<http.Response> sendRequest() => _client.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-CSRFToken': ?token,
        ...?headers,
      },
      body: fields,
    );

    var response = await sendRequest();
    if (requireCsrf && response.statusCode == 403) {
      token = await fetchCsrfToken(force: true);
      response = await sendRequest();
    }

    _extractCsrfFromResponse(response);
    return response;
  }
  /// Send a multipart POST containing one upload and CSRF protection.
  Future<http.Response> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required List<int> fileBytes,
    required String filename,
    bool requireCsrf = true,
  }) async {
    final uri = _buildUri(path);
    var token = requireCsrf ? await fetchCsrfToken() : null;

    Future<http.Response> sendRequest() async {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Accept': 'application/json',
          if (token != null) 'X-CSRFToken': token!,
        })
        ..fields.addAll(fields)
        ..files.add(http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: filename,
        ));
      final streamedResponse = await _client.send(request);
      return http.Response.fromStream(streamedResponse);
    }

    var response = await sendRequest();
    if (requireCsrf && response.statusCode == 403) {
      token = await fetchCsrfToken(force: true);
      response = await sendRequest();
    }
    _extractCsrfFromResponse(response);
    return response;
  }

  /// Perform a PATCH request with CSRF token and JSON headers.
  Future<http.Response> patch(
    String path, {
    Object? body,
    Map<String, String>? headers,
    bool requireCsrf = true,
  }) async {
    final uri = _buildUri(path);

    String? token;
    if (requireCsrf) {
      token = await fetchCsrfToken();
    }

    final mergedHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'X-CSRFToken': ?token,
      ...?headers,
    };

    final payload = body is String || body == null ? body as String? : jsonEncode(body);
    final response = await _client.patch(uri, headers: mergedHeaders, body: payload);

    _extractCsrfFromResponse(response);
    return response;
  }

  /// Perform a DELETE request with CSRF token support.
  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    bool requireCsrf = true,
  }) async {
    final uri = _buildUri(path);

    String? token;
    if (requireCsrf) {
      token = await fetchCsrfToken();
    }

    final mergedHeaders = {
      'Accept': 'application/json',
      'X-CSRFToken': ?token,
      ...?headers,
    };

    return _client.delete(uri, headers: mergedHeaders);
  }

  /// Close the underlying HTTP client.
  void close() {
    _client.close();
  }
}
