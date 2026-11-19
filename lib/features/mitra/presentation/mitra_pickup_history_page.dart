import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../data/mitra_pickup_service.dart';

class MitraPickupHistoryPage extends StatefulWidget {
  const MitraPickupHistoryPage({
    this.authService,
    this.onBack,
    this.onCreatePickup,
    super.key,
  });

  final AuthService? authService;
  final VoidCallback? onBack;
  final VoidCallback? onCreatePickup;

  @override
  State<MitraPickupHistoryPage> createState() => _MitraPickupHistoryPageState();
}

class _MitraPickupHistoryPageState extends State<MitraPickupHistoryPage> {
  static const _filters = ['Semua', 'Menunggu', 'Dijadwalkan', 'Selesai'];
  late final MitraPickupService _pickupService;
  final _searchController = TextEditingController();
  List<MitraPickupItem> _items = const [];
  String _selectedFilter = 'Semua';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pickupService = MitraPickupService(widget.authService ?? defaultAuthService);
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _pickupService.history();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<MitraPickupItem> get _visibleItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      final matchesStatus = switch (_selectedFilter) {
        'Menunggu' => item.status == 'PENDING',
        'Dijadwalkan' => const {'APPROVED', 'SCHEDULED', 'IN_PROGRESS'}.contains(item.status),
        'Selesai' => item.status == 'COMPLETED',
        _ => true,
      };
      final matchesQuery = query.isEmpty ||
          item.code.toLowerCase().contains(query) ||
          item.wasteTypeLabel.toLowerCase().contains(query) ||
          item.notes.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final totalWeight = _items.fold<double>(0, (sum, item) => sum + item.estimatedWeight);
    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(
        backgroundColor: GreenLoopColors.surface,
        leading: IconButton(
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Riwayat Penjemputan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(onPressed: _loading ? null : _loadHistory, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Text(
              _loading ? 'Memuat riwayat...' : '${_items.length} pengajuan · ${totalWeight.toStringAsFixed(1)} kg estimasi',
              style: const TextStyle(fontSize: 11, color: GreenLoopColors.muted),
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
              child: Row(children: [
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
                      color: _selectedFilter == filter ? GreenLoopColors.circleGreen : GreenLoopColors.border,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(38),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _HistoryMessage(
                icon: Icons.cloud_off_outlined,
                title: 'Riwayat tidak dapat dimuat',
                message: _error!,
                actionLabel: 'Coba lagi',
                onAction: _loadHistory,
              )
            else if (_visibleItems.isEmpty)
              _HistoryMessage(
                icon: Icons.receipt_long_outlined,
                title: _items.isEmpty ? 'Belum ada pengajuan' : 'Pengajuan tidak ditemukan',
                message: _items.isEmpty
                    ? 'Pengajuan yang berhasil dikirim akan muncul di sini bersama statusnya.'
                    : 'Coba ubah kata pencarian atau filter status.',
                actionLabel: _items.isEmpty ? 'Ajukan Penjemputan' : null,
                onAction: widget.onCreatePickup,
              )
            else
              for (final item in _visibleItems) ...[
                _PickupHistoryCard(item: item),
                const SizedBox(height: 9),
              ],
          ],
        ),
      ),
    );
  }
}

class _PickupHistoryCard extends StatelessWidget {
  const _PickupHistoryCard({required this.item});

  final MitraPickupItem item;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.status) {
      'COMPLETED' => const Color(0xFF3C8C52),
      'APPROVED' || 'SCHEDULED' || 'IN_PROGRESS' => const Color(0xFF3887C8),
      'REJECTED' || 'CANCELLED' => const Color(0xFFD9534F),
      _ => const Color(0xFFCC861B),
    };
    final day = item.pickupDate.day.toString().padLeft(2, '0');
    final month = item.pickupDate.month.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GreenLoopColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(item.code, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
            child: Text(item.statusLabel, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 7),
        Text('$day/$month · ${item.timeSlot}', style: const TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
        const SizedBox(height: 4),
        Text('${item.wasteTypeLabel} · ${item.estimatedWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Armada: ${item.vehicle}', style: const TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
        if (item.notes.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(item.notes, style: const TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
        ],
      ]),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(17),
    ),
    child: Column(children: [
      Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(color: GreenLoopColors.mint, shape: BoxShape.circle),
        child: Icon(icon, color: GreenLoopColors.circleGreen),
      ),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, height: 1.45, color: GreenLoopColors.muted)),
      if (actionLabel != null && onAction != null) ...[
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onAction,
          icon: Icon(icon == Icons.cloud_off_outlined ? Icons.refresh : Icons.add, size: 16),
          label: Text(actionLabel!),
          style: OutlinedButton.styleFrom(
            foregroundColor: GreenLoopColors.circleGreen,
            side: const BorderSide(color: GreenLoopColors.circleGreen),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    ]),
  );
}
