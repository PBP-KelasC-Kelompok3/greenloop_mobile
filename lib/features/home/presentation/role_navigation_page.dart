import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/presentation/profile_pages.dart';

/// Tab bar mana yang dipakai tiap role (komponen "Mobile / Tab Bar ..." di
/// Figma).
GLTabRole tabRoleFor(UserRole role) => switch (role) {
      UserRole.mitra => GLTabRole.mitra,
      UserRole.courier => GLTabRole.kurir,
      UserRole.admin => GLTabRole.admin,
      UserRole.consumer || UserRole.unknown => GLTabRole.konsumen,
    };

/// Shell untuk user yang sudah login, dengan tab bar bawah sesuai role.
class RoleNavigationPage extends StatefulWidget {
  const RoleNavigationPage({
    required this.role,
    this.authService,
    this.initialIndex = 0,
    super.key,
  });

  final UserRole role;
  final AuthService? authService;
  final int initialIndex;

  @override
  State<RoleNavigationPage> createState() => _RoleNavigationPageState();
}

class _RoleNavigationPageState extends State<RoleNavigationPage> {
  late int _selectedIndex = widget.initialIndex;

  GLTabRole get _tabRole => tabRoleFor(widget.role);

  List<GLTabItem> get _tabs => glTabsByRole[_tabRole]!;

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  Widget _selectedPage() {
    final label = _tabs[_selectedIndex].label;

    switch (label) {
      case 'Profil':
        return ProfilePage(role: widget.role, authService: widget.authService);
      case 'Beranda':
      case 'Dashboard':
        return AuthenticatedHomePage(role: widget.role);
      default:
        return ModulePlaceholderPage(
          title: label,
          module: _moduleFor(label),
          icon: _tabs[_selectedIndex].icon,
        );
    }
  }

  /// Nama modul (dan pemiliknya) untuk tab yang belum punya halaman.
  String _moduleFor(String label) => switch (label) {
        'Jemput' || 'Pikap' => 'Mitra & Pickup Scheduling',
        'Reward' => 'Waste & Reward System',
        'Belanja' || 'Katalog' || 'Keranjang' || 'Pesanan' || 'Produk' =>
          'E-Commerce',
        'Rute' || 'Rekap' || 'Kurir' => 'Courier & Route',
        _ => 'GreenLoop',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenLoopColors.background,
      body: SafeArea(bottom: false, child: _selectedPage()),
      bottomNavigationBar: GLTabBar(
        role: _tabRole,
        currentIndex: _selectedIndex,
        onTap: _selectTab,
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

/// Halaman sementara untuk tab yang layarnya belum dibangun.
class ModulePlaceholderPage extends StatelessWidget {
  const ModulePlaceholderPage({
    required this.title,
    required this.module,
    this.icon = LucideIcons.hourglass,
    super.key,
  });

  final String title;
  final String module;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GLScreenHeader(title: title, subtitle: 'Modul $module'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GLCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GLIconTile(icon: icon, size: 56, iconSize: 26),
                const SizedBox(height: 12),
                Text(
                  'Halaman $title sedang dibangun',
                  textAlign: TextAlign.center,
                  style: GreenLoopTypography.style(15, FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tampilan mengikuti Figma GreenLoop Mobile dan akan '
                  'dihubungkan ke API oleh pemilik modul.',
                  textAlign: TextAlign.center,
                  style: GreenLoopTypography.style(
                    12,
                    FontWeight.w400,
                    color: GreenLoopColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
