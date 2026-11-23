import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenloop_mobile/features/admin/presentation/admin_courier_verification_page.dart';
import 'package:greenloop_mobile/features/admin/presentation/admin_orders_page.dart';
import 'package:greenloop_mobile/features/admin/presentation/admin_products_page.dart';
import 'package:greenloop_mobile/features/admin/presentation/admin_profile_page.dart';
import 'package:greenloop_mobile/features/admin/presentation/admin_vouchers_page.dart';
import 'package:greenloop_mobile/features/auth/data/auth_models.dart';
import 'package:greenloop_mobile/features/home/presentation/role_navigation_page.dart';
import 'package:greenloop_mobile/shared/theme/greenloop_theme.dart';

Future<void> _pump(WidgetTester tester, Widget home) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(MaterialApp(
    theme: GreenLoopTheme.light,
    home: home is Scaffold ? home : Scaffold(body: home),
  ));
}

void main() {
  testWidgets('tab Admin membuka M21, M32, M34', (tester) async {
    await _pump(tester, const RoleNavigationPage(role: UserRole.admin));

    await tester.tap(find.text('Kurir'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminCourierVerificationPage), findsOneWidget);

    await tester.tap(find.text('Produk'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminProductsPage), findsOneWidget);

    await tester.tap(find.text('Pesanan'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminOrdersPage), findsOneWidget);
  });

  testWidgets('M21 menyetujui kurir memindahkannya ke Disetujui',
      (tester) async {
    await _pump(tester, const AdminCourierVerificationPage());

    expect(find.text('Admin · 2 pendaftar baru'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);

    await tester.tap(find.text('Setujui').first);
    await tester.pumpAndSettle();

    expect(find.text('Admin · 1 pendaftar baru'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsNothing);

    await tester.tap(find.text('Disetujui'));
    await tester.pumpAndSettle();
    expect(find.text('Budi Santoso'), findsOneWidget);
  });

  testWidgets('M32 mencari produk dan M33 menyimpan perubahan',
      (tester) async {
    await _pump(tester, const AdminProductsPage());

    expect(find.text('5 produk · tambah, ubah, hapus'), findsOneWidget);
    expect(find.text('B2C Rp 32.000 · B2B Rp 26.000'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'jeruk');
    await tester.pumpAndSettle();
    expect(find.text('Sabun Mandi Batang Jeruk'), findsOneWidget);
    expect(find.text('Refill Pouch 1L'), findsNothing);

    await tester.tap(find.byTooltip('Ubah'));
    await tester.pumpAndSettle();
    expect(find.text('Ubah Produk'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, '64'), '70');
    await tester.tap(find.text('Simpan Produk'));
    await tester.pumpAndSettle();

    expect(find.text('Stok 70 · 100 g'), findsOneWidget);
  });

  testWidgets('M34 memajukan status pesanan dan wajib isi resi',
      (tester) async {
    await _pump(tester, const AdminOrdersPage());

    expect(find.text('Dibayar 1'), findsOneWidget);
    await tester.tap(find.text('Lanjut ke Sedang Disiapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Lanjut ke Dalam Pengiriman'), findsNWidgets(2));

    // Tanpa resi: tetap di Sedang Disiapkan.
    await tester.tap(find.text('Lanjut ke Dalam Pengiriman').first);
    await tester.pumpAndSettle();
    expect(find.text('Isi nomor resi sebelum mengirim.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'JNE0001');
    await tester.tap(find.text('Lanjut ke Dalam Pengiriman').first);
    await tester.pumpAndSettle();
    expect(find.text('Resi JNE0001'), findsOneWidget);
  });

  testWidgets('M37 membuka M35, lalu M36 menambah voucher', (tester) async {
    await _pump(tester, const AdminProfilePage());

    expect(find.text('Admin GreenLoop'), findsOneWidget);
    expect(find.text('Kota Depok'), findsOneWidget);

    await tester.tap(find.text('Voucher Reward'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminVouchersPage), findsOneWidget);
    expect(find.text('4 aktif · 1 diarsipkan'), findsOneWidget);

    await tester.tap(find.text('Tambah Voucher'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminVoucherFormPage), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Diskon Rp50.000');
    await tester.enterText(fields.at(3), '900');
    await tester.tap(find.text('Simpan Voucher'));
    await tester.pumpAndSettle();

    expect(find.text('5 aktif · 1 diarsipkan'), findsOneWidget);
    expect(find.text('Diskon Rp50.000'), findsOneWidget);
    expect(find.text('Diskon · 900 poin · 30 hari'), findsOneWidget);
  });
}
