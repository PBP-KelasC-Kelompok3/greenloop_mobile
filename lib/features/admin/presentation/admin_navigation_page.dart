import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import 'admin_dashboard_page.dart';

class AdminNavigationPage extends StatelessWidget {
  const AdminNavigationPage({this.authService, super.key});

  final AuthService? authService;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: GreenLoopColors.surface,
        body: AdminDashboardPage(authService: authService),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: GreenLoopColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 68,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 29,
                    decoration: BoxDecoration(
                      color: GreenLoopColors.mint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.dashboard,
                      size: 21,
                      color: GreenLoopColors.forest2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: GreenLoopColors.forest2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
