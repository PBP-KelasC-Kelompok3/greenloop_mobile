import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenloop_mobile/features/auth/data/auth_models.dart';
import 'package:greenloop_mobile/features/home/presentation/role_navigation_page.dart';
import 'package:greenloop_mobile/features/waste_reward/presentation/waste_reward_page.dart';
import 'package:greenloop_mobile/shared/theme/greenloop_theme.dart';

Future<void> _pumpReward(WidgetTester tester, {VoidCallback? onOpenCatalog}) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(MaterialApp(
    theme: GreenLoopTheme.light,
    home: Scaffold(
      body: WasteRewardPage(
        onOpenCatalog: onOpenCatalog,
        now: DateTime(2026, 11, 18),
        random: Random(1),
      ),
    ),
  ));
}

void main() {
  testWidgets('M07 menampilkan saldo, katalog voucher, dan riwayat poin',
      (tester) async {
    await _pumpReward(tester);

    expect(find.text('Waste & Reward'), findsOneWidget);
    expect(find.text('1 kg terverifikasi = 5 Waste Points'), findsOneWidget);
    expect(find.text('2.430'), findsOneWidget);
    expect(find.text('570 poin lagi ke Gold'), findsOneWidget);
    expect(find.text('Level Silver'), findsOneWidget);
    expect(find.text('Rp 10.000'), findsOneWidget);
    expect(find.text('GLV-10K-8FQ2'), findsOneWidget);
    expect(find.text('Setoran PK-0931 · 35,2 kg'), findsOneWidget);
    expect(find.text('+176'), findsOneWidget);
  });

  testWidgets('tukar voucher memotong poin dan membuka M24', (tester) async {
    var openedCatalog = false;
    await _pumpReward(tester, onOpenCatalog: () => openedCatalog = true);

    await tester.tap(find.text('Tukar').first);
    await tester.pumpAndSettle();

    expect(find.text('Voucher Berhasil Ditukar!'), findsOneWidget);
    expect(find.text('−200 poin'), findsOneWidget);
    expect(
      find.text('Berlaku s.d. 18 Des 2026 · Sisa saldo 2.230 poin'),
      findsOneWidget,
    );
    final code = tester.widget<Text>(find.byKey(const Key('redeemed-code')));
    expect(code.data, startsWith('GLV-10K-'));

    await tester.tap(find.text('Pakai di Katalog'));
    await tester.pumpAndSettle();

    expect(openedCatalog, isTrue);
    expect(find.text('2.230'), findsOneWidget);
    expect(find.text(code.data!), findsOneWidget);
  });

  testWidgets('voucher yang poinnya tidak cukup tidak bisa ditukar',
      (tester) async {
    await _pumpReward(tester);

    // Voucher B2B butuh 1.000 poin: dua kali tukar 1.000 dari 2.430 poin,
    // tukar ketiga harus ditolak.
    final catalog = find.byKey(const Key('voucher-catalog'));
    await tester.drag(catalog, const Offset(-600, 0));
    await tester.pumpAndSettle();
    final b2bButton = find.text('Tukar').last;

    for (var i = 0; i < 2; i++) {
      await tester.tap(b2bButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
    }
    expect(find.text('430'), findsOneWidget);

    await tester.tap(b2bButton);
    await tester.pumpAndSettle();
    expect(find.text('Voucher Berhasil Ditukar!'), findsNothing);
  });

  testWidgets('tab Reward Mitra membuka halaman Waste & Reward',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: GreenLoopTheme.light,
      home: const RoleNavigationPage(role: UserRole.mitra),
    ));

    await tester.tap(find.text('Reward'));
    await tester.pumpAndSettle();

    expect(find.byType(WasteRewardPage), findsOneWidget);
  });
}
