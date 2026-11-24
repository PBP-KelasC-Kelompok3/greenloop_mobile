import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';

class MitraFaqPage extends StatelessWidget {
  const MitraFaqPage({super.key});

  static const _questions = <(String, String)>[
    (
      'Bagaimana mengajukan penjemputan?',
      'Buka tab Jemput, isi jenis dan perkiraan berat limbah, pilih jadwal, lalu kirim foto untuk verifikasi.',
    ),
    (
      'Di mana melihat status penjemputan?',
      'Status pengajuan dan tahapan penjemputan dapat dilihat dari Riwayat Penjemputan.',
    ),
    (
      'Bagaimana membeli produk GreenLoop?',
      'Pilih produk pada tab Belanja, masukkan ke keranjang, lalu selesaikan checkout dan pembayaran.',
    ),
    (
      'Siapa yang memperbarui status pesanan?',
      'Status pesanan diperbarui oleh sistem dan Admin. Nomor resi tampil setelah informasi pengiriman tersedia.',
    ),
    (
      'Bagaimana mengubah informasi usaha?',
      'Buka Profil, pilih tombol edit, perbarui data usaha, lalu simpan perubahan.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(title: const Text('Bantuan & FAQ')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Pertanyaan seputar akun Mitra, penjemputan, dan belanja produk.',
          style: TextStyle(color: GreenLoopColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        for (final item in _questions)
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: GreenLoopColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ExpansionTile(
              title: Text(
                item.$1,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              children: [
                Text(
                  item.$2,
                  style: const TextStyle(
                    color: GreenLoopColors.muted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
