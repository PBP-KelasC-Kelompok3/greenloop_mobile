import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/dummy/dummy_data.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../services/auth_service.dart';
import 'auth_pages.dart';

/// M15 · Kurir Menunggu Verifikasi.
///
/// Tampil setelah kurir mendaftar. Data pendaftaran diisi dari form
/// register; kalau kosong memakai data contoh dari Figma.
class CourierPendingPage extends StatelessWidget {
  const CourierPendingPage({
    this.authService,
    this.name,
    this.email,
    this.plateNumber,
    this.vehicleType,
    this.registeredAt = '18 Nov 2026',
    super.key,
  });

  final AuthService? authService;
  final String? name;
  final String? email;
  final String? plateNumber;
  final String? vehicleType;
  final String registeredAt;

  String _or(String? value, String fallback) =>
      value == null || value.isEmpty ? fallback : value;

  Future<void> _logout(BuildContext context) async {
    final auth = authService ?? defaultAuthService;
    try {
      await auth.logout();
    } catch (_) {
      // Tetap kembali ke onboarding walau server tidak bisa dihubungi.
    }
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => WelcomePage(authService: auth, skipSessionCheck: true),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Nama', _or(name, DummyData.courier.name)),
      ('Email', _or(email, 'budi.kurir@greenloop.id')),
      ('No. Plat', _or(plateNumber, DummyData.courier.plateNumber)),
      ('Jenis Kendaraan', _or(vehicleType, DummyData.courier.vehicleType)),
      ('Didaftarkan', registeredAt),
    ];

    return Scaffold(
      backgroundColor: GreenLoopColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 76),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: const BoxDecoration(
                        color: GreenLoopColors.green100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.hourglass,
                        size: 52,
                        color: GreenLoopColors.green700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Akun Kurir Sedang Diverifikasi',
                      textAlign: TextAlign.center,
                      style: GreenLoopTypography.style(20, FontWeight.w700,
                          color: GreenLoopColors.green900, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Admin GreenLoop sedang memeriksa data kendaraanmu. Kamu '
                      'bisa mulai menerima tugas penjemputan setelah akun disetujui.',
                      textAlign: TextAlign.center,
                      style: GreenLoopTypography.style(13, FontWeight.w400,
                          color: GreenLoopColors.textMuted),
                    ),
                    const SizedBox(height: 20),
                    GLCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Data Pendaftaran',
                                  style: GreenLoopTypography.style(14, FontWeight.w600,
                                      height: 1.3),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: GreenLoopColors.amber,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.clock,
                                        size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Menunggu Verifikasi',
                                      style: GreenLoopTypography.style(
                                          11, FontWeight.w600,
                                          color: Colors.white, height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: GreenLoopColors.cardBorder),
                          for (final (label, value) in rows) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  label,
                                  style: GreenLoopTypography.style(12, FontWeight.w400,
                                      color: GreenLoopColors.textMuted, height: 1.3),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    value,
                                    textAlign: TextAlign.right,
                                    style: GreenLoopTypography.style(
                                        12, FontWeight.w600, height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: GreenLoopColors.green100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(LucideIcons.info,
                              size: 18, color: GreenLoopColors.green700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Kami akan kirim notifikasi begitu admin menyetujui '
                              'akunmu. Biasanya 1×24 jam.',
                              style: GreenLoopTypography.style(12, FontWeight.w400,
                                  color: GreenLoopColors.green700, height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 20),
                    GreenLoopButton(
                      label: 'Keluar',
                      secondary: true,
                      onPressed: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
