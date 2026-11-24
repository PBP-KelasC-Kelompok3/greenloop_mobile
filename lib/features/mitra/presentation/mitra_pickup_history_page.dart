import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../data/mitra_pickup_service.dart';
import 'pickup_progress_timeline.dart';

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
  static const _filters = [
    'Semua',
    'Menunggu',
    'Dijadwalkan',
    'Selesai',
    'Sertifikat',
  ];
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

  Future<void> _editSchedule(MitraPickupItem item) async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    var selectedDate = item.pickupDate.isBefore(firstDate)
        ? firstDate
        : item.pickupDate;
    const slots = [
      '08:00 - 10:00 WIB',
      '10:00 - 12:00 WIB',
      '13:00 - 15:00 WIB',
      '15:00 - 17:00 WIB',
    ];
    var selectedSlot = slots.contains(item.timeSlot)
        ? item.timeSlot
        : slots.first;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Ubah jadwal ${item.code}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: firstDate,
                    lastDate: firstDate.add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  '${selectedDate.day.toString().padLeft(2, '0')}/'
                  '${selectedDate.month.toString().padLeft(2, '0')}/'
                  '${selectedDate.year}',
                ),
              ),
              const SizedBox(height: 10),
              for (final slot in slots)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(slot, style: const TextStyle(fontSize: 12)),
                  value: slot,
                  groupValue: selectedSlot,
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedSlot = value);
                  },
                ),
              const Text(
                'Perubahan hanya bisa dilakukan sebelum kurir ditugaskan.',
                style: TextStyle(fontSize: 11, color: GreenLoopColors.muted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Simpan jadwal'),
            ),
          ],
        ),
      ),
    );
    if (shouldSave != true) return;

    try {
      await _pickupService.reschedule(
        pickupId: item.id,
        date: selectedDate,
        timeSlot: selectedSlot,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal penjemputan berhasil diperbarui.')),
      );
      await _loadHistory();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jadwal gagal diubah: $error')),
        );
      }
    }
  }

  Future<void> _downloadCertificate() async {
    final url = Uri.parse(_pickupService.baseUrl).resolve(
      '/api/pickups/certificate/download/',
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unduh sertifikat'),
        content: SelectableText(url.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelPickup(MitraPickupItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Batalkan ${item.code}?'),
        content: const Text(
          'Pengajuan hanya bisa dibatalkan sebelum kurir ditugaskan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Batalkan pengajuan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _pickupService.cancel(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil dibatalkan.')),
      );
      await _loadHistory();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }

  List<MitraPickupItem> get _visibleItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      final matchesStatus = switch (_selectedFilter) {
        'Menunggu' => item.status == 'PENDING',
        'Dijadwalkan' => const {'APPROVED', 'SCHEDULED', 'IN_PROGRESS'}.contains(item.status),
        'Selesai' => item.status == 'COMPLETED',
        'Sertifikat' => item.status == 'COMPLETED' &&
            item.certificateUrl?.isNotEmpty == true,
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
    final completedCount = _items.where((item) => item.status == 'COMPLETED').length;
    final verifiedWeight = _items
        .where((item) => item.status == 'COMPLETED')
        .fold<double>(0, (sum, item) => sum + (item.actualWeight ?? 0));
    final availableFilters = completedCount >= 10
        ? _filters
        : _filters.where((filter) => filter != 'Sertifikat').toList();
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
              _loading
                  ? 'Memuat riwayat...'
                  : '${_items.length} penjemputan · ${verifiedWeight.toStringAsFixed(1)} kg terverifikasi',
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
                for (final filter in availableFilters) ...[
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
                icon: _selectedFilter == 'Sertifikat'
                    ? Icons.workspace_premium_outlined
                    : Icons.receipt_long_outlined,
                title: _selectedFilter == 'Sertifikat'
                    ? 'Sertifikat belum tersedia'
                    : _items.isEmpty
                        ? 'Belum ada pengajuan'
                        : 'Pengajuan tidak ditemukan',
                message: _selectedFilter == 'Sertifikat'
                    ? 'Sertifikat akan muncul setelah penjemputan ke-10 selesai dan file sertifikat tersedia.'
                    : _items.isEmpty
                    ? 'Pengajuan yang berhasil dikirim akan muncul di sini bersama statusnya.'
                    : 'Coba ubah kata pencarian atau filter status.',
                actionLabel: _items.isEmpty ? 'Ajukan Penjemputan' : null,
                onAction: widget.onCreatePickup,
              )
            else
              for (final item in _visibleItems) ...[
                _PickupHistoryCard(
                  item: item,
                  onEdit: item.canReschedule ? () => _editSchedule(item) : null,
                  onCancel: item.canCancel ? () => _cancelPickup(item) : null,
                  onDownloadCertificate: _selectedFilter == 'Sertifikat'
                      ? _downloadCertificate
                      : null,
                ),
                const SizedBox(height: 9),
              ],
          ],
        ),
      ),
    );
  }
}

class _PickupHistoryCard extends StatelessWidget {
  const _PickupHistoryCard({
    required this.item,
    this.onEdit,
    this.onCancel,
    this.onDownloadCertificate,
  });

  final MitraPickupItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDownloadCertificate;

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
        Text(
          '${item.wasteTypeLabel} · '
          '${item.status == 'COMPLETED' && item.actualWeight != null ? 'aktual ${item.actualWeight!.toStringAsFixed(1)}' : 'estimasi ${item.estimatedWeight.toStringAsFixed(1)}'} kg',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text('Armada: ${item.vehicle}', style: const TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
        if (item.notes.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(item.notes, style: const TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
        ],
        const SizedBox(height: 12),
        PickupProgressTimeline(
          status: item.status,
          courierName: item.courierName,
        ),
        if (onDownloadCertificate != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDownloadCertificate,
              icon: const Icon(Icons.download_outlined, size: 16),
              label: const Text('Unduh sertifikat GreenLoop (.png)'),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: GreenLoopColors.forest2,
              ),
            ),
          ),
        ],
        if (onEdit != null || onCancel != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (onEdit != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                    label: const Text('Ubah jadwal'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: GreenLoopColors.forest2,
                    ),
                  ),
                ),
              if (onEdit != null && onCancel != null)
                const SizedBox(width: 8),
              if (onCancel != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Batalkan'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: const Color(0xFFD9534F),
                      side: const BorderSide(color: Color(0xFFF3C8C5)),
                    ),
                  ),
                ),
            ],
          ),
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
