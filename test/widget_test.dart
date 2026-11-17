import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenloop_mobile/app/app.dart';
import 'package:greenloop_mobile/core/network/api_client.dart';
import 'package:greenloop_mobile/features/auth/presentation/auth_pages.dart';
import 'package:greenloop_mobile/features/auth/services/auth_service.dart';
import 'package:greenloop_mobile/features/home/presentation/home_pages.dart';
import 'package:greenloop_mobile/features/profile/presentation/profile_pages.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('onboarding opens login and mitra registration', (tester) async {
    await tester.pumpWidget(const GreenLoopApp());

    expect(
      find.text('Ubah Limbah Organik Jadi Sabun yang Bermakna'),
      findsOneWidget,
    );

    final loginButton = find.text('Saya sudah punya akun');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.byKey(const Key('login-email')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    final registerButton = find.text('Daftar sebagai Mitra');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('Gabung dengan GreenLoop'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Nama Usaha'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Nama Usaha'), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('login validates required fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Username wajib diisi.'), findsOneWidget);
    expect(find.text('Bagian ini wajib diisi.'), findsOneWidget);
  });

  testWidgets('login navigates to RoleNavigationPage based on backend role', (
    tester,
  ) async {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/auth/csrf/') {
        return http.Response(
          jsonEncode({'csrf_token': 'csrf-123'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/api/auth/login/') {
        return http.Response(
          jsonEncode({
            'detail': 'Login berhasil.',
            'profile': {
              'user': {
                'id': 1,
                'username': 'budi',
                'email': 'budi@example.com',
              },
              'role': 'courier',
              'courier_profile': {
                'plate_number': 'B 1234 KZT',
                'vehicle_type': 'Motor Box',
              },
            },
            'csrf_token': 'new-csrf',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not found', 404);
    });

    final authService = AuthService(apiClient: ApiClient(client: mockClient));

    await tester.pumpWidget(MaterialApp(
      home: LoginPage(authService: authService),
    ));

    await tester.enterText(find.byKey(const Key('login-email')), 'budi');
    await tester.enterText(find.byKey(const Key('login-password')), 'secret123');
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(RoleNavigationPage), findsOneWidget);
    expect(find.text('Ruang Courier di GreenLoop'), findsOneWidget);
  });

  testWidgets('registration fields follow selected role', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Admin'), findsNothing);

    await tester.ensureVisible(find.text('Mitra'));
    await tester.tap(find.text('Mitra'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Nama Usaha'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Nama Usaha'), findsOneWidget);
    expect(find.text('Plat Nomor'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Alamat Lengkap'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Alamat Lengkap'), findsOneWidget);

    // Kembali ke bagian pilihan role.
    await tester.drag(find.byType(ListView), const Offset(0, 1400));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Courier'));
    await tester.tap(find.text('Courier'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Plat Nomor'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Plat Nomor'), findsOneWidget);
    expect(find.text('Nama Usaha'), findsNothing);
  });

  testWidgets('registration navigates to RoleNavigationPage on success', (
    tester,
  ) async {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/auth/csrf/') {
        return http.Response(
          jsonEncode({'csrf_token': 'csrf-123'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/api/auth/register/') {
        return http.Response(
          jsonEncode({
            'detail': 'Registrasi berhasil.',
            'profile': {
              'user': {
                'id': 2,
                'username': 'newbie',
                'email': 'newbie@example.com',
              },
              'role': 'consumer',
              'mitra_profile': null,
              'courier_profile': null,
            },
            'csrf_token': 'reg-csrf',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not found', 404);
    });

    final authService = AuthService(apiClient: ApiClient(client: mockClient));

    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(authService: authService),
    ));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'newbie',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'newbie@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kata sandi'),
      'password123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ulangi kata sandi'),
      'password123',
    );

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Daftar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPage), findsNothing);
    expect(find.byType(RoleNavigationPage), findsOneWidget);
    expect(find.text('Ruang Consumer di GreenLoop'), findsOneWidget);
  });

  testWidgets('public home displays Live Impact placeholder', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PublicHomePage()));

    expect(find.text('Live Impact'), findsOneWidget);
    expect(find.textContaining('endpoint Live Impact'), findsOneWidget);
    expect(find.textContaining('12.480'), findsNothing);

    final loginButton = find.text('Masuk ke akun');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang kembali'), findsOneWidget);
  });

  testWidgets('mitra navigation opens profile and edit profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RoleNavigationPage(role: UserRole.mitra)),
    );

    expect(find.text('Jemput'), findsOneWidget);
    expect(find.text('Belanja'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(
      find.text('Data akun akan tampil setelah API tersambung'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Edit profil'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfilePage), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Informasi Mitra'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Informasi Mitra'), findsOneWidget);
    expect(find.text('Nama Usaha'), findsOneWidget);
  });

  testWidgets('logout in ProfilePage logs out and returns to WelcomePage', (
    tester,
  ) async {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/auth/csrf/') {
        return http.Response(
          jsonEncode({'csrf_token': 'csrf-123'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/api/auth/login/') {
        return http.Response(
          jsonEncode({
            'detail': 'Login berhasil.',
            'profile': {
              'user': {
                'id': 1,
                'username': 'logout_user',
                'email': 'user@example.com',
              },
              'role': 'consumer',
            },
            'csrf_token': 'logout-csrf',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      if (request.url.path == '/api/auth/logout/') {
        return http.Response(
          jsonEncode({'detail': 'Logout berhasil.'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not found', 404);
    });

    final authService = AuthService(apiClient: ApiClient(client: mockClient));
    await authService.login(username: 'logout_user', password: 'password');
    expect(authService.isAuthenticated, isTrue);

    await tester.pumpWidget(MaterialApp(
      home: ProfilePage(role: UserRole.consumer, authService: authService),
    ));

    expect(find.text('logout_user'), findsOneWidget);

    await tester.ensureVisible(find.text('Keluar'));
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Keluar dari Akun'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
    expect(authService.isAuthenticated, isFalse);
  });

  testWidgets(
    'WelcomePage restores session on startup and navigates to RoleNavigationPage',
    (tester) async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/profile/') {
          return http.Response(
            jsonEncode({
              'user': {
                'id': 3,
                'username': 'restored_courier',
                'email': 'c@example.com',
              },
              'role': 'courier',
              'courier_profile': {
                'plate_number': 'B 9999 KZT',
                'vehicle_type': 'motor_box',
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final authService = AuthService(apiClient: ApiClient(client: mockClient));

      await tester.pumpWidget(MaterialApp(
        home: WelcomePage(authService: authService),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomePage), findsNothing);
      expect(find.byType(RoleNavigationPage), findsOneWidget);
      expect(find.text('Ruang Courier di GreenLoop'), findsOneWidget);
    },
  );

  testWidgets(
    'WelcomePage remains on WelcomePage when session check is 401/403',
    (tester) async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/profile/') {
          return http.Response(
            jsonEncode({
              'detail': 'Authentication credentials were not provided.',
            }),
            403,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final authService = AuthService(apiClient: ApiClient(client: mockClient));

      await tester.pumpWidget(MaterialApp(
        home: WelcomePage(authService: authService),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.byType(RoleNavigationPage), findsNothing);
    },
  );

  testWidgets(
    'WelcomePage remains on WelcomePage on network error without crashing',
    (tester) async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Failed to connect to host');
      });

      final authService = AuthService(apiClient: ApiClient(client: mockClient));

      await tester.pumpWidget(MaterialApp(
        home: WelcomePage(authService: authService),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.byType(RoleNavigationPage), findsNothing);
    },
  );
}
