import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenloop_mobile/core/widgets/gl_components.dart';
import 'package:greenloop_mobile/features/auth/data/auth_models.dart';
import 'package:greenloop_mobile/features/courier/presentation/courier_page.dart';
import 'package:greenloop_mobile/features/home/presentation/demo_login.dart';
import 'package:greenloop_mobile/features/home/presentation/role_navigation_page.dart';
import 'package:greenloop_mobile/shared/dummy/dummy_data.dart';
import 'package:greenloop_mobile/shared/theme/greenloop_theme.dart';

void main() {
  testWidgets('tiap role memakai tab bar sesuai Figma', (tester) async {
    const expected = {
      UserRole.mitra: GLTabRole.mitra,
      UserRole.consumer: GLTabRole.konsumen,
      UserRole.courier: GLTabRole.kurir,
      UserRole.admin: GLTabRole.admin,
    };

    for (final entry in expected.entries) {
      await tester.pumpWidget(MaterialApp(
        theme: GreenLoopTheme.light,
        home: RoleNavigationPage(role: entry.key),
      ));

      final tabBar = tester.widget<GLTabBar>(find.byType(GLTabBar));
      expect(tabBar.role, entry.value);
    }
  });

  testWidgets('tab Kurir membuka dashboard kurir dari main', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: GreenLoopTheme.light,
      home: const RoleNavigationPage(role: UserRole.courier),
    ));

    expect(find.byType(CourierDashboardPage), findsOneWidget);

    await tester.tap(find.text('Rute'));
    await tester.pumpAndSettle();

    expect(find.byType(CourierDashboardPage), findsOneWidget);
    expect(find.byType(ModulePlaceholderPage), findsNothing);
  });

  testWidgets('masuk demo membuka shell role yang dipilih', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: GreenLoopTheme.light,
      home: const Scaffold(body: Center(child: DemoLoginButton())),
    ));

    await tester.tap(find.text('Masuk demo (tanpa backend)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kurir'));
    await tester.pumpAndSettle();

    final page = tester.widget<RoleNavigationPage>(find.byType(RoleNavigationPage));
    expect(page.role, UserRole.courier);
  });

  test('format angka dummy', () {
    expect(formatRupiah(32000), 'Rp32.000');
    expect(formatThousands(2430), '2.430');
    expect(formatKg(35.2), '35,2 kg');
    expect(formatKg(40), '40 kg');
  });
}
