import 'package:flutter/material.dart';

import 'features/auth/services/auth_service.dart';
import 'features/mitra/data/mitra_dashboard_service.dart';
import 'features/mitra/presentation/pickup_progress_timeline.dart';
import 'shared/theme/greenloop_theme.dart';

class DashboardMitraPage extends StatefulWidget {
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
  State<DashboardMitraPage> createState() => _DashboardMitraPageState();
}

class _DashboardMitraPageState extends State<DashboardMitraPage> {
  late final MitraDashboardService _service;
  MitraDashboardSummary? _summary;
  bool _loading = true;
  String? _error;

  AuthService get _auth => widget.authService ?? defaultAuthService;

  @override
  void initState() {
    super.initState();
    _service = MitraDashboardService(_auth);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await _service.fetch();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _auth.currentUser;
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
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (_error != null) ...[
              _DashboardErrorCard(message: _error!, onRetry: _load),
              const SizedBox(height: 10),
            ],
            _PointsCard(summary: _summary, loading: _loading),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickAction(
                  icon: Icons.local_shipping_outlined,
                  label: 'Ajukan',
                  onTap: widget.onCreatePickup,
                ),
                _QuickAction(
                  icon: Icons.receipt_long_outlined,
                  label: 'Riwayat',
                  onTap: widget.onShowHistory,
                ),
                _QuickAction(
                  icon: Icons.card_giftcard_outlined,
                  label: 'Tukar Poin',
                  onTap: widget.onShowReward,
                ),
                _QuickAction(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Belanja',
                  onTap: widget.onShowShop,
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
                  onPressed: widget.onShowHistory,
                  child: const Text('Lihat riwayat'),
                ),
              ],
            ),
            _ActivePickupCard(
              pickup: _summary?.activePickup,
              loading: _loading,
              onTap: widget.onShowHistory,
            ),
            const SizedBox(height: 18),
            const Text(
              'Dampak Kamu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ImpactCard(
                  icon: Icons.recycling_outlined,
                  label: 'Limbah',
                  value: _loading || _summary == null
                      ? '—'
                      : '${_formatNumber(_summary!.totalWasteKg)} kg',
                ),
                _ImpactCard(
                  icon: Icons.water_drop_outlined,
                  label: 'CO₂e dicegah',
                  value: _loading || _summary == null
                      ? '—'
                      : '${_formatNumber(_summary!.co2SavedKg)} kg',
                ),
                _ImpactCard(
                  icon: Icons.local_shipping_outlined,
                  label: 'Pickup selesai',
                  value: _loading || _summary == null
                      ? '—'
                      : '${_summary!.completedPickups}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _loading
                  ? 'Memuat ringkasan data terverifikasi…'
                  : 'Dampak dihitung dari berat aktual penjemputan yang selesai.',
              style: const TextStyle(
                fontSize: 11,
                color: GreenLoopColors.muted,
              ),
            ),
          ],
        ),
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
  const _PointsCard({required this.summary, required this.loading});

  final MitraDashboardSummary? summary;
  final bool loading;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: GreenLoopColors.deepForest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo Waste Points',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              loading
                  ? 'Memuat…'
                  : summary == null
                      ? 'Belum tersedia'
                      : '${_formatInteger(summary!.points)} poin',
              style: const TextStyle(
                color: GreenLoopColors.leaf,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              loading
                  ? 'Mengambil saldo dari akun kamu…'
                  : summary == null
                      ? 'Saldo belum dapat dimuat. Tarik layar untuk mencoba lagi.'
                      : 'Level ${summary!.currentTier} · ${summary!.levelProgress}% menuju ${summary!.nextTier}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            if (summary != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: summary!.levelProgress.clamp(0, 100) / 100,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(GreenLoopColors.leaf),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${_formatInteger(summary!.points)} / ${_formatInteger(summary!.targetPoints)} poin',
                style: const TextStyle(color: Colors.white70, fontSize: 9),
              ),
            ],
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
                  child:
                      Icon(icon, color: GreenLoopColors.circleGreen, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  color: GreenLoopColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ActivePickupCard extends StatelessWidget {
  const _ActivePickupCard({
    required this.pickup,
    required this.loading,
    this.onTap,
  });

  final MitraActivePickup? pickup;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GreenLoopColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: loading
          ? const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Memuat penjemputan…',
                  style: TextStyle(color: GreenLoopColors.muted, fontSize: 12),
                ),
              ],
            )
          : pickup == null
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.inbox_outlined,
                        color: GreenLoopColors.circleGreen),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Belum ada penjemputan aktif',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pengajuan yang menunggu atau sedang diproses akan tampil di sini.',
                            style: TextStyle(
                              color: GreenLoopColors.muted,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${pickup!.code} · ${pickup!.wasteTypeLabel}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        _PickupStatusPill(status: pickup!.statusLabel),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_dateLabel(pickup!.pickupDate)} · ${pickup!.timeSlot} WIB · ${_formatNumber(pickup!.estimatedWeight)} kg',
                      style: const TextStyle(
                        color: GreenLoopColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    if (pickup!.courierName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Kurir: ${pickup!.courierName}',
                        style: const TextStyle(
                          color: GreenLoopColors.forest2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    PickupProgressTimeline(
                      status: pickup!.status,
                      courierName: pickup!.courierName,
                    ),
                  ],
                ),
    );

    if (loading || pickup == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: content,
    );
  }
}

class _PickupStatusPill extends StatelessWidget {
  const _PickupStatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: GreenLoopColors.mint,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: const TextStyle(
            color: GreenLoopColors.forest2,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _DashboardErrorCard extends StatelessWidget {
  const _DashboardErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: GreenLoopColors.border),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: GreenLoopColors.forest2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Dashboard gagal dimuat: $message',
                style: const TextStyle(
                  fontSize: 11,
                  color: GreenLoopColors.muted,
                ),
              ),
            ),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              tooltip: 'Coba lagi',
            ),
          ],
        ),
      );
}

String _formatNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);

String _formatInteger(int value) => value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
