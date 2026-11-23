import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenloop_mobile/features/auth/data/auth_models.dart';
import 'package:greenloop_mobile/features/consumer/presentation/consumer_profile_page.dart';
import 'package:greenloop_mobile/features/consumer/presentation/order_tracking_page.dart';
import 'package:greenloop_mobile/features/home/presentation/role_navigation_page.dart';
import 'package:greenloop_mobile/features/mitra/presentation/mitra_shop_page.dart';
import 'package:greenloop_mobile/shared/theme/greenloop_theme.dart';

void _phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('M14 menampilkan ringkasan, timeline, dan isi paket',
      (tester) async {
    _phoneSize(tester);
    await tester.pumpWidget(MaterialApp(
      theme: GreenLoopTheme.light,
      home: const OrderTrackingPage(),
    ));

    expect(find.text('Lacak Pesanan'), findsOneWidget);
    expect(find.text('#GL-260926-0142'), findsOneWidget);
    expect(find.text('JNE0123456789'), findsOneWidget);
    expect(find.text('QRIS · Lunas'), findsOneWidget);
    // Status di badge + di timeline.
    expect(find.text('Dalam Pengiriman'), findsNWidgets(2));
    expect(find.text('Terkini'), findsOneWidget);
    expect(find.text('Estimasi 30 Sep 2026'), findsOneWidget);
    expect(find.text('2 × Rp 32.000'), findsOneWidget);
    expect(
      find.text(
          'Pesanan ini membantu menyelamatkan ±4,6 kg limbah organik dari TPA.'),
      findsOneWidget,
    );
  });

  testWidgets('tab Profil Konsumen membuka M26 dan menunya pindah tab',
      (tester) async {
    _phoneSize(tester);
    await tester.pumpWidget(MaterialApp(
      theme: GreenLoopTheme.light,
      home: const RoleNavigationPage(role: UserRole.consumer),
    ));

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.byType(ConsumerProfilePage), findsOneWidget);
    expect(find.text('Nadia Putri'), findsOneWidget);
    expect(find.text('nadiaputri'), findsOneWidget);
    expect(find.text('2 Nov 2026'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);

    await tester.tap(find.text('Katalog Produk'));
    await tester.pumpAndSettle();

    expect(find.byType(ConsumerProfilePage), findsNothing);
    expect(find.byType(MitraShopPage), findsOneWidget);
  });
}
