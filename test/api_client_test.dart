import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:greenloop_mobile/core/network/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiClient', () {
    test('fetches and attaches CSRF token on POST', () async {
      var csrfCallCount = 0;
      var postCallCount = 0;
      String? sentCsrfToken;

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/csrf/') {
          csrfCallCount++;
          return http.Response(
            jsonEncode({'csrf_token': 'test-csrf-token-123'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.url.path == '/api/auth/login/') {
          postCallCount++;
          sentCsrfToken = request.headers['X-CSRFToken'];
          return http.Response(
            jsonEncode({
              'detail': 'Login berhasil.',
              'csrf_token': 'rotated-token-456',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('Not Found', 404);
      });

      final client = ApiClient(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      final response = await client.post('/api/auth/login/', body: {
        'username': 'tester',
        'password': 'password',
      });

      expect(response.statusCode, 200);
      expect(csrfCallCount, 1);
      expect(postCallCount, 1);
      expect(sentCsrfToken, 'test-csrf-token-123');
      // Token rotated and updated from response
      expect(client.csrfToken, 'rotated-token-456');
    });

    test('parses Django error detail and field validation errors', () {
      final responseWithDetail = http.Response(
        jsonEncode({'detail': 'Username atau password salah.'}),
        401,
      );
      final exception1 = ApiException.fromResponse(responseWithDetail);
      expect(exception1.statusCode, 401);
      expect(exception1.message, 'Username atau password salah.');

      final responseWithErrors = http.Response(
        jsonEncode({
          'errors': {
            'username': [
              {'message': 'Username sudah digunakan.', 'code': 'unique'}
            ]
          }
        }),
        400,
      );
      final exception2 = ApiException.fromResponse(responseWithErrors);
      expect(exception2.statusCode, 400);
      expect(exception2.message, contains('username: Username sudah digunakan.'));
    });
  });
}
