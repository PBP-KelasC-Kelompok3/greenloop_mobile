import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';

class MitraShopPage extends StatelessWidget {
  const MitraShopPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(
      backgroundColor: GreenLoopColors.surface,
      title: const Text('Belanja Produk', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Text('Produk GreenLoop', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GreenLoopColors.border), borderRadius: BorderRadius.circular(16)),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: GreenLoopColors.mint,
                child: Icon(Icons.storefront_outlined, color: GreenLoopColors.circleGreen),
              ),
              SizedBox(height: 12),
              Text('Katalog belum tersedia', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              SizedBox(height: 5),
              Text(
                'Produk akan tampil di sini setelah katalog belanja terhubung.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, height: 1.45, color: GreenLoopColors.muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
