import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import 'admin_courier_approval_page.dart';
import 'admin_dashboard_page.dart';

class AdminNavigationPage extends StatefulWidget {
  const AdminNavigationPage({this.authService, super.key});

  final AuthService? authService;

  @override
  State<AdminNavigationPage> createState() => _AdminNavigationPageState();
}

class _AdminNavigationPageState extends State<AdminNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: GreenLoopColors.surface,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            AdminDashboardPage(authService: widget.authService),
            AdminCourierApprovalPage(
              authService: widget.authService ?? defaultAuthService,
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: GreenLoopColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 68,
              child: Row(
                children: [
                  Expanded(
                    child: _AdminNavItem(
                      label: 'Penjemputan',
                      icon: Icons.fact_check_outlined,
                      selectedIcon: Icons.fact_check,
                      selected: _selectedIndex == 0,
                      onTap: () => setState(() => _selectedIndex = 0),
                    ),
                  ),
                  Expanded(
                    child: _AdminNavItem(
                      label: 'Kurir',
                      icon: Icons.people_alt_outlined,
                      selectedIcon: Icons.people_alt,
                      selected: _selectedIndex == 1,
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 46,
                height: 29,
                decoration: BoxDecoration(
                  color: selected ? GreenLoopColors.mint : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: 21,
                  color: selected
                      ? GreenLoopColors.forest2
                      : GreenLoopColors.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? GreenLoopColors.forest2
                      : GreenLoopColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
}
