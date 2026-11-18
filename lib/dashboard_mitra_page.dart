import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../mitra_form_page.dart';

class DashboardMitraPage extends StatelessWidget {
  const DashboardMitraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: const [
            Icon(Icons.all_inclusive, color: Color(0xFF198754), size: 28),
            SizedBox(width: 8),
            Text(
              'GREENLOOP',
              style: TextStyle(
                color: Color(0xFF198754),
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF198754),
                  child: const Text('FS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Kafe Senja Margonda', style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('Mitra B2B', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12, width: 1))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.all_inclusive, color: Color(0xFF198754), size: 32),
                        SizedBox(width: 8),
                        Text('GREENLOOP', style: TextStyle(color: Color(0xFF198754), fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Mitra B2B', style: TextStyle(color: Color(0xFF198754), fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text('MENU', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.grid_view, color: Color(0xFF198754)),
                title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF198754))),
                selected: true,
                selectedTileColor: Colors.green.shade50,
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.grey),
                title: const Text('Ajukan Penjemputan'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MitraFormPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt, color: Colors.grey),
                title: const Text('Riwayat Penjemputan'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.card_giftcard, color: Colors.grey),
                title: const Text('Waste & Reward'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.grey),
                title: const Text('Belanja Produk'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.grey),
                title: const Text('Profil Mitra'),
                onTap: () {},
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Area Pilot: Kota Depok', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
                    SizedBox(height: 2),
                    Text('Layanan penjemputan khusus wilayah Kota Depok.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Dashboard Mitra B2B', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 4),
                      Text('Pantau penjemputan, poin, dan dampak lingkungan usaha Anda secara real-time.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF198754),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MitraFormPage()));
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Ajukan Penjemputan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Total limbah disetor', '486', 'kg', Icons.autorenew, Colors.green.shade50, const Color(0xFF198754)),
                _buildStatCard('Saldo Waste Points', '2.430', 'PTS', Icons.monetization_on, const Color(0xFF1B4D3E), Colors.white, isDark: true),
                _buildStatCard('Penjemputan selesai', '8', 'kali', Icons.local_shipping_outlined, Colors.grey.shade100, Colors.black87),
                _buildStatCard('Estimasi CO2e dicegah', '364', 'kg', Icons.eco_outlined, Colors.cyan.shade50, Colors.cyan.shade800),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, IconData icon, Color bgColor, Color textColor, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18, color: textColor),
              ),
              if (!isDark)
                const Text('Terverifikasi', style: TextStyle(fontSize: 10, color: Color(0xFF198754), fontWeight: FontWeight.w600)),
            ],
          ),
          const Spacer(),
          Text(title, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}