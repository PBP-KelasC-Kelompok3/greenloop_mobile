import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/presentation/auth_pages.dart';
import '../../auth/services/auth_service.dart';
import '../data/admin_pickup_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({this.authService, super.key});

  final AuthService? authService;

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  static const _filters = <String, String>{
    'Semua': 'ALL',
    'Menunggu': 'PENDING',
    'Menunggu kurir': 'APPROVED',
    'Diproses': 'SCHEDULED',
    'Selesai': 'COMPLETED',
    'Ditolak': 'REJECTED',
  };

  late final AdminPickupService _service;
  final _searchController = TextEditingController();
  List<AdminPickupItem> _items = const [];
  bool _loading = true;
  String? _error;
  String _filter = 'ALL';

  AuthService get _auth => widget.authService ?? defaultAuthService;

  @override
  void initState() {
    super.initState();
    _service = AdminPickupService(_auth);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.list();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Data pengajuan gagal dimuat: $error';
        _loading = false;
      });
    }
  }

  List<AdminPickupItem> get _visibleItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items
        .where((item) {
          final matchesStatus = _filter == 'ALL' || item.status == _filter;
          final haystack = <String>[
            item.code,
            item.mitraName,
            item.businessName,
            item.mitraEmail,
            item.wasteTypeLabel,
            item.notes,
          ].join(' ').toLowerCase();
          return matchesStatus && (query.isEmpty || haystack.contains(query));
        })
        .toList(growable: false);
  }

  Future<void> _changeStatus(AdminPickupItem item, String action) async {
    final approve = action == 'approve';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Setujui penjemputan?' : 'Tolak pengajuan?'),
        content: Text(
          approve
              ? 'Foto dan data ${item.code} akan disetujui. Sistem akan mencari kurir yang memenuhi syarat.'
              : 'Pengajuan ${item.code} akan ditolak dan statusnya diperbarui untuk mitra.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final detail = await _service.updateStatus(item.id, action);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(detail)));
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.logout();
    } catch (_) {
      // Returning to login also lets the user retry if the server is offline.
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => LoginPage(authService: _auth)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _items.where((item) => item.status == 'PENDING').length;
    final waitingCourier = _items
        .where((item) => item.status == 'APPROVED')
        .length;
    final visible = _visibleItems;

    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sampah'),
            Text(
              'Verifikasi penjemputan',
              style: TextStyle(fontSize: 11, color: GreenLoopColors.muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Keluar',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            const Text(
              'Periksa foto limbah sebelum penugasan kurir.',
              style: TextStyle(color: GreenLoopColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _CountCard(label: 'Menunggu', count: pending),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _CountCard(
                    label: 'Menunggu kurir',
                    count: waitingCourier,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _CountCard(label: 'Total', count: _items.length),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari ID, mitra, atau jenis limbah',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _filters.entries.map((entry) {
                  final selected = _filter == entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(entry.key),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = entry.value),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _MessageCard(
                icon: Icons.cloud_off_outlined,
                title: 'Data admin belum dapat dimuat',
                message: _error!,
                actionLabel: 'Coba lagi',
                onAction: _load,
              )
            else if (visible.isEmpty)
              const _MessageCard(
                icon: Icons.fact_check_outlined,
                title: 'Tidak ada pengajuan',
                message: 'Pengajuan yang sesuai filter akan tampil di sini.',
              )
            else
              ...visible.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PickupCard(
                    item: item,
                    onTap: () => _showDetails(item),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetails(AdminPickupItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PickupDetailsSheet(
        item: item,
        onApprove: item.status == 'PENDING'
            ? () {
                Navigator.pop(context);
                _changeStatus(item, 'approve');
              }
            : null,
        onReject: item.status == 'PENDING'
            ? () {
                Navigator.pop(context);
                _changeStatus(item, 'reject');
              }
            : null,
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: GreenLoopColors.muted),
        ),
      ],
    ),
  );
}

class _PickupCard extends StatelessWidget {
  const _PickupCard({required this.item, required this.onTap});

  final AdminPickupItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.code,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusPill(status: item.status, label: item.statusLabel),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              item.businessName.isEmpty
                  ? item.mitraName
                  : '${item.businessName} · ${item.mitraName}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              '${_dateLabel(item.pickupDate)} · ${item.timeSlot}',
              style: const TextStyle(
                color: GreenLoopColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${item.wasteTypeLabel} · ${_weightLabel(item.estimatedWeight)} kg',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            Text(
              'Armada: ${item.vehicle}',
              style: const TextStyle(
                color: GreenLoopColors.muted,
                fontSize: 12,
              ),
            ),
            if (item.photoUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.photoUrl!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _NoPhoto(),
                ),
              ),
            ],
            if (item.status == 'PENDING') ...[
              const SizedBox(height: 9),
              const Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 16,
                    color: GreenLoopColors.forest2,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Buka untuk periksa foto dan detail',
                    style: TextStyle(
                      color: GreenLoopColors.forest2,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ] else if (item.courierName != null) ...[
              const SizedBox(height: 7),
              Text(
                'Kurir: ${item.courierName}',
                style: const TextStyle(
                  color: GreenLoopColors.forest2,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _PickupDetailsSheet extends StatelessWidget {
  const _PickupDetailsSheet({
    required this.item,
    this.onApprove,
    this.onReject,
  });

  final AdminPickupItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.code,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusPill(status: item.status, label: item.statusLabel),
            ],
          ),
          const SizedBox(height: 14),
          if (item.photoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                item.photoUrl!,
                height: 210,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _NoPhoto(),
              ),
            )
          else
            const _NoPhoto(),
          const SizedBox(height: 16),
          _DetailLine(label: 'Mitra', value: item.mitraName),
          if (item.businessName.isNotEmpty)
            _DetailLine(label: 'Nama usaha', value: item.businessName),
          if (item.mitraEmail.isNotEmpty)
            _DetailLine(label: 'Email', value: item.mitraEmail),
          _DetailLine(label: 'Alamat', value: item.address),
          _DetailLine(label: 'Jenis limbah', value: item.wasteTypeLabel),
          _DetailLine(
            label: 'Estimasi berat',
            value: '${_weightLabel(item.estimatedWeight)} kg',
          ),
          _DetailLine(
            label: 'Jadwal',
            value: '${_dateLabel(item.pickupDate)} · ${item.timeSlot}',
          ),
          _DetailLine(label: 'Armada', value: item.vehicle),
          _DetailLine(
            label: 'Catatan mitra',
            value: item.notes.isEmpty ? 'Tidak ada catatan' : item.notes,
          ),
          if (item.latitude != null && item.longitude != null)
            _DetailLine(
              label: 'Titik peta',
              value:
                  '${item.latitude!.toStringAsFixed(5)}, ${item.longitude!.toStringAsFixed(5)}',
            ),
          if (item.courierName != null)
            _DetailLine(label: 'Kurir', value: item.courierName!),
          if (onApprove != null || onReject != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check),
                label: const Text('Setujui & cari kurir'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close),
                label: const Text('Tolak pengajuan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC74242),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: GreenLoopColors.muted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.label});

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'PENDING' => const Color(0xFFB9750C),
      'REJECTED' || 'CANCELLED' => const Color(0xFFC74242),
      'COMPLETED' => GreenLoopColors.forest2,
      'APPROVED' => const Color(0xFF4A82C4),
      _ => GreenLoopColors.textInk,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Icon(icon, size: 34, color: GreenLoopColors.forest2),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: GreenLoopColors.muted),
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}

class _NoPhoto extends StatelessWidget {
  const _NoPhoto();

  @override
  Widget build(BuildContext context) => Container(
    height: 190,
    decoration: BoxDecoration(
      color: GreenLoopColors.mint,
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 32),
          SizedBox(height: 6),
          Text('Foto tidak tersedia'),
        ],
      ),
    ),
  );
}

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _weightLabel(double weight) => weight == weight.roundToDouble()
    ? weight.toInt().toString()
    : weight.toStringAsFixed(1);
