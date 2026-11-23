import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/network/api_client.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/services/auth_service.dart';
import '../data/courier_service.dart';

const Color _green = Color(0xFF185D3C);
const Color _darkGreen = Color(0xFF123D28);
const Color _ink = Color(0xFF1E3327);
const Color _muted = Color(0xFF7A887E);
const Color _page = Color(0xFFF4F7F2);
const Color _line = Color(0xFFE5EBE3);

enum CourierPageMode { dashboard, route, recap }

class CourierDashboardPage extends StatefulWidget {
  const CourierDashboardPage({
    required this.authService,
    this.mode = CourierPageMode.dashboard,
    super.key,
  });

  final AuthService? authService;
  final CourierPageMode mode;

  @override
  State<CourierDashboardPage> createState() => _CourierDashboardPageState();
}

class _CourierDashboardPageState extends State<CourierDashboardPage> {
  late final CourierService? _service;
  CourierPlan? _plan;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final api = widget.authService?.apiClient;
    _service = api == null ? null : CourierService(api);
    final courierProfile = widget.authService?.currentUser?.courierProfile;
    if (courierProfile != null) {
      _plan = CourierPlan(
        stops: const [],
        isOnDuty: courierProfile.isOnDuty ?? false,
        isApproved: courierProfile.isApproved ?? false,
        plateNumber: courierProfile.plateNumber ?? '',
        vehicleType: courierProfile.vehicleType ?? '',
      );
    }
    _load();
  }

  Future<void> _load() async {
    if (_service == null) {
      setState(() {
        _loading = false;
        _error = 'Sesi login Kurir tidak tersedia. Silakan masuk ulang.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plan = await _service!.fetchPlan();
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Data rute gagal dimuat. Periksa koneksi ke server.';
        _loading = false;
      });
    }
  }

  Future<void> _changeDuty(bool value) async {
    if (_service == null || _saving) return;
    setState(() => _saving = true);
    try {
      final plan = await _service!.setDuty(value);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _saving = false;
      });
      _message(value
          ? 'Status aktif. Sistem akan menugaskan pickup yang sesuai.'
          : 'Status bertugas dinonaktifkan.');
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _message(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _message('Status bertugas gagal diperbarui. Coba lagi.');
    }
  }

  Future<void> _startPickup(CourierStop stop) async {
    if (_service == null || _saving) return;
    setState(() => _saving = true);
    try {
      final plan = await _service!.startPickup(stop.id);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _saving = false;
      });
      _message('Perjalanan ke ${stop.name} dimulai.');
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _message(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _message('Pickup gagal dimulai. Periksa koneksi lalu coba lagi.');
    }
  }

  Future<void> _finishPickup(CourierStop stop) async {
    final controller = TextEditingController();
    final weight = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan penjemputan'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Masukkan berat aktual dari ${stop.name}.'),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Berat aktual', suffixText: 'kg', border: OutlineInputBorder()),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Lanjutkan')),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || weight == null) return;
    final parsedWeight = double.tryParse(weight.replaceAll(',', '.'));
    if (parsedWeight == null || parsedWeight < 0.1 || parsedWeight > 5000) {
      _message('Masukkan berat aktual antara 0,1 sampai 5.000 kg.');
      return;
    }

    setState(() => _saving = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Aktifkan layanan lokasi perangkat lalu coba lagi.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi diperlukan untuk memverifikasi kamu berada di titik mitra.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );
      final plan = await _service!.finishPickup(
        id: stop.id,
        weightKg: weight.replaceAll(',', '.'),
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _saving = false;
      });
      _message('Pickup ${stop.code} selesai. Berat aktual dan poin sudah dicatat.');
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _message(error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _message(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _vehicleLabel(UserProfile? user) {
    final profile = user?.courierProfile;
    final vehicle = profile?.vehicleType?.trim() ?? '';
    final plate = profile?.plateNumber?.trim() ?? '';
    final vehicleLabel = switch (vehicle.toLowerCase()) {
      'motor_box' || 'motor box' => 'Motor Box',
      'pickup_bak' || 'pickup bak' => 'Pickup Bak',
      _ => vehicle,
    };
    return [plate, vehicleLabel].where((value) => value.isNotEmpty).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.authService?.currentUser;
    final stops = _plan?.stops ?? const <CourierStop>[];
    final completed = stops.where((stop) => stop.isDone).toList();
    final active = stops.where((stop) => !stop.isDone).toList();
    final estimated = stops.fold<double>(0, (sum, stop) => sum + stop.estimatedKg);
    final weighed = completed.fold<double>(
      0,
      (sum, stop) => sum + (stop.actualKg ?? 0),
    );

    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: RefreshIndicator(
              color: _green,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                children: [
                  _heading(currentUser, _vehicleLabel(currentUser)),
                  const SizedBox(height: 15),
                  if (_error != null) _errorCard(_error!),
                  if (_loading && _plan == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator(color: _green)),
                    )
                  else if (_plan != null) ...[
                    if (!_plan!.isApproved) _approvalNotice(),
                    if (widget.mode != CourierPageMode.recap)
                      _dutyCard(_plan!),
                    if (widget.mode == CourierPageMode.dashboard) ...[
                      const SizedBox(height: 12),
                      _stats(stops.length, completed.length, estimated, weighed),
                      const SizedBox(height: 18),
                      _sectionTitle('Tugas Berikutnya'),
                      const SizedBox(height: 9),
                      if (active.isEmpty)
                        _emptyCard('Belum ada tugas pickup',
                            'Pickup yang disetujui admin dan ditugaskan kepada akunmu akan muncul di sini.')
                      else
                        _stopCard(active.first, canStart: _plan!.isApproved),
                    ] else if (widget.mode == CourierPageMode.route) ...[
                      const SizedBox(height: 17),
                      _sectionTitle('Rute Penjemputan', subtitle: '${stops.length} tugas dari sistem'),
                      const SizedBox(height: 9),
                      if (stops.isEmpty)
                        _emptyCard('Rute belum tersedia',
                            'Tugas akan muncul setelah ada pickup yang disetujui admin dan dialokasikan kepadamu.')
                      else
                        for (final stop in stops) ...[
                          _stopCard(stop, canStart: _plan!.isApproved),
                          const SizedBox(height: 9),
                        ],
                    ] else ...[
                      const SizedBox(height: 17),
                      _sectionTitle('Rekap Penjemputan', subtitle: '${completed.length} selesai hari ini'),
                      const SizedBox(height: 9),
                      if (completed.isEmpty)
                        _emptyCard('Belum ada pickup selesai',
                            'Berat aktual dan Waste Points akan tercatat setelah proses penjemputan diselesaikan.')
                      else
                        for (final stop in completed) ...[
                          _completedCard(stop),
                          const SizedBox(height: 9),
                        ],
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heading(UserProfile? user, String vehicle) {
    final name = user?.user.displayName ?? 'Kurir';
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Halo, $name 👋',
              style: const TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(height: 3),
          Text(vehicle.isEmpty ? 'Kurir GreenLoop' : vehicle,
              style: const TextStyle(color: _muted, fontSize: 11)),
        ]),
      ),
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: _line)),
        child: const Icon(Icons.local_shipping_outlined, color: _green, size: 21),
      ),
    ]);
  }

  Widget _approvalNotice() => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFFFF4DE), borderRadius: BorderRadius.circular(13)),
        child: const Row(children: [
          Icon(Icons.hourglass_top_rounded, color: Color(0xFFAA6B00), size: 19),
          SizedBox(width: 8),
          Expanded(child: Text('Akun Kurir menunggu persetujuan admin. Pickup belum dapat dimulai.', style: TextStyle(color: Color(0xFF77520C), fontSize: 11, height: 1.4))),
        ]),
      );

  Widget _dutyCard(CourierPlan plan) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 11, 12),
        decoration: BoxDecoration(color: _darkGreen, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF2C764C), borderRadius: BorderRadius.circular(11)), child: Icon(plan.isOnDuty ? Icons.power_settings_new_rounded : Icons.power_off_rounded, color: Colors.white, size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Status bertugas', style: TextStyle(color: Colors.white70, fontSize: 10)),
              Text(plan.isOnDuty ? 'Sedang Bertugas' : 'Tidak Bertugas', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
            ])),
            Switch(
              value: plan.isOnDuty,
              onChanged: _saving || !plan.isApproved ? null : _changeDuty,
              activeTrackColor: const Color(0xFFA6D85D),
            ),
          ]),
          Text(
            !plan.isApproved
                ? 'Status bertugas dapat diaktifkan setelah akun disetujui admin.'
                : plan.isOnDuty
                    ? 'Sistem dapat menugaskan pickup yang sesuai dengan armada dan kapasitasmu.'
                    : 'Aktifkan status agar sistem dapat mengalokasikan pickup kepadamu.',
            style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.45),
          ),
        ]),
      );

  Widget _stats(int count, int done, double estimate, double weighed) => Row(children: [
        Expanded(child: _StatCard(value: '$count', label: 'Tugas hari ini')),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(value: '$done', label: 'Selesai')),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(value: '${_kg(weighed > 0 ? weighed : estimate)} kg', label: weighed > 0 ? 'Berat aktual' : 'Estimasi tugas')),
      ]);

  Widget _sectionTitle(String title, {String? subtitle}) => Row(children: [
        Expanded(child: Text(title, style: const TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w800))),
        if (subtitle != null) Text(subtitle, style: const TextStyle(color: _muted, fontSize: 10)),
      ]);

  Widget _stopCard(CourierStop stop, {required bool canStart}) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: _line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.location_on_rounded, color: _green, size: 19),
            const SizedBox(width: 7),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(stop.name, style: const TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 13)),
              if (stop.address.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(stop.address, style: const TextStyle(color: _muted, fontSize: 10, height: 1.35)),
              ],
            ])),
            _statusPill(stop.status),
          ]),
          const SizedBox(height: 11),
          const Divider(height: 1, color: _line),
          const SizedBox(height: 10),
          Wrap(spacing: 12, runSpacing: 7, children: [
            _TaskDetail(icon: Icons.confirmation_number_outlined, text: stop.code),
            if (stop.slot.isNotEmpty) _TaskDetail(icon: Icons.access_time_rounded, text: stop.slot),
            _TaskDetail(
              icon: Icons.scale_outlined,
              text: stop.actualKg == null
                  ? '${_kg(stop.estimatedKg)} kg estimasi'
                  : '${_kg(stop.actualKg!)} kg aktual',
            ),
            if (stop.vehicle.isNotEmpty) _TaskDetail(icon: Icons.local_shipping_outlined, text: stop.vehicle),
          ]),
          if (stop.photoNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Catatan mitra: ${stop.photoNote}', style: const TextStyle(color: _muted, fontSize: 10)),
          ],
          if (!stop.isDone && canStart) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 40, child: FilledButton.icon(
              onPressed: _saving
                  ? null
                  : stop.isActive
                      ? () => _finishPickup(stop)
                      : () => _startPickup(stop),
              style: FilledButton.styleFrom(backgroundColor: _green, disabledBackgroundColor: const Color(0xFFE7EEE8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
              icon: Icon(stop.isActive ? Icons.task_alt_rounded : Icons.play_arrow_rounded, size: 18),
              label: Text(stop.isActive ? 'Input berat & selesaikan' : 'Mulai penjemputan', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            )),
          ],
        ]),
      );

  Widget _completedCard(CourierStop stop) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: _line)),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF4B985B)),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(stop.name, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w700)),
            Text(stop.code, style: const TextStyle(color: _muted, fontSize: 10)),
          ])),
          Text('${_kg(stop.actualKg ?? 0)} kg', style: const TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
      );

  Widget _emptyCard(String title, String subtitle) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: _line)),
        child: Column(children: [
          const Icon(Icons.route_outlined, color: _green, size: 27),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 10, height: 1.45)),
        ]),
      );

  Widget _errorCard(String message) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFFFEAE8), borderRadius: BorderRadius.circular(13)),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFD64A43), size: 19),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF9D3833), fontSize: 11))),
          TextButton(onPressed: _load, child: const Text('Ulangi')),
        ]),
      );

  Widget _statusPill(String status) {
    final (label, color, background) = switch (status) {
      'done' => ('Selesai', const Color(0xFF43874D), const Color(0xFFE7F3E7)),
      'active' => ('Menuju', const Color(0xFF317CB5), const Color(0xFFE7F2FA)),
      'next' => ('Berikutnya', const Color(0xFFB27610), const Color(0xFFFFF2DC)),
      _ => ('Dijadwalkan', const Color(0xFF63736A), const Color(0xFFF0F3F0)),
    };
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 9)));
  }

  String _kg(double value) => value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1).replaceAll('.', ',');
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: _line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 9)),
        ]),
      );
}

class _TaskDetail extends StatelessWidget {
  const _TaskDetail({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: _muted, size: 13),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w600)),
      ]);
}
