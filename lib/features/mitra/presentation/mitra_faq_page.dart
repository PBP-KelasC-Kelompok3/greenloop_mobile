import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';

class MitraFaqPage extends StatefulWidget {
  const MitraFaqPage({super.key});

  @override
  State<MitraFaqPage> createState() => _MitraFaqPageState();
}

class _MitraFaqPageState extends State<MitraFaqPage> {
  static const _categories = [
    'Semua',
    'Akun & Lokasi',
    'Penjemputan',
    'Status & Riwayat',
  ];

  static const _items = [
    _FaqItem(
      category: 'Akun & Lokasi',
      question: 'Mengapa titik lokasi usaha harus disimpan?',
      answer:
          'Pengajuan penjemputan membutuhkan titik lokasi usaha yang tersimpan. Atur pin di peta pada Profil Mitra, pastikan titiknya berada di Kota Depok, lalu simpan perubahan. Titik yang tersimpan akan terkunci dan dapat diubah kembali melalui tombol “Ubah titik”.',
    ),
    _FaqItem(
      category: 'Akun & Lokasi',
      question: 'Mengapa lokasi di luar Kota Depok tidak bisa dipilih?',
      answer:
          'Area layanan penjemputan saat ini dibatasi di Kota Depok. Titik di luar batas wilayah tersebut tidak dapat disimpan sebagai alamat penjemputan.',
    ),
    _FaqItem(
      category: 'Penjemputan',
      question: 'Jenis limbah apa yang bisa diajukan?',
      answer:
          'Pilih salah satu jenis yang tersedia di formulir: sisa makanan/dapur, ampas kopi, sisa buah dan sayur, atau organik campuran.',
    ),
    _FaqItem(
      category: 'Penjemputan',
      question: 'Apakah foto limbah wajib diunggah?',
      answer:
          'Ya. Foto limbah wajib disertakan untuk pemeriksaan admin. Format yang diterima JPG atau PNG dengan ukuran maksimal 5 MB.',
    ),
    _FaqItem(
      category: 'Penjemputan',
      question: 'Berapa berat maksimal satu pengajuan?',
      answer:
          'Satu pengajuan dapat memuat estimasi berat sampai 120 kg. Jika limbah lebih berat, ajukan dalam beberapa jadwal penjemputan.',
    ),
    _FaqItem(
      category: 'Penjemputan',
      question: 'Kapan jadwal penjemputan bisa dipilih?',
      answer:
          'Pilih slot yang tersedia: 08.00–10.00, 10.00–12.00, 13.00–15.00, atau 15.00–17.00 WIB. Penjemputan tidak dijadwalkan pada hari Minggu, dan jadwal harus diajukan minimal satu jam sebelum slot dimulai.',
    ),
    _FaqItem(
      category: 'Penjemputan',
      question: 'Armada apa yang sebaiknya saya pilih?',
      answer:
          'Rekomendasi formulir adalah Motor Box untuk estimasi sampai 20 kg dan Pickup Bak untuk berat di atas 20 kg sampai 120 kg. Sesuaikan pilihan dengan berat limbah.',
    ),
    _FaqItem(
      category: 'Status & Riwayat',
      question: 'Apa arti status “Menunggu Verifikasi”?',
      answer:
          'Pengajuan sudah tercatat dan menunggu pemeriksaan admin. Kurir ditugaskan setelah foto pengajuan diperiksa dan disetujui.',
    ),
    _FaqItem(
      category: 'Status & Riwayat',
      question: 'Di mana saya bisa melihat riwayat penjemputan?',
      answer:
          'Buka Beranda Mitra, lalu tekan “Lihat riwayat” pada bagian Penjemputan Aktif. Pengajuan yang berhasil dikirim akan tampil dengan ID dan statusnya.',
    ),
  ];

  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqItem> get _visibleItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      final categoryMatches =
          _selectedCategory == 'Semua' || item.category == _selectedCategory;
      final queryMatches = query.isEmpty ||
          item.question.toLowerCase().contains(query) ||
          item.answer.toLowerCase().contains(query);
      return categoryMatches && queryMatches;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(
      backgroundColor: GreenLoopColors.surface,
      leading: IconButton(
        tooltip: 'Kembali',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back),
        style: IconButton.styleFrom(foregroundColor: GreenLoopColors.ink),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bantuan & FAQ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text('Pusat bantuan Mitra', style: TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
        ],
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Text(
          'Temukan jawaban seputar profil dan penjemputan.',
          style: TextStyle(fontSize: 12, color: GreenLoopColors.muted),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari pertanyaan',
            prefixIcon: const Icon(Icons.search, size: 19),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Hapus pencarian',
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
          child: Row(children: [
            for (final category in _categories) ...[
              ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (_) => setState(() => _selectedCategory = category),
                selectedColor: GreenLoopColors.circleGreen,
                labelStyle: TextStyle(
                  fontSize: 10,
                  color: _selectedCategory == category
                      ? Colors.white
                      : GreenLoopColors.ink,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: _selectedCategory == category
                      ? GreenLoopColors.circleGreen
                      : GreenLoopColors.border,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        if (_visibleItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: GreenLoopColors.border),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(children: [
              Icon(Icons.search_off, color: GreenLoopColors.muted, size: 28),
              SizedBox(height: 8),
              Text('Pertanyaan tidak ditemukan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              SizedBox(height: 3),
              Text('Coba kata kunci atau kategori lain.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
            ]),
          )
        else
          for (final item in _visibleItems) ...[
            _FaqCard(item: item),
            const SizedBox(height: 8),
          ],
      ],
    ),
  );
}

class _FaqItem {
  const _FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });

  final String category;
  final String question;
  final String answer;
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.item});

  final _FaqItem item;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(13, 0, 13, 14),
        iconColor: GreenLoopColors.circleGreen,
        collapsedIconColor: GreenLoopColors.muted,
        title: Text(
          item.question,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.answer,
              style: const TextStyle(
                fontSize: 11,
                height: 1.5,
                color: GreenLoopColors.muted,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
