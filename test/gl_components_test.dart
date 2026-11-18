import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenloop_mobile/core/widgets/gl_components.dart';
import 'package:greenloop_mobile/shared/theme/greenloop_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: GreenLoopTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('GLTabBar menampilkan tab sesuai role dan memanggil onTap', (tester) async {
    for (final role in GLTabRole.values) {
      int? tapped;
      await tester.pumpWidget(_wrap(
        GLTabBar(role: role, currentIndex: 0, onTap: (i) => tapped = i),
      ));

      final items = glTabsByRole[role]!;
      for (final item in items) {
        expect(find.text(item.label), findsOneWidget);
      }

      await tester.tap(find.text(items.last.label));
      expect(tapped, items.length - 1);
    }
  });

  testWidgets('GLFilterChips mengirim index chip yang diketuk', (tester) async {
    int? selected;
    await tester.pumpWidget(_wrap(
      GLFilterChips(
        labels: const ['Semua', 'Menunggu', 'Selesai'],
        selectedIndex: 0,
        onSelected: (i) => selected = i,
      ),
    ));

    await tester.tap(find.text('Selesai'));
    expect(selected, 2);
  });

  testWidgets('GLStatusStepper menampilkan semua langkah', (tester) async {
    await tester.pumpWidget(_wrap(
      const GLStatusStepper(
        steps: ['Verifikasi foto', 'Kurir ditugaskan', 'Dijemput', 'Selesai'],
        currentIndex: 1,
      ),
    ));

    expect(find.text('Verifikasi foto'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    // Langkah setelah langkah aktif masih bernomor.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });
}
