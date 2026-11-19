import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../data/admin_courier_service.dart';

class AdminCourierApprovalPage extends StatefulWidget {
  const AdminCourierApprovalPage({required this.authService, super.key});

  final AuthService authService;

  @override
  State<AdminCourierApprovalPage> createState() =>
      _AdminCourierApprovalPageState();
}

class _AdminCourierApprovalPageState extends State<AdminCourierApprovalPage> {
  late final AdminCourierService _service;
  List<AdminCourierItem> _couriers = const [];
  bool _loading = true;
  String? _error;
  bool _showApproved = false;

  @override
  void initState() {
    super.initState();
    _service = AdminCourierService(widget.authService);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final couriers = await _service.list();
      if (!mounted) return;
      setState(() {
        _couriers = couriers;
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
        _error = 'Daftar kurir gagal dimuat: $error';
        _loading = false;
      });
    }
  }

  Future<void> _approve(AdminCourierItem courier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui akun kurir?'),
        content: Text(
          'Setelah disetujui, ${courier.fullName.isEmpty ? courier.username : courier.fullName} dapat masuk ke dashboard kurir dan dipertimbangkan sistem untuk menerima penjemputan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Setujui kurir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final detail = await _service.approve(courier.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail)),
      );
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _couriers.where((item) => !item.isApproved).length;
    final visible = _couriers
        .where((item) => item.isApproved == _showApproved)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(
        title: const Text('Verifikasi Kurir'),
        actions: [
          IconButton(
            onPressed: _load,
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            Text(
              '$pendingCount akun menunggu pemeriksaan data kurir.',
              style: const TextStyle(
                color: GreenLoopColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text('Menunggu ($pendingCount)'),
                ),
                const ButtonSegment(
                  value: true,
                  label: Text('Disetujui'),
                ),
              ],
              selected: {_showApproved},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _showApproved = selection.first),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _CourierMessage(
                icon: Icons.cloud_off_outlined,
                title: 'Data kurir gagal dimuat',
                message: _error!,
                action: _load,
              )
            else if (visible.isEmpty)
              _CourierMessage(
                icon: _showApproved
                    ? Icons.verified_user_outlined
                    : Icons.hourglass_empty,
                title: _showApproved
                    ? 'Belum ada kurir disetujui'
                    : 'Tidak ada antrean kurir',
                message: _showApproved
                    ? 'Akun kurir yang disetujui akan tampil di sini.'
                    : 'Pendaftaran kurir baru akan muncul di sini untuk diperiksa.',
              )
            else
              ...visible.map(
                (courier) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _CourierCard(
                    courier: courier,
                    onApprove: courier.isApproved ? null : () => _approve(courier),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CourierCard extends StatelessWidget {
  const _CourierCard({required this.courier, this.onApprove});

  final AdminCourierItem courier;
  final VoidCallback? onApprove;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: GreenLoopColors.border),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: GreenLoopColors.mint,
                  child: Text(
                    courier.username.isEmpty
                        ? 'K'
                        : courier.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: GreenLoopColors.forest2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courier.fullName.isEmpty
                            ? courier.username
                            : courier.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        courier.email.isEmpty ? courier.username : courier.email,
                        style: const TextStyle(
                          color: GreenLoopColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  courier.isApproved
                      ? Icons.verified
                      : Icons.pending_outlined,
                  color: courier.isApproved
                      ? GreenLoopColors.forest2
                      : const Color(0xFFB9750C),
                ),
              ],
            ),
            const Divider(height: 22),
            _CourierInfo(label: 'Jenis armada', value: courier.vehicleType),
            const SizedBox(height: 7),
            _CourierInfo(label: 'Nomor kendaraan', value: courier.plateNumber),
            if (courier.isApproved) ...[
              const SizedBox(height: 7),
              _CourierInfo(
                label: 'Status tugas',
                value: courier.isOnDuty ? 'Sedang bertugas' : 'Tidak bertugas',
              ),
            ],
            if (onApprove != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('Setujui akun kurir'),
                ),
              ),
            ],
          ],
        ),
      );
}

class _CourierInfo extends StatelessWidget {
  const _CourierInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: GreenLoopColors.muted,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Belum diisi' : value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
}

class _CourierMessage extends StatelessWidget {
  const _CourierMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: GreenLoopColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: GreenLoopColors.forest2, size: 32),
            const SizedBox(height: 9),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GreenLoopColors.muted,
                fontSize: 12,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 10),
              OutlinedButton(onPressed: action, child: const Text('Coba lagi')),
            ],
          ],
        ),
      );
}
