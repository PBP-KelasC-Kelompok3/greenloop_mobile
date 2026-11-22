import 'package:flutter/material.dart';

import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../mitra/presentation/mitra_pickup_page.dart';
import '../../mitra/presentation/mitra_pickup_history_page.dart';
import '../../mitra/presentation/mitra_reward_page.dart';
import '../../mitra/presentation/mitra_shop_page.dart';
import '../../profile/presentation/profile_pages.dart';
import '../../../dashboard_mitra_page.dart';
import '../../admin/presentation/admin_navigation_page.dart';

/// Shell for authenticated users with role-specific bottom navigation tabs.
class RoleNavigationPage extends StatefulWidget {
  const RoleNavigationPage({
    required this.role,
    this.authService,
    super.key,
  });

  final UserRole role;
  final AuthService? authService;

  @override
  State<RoleNavigationPage> createState() => _RoleNavigationPageState();
}

class _RoleNavigationPageState extends State<RoleNavigationPage> {
  int _selectedIndex = 0;
  bool _showMitraHistory = false;

  List<_NavTab> get _tabs {
    switch (widget.role) {
      case UserRole.consumer:
      case UserRole.mitra:
        return const [
          _NavTab('Beranda', Icons.home_outlined, Icons.home),
          _NavTab(
            'Jemput',
            Icons.local_shipping_outlined,
            Icons.local_shipping,
          ),
          _NavTab('Reward', Icons.card_giftcard_outlined, Icons.card_giftcard),
          _NavTab('Belanja', Icons.shopping_cart_outlined, Icons.shopping_cart),
          _NavTab('Profil', Icons.person_outline, Icons.person),
        ];

      case UserRole.courier:
        return const [
          _NavTab('Beranda', Icons.home_outlined, Icons.home),
          _NavTab(
            'Jemput',
            Icons.local_shipping_outlined,
            Icons.local_shipping,
          ),
          _NavTab('Profil', Icons.person_outline, Icons.person),
        ];

      case UserRole.admin:
      case UserRole.unknown:
        return const [
          _NavTab('Beranda', Icons.home_outlined, Icons.home),
          _NavTab('Profil', Icons.person_outline, Icons.person),
        ];
    }
  }

  Widget _selectedPage() {
    if (widget.role == UserRole.mitra && _showMitraHistory) {
      return MitraPickupHistoryPage(
        authService: widget.authService,
        onBack: () => setState(() {
          _showMitraHistory = false;
          if (_selectedIndex == 1) _selectedIndex = 0;
        }),
        onCreatePickup: () => setState(() {
          _showMitraHistory = false;
          _selectedIndex = 1;
        }),
      );
    }

    final selectedLabel = _tabs[_selectedIndex].label;

    if (widget.role == UserRole.mitra && selectedLabel == 'Reward') {
      return const MitraRewardPage();
    }
    if (widget.role == UserRole.mitra && selectedLabel == 'Belanja') {
      return const MitraShopPage();
    }

    if (selectedLabel == 'Profil') {
      return ProfilePage(
        role: widget.role,
        authService: widget.authService,
      );
    }

    if (widget.role == UserRole.mitra && selectedLabel == 'Jemput') {
      return MitraPickupPage(
        authService: widget.authService,
        onBack: () => setState(() => _selectedIndex = 0),
        onSubmitted: (_) => setState(() => _showMitraHistory = true),
      );
    }

    if (selectedLabel == 'Beranda') {
      if (widget.role == UserRole.mitra) {
        return DashboardMitraPage(
          authService: widget.authService,
          onCreatePickup: () => setState(() => _selectedIndex = 1),
          onShowReward: () => setState(() => _selectedIndex = 2),
          onShowShop: () => setState(() => _selectedIndex = 3),
          onShowHistory: () => setState(() => _showMitraHistory = true),
        );
      }
      return AuthenticatedHomePage(role: widget.role);
    }

    return _ModulePlaceholder(title: selectedLabel);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == UserRole.admin) {
      return AdminNavigationPage(authService: widget.authService);
    }

    if (widget.role == UserRole.mitra &&
        (_selectedIndex == 1 || _showMitraHistory)) {
      return _selectedPage();
    }

    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      body: SafeArea(bottom: false, child: _selectedPage()),
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
                for (var index = 0; index < _tabs.length; index++)
                  Expanded(
                    child: _BottomNavItem(
                      tab: _tabs[index],
                      selected: _selectedIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticatedHomePage extends StatelessWidget {
  const AuthenticatedHomePage({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(title: const GreenLoopLogo(width: 165)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Beranda',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Ruang ${role.label} di GreenLoop',
            style: const TextStyle(color: GreenLoopColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: GreenLoopColors.deepForest,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.insights_outlined,
                  color: GreenLoopColors.leaf,
                  size: 28,
                ),
                SizedBox(height: 10),
                Text(
                  'Live Impact',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Data dashboard akan ditampilkan setelah API terintegrasi.',
                  style: TextStyle(
                    color: Color(0xFFD8E6DA),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  const _NavTab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                selected ? tab.selectedIcon : tab.icon,
                size: 21,
                color: selected
                    ? GreenLoopColors.forest2
                    : GreenLoopColors.muted,
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
}

class _ModulePlaceholder extends StatelessWidget {
  const _ModulePlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.hourglass_empty,
                size: 40,
                color: GreenLoopColors.forest2,
              ),
              const SizedBox(height: 12),
              Text(
                '$title belum tersedia',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Modul ini akan diintegrasikan dengan pekerjaan '
                'anggota tim terkait.',
                textAlign: TextAlign.center,
                style: TextStyle(color: GreenLoopColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
