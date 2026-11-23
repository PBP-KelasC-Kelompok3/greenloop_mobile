import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/presentation/auth_pages.dart';
import '../../auth/services/auth_service.dart';
import '../data/admin_management_service.dart';
import '../data/admin_pickup_service.dart';

class AdminOverviewPage extends StatefulWidget {
  const AdminOverviewPage({
    this.authService,
    this.onWaste,
    this.onCouriers,
    this.onCatalog,
    super.key,
  });
  final AuthService? authService;
  final VoidCallback? onWaste;
  final VoidCallback? onCouriers;
  final VoidCallback? onCatalog;
  @override
  State<AdminOverviewPage> createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends State<AdminOverviewPage> {
  int? _pendingPickups;
  int? _waitingCouriers;
  int? _products;
  bool _loading = true;

  Future<void> _logout() async {
    final auth = widget.authService ?? defaultAuthService;
    try {
      await auth.logout();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => LoginPage(authService: auth)),
      (_) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final auth = widget.authService ?? defaultAuthService;
    final management = AdminManagementService(auth);
    try {
      final results = await Future.wait([
        AdminPickupService(auth).list(),
        management.couriers(),
        management.products(),
      ]);
      if (!mounted) return;
      final pickups = results[0] as List<AdminPickupItem>;
      final couriers = results[1] as List<AdminCourierItem>;
      final products = results[2] as List<AdminProduct>;
      setState(() {
        _pendingPickups = pickups
            .where((item) => item.status == 'PENDING')
            .length;
        _waitingCouriers = couriers.where((item) => !item.isApproved).length;
        _products = products.length;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          _pendingPickups = null;
          _waitingCouriers = null;
          _products = null;
        });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard Admin'),
          Text(
            'Ringkasan operasional GreenLoop',
            style: TextStyle(fontSize: 11, color: GreenLoopColors.muted),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _loading ? null : _load,
          tooltip: 'Muat ulang',
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          onPressed: _logout,
          tooltip: 'Keluar',
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: GreenLoopColors.deepForest,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  color: GreenLoopColors.leaf,
                  size: 28,
                ),
                SizedBox(height: 9),
                Text(
                  'Pusat pengelolaan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tinjau pengajuan limbah, verifikasi akun Kurir, dan kelola produk katalog dari satu tempat.',
                  style: TextStyle(
                    color: Color(0xFFD8E6DA),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Perlu ditangani',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Pengajuan menunggu',
                  value: _loading ? '…' : _show(_pendingPickups),
                  icon: Icons.recycling_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  label: 'Kurir menunggu',
                  value: _loading ? '…' : _show(_waitingCouriers),
                  icon: Icons.delivery_dining_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _Metric(
            label: 'Produk dalam katalog',
            value: _loading ? '…' : _show(_products),
            icon: Icons.inventory_2_outlined,
            horizontal: true,
          ),
          const SizedBox(height: 18),
          const Text(
            'Modul Admin',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 9),
          _ModuleTile(
            icon: Icons.recycling_outlined,
            title: 'Sampah',
            subtitle: 'Periksa foto, setujui atau tolak pengajuan Mitra.',
            onTap: widget.onWaste,
          ),
          _ModuleTile(
            icon: Icons.delivery_dining_outlined,
            title: 'Kurir',
            subtitle: 'Verifikasi akun dan lihat status bertugas Kurir.',
            onTap: widget.onCouriers,
          ),
          _ModuleTile(
            icon: Icons.storefront_outlined,
            title: 'Katalog',
            subtitle: 'Tambah produk, harga bersama, stok, dan berat.',
            onTap: widget.onCatalog,
          ),
        ],
      ),
    ),
  );
}

String _show(int? value) => value?.toString() ?? '—';

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    this.horizontal = false,
  });
  final String label;
  final String value;
  final IconData icon;
  final bool horizontal;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(15),
    ),
    child: horizontal
        ? Row(
            children: [
              Icon(icon, color: GreenLoopColors.forest2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: GreenLoopColors.muted,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: GreenLoopColors.forest2),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.3,
                  color: GreenLoopColors.muted,
                ),
              ),
            ],
          ),
  );
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: GreenLoopColors.border),
    ),
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: GreenLoopColors.mint,
        child: Icon(icon, color: GreenLoopColors.forest2),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
