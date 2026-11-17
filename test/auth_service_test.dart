import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:greenloop_mobile/core/network/api_client.dart';
import 'package:greenloop_mobile/features/auth/data/auth_models.dart';
import 'package:greenloop_mobile/features/auth/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    late Map<String, dynamic> mockResponses;
    late Map<String, int> statusCodes;
    final capturedRequests = <http.BaseRequest>[];

    setUp(() {
      capturedRequests.clear();
      statusCodes = {};
      mockResponses = {
        '/api/auth/csrf/': {'csrf_token': 'test-csrf-123'},
      };

      final mockClient = MockClient((request) async {
        capturedRequests.add(request);
        final path = request.url.path;
        final status = statusCodes[path] ?? 200;
        final body = mockResponses[path] ?? {};

        return http.Response(
          jsonEncode(body),
          status,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      authService = AuthService(apiClient: apiClient);
    });

    test('login success sets currentUser and notifies listeners', () async {
      mockResponses['/api/auth/login/'] = {
        'detail': 'Login berhasil.',
        'profile': {
          'user': {
            'id': 1,
            'username': 'andi',
            'email': 'andi@example.com',
            'first_name': '',
            'last_name': '',
          },
          'role': 'consumer',
          'mitra_profile': null,
          'courier_profile': null,
        },
        'csrf_token': 'new-session-csrf-456',
      };

      var notified = false;
      authService.currentUserNotifier.addListener(() {
        notified = true;
      });

      final profile = await authService.login(
        username: 'andi',
        password: 'password123',
      );

      expect(profile.user.username, 'andi');
      expect(profile.role, UserRole.consumer);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser?.user.id, 1);
      expect(notified, isTrue);
      expect(authService.apiClient.csrfToken, 'new-session-csrf-456');
    });

    test('login failure throws ApiException with backend error message', () async {
      statusCodes['/api/auth/login/'] = 401;
      mockResponses['/api/auth/login/'] = {
        'detail': 'Username atau password salah.',
      };

      expect(
        () => authService.login(username: 'andi', password: 'wrongpassword'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having(
                (e) => e.message,
                'message',
                'Username atau password salah.',
              ),
        ),
      );

      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });

    test('register success stores profile and establishes session', () async {
      statusCodes['/api/auth/register/'] = 201;
      mockResponses['/api/auth/register/'] = {
        'detail': 'Registrasi berhasil.',
        'profile': {
          'user': {
            'id': 2,
            'username': 'mitra_cafe',
            'email': 'cafe@example.com',
            'first_name': '',
            'last_name': '',
          },
          'role': 'mitra',
          'mitra_profile': {
            'business_name': 'Cafe Senja',
            'business_type': 'Kafe',
            'pic_name': 'Afiqah',
            'phone_number': '081234567890',
            'operational_hours': '08:00 - 22:00',
            'courier_notes': null,
          },
          'courier_profile': null,
        },
        'csrf_token': 'register-csrf-789',
      };

      final profile = await authService.register(data: {
        'username': 'mitra_cafe',
        'email': 'cafe@example.com',
        'password1': 'StrongPass123!',
        'password2': 'StrongPass123!',
        'role': 'mitra',
        'business_name': 'Cafe Senja',
      });

      expect(profile.user.username, 'mitra_cafe');
      expect(profile.role, UserRole.mitra);
      expect(profile.mitraProfile?.businessName, 'Cafe Senja');
      expect(authService.isAuthenticated, isTrue);
    });

    test('register validation error throws ApiException with field details', () async {
      statusCodes['/api/auth/register/'] = 400;
      mockResponses['/api/auth/register/'] = {
        'errors': {
          'username': [
            {'message': 'Username sudah digunakan.', 'code': 'unique'}
          ],
        },
      };

      expect(
        () => authService.register(data: {'username': 'andi'}),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.message,
                'message',
                contains('username: Username sudah digunakan.'),
              ),
        ),
      );
    });

    test('logout clears user state and CSRF token', () async {
      // First populate user
      mockResponses['/api/auth/login/'] = {
        'detail': 'Login berhasil.',
        'profile': {
          'user': {'id': 1, 'username': 'andi', 'email': 'andi@example.com'},
          'role': 'consumer',
        },
        'csrf_token': 'temp-token',
      };
      await authService.login(username: 'andi', password: 'password');
      expect(authService.isAuthenticated, isTrue);

      // Now logout
      mockResponses['/api/auth/logout/'] = {'detail': 'Logout berhasil.'};
      await authService.logout();

      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
      expect(authService.apiClient.csrfToken, isNull);
    });

    test('fetchProfile updates currentUser', () async {
      mockResponses['/api/auth/profile/'] = {
        'user': {
          'id': 5,
          'username': 'kurir_budi',
          'email': 'budi@example.com',
        },
        'role': 'courier',
        'courier_profile': {
          'plate_number': 'B 1234 KZT',
          'vehicle_type': 'Motor Box',
        },
      };

      final profile = await authService.fetchProfile();
      expect(profile.user.username, 'kurir_budi');
      expect(profile.role, UserRole.courier);
      expect(profile.courierProfile?.plateNumber, 'B 1234 KZT');
      expect(authService.currentUser?.user.id, 5);
    });

    test('fetchProfile 403 resets currentUser to null and throws', () async {
      statusCodes['/api/auth/profile/'] = 403;
      mockResponses['/api/auth/profile/'] = {
        'detail': 'Authentication credentials were not provided.',
      };

      expect(
        () => authService.fetchProfile(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403)),
      );
      expect(authService.currentUser, isNull);
    });

    test('updateProfile updates currentUser with patched profile', () async {
      mockResponses['/api/auth/profile/'] = {
        'user': {
          'id': 1,
          'username': 'renamed_user',
          'email': 'new_email@example.com',
          'first_name': 'New',
          'last_name': 'Name',
        },
        'role': 'consumer',
      };

      final updated = await authService.updateProfile({
        'username': 'renamed_user',
        'email': 'new_email@example.com',
      });

      expect(updated.user.username, 'renamed_user');
      expect(updated.user.displayName, 'New Name');
      expect(authService.currentUser?.user.username, 'renamed_user');
    });

    test('checkSession returns profile on valid session', () async {
      mockResponses['/api/auth/profile/'] = {
        'user': {'id': 8, 'username': 'restored', 'email': 'r@example.com'},
        'role': 'mitra',
      };

      final profile = await authService.checkSession();
      expect(profile, isNotNull);
      expect(profile?.user.username, 'restored');
      expect(profile?.role, UserRole.mitra);
      expect(authService.isAuthenticated, isTrue);
    });

    test('checkSession returns null on expired session (401/403)', () async {
      statusCodes['/api/auth/profile/'] = 403;
      mockResponses['/api/auth/profile/'] = {
        'detail': 'Authentication credentials were not provided.',
      };

      final profile = await authService.checkSession();
      expect(profile, isNull);
      expect(authService.isAuthenticated, isFalse);
    });

    test('checkSession returns null on network error without crashing', () async {
      final mockThrowingClient = MockClient((request) async {
        throw http.ClientException('Network connection failed');
      });
      final throwingAuthService = AuthService(
        apiClient: ApiClient(client: mockThrowingClient),
      );

      final profile = await throwingAuthService.checkSession();
      expect(profile, isNull);
      expect(throwingAuthService.isAuthenticated, isFalse);
    });

    test('checkSession deduplicates concurrent calls', () async {
      var callCount = 0;
      final countingClient = MockClient((request) async {
        if (request.url.path == '/api/auth/profile/') {
          callCount++;
          return http.Response(
            jsonEncode({
              'user': {
                'id': 9,
                'username': 'single_call',
                'email': 's@example.com',
              },
              'role': 'consumer',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final service = AuthService(
        apiClient: ApiClient(client: countingClient),
      );

      final futures = await Future.wait([
        service.checkSession(),
        service.checkSession(),
        service.checkSession(),
      ]);

      expect(callCount, 1);
      expect(futures[0]?.user.username, 'single_call');
      expect(futures[1]?.user.username, 'single_call');
      expect(futures[2]?.user.username, 'single_call');
    });
  });
}
