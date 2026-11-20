import 'package:flutter/material.dart';

import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/presentation/auth_pages.dart';
export 'role_navigation_page.dart'
    show AuthenticatedHomePage, RoleNavigationPage;

// PUBLIC HOME

class PublicHomePage extends StatelessWidget {
  const PublicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(title: const GreenLoopLogo(width: 170)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GreenLoopColors.deepForest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GreenLoop',
                  style: TextStyle(
                    color: GreenLoopColors.leaf,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Ekonomi sirkular dimulai dari dapurmu.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Hubungkan limbah organik dengan penjemputan '
                  'dan produk eco-enzyme.',
                  style: TextStyle(
                    color: Color(0xFFD8E6DA),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: GreenLoopColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights_outlined,
                      color: GreenLoopColors.forest2,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Live Impact',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Data dampak akan ditampilkan setelah endpoint '
                  'Live Impact terintegrasi.',
                  style: TextStyle(
                    color: GreenLoopColors.muted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GreenLoopButton(
            label: 'Masuk ke akun',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          GreenLoopButton(
            label: 'Buat akun',
            secondary: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
