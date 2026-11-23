import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../data/admin_management_service.dart';

class AdminCourierPage extends StatefulWidget {
  const AdminCourierPage({this.authService, super.key});
  final AuthService? authService;
  @override
  State<AdminCourierPage> createState() => _AdminCourierPageState();
}

class _AdminCourierPageState extends State<AdminCourierPage> {
  late final AdminManagementService _service;
  List<AdminCourierItem> _couriers = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  bool _showApproved = false;

  @override
  void initState() {
    super.initState();
    _service = AdminManagementService(widget.authService ?? defaultAuthService);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _service.couriers();
      if (mounted) setState(() => _couriers = rows);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve(AdminCourierItem courier) async {
    final okay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui akun Kurir?'),
        content: Text(
          'Pastikan data kendaraan ${courier.name} (${courier.plateNumber.isEmpty ? 'plat belum diisi' : courier.plateNumber}) sudah diverifikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Periksa lagi'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
    if (okay != true) return;
    setState(() => _saving = true);
    try {
      final message = await _service.approveCourier(courier.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      await _load();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _couriers.where((item) => !item.isApproved).toList();
    final approved = _couriers.where((item) => item.isApproved).toList();
    final visible = _showApproved ? approved : pending;
    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kurir'),
            Text(
              'Verifikasi dan status akun',
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
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Text(
              'Persetujuan Kurir',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _countCard(
                    'Menunggu verifikasi',
                    pending.length,
                    Icons.hourglass_top_rounded,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _countCard(
                    'Disetujui',
                    approved.length,
                    Icons.verified_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text('Menunggu (${pending.length})'),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Disetujui (${approved.length})'),
                ),
              ],
              selected: {_showApproved},
              onSelectionChanged: _loading
                  ? null
                  : (value) => setState(() => _showApproved = value.first),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _notice(
                'Data Kurir belum dapat dimuat',
                _error!,
                action: TextButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi'),
                ),
              )
            else if (visible.isEmpty)
              _notice(
                _showApproved
                    ? 'Belum ada Kurir disetujui'
                    : 'Tidak ada pendaftaran menunggu',
                _showApproved
                    ? 'Akun yang disetujui Admin akan tercatat di sini.'
                    : 'Pendaftaran Kurir baru akan muncul di daftar ini.',
              )
            else
              for (final courier in visible)
                _CourierCard(
                  courier: courier,
                  approved: _showApproved,
                  saving: _saving,
                  onApprove: () => _approve(courier),
                ),
          ],
        ),
      ),
    );
  }

  Widget _countCard(String label, int count, IconData icon) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: GreenLoopColors.forest2),
        const SizedBox(height: 7),
        Text(
          '$count',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: GreenLoopColors.muted),
        ),
      ],
    ),
  );
}

class _CourierCard extends StatelessWidget {
  const _CourierCard({
    required this.courier,
    required this.approved,
    required this.saving,
    required this.onApprove,
  });
  final AdminCourierItem courier;
  final bool approved;
  final bool saving;
  final VoidCallback onApprove;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: GreenLoopColors.mint,
              child: Text(
                courier.name.isEmpty ? 'K' : courier.name[0].toUpperCase(),
                style: const TextStyle(
                  color: GreenLoopColors.forest2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courier.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '@${courier.username}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: GreenLoopColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            _pill(approved ? 'Disetujui' : 'Menunggu', approved),
          ],
        ),
        const Divider(height: 22),
        _line(
          Icons.email_outlined,
          courier.email.isEmpty ? 'Email belum diisi' : courier.email,
        ),
        _line(Icons.local_shipping_outlined, courier.vehicleType),
        _line(
          Icons.pin_outlined,
          courier.plateNumber.isEmpty
              ? 'Nomor kendaraan belum diisi'
              : courier.plateNumber,
        ),
        _line(
          courier.isOnDuty ? Icons.work_outline : Icons.work_off_outlined,
          courier.isOnDuty ? 'Sedang bertugas' : 'Tidak bertugas',
        ),
        if (!approved) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: saving ? null : onApprove,
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Setujui Kurir'),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _line(IconData icon, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Row(
    children: [
      Icon(icon, size: 16, color: GreenLoopColors.forest2),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: GreenLoopColors.textMuted,
          ),
        ),
      ),
    ],
  ),
);
Widget _pill(String value, bool approved) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
  decoration: BoxDecoration(
    color: approved ? GreenLoopColors.mint : const Color(0xFFFFF2DB),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    value,
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: approved ? GreenLoopColors.forest2 : const Color(0xFF9A6500),
    ),
  ),
);
Widget _notice(String title, String body, {Widget? action}) => Container(
  padding: const EdgeInsets.all(22),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: GreenLoopColors.border),
    borderRadius: BorderRadius.circular(15),
  ),
  child: Column(
    children: [
      const Icon(
        Icons.badge_outlined,
        size: 36,
        color: GreenLoopColors.forest2,
      ),
      const SizedBox(height: 10),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      Text(
        body,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: GreenLoopColors.muted),
      ),
      if (action != null) action,
    ],
  ),
);
