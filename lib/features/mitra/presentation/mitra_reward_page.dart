import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';

class MitraRewardPage extends StatelessWidget {
  const MitraRewardPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(
      backgroundColor: GreenLoopColors.surface,
      title: const Text('Waste & Reward', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: GreenLoopColors.deepForest, borderRadius: BorderRadius.circular(17)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saldo Waste Points', style: TextStyle(color: Colors.white70, fontSize: 11)),
              SizedBox(height: 10),
              Text('Belum tersedia', style: TextStyle(color: GreenLoopColors.leaf, fontSize: 21, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('Saldo poin akan tampil setelah data reward terhubung.', style: TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tukar Poin jadi Voucher', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text('Berlaku 30 hari', style: TextStyle(fontSize: 9, color: GreenLoopColors.muted)),
          ],
        ),
        const SizedBox(height: 9),
        const _RewardEmptyCard(
          icon: Icons.confirmation_num_outlined,
          title: 'Voucher belum tersedia',
          message: 'Voucher yang bisa ditukar akan tampil di sini setelah katalog reward tersambung.',
        ),
        const SizedBox(height: 18),
        const Text('Voucher Saya', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 9),
        const _RewardEmptyCard(
          icon: Icons.local_activity_outlined,
          title: 'Belum ada voucher',
          message: 'Voucher yang berhasil ditukar akan tersimpan di sini.',
        ),
        const SizedBox(height: 18),
        const Text('Riwayat Poin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 9),
        const _RewardEmptyCard(
          icon: Icons.history,
          title: 'Riwayat poin belum tersedia',
          message: 'Transaksi poin akan ditampilkan setelah API reward tersedia.',
        ),
      ],
    ),
  );
}

class _RewardEmptyCard extends StatelessWidget {
  const _RewardEmptyCard({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GreenLoopColors.border), borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Icon(icon, color: GreenLoopColors.circleGreen, size: 20),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(message, style: const TextStyle(fontSize: 9, height: 1.4, color: GreenLoopColors.muted)),
      ])),
    ]),
  );
}
