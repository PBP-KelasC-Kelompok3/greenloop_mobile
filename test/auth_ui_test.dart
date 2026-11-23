import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenloop_mobile/core/network/api_client.dart';
import 'package:greenloop_mobile/features/auth/presentation/auth_pages.dart';
import 'package:greenloop_mobile/features/auth/presentation/courier_pending_page.dart';
import 'package:greenloop_mobile/features/auth/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('tombol daftar mengikuti role yang dipilih', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Daftar sebagai Konsumen'), findsOneWidget);

    await tester.tap(find.byKey(const Key('register-role-courier')));
    await tester.pumpAndSettle();

    expect(find.text('Daftar sebagai Kurir'), findsOneWidget);
    expect(find.text('Nama lengkap'), findsOneWidget);
  });

  testWidgets('kurir yang baru daftar diarahkan ke halaman menunggu verifikasi', (
    tester,
  ) async {
    Map<String, dynamic>? sentPayload;
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/auth/csrf/') {
        return http.Response(jsonEncode({'csrf_token': 'csrf'}), 200,
            headers: {'content-type': 'application/json'});
      }
      if (request.url.path == '/api/auth/register/') {
        sentPayload = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'detail': 'Registrasi berhasil.',
            'profile': {
              'user': {'id': 9, 'username': 'budi.kurir', 'email': 'budi@mail.id'},
              'role': 'courier',
              'courier_profile': {'plate_number': 'B 1234 KZT', 'vehicle_type': 'mobil'},
            },
            'csrf_token': 'x',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not found', 404);
    });
    final authService = AuthService(apiClient: ApiClient(client: mockClient));

    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(
        authService: authService,
        initialRole: PublicRegistrationRole.courier,
      ),
    ));

    await tester.enterText(find.byKey(const Key('register-full_name')), 'Budi Santoso');
    await tester.enterText(find.byKey(const Key('register-username')), 'budi.kurir');
    await tester.enterText(find.byKey(const Key('register-email')), 'budi@mail.id');
    await tester.enterText(find.byKey(const Key('register-password1')), 'rahasia123');
    await tester.enterText(find.byKey(const Key('register-password2')), 'rahasia123');
    await tester.scrollUntilVisible(
      find.byKey(const Key('register-plate_number')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byKey(const Key('register-plate_number')), 'b 1234 kzt');

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.byType(CourierPendingPage), findsOneWidget);
    expect(find.text('Akun Kurir Sedang Diverifikasi'), findsOneWidget);
    expect(find.text('B 1234 KZT'), findsOneWidget);
    expect(sentPayload?['vehicle_type'], 'mobil');
  });
}
