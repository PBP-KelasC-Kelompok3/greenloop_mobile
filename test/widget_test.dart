import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:greenloop_mobile/app/app.dart';
import 'package:greenloop_mobile/features/auth/presentation/auth_pages.dart';
import 'package:greenloop_mobile/features/home/presentation/home_pages.dart';
import 'package:greenloop_mobile/features/profile/presentation/profile_pages.dart';

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

    // Dicek sebelum scroll: ListView hanya membangun item yang dekat dengan
    // area terlihat, jadi judul di bagian atas bisa hilang dari tree setelah
    // halaman digulir (bergantung pada tinggi layout/teks).
    expect(find.text('Gabung dengan GreenLoop'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Nama Usaha'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Nama Usaha'), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('login validates locally without claiming success', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Email wajib diisi.'), findsOneWidget);
    expect(find.text('Bagian ini wajib diisi.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'user@example.com',
    );
    await tester.enterText(find.byKey(const Key('login-password')), 'password');

    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(
      find.textContaining('Koneksi API belum diimplementasikan'),
      findsOneWidget,
    );
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(RoleNavigationPage), findsNothing);
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
}