import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../data/mitra_pickup_service.dart';

class MitraPickupPage extends StatefulWidget {
  const MitraPickupPage({this.authService, this.onBack, this.onSubmitted, super.key});

  final AuthService? authService;
  final VoidCallback? onBack;
  final ValueChanged<String>? onSubmitted;

  @override
  State<MitraPickupPage> createState() => _MitraPickupPageState();
}

class _MitraPickupPageState extends State<MitraPickupPage> {
  static const _wasteTypes = [
    'Sisa Makanan / Dapur',
    'Ampas Kopi',
    'Sisa Buah & Sayur',
    'Organik Campuran',
  ];
  static const _slots = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
  ];

  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  late final MitraPickupService _pickupService;
  String? _wasteType;
  DateTime? _date;
  String? _slot;
  String? _vehicle;
  XFile? _photo;
  Uint8List? _photoBytes;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _pickupService = MitraPickupService(widget.authService ?? defaultAuthService);
  }

  double get _weight => double.tryParse(_weightController.text) ?? 0;
  String get _recommendedVehicle => _weight <= 20 ? 'Motor Box' : 'Pickup Bak';
  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var initialDate = _date ?? today;
    if (initialDate.weekday == DateTime.sunday) {
      initialDate = initialDate.add(const Duration(days: 1));
    }
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(now.year + 1),
      selectableDayPredicate: (day) => day.weekday != DateTime.sunday,
      helpText: 'Pilih tanggal penjemputan',
    );
    if (selected == null) return;
    setState(() {
      _date = selected;
      if (_slot != null && !_isSlotAvailable(selected, _slot!)) _slot = null;
    });
  }

  bool _isSlotAvailable(DateTime date, String slot) {
    final parts = slot.substring(0, 5).split(':');
    final startsAt = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    return !startsAt.isBefore(DateTime.now().add(const Duration(minutes: 60)));
  }

  void _onWeightChanged(String value) {
    final weight = double.tryParse(value) ?? 0;
    setState(() {
      if (weight > 0 && weight <= 120) {
        _vehicle = weight <= 20 ? 'Motor Box' : 'Pickup Bak';
      } else {
        _vehicle = null;
      }
    });
  }

  Future<void> _choosePhoto() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return;
    final name = file.name.toLowerCase();
    if (!(name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png'))) {
      _showMessage('Format foto harus JPG atau PNG.');
      return;
    }
    if (await file.length() > 5 * 1024 * 1024) {
      _showMessage('Ukuran foto maksimal 5 MB.');
      return;
    }
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _photo = file;
      _photoBytes = bytes;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_date == null ||
        _slot == null ||
        _wasteType == null ||
        _weight <= 0 ||
        _weight > 120 ||
        _vehicle == null ||
        _photo == null) {
      _showMessage('Lengkapi semua data wajib sebelum mengirim pengajuan.');
      return;
    }
    if (!_isSlotAvailable(_date!, _slot!)) {
      _showMessage('Pilih slot yang dimulai minimal satu jam dari sekarang.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final photoBytes = _photoBytes ?? await _photo!.readAsBytes();
      final pickup = await _pickupService.create(
        fields: {
          'waste_type': _wasteTypeCode(_wasteType!),
          'estimated_weight': _weight.toString(),
          'pickup_date': _formatDateForApi(_date!),
          'pickup_time_slot': '$_slot WIB',
          'armada': _vehicle!,
          'notes': _notesController.text.trim(),
        },
        photoBytes: photoBytes,
        filename: _photo!.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengajuan ${pickup.code} berhasil dikirim.')),
      );
      widget.onSubmitted?.call(pickup.code);
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (error) {
      if (mounted) _showMessage('Pengajuan gagal dikirim: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(
      backgroundColor: GreenLoopColors.surface,
      leading: IconButton(
        onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.chevron_left),
        style: IconButton.styleFrom(foregroundColor: GreenLoopColors.ink),
      ),
      titleSpacing: 8,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajukan Penjemputan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('Smart Pick-Up Scheduler', style: TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
        ],
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      children: [
        const _FieldLabel('Jenis limbah'),
        const SizedBox(height: 7),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 7,
          crossAxisSpacing: 7,
          childAspectRatio: 3.35,
          children: [
            for (final type in _wasteTypes)
              _ChoiceTile(
                text: type,
                icon: _wasteIcon(type),
                selected: _wasteType == type,
                onTap: () => setState(() => _wasteType = type),
              ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            const Expanded(child: _FieldLabel('Estimasi berat')),
            const SizedBox(width: 8),
            const Expanded(child: _FieldLabel('Tanggal')),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _ValueTile(
                icon: Icons.scale_outlined,
                child: TextField(
                  controller: _weightController,
                  onChanged: _onWeightChanged,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan berat',
                    hintStyle: TextStyle(fontSize: 12, color: GreenLoopColors.muted),
                    suffixText: 'kg',
                    suffixStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ValueTile(
                icon: Icons.calendar_month_outlined,
                onTap: _chooseDate,
                child: Text(
                  _date == null ? 'Pilih tanggal' : _formatDate(_date!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        if (_weight > 120) ...[
          const SizedBox(height: 4),
          const Text('Maksimal berat satu pengajuan 120 kg.', style: TextStyle(color: Colors.red, fontSize: 10)),
        ],
        const SizedBox(height: 13),
        const _FieldLabel('Slot waktu'),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 7,
          crossAxisSpacing: 7,
          childAspectRatio: 3.1,
          children: [
            for (final slot in _slots)
              _SlotTile(
                text: '$slot WIB',
                selected: _slot == slot,
                enabled: _date != null && _isSlotAvailable(_date!, slot),
                onTap: () => setState(() => _slot = slot),
              ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            const Expanded(child: _FieldLabel('Armada')),
            if (_weight > 0 && _weight <= 120)
              Text(
                'Rekomendasi: $_recommendedVehicle',
                style: const TextStyle(fontSize: 10, color: GreenLoopColors.circleGreen, fontWeight: FontWeight.w600),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _VehicleTile(
              title: 'Motor Box',
              limit: 'maks. 20 kg',
              icon: Icons.inventory_2_outlined,
              selected: _vehicle == 'Motor Box',
              onTap: () => setState(() => _vehicle = 'Motor Box'),
            ),
            const SizedBox(width: 8),
            _VehicleTile(
              title: 'Pickup Bak',
              limit: '20,1–120 kg',
              icon: Icons.local_shipping_outlined,
              selected: _vehicle == 'Pickup Bak',
              onTap: () => setState(() => _vehicle = 'Pickup Bak'),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            const Expanded(child: _FieldLabel('Foto limbah')),
            const _SmallBadge(text: 'wajib', color: Color(0xFFD74444)),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Wajib · diverifikasi admin sebelum kurir ditugaskan',
          style: TextStyle(fontSize: 9, color: GreenLoopColors.muted),
        ),
        const SizedBox(height: 7),
        _PhotoPicker(
          imageBytes: _photoBytes,
          filename: _photo?.name,
          onTap: _choosePhoto,
          onRemove: () => setState(() { _photo = null; _photoBytes = null; }),
        ),
        const SizedBox(height: 12),
        const _FieldLabel('Catatan (opsional)'),
        const SizedBox(height: 6),
        TextField(
          controller: _notesController,
          maxLines: 1,
          decoration: const InputDecoration(
            hintText: 'Catatan untuk kurir',
            filled: true,
            fillColor: Colors.white,
            isDense: true,
          ),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 8),
      ],
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
        decoration: const BoxDecoration(
          color: GreenLoopColors.surface,
          border: Border(top: BorderSide(color: GreenLoopColors.border)),
        ),
        child: SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: const Icon(Icons.send_outlined, size: 16),
            label: _submitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Kirim untuk Verifikasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: GreenLoopColors.circleGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    ),
  );

  static IconData _wasteIcon(String type) {
    if (type.contains('Kopi')) return Icons.coffee_outlined;
    if (type.contains('Buah')) return Icons.eco_outlined;
    if (type.contains('Campuran')) return Icons.spa_outlined;
    return Icons.restaurant_outlined;
  }

  static String _wasteTypeCode(String type) => switch (type) {
    'Sisa Makanan / Dapur' => 'ORGANIC_FOOD',
    'Ampas Kopi' => 'COFFEE_GROUNDS',
    'Sisa Buah & Sayur' => 'FRUIT_VEG',
    _ => 'MIXED_ORGANIC',
  };

  static String _formatDateForApi(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _formatDate(DateTime date) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GreenLoopColors.ink));
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({required this.text, required this.icon, required this.selected, required this.onTap});
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFE5F2E7) : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: selected ? GreenLoopColors.circleGreen : GreenLoopColors.border, width: selected ? 1.4 : 1),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Row(children: [Icon(icon, size: 16, color: GreenLoopColors.muted), const SizedBox(width: 7), Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, height: 1.15, fontWeight: FontWeight.w600)))]),
      ),
    ),
  );
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({required this.icon, required this.child, this.onTap});
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: GreenLoopColors.border)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(height: 46, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Row(children: [Icon(icon, size: 17, color: GreenLoopColors.muted), const SizedBox(width: 7), Expanded(child: child)]))),
    ),
  );
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.text, required this.selected, required this.enabled, required this.onTap});
  final String text;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFE5F2E7) : (enabled ? Colors.white : const Color(0xFFF0F2F0)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: selected ? GreenLoopColors.circleGreen : GreenLoopColors.border, width: selected ? 1.3 : 1)),
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(height: 42, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.access_time, size: 14, color: GreenLoopColors.muted), const SizedBox(width: 5), Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: enabled ? GreenLoopColors.ink : GreenLoopColors.muted, fontWeight: FontWeight.w600)))])),
    ),
  );
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.title, required this.limit, required this.icon, required this.selected, required this.onTap});
  final String title;
  final String limit;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: selected ? const Color(0xFFE5F2E7) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11), side: BorderSide(color: selected ? GreenLoopColors.circleGreen : GreenLoopColors.border, width: selected ? 1.4 : 1)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(height: 58, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: GreenLoopColors.circleGreen), const SizedBox(width: 7), Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), Text(limit, style: const TextStyle(fontSize: 10, color: GreenLoopColors.muted))])])),
      ),
    ),
  );
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.imageBytes, required this.filename, required this.onTap, required this.onRemove});
  final Uint8List? imageBytes;
  final String? filename;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorderPainter(),
    child: Material(
      color: const Color(0xFFEAF5EC),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          height: imageBytes == null ? 59 : 118,
          child: imageBytes == null
              ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.camera_alt_outlined, size: 19, color: GreenLoopColors.circleGreen),
                  SizedBox(width: 8),
                  Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Upload foto limbah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    Text('Wajib · JPG/PNG · maks. 5 MB', style: TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
                  ]),
                ])
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(imageBytes!, fit: BoxFit.cover)),
                    Positioned(top: 3, right: 3, child: IconButton.filledTonal(onPressed: onRemove, icon: const Icon(Icons.close, size: 16), constraints: const BoxConstraints.tightFor(width: 29, height: 29), padding: EdgeInsets.zero)),
                    if (filename != null) Positioned(left: 6, right: 36, bottom: 5, child: Container(color: Colors.white.withValues(alpha: .85), padding: const EdgeInsets.symmetric(horizontal: 5), child: Text(filename!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8)))),
                  ],
                ),
        ),
      ),
    ),
  );
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(11);
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, radius));
    final paint = Paint()..color = GreenLoopColors.green..style = PaintingStyle.stroke..strokeWidth = 1.4;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 5).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: .1), border: Border.all(color: color.withValues(alpha: .25)), borderRadius: BorderRadius.circular(5)),
    child: Text(text, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.w700)),
  );
}
