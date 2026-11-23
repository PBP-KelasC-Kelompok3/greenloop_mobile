import 'package:flutter/material.dart';

const Color _green = Color(0xFF185D3C);
const Color _darkGreen = Color(0xFF123D28);
const Color _ink = Color(0xFF1E3327);
const Color _muted = Color(0xFF7A887E);
const Color _page = Color(0xFFF4F7F2);
const Color _line = Color(0xFFE5EBE3);

class CourierDashboardPage extends StatefulWidget {
  const CourierDashboardPage({super.key});

  @override
  State<CourierDashboardPage> createState() => _CourierDashboardPageState();
}

class _CourierDashboardPageState extends State<CourierDashboardPage> {
  bool _onDuty = true;
  bool _pickupStarted = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              children: [
                _buildGreeting(),
                const SizedBox(height: 14),
                _buildDutyCard(),
                const SizedBox(height: 12),
                _buildWeatherCard(),
                const SizedBox(height: 12),
                _buildStats(),
                const SizedBox(height: 16),
                _buildNextTaskHeading(),
                const SizedBox(height: 9),
                _buildNextTaskCard(),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, Budi 👋', style: TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 21)),
              SizedBox(height: 4),
              Text('B 1234 KZT · Motor Box', style: TextStyle(color: _muted, fontSize: 10)),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _line)),
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Notifikasi',
                onPressed: () => _showMessage('Belum ada notifikasi baru.'),
                icon: const Icon(Icons.notifications_none_rounded, color: _ink, size: 20),
              ),
            ),
            Positioned(right: 8, top: 7, child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFE45448), shape: BoxShape.circle))),
          ],
        ),
      ],
    );
  }

  Widget _buildDutyCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 11, 12),
      decoration: BoxDecoration(color: _darkGreen, borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(color: const Color(0xFF2C764C), borderRadius: BorderRadius.circular(10)),
            child: Icon(_onDuty ? Icons.power_settings_new_rounded : Icons.power_off_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Status Tugas', style: TextStyle(color: Colors.white70, fontSize: 9)),
            Text(_onDuty ? 'Sedang Bertugas' : 'Tidak Bertugas', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ])),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _onDuty,
              onChanged: (value) => setState(() => _onDuty = value),
              activeTrackColor: const Color(0xFFA6D85D),
              activeThumbColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              inactiveThumbColor: Colors.white,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Text(
          _onDuty
              ? 'Kamu akan menerima penugasan penjemputan dari admin selama status aktif.'
              : 'Aktifkan status untuk menerima penugasan penjemputan dari admin.',
          style: const TextStyle(color: Colors.white, fontSize: 9, height: 1.45),
        ),
      ]),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: _line)),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: const Color(0xFFFFF0D8), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFF0A126), size: 19),
        ),
        const SizedBox(width: 9),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Depok · 29°C Cerah Berawan', style: TextStyle(color: _ink, fontSize: 10, fontWeight: FontWeight.w800)),
          SizedBox(height: 3),
          Text('Hujan 10% · via Open-Meteo', style: TextStyle(color: _muted, fontSize: 8)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFFE8F4E7), borderRadius: BorderRadius.circular(20)),
          child: const Text('Aman', style: TextStyle(color: Color(0xFF4E863B), fontWeight: FontWeight.w700, fontSize: 8)),
        ),
      ]),
    );
  }

  Widget _buildStats() {
    return const Row(children: [
      Expanded(child: _StatCard(value: '4', label: 'Tugas Hari Ini')),
      SizedBox(width: 8),
      Expanded(child: _StatCard(value: '1', label: 'Selesai')),
      SizedBox(width: 8),
      Expanded(child: _StatCard(value: '14,2 kg', label: 'Ditimbang')),
    ]);
  }

  Widget _buildNextTaskHeading() {
    return Row(children: [
      const Expanded(child: Text('Tugas Berikutnya', style: TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w800))),
      TextButton(
        onPressed: () => _showMessage('Halaman rute akan tersedia pada tahap berikutnya.'),
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        child: const Text('Lihat rute', style: TextStyle(color: _green, fontSize: 9, fontWeight: FontWeight.w700)),
      ),
    ]);
  }

  Widget _buildNextTaskCard() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.location_on_rounded, color: _green, size: 17),
          const SizedBox(width: 5),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hotel Arya Depok', style: TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 11)),
            SizedBox(height: 3),
            Text('Jl. Margonda Raya 88, Beji', style: TextStyle(color: _muted, fontSize: 8)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFF4385C9), borderRadius: BorderRadius.circular(20)),
            child: const Text('Dijadwalkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 7)),
          ),
        ]),
        const SizedBox(height: 10),
        const Divider(height: 1, color: _line),
        const SizedBox(height: 9),
        const Wrap(spacing: 12, runSpacing: 6, children: [
          _TaskDetail(icon: Icons.access_time_rounded, text: '10:00–12:00'),
          _TaskDetail(icon: Icons.eco_outlined, text: 'Sisa Makanan'),
          _TaskDetail(icon: Icons.scale_outlined, text: '±55 kg'),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 35,
              child: FilledButton(
                onPressed: () {
                  setState(() => _pickupStarted = true);
                  _showMessage('Penjemputan Hotel Arya Depok dimulai.');
                },
                style: FilledButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)), padding: EdgeInsets.zero),
                child: Text(_pickupStarted ? 'Penjemputan Dimulai' : 'Mulai Penjemputan', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 35,
            height: 35,
            child: OutlinedButton(
              onPressed: () => _showMessage('Fitur telepon mitra akan tersedia berikutnya.'),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, side: const BorderSide(color: _line), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
              child: const Icon(Icons.call_outlined, color: _green, size: 16),
            ),
          ),
        ]),
      ]),
    );
  }

}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: _line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, maxLines: 1, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 7)),
      ]),
    );
  }
}

class _TaskDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TaskDetail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: _muted, size: 11),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: _ink, fontSize: 8, fontWeight: FontWeight.w600)),
    ]);
  }
}