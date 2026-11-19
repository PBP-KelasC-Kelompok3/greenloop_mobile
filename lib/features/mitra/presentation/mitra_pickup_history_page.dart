import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';

class MitraPickupHistoryPage extends StatefulWidget {
  const MitraPickupHistoryPage({this.onBack, this.onCreatePickup, super.key});

  final VoidCallback? onBack;
  final VoidCallback? onCreatePickup;

  @override
  State<MitraPickupHistoryPage> createState() => _MitraPickupHistoryPageState();
}

class _MitraPickupHistoryPageState extends State<MitraPickupHistoryPage> {
  static const _filters = ['Semua', 'Menunggu', 'Dijadwalkan', 'Selesai'];
  String _selectedFilter = 'Semua';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(
      backgroundColor: GreenLoopColors.surface,
      leading: IconButton(
        onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text(
        'Riwayat Penjemputan',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        const Text(
          'Pantau status pengajuan penjemputanmu.',
          style: TextStyle(fontSize: 11, color: GreenLoopColors.muted),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari ID, jenis limbah, atau catatan',
            prefixIcon: const Icon(Icons.search, size: 19),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close, size: 17),
                  ),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
          ),
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in _filters) ...[
                ChoiceChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: GreenLoopColors.circleGreen,
                  labelStyle: TextStyle(
                    fontSize: 10,
                    color: _selectedFilter == filter ? Colors.white : GreenLoopColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: _selectedFilter == filter
                        ? GreenLoopColors.circleGreen
                        : GreenLoopColors.border,
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 25),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: GreenLoopColors.border),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: GreenLoopColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: GreenLoopColors.circleGreen,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Riwayat belum tersedia',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              const Text(
                'Pengajuan yang berhasil dikirim akan muncul di sini bersama status verifikasi dan jadwalnya.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.45,
                  color: GreenLoopColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: widget.onCreatePickup,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Ajukan Penjemputan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: GreenLoopColors.circleGreen,
                  side: const BorderSide(color: GreenLoopColors.circleGreen),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
