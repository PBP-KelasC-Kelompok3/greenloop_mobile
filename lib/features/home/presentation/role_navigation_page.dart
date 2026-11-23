import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../admin/presentation/admin_courier_verification_page.dart';
import '../../admin/presentation/admin_orders_page.dart';
import '../../admin/presentation/admin_products_page.dart';
import '../../auth/services/auth_service.dart';
import '../../admin/presentation/admin_dashboard_page.dart';
import '../../consumer/presentation/consumer_profile_page.dart';
import '../../courier/presentation/courier_page.dart';
import '../../mitra/data/mitra_shop_service.dart';
import '../../mitra/presentation/mitra_cart_page.dart';
import '../../mitra/presentation/mitra_orders_page.dart';
import '../../mitra/presentation/mitra_pickup_history_page.dart';
import '../../mitra/presentation/mitra_pickup_page.dart';
import '../../mitra/presentation/mitra_shop_page.dart';
import '../../profile/presentation/profile_pages.dart';
import '../../waste_reward/presentation/waste_reward_page.dart';
import '../../../dashboard_mitra_page.dart';

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
  bool _showMitraHistory = false;

  GLTabRole get _tabRole => tabRoleFor(widget.role);

  List<GLTabItem> get _tabs => glTabsByRole[_tabRole]!;

  AuthService get _auth => widget.authService ?? defaultAuthService;

  late final MitraShopService _shopService = MitraShopService(_auth);

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  void _selectTabLabel(String label) =>
      _selectTab(_tabs.indexWhere((tab) => tab.label == label));

  Widget _selectedPage() {
    // Riwayat penjemputan Mitra (halaman Filza) tampil penuh tanpa tab bar.
    if (_tabRole == GLTabRole.mitra && _showMitraHistory) {
      return MitraPickupHistoryPage(
        authService: widget.authService,
        onBack: () => setState(() {
          _showMitraHistory = false;
          if (_tabs[_selectedIndex].label == 'Jemput') {
            _selectedIndex = 0;
          }
        }),
        onCreatePickup: () => setState(() {
          _showMitraHistory = false;
          _selectedIndex = _tabs.indexWhere((t) => t.label == 'Jemput');
        }),
      );
    }

    final label = _tabs[_selectedIndex].label;

    switch ((_tabRole, label)) {
      // --- Mitra (halaman Filza + Waste & Reward) ---------------------------
      case (GLTabRole.mitra, 'Beranda'):
        return DashboardMitraPage(
          authService: widget.authService,
          onCreatePickup: () => _selectTabLabel('Jemput'),
          onShowReward: () => _selectTabLabel('Reward'),
          onShowShop: () => _selectTabLabel('Belanja'),
          onShowHistory: () => setState(() => _showMitraHistory = true),
        );
      case (GLTabRole.mitra, 'Jemput'):
        return MitraPickupPage(
          authService: widget.authService,
          onBack: () => _selectTabLabel('Beranda'),
          onSubmitted: (_) => setState(() => _showMitraHistory = true),
        );
      case (GLTabRole.mitra, 'Reward'):
        return WasteRewardPage(
          onOpenCatalog: () => _selectTabLabel('Belanja'),
        );
      case (GLTabRole.mitra, 'Belanja'):
        return MitraShopPage(authService: widget.authService);

      // --- Konsumen (katalog, keranjang, pesanan memakai halaman Filza) -----
      case (GLTabRole.konsumen, 'Katalog'):
        return MitraShopPage(authService: widget.authService);
      case (GLTabRole.konsumen, 'Keranjang'):
        return MitraCartPage(service: _shopService);
      case (GLTabRole.konsumen, 'Pesanan'):
        return MitraOrdersPage(service: _shopService);
      case (GLTabRole.konsumen, 'Profil'):
        return ConsumerProfilePage(
          authService: widget.authService,
          onOpenOrders: () => _selectTabLabel('Pesanan'),
          onOpenCart: () => _selectTabLabel('Keranjang'),
          onOpenCatalog: () => _selectTabLabel('Katalog'),
        );

      // --- Kurir (halaman Rafata) -------------------------------------------
      case (GLTabRole.kurir, 'Dashboard' || 'Rute' || 'Rekap'):
        return const CourierDashboardPage();

      // --- Admin (dashboard verifikasi Filza + layar Figma baru) ------------
      case (GLTabRole.admin, 'Beranda' || 'Pikap'):
        return AdminDashboardPage(authService: widget.authService);
      case (GLTabRole.admin, 'Kurir'):
        return AdminCourierVerificationPage(
          onBack: () => _selectTabLabel('Beranda'),
        );
      case (GLTabRole.admin, 'Produk'):
        return const AdminProductsPage();
      case (GLTabRole.admin, 'Pesanan'):
        return const AdminOrdersPage();

      // --- Umum -------------------------------------------------------------
      case (_, 'Profil'):
        return ProfilePage(role: widget.role, authService: widget.authService);
      case (_, 'Beranda' || 'Dashboard'):
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
        'Belanja' || 'Katalog' || 'Keranjang' || 'Pesanan' => 'E-Commerce',
        'Rute' || 'Rekap' => 'Courier & Route',
        _ => 'GreenLoop',
      };

  @override
  Widget build(BuildContext context) {
    // Ajukan Penjemputan dan Riwayat (halaman Filza) punya tombol kembali
    // sendiri dan tampil tanpa tab bar, seperti di main.
    if (_tabRole == GLTabRole.mitra &&
        (_showMitraHistory || _tabs[_selectedIndex].label == 'Jemput')) {
      return _selectedPage();
    }

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
    this.showBack = false,
    super.key,
  });

  final String title;
  final String module;
  final IconData icon;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GLScreenHeader(
          title: title,
          subtitle: 'Modul $module',
          showBack: showBack,
        ),
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
