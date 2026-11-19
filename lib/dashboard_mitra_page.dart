import 'package:flutter/material.dart';

import 'features/auth/services/auth_service.dart';
import 'shared/theme/greenloop_theme.dart';

class DashboardMitraPage extends StatelessWidget {
  const DashboardMitraPage({
    this.authService,
    this.onCreatePickup,
    this.onShowHistory,
    this.onShowReward,
    this.onShowShop,
    super.key,
  });

  final AuthService? authService;
  final VoidCallback? onCreatePickup;
  final VoidCallback? onShowHistory;
  final VoidCallback? onShowReward;
  final VoidCallback? onShowShop;

  @override
  Widget build(BuildContext context) {
    final profile = (authService ?? defaultAuthService).currentUser;
    final mitra = profile?.mitraProfile;
    final businessName = mitra?.businessName?.trim().isNotEmpty == true
        ? mitra!.businessName!.trim()
        : (profile?.user.displayName ?? 'Mitra');
    final location = [mitra?.kecamatan, mitra?.kota]
        .where((part) => part?.trim().isNotEmpty == true)
        .join(', ');

    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(
        backgroundColor: GreenLoopColors.surface,
        titleSpacing: 18,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: GreenLoopColors.circleGreen,
              child: Text(
                _initials(businessName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Halo, $businessName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Mitra B2B${location.isEmpty ? '' : ' · $location'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: GreenLoopColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Notifikasi',
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: GreenLoopColors.border),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _PointsCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickAction(
                icon: Icons.local_shipping_outlined,
                label: 'Ajukan',
                onTap: onCreatePickup,
              ),
              _QuickAction(
                icon: Icons.receipt_long_outlined,
                label: 'Riwayat',
                onTap: onShowHistory,
              ),
              _QuickAction(
                icon: Icons.card_giftcard_outlined,
                label: 'Tukar Poin',
                onTap: onShowReward,
              ),
              _QuickAction(
                icon: Icons.shopping_cart_outlined,
                label: 'Belanja',
                onTap: onShowShop,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Penjemputan Aktif',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: onShowHistory,
                child: const Text('Lihat riwayat'),
              ),
            ],
          ),
          const _EmptyDataCard(
            icon: Icons.inbox_outlined,
            title: 'Belum ada data penjemputan',
            message:
                'Pengajuan yang kamu buat akan muncul di bagian ini setelah data penjemputan tersedia.',
          ),
          const SizedBox(height: 18),
          const Text(
            'Dampak Kamu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _ImpactCard(icon: Icons.recycling_outlined, label: 'Limbah'),
              _ImpactCard(icon: Icons.water_drop_outlined, label: 'CO₂e dicegah'),
              _ImpactCard(icon: Icons.eco_outlined, label: 'Sabun dibuat'),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ringkasan dampak akan tampil setelah data penjemputan tersedia.',
            style: TextStyle(fontSize: 11, color: GreenLoopColors.muted),
          ),
        ],
      ),
    );
  }

  static String _initials(String value) {
    final words = value.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return 'M';
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }
}

class _PointsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: GreenLoopColors.deepForest,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saldo Waste Points',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        SizedBox(height: 12),
        Text(
          'Belum tersedia',
          style: TextStyle(
            color: GreenLoopColors.leaf,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Saldo poin akan tampil setelah terhubung ke data reward.',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: GreenLoopColors.border),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: GreenLoopColors.circleGreen, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GreenLoopColors.border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: GreenLoopColors.circleGreen),
          const SizedBox(height: 14),
          const Text('—', style: TextStyle(fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 9, color: GreenLoopColors.muted)),
        ],
      ),
    ),
  );
}

class _EmptyDataCard extends StatelessWidget {
  const _EmptyDataCard({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: GreenLoopColors.circleGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(message, style: const TextStyle(color: GreenLoopColors.muted, fontSize: 11, height: 1.4)),
            ],
          ),
        ),
      ],
    ),
  );
}
