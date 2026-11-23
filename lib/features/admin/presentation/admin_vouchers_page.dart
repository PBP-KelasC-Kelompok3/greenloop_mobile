import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../data/admin_dummy.dart';
import 'admin_widgets.dart';

/// M35 · Voucher Reward (Admin), dibuka dari Profil Admin.
class AdminVouchersPage extends StatefulWidget {
  const AdminVouchersPage({this.vouchers = AdminDummy.vouchers, super.key});

  final List<AdminVoucher> vouchers;

  @override
  State<AdminVouchersPage> createState() => _AdminVouchersPageState();
}

class _AdminVouchersPageState extends State<AdminVouchersPage> {
  late final List<AdminVoucher> _vouchers = [...widget.vouchers];
  final _search = TextEditingController();
  bool _showArchived = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openForm([AdminVoucher? voucher]) async {
    final saved = await Navigator.of(context).push<AdminVoucher>(
      MaterialPageRoute(builder: (_) => AdminVoucherFormPage(voucher: voucher)),
    );
    if (saved == null || !mounted) return;
    setState(() {
      final i = voucher == null ? -1 : _vouchers.indexOf(voucher);
      if (i >= 0) {
        _vouchers[i] = saved;
      } else {
        _vouchers.add(saved);
      }
    });
  }

  void _toggleArchive(AdminVoucher voucher) {
    setState(() {
      final i = _vouchers.indexOf(voucher);
      _vouchers[i] = voucher.copyWith(active: !voucher.active);
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _vouchers.where((v) => v.active).length;
    final archived = _vouchers.length - active;
    final query = _search.text.trim().toLowerCase();
    final shown = _vouchers
        .where((v) => v.active != _showArchived)
        .where((v) => query.isEmpty || v.title.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: GreenLoopColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GLScreenHeader(
              title: 'Voucher Reward',
              subtitle: '$active aktif · $archived diarsipkan',
              showBack: true,
              trailing: AdminSolidIconButton(
                icon: LucideIcons.plus,
                tooltip: 'Tambah voucher',
                onTap: () => _openForm(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  AdminSearchField(
                    controller: _search,
                    hint: 'Cari voucher...',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  GLSegmentedControl(
                    labels: const ['Aktif', 'Diarsipkan'],
                    selectedIndex: _showArchived ? 1 : 0,
                    onSelected: (i) => setState(() => _showArchived = i == 1),
                  ),
                  const SizedBox(height: 12),
                  if (shown.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('Belum ada voucher di sini.',
                          textAlign: TextAlign.center,
                          style: adminText(12, FontWeight.w400,
                              color: GreenLoopColors.textMuted)),
                    ),
                  for (final voucher in shown) ...[
                    _VoucherRow(
                      voucher: voucher,
                      onEdit: () => _openForm(voucher),
                      onArchive: () => _toggleArchive(voucher),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            GLBottomActionBar(
              child: GreenLoopButton(
                label: 'Tambah Voucher',
                onPressed: () => _openForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherRow extends StatelessWidget {
  const _VoucherRow({
    required this.voucher,
    required this.onEdit,
    required this.onArchive,
  });

  final AdminVoucher voucher;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: adminCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const GLIconTile(
                  icon: LucideIcons.ticket, size: 36, iconSize: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(voucher.title, style: adminText(13, FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${voucher.kind.summaryLabel} · '
                      '${thousands(voucher.cost)} poin · '
                      '${voucher.validDays} hari',
                      style: adminText(10, FontWeight.w400,
                          color: GreenLoopColors.textMuted),
                    ),
                  ],
                ),
              ),
              AdminSmallIconButton(
                icon: LucideIcons.pencil,
                tooltip: 'Ubah',
                onTap: onEdit,
              ),
              const SizedBox(width: 2),
              AdminSmallIconButton(
                icon: voucher.active
                    ? LucideIcons.archive
                    : LucideIcons.archiveRestore,
                tooltip: voucher.active ? 'Arsipkan' : 'Aktifkan lagi',
                color: GreenLoopColors.amber,
                onTap: onArchive,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('${voucher.redeemed}× ditukar',
                    style: adminText(10, FontWeight.w500,
                        color: GreenLoopColors.green700)),
              ),
              voucher.active
                  ? const TinyBadge(label: 'Aktif')
                  : const TinyBadge(
                      label: 'Diarsipkan',
                      background: GreenLoopColors.background,
                      foreground: GreenLoopColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

/// M36 · Tambah Voucher (juga dipakai untuk ubah voucher).
class AdminVoucherFormPage extends StatefulWidget {
  const AdminVoucherFormPage({this.voucher, super.key});

  final AdminVoucher? voucher;

  @override
  State<AdminVoucherFormPage> createState() => _AdminVoucherFormPageState();
}

class _AdminVoucherFormPageState extends State<AdminVoucherFormPage> {
  late final AdminVoucher? _v = widget.voucher;
  late final _title = TextEditingController(text: _v?.title);
  late final _slug = TextEditingController(text: _v?.slug);
  late final _value = TextEditingController(text: _v?.valueLabel);
  late final _cost =
      TextEditingController(text: _v == null ? '' : _v.cost.toString());
  late final _days =
      TextEditingController(text: '${_v?.validDays ?? 30} hari');
  late final _order = TextEditingController(text: _v?.order.toString());
  late final _description = TextEditingController(text: _v?.description);
  late VoucherKind _kind = _v?.kind ?? VoucherKind.discount;
  late bool _active = _v?.active ?? true;

  /// Slug ikut judul sampai admin mengubah slug sendiri.
  late bool _slugEdited = _v != null;

  @override
  void initState() {
    super.initState();
    _title.addListener(() {
      if (!_slugEdited) _slug.text = _slugify(_title.text);
    });
  }

  @override
  void dispose() {
    for (final c in [_title, _slug, _value, _cost, _days, _order, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _slugify(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'rp\s?'), '')
      .replaceAll(RegExp(r'\.000\b'), 'k')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  int _number(TextEditingController c) =>
      int.tryParse(c.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  void _save() {
    if (_title.text.trim().isEmpty || _number(_cost) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan biaya poin wajib diisi.')),
      );
      return;
    }
    Navigator.of(context).pop(AdminVoucher(
      title: _title.text.trim(),
      slug: _slug.text.trim(),
      kind: _kind,
      valueLabel: _value.text.trim(),
      cost: _number(_cost),
      validDays: _number(_days) == 0 ? 30 : _number(_days),
      order: _number(_order),
      description: _description.text.trim(),
      redeemed: _v?.redeemed ?? 0,
      active: _active,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenLoopColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GLScreenHeader(
              title: _v == null ? 'Tambah Voucher' : 'Ubah Voucher',
              subtitle: 'Validasi dicek lagi di server',
              showBack: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  AdminFormField(
                    label: 'Judul Voucher',
                    controller: _title,
                    hint: 'Diskon Rp50.000',
                  ),
                  const SizedBox(height: 12),
                  Focus(
                    onFocusChange: (f) {
                      if (f) _slugEdited = true;
                    },
                    child: AdminFormField(
                      label: 'Kode (slug)',
                      controller: _slug,
                      hint: 'diskon-50k',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Jenis', style: adminText(13, FontWeight.w600)),
                  const SizedBox(height: 12),
                  GLSegmentedControl(
                    labels: [for (final k in VoucherKind.values) k.label],
                    selectedIndex: _kind.index,
                    onSelected: (i) =>
                        setState(() => _kind = VoucherKind.values[i]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AdminFormField(
                          label: 'Nilai (label)',
                          controller: _value,
                          hint: 'Rp50.000',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AdminFormField(
                          label: 'Biaya Poin',
                          controller: _cost,
                          icon: LucideIcons.star,
                          keyboardType: TextInputType.number,
                          hint: '900',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AdminFormField(
                          label: 'Masa Aktif',
                          controller: _days,
                          icon: LucideIcons.calendar,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AdminFormField(
                          label: 'Urutan',
                          controller: _order,
                          keyboardType: TextInputType.number,
                          hint: '5',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AdminFormField(
                    label: 'Deskripsi',
                    controller: _description,
                    hint: 'Potongan Rp50.000 min. belanja Rp200.000',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GreenLoopColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Aktifkan voucher',
                                  style: adminText(13, FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('Langsung tampil di halaman Waste & Reward',
                                  style: adminText(10, FontWeight.w400,
                                      color: GreenLoopColors.textMuted)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _active,
                          onChanged: (v) => setState(() => _active = v),
                          activeThumbColor: Colors.white,
                          activeTrackColor: GreenLoopColors.green700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GLBottomActionBar(
              child: Row(
                children: [
                  Expanded(
                    child: GreenLoopButton(
                      label: 'Batal',
                      secondary: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GreenLoopButton(
                      label: 'Simpan Voucher',
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
