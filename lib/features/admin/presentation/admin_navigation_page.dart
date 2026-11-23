import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import 'admin_catalog_page.dart';
import 'admin_courier_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_overview_page.dart';

class AdminNavigationPage extends StatefulWidget {
  const AdminNavigationPage({this.authService, super.key});
  final AuthService? authService;
  @override
  State<AdminNavigationPage> createState() => _AdminNavigationPageState();
}

class _AdminNavigationPageState extends State<AdminNavigationPage> {
  int _index = 0;

  static const _tabs = <({String label, IconData icon, IconData selected})>[
    (
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selected: Icons.dashboard,
    ),
    (
      label: 'Sampah',
      icon: Icons.recycling_outlined,
      selected: Icons.recycling,
    ),
    (
      label: 'Kurir',
      icon: Icons.delivery_dining_outlined,
      selected: Icons.delivery_dining,
    ),
    (
      label: 'Katalog',
      icon: Icons.storefront_outlined,
      selected: Icons.storefront,
    ),
  ];

  Widget _page() => switch (_index) {
    0 => AdminOverviewPage(
      authService: widget.authService,
      onWaste: () => setState(() => _index = 1),
      onCouriers: () => setState(() => _index = 2),
      onCatalog: () => setState(() => _index = 3),
    ),
    1 => AdminDashboardPage(authService: widget.authService),
    2 => AdminCourierPage(authService: widget.authService),
    _ => AdminCatalogPage(authService: widget.authService),
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    body: SafeArea(bottom: false, child: _page()),
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
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _AdminNavItem(
                    tab: _tabs[i],
                    selected: _index == i,
                    onTap: () => setState(() => _index = i),
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
    required this.tab,
    required this.selected,
    required this.onTap,
  });
  final ({String label, IconData icon, IconData selected}) tab;
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
              selected ? tab.selected : tab.icon,
              size: 21,
              color: selected ? GreenLoopColors.forest2 : GreenLoopColors.muted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            tab.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? GreenLoopColors.forest2 : GreenLoopColors.muted,
            ),
          ),
        ],
      ),
    ),
  );
}
