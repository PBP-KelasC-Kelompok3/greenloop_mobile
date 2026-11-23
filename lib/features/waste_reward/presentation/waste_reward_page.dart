import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/dummy/dummy_data.dart';
import '../../../shared/theme/greenloop_theme.dart';

/// Voucher yang sudah ditukar dan dimiliki mitra.
class OwnedVoucher {
  const OwnedVoucher({
    required this.label,
    required this.code,
    required this.validUntil,
  });

  /// "Diskon Rp 10.000"
  final String label;
  final String code;

  /// "25 Des 2026"
  final String validUntil;
}

/// Satu baris riwayat poin.
class PointEntry {
  const PointEntry({
    required this.title,
    required this.date,
    required this.points,
  });

  final String title;
  final String date;

  /// Positif = poin masuk, negatif = poin ditukar.
  final int points;
}

/// M07 · Waste & Reward (tab Reward Mitra).
///
/// Data masih dummy dari [DummyData]. Saat API reward siap, ganti isi awal
/// state dan [_redeem] dengan pemanggilan service.
class WasteRewardPage extends StatefulWidget {
  const WasteRewardPage({
    this.onOpenCatalog,
    this.now,
    this.random,
    super.key,
  });

  /// Dipanggil dari tombol "Pakai di Katalog" di M24.
  final VoidCallback? onOpenCatalog;

  /// Untuk test: tanggal "hari ini" saat menghitung masa berlaku voucher.
  final DateTime? now;

  /// Untuk test: sumber acak kode voucher.
  final Random? random;

  @override
  State<WasteRewardPage> createState() => _WasteRewardPageState();
}

class _WasteRewardPageState extends State<WasteRewardPage> {
  late int _points = DummyData.points;
  final List<OwnedVoucher> _owned = [
    const OwnedVoucher(
      label: 'Diskon Rp 10.000',
      code: DummyData.activeVoucherCode,
      validUntil: DummyData.activeVoucherUntil,
    ),
  ];
  final List<PointEntry> _history = [
    for (final h in DummyData.pointHistory)
      PointEntry(title: h.title, date: h.date, points: h.points),
  ];
  bool _showAllHistory = false;

  late final Random _random = widget.random ?? Random();

  String _newCode(DummyVoucher voucher) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final suffix =
        List.generate(4, (_) => chars[_random.nextInt(chars.length)]).join();
    return '${voucher.codePrefix}-$suffix';
  }

  Future<void> _redeem(DummyVoucher voucher) async {
    if (_points < voucher.cost) return;
    final today = widget.now ?? DateTime.now();
    final owned = OwnedVoucher(
      label: '${voucher.category} ${voucher.value}',
      code: _newCode(voucher),
      validUntil: formatShortDate(
        today.add(Duration(days: voucher.validDays)),
        withYear: true,
      ),
    );
    setState(() {
      _points -= voucher.cost;
      _owned.insert(0, owned);
      _history.insert(
        0,
        PointEntry(
          title: 'Tukar voucher ${owned.label}',
          date: formatShortDate(today),
          points: -voucher.cost,
        ),
      );
    });

    final openCatalog = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8008140D),
      builder: (_) => VoucherRedeemedSheet(
        voucher: voucher,
        owned: owned,
        remainingPoints: _points,
      ),
    );
    if (openCatalog == true) widget.onOpenCatalog?.call();
  }

  @override
  Widget build(BuildContext context) {
    final history = _showAllHistory ? _history : _history.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GLScreenHeader(
          title: 'Waste & Reward',
          subtitle:
              '1 kg terverifikasi = ${DummyData.pointsPerKg} Waste Points',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [
              _PointsCard(points: _points),
              const SizedBox(height: 12),
              const _SectionTitle(
                title: 'Tukar Poin jadi Voucher',
                trailing: Text(
                  'Berlaku 30 hari',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: GreenLoopColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                key: const Key('voucher-catalog'),
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final voucher in DummyData.vouchers) ...[
                        if (voucher != DummyData.vouchers.first)
                          const SizedBox(width: 10),
                        _VoucherOfferCard(
                          voucher: voucher,
                          enabled: _points >= voucher.cost,
                          onRedeem: () => _redeem(voucher),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _SectionTitle(title: 'Voucher Saya'),
              const SizedBox(height: 12),
              for (final owned in _owned) ...[
                _OwnedVoucherCard(voucher: owned),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 4),
              _SectionTitle(
                title: 'Riwayat Poin',
                trailing: GestureDetector(
                  onTap: () =>
                      setState(() => _showAllHistory = !_showAllHistory),
                  child: Text(
                    _showAllHistory ? 'Ringkas' : 'Lihat semua',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: GreenLoopColors.green700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _HistoryCard(entries: history),
            ],
          ),
        ),
      ],
    );
  }
}

/// "26 Sep" atau "18 Des 2026".
String formatShortDate(DateTime date, {bool withYear = false}) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  final text = '${date.day} ${months[date.month - 1]}';
  return withYear ? '$text ${date.year}' : text;
}

TextStyle _text(double size, FontWeight weight,
        {Color color = GreenLoopColors.textInk, double height = 1.5}) =>
    GreenLoopTypography.style(size, weight, color: color, height: height);

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: _text(15, FontWeight.w700, color: GreenLoopColors.green900),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu saldo poin
// ---------------------------------------------------------------------------

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    const target = DummyData.nextLevelPoints;
    final remaining = max(0, target - points);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: GreenLoopColors.green900,
        child: Stack(
          children: [
            const Positioned(right: -30, top: -50, child: GLDecorCircle()),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Saldo Waste Points',
                          style: _text(13, FontWeight.w400,
                              color: Colors.white),
                        ),
                      ),
                      const GLStatusBadge(
                        label: 'Level ${DummyData.level}',
                        tone: GLTone.lime,
                        fontSize: 11,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formatThousands(points),
                        key: const Key('points-balance'),
                        style: _text(32, FontWeight.w700,
                            color: GreenLoopColors.lime, height: 1.2),
                      ),
                      const SizedBox(width: 6),
                      Text('poin',
                          style: _text(14, FontWeight.w500,
                              color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${formatThousands(remaining)} poin lagi ke '
                          '${DummyData.nextLevel}',
                          style: _text(12, FontWeight.w400,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        '${formatThousands(points)} / '
                        '${formatThousands(target)}',
                        style: _text(12, FontWeight.w600,
                            color: GreenLoopColors.lime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GLProgressBar(value: points / target),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (var i = 0; i < DummyData.tiers.length; i++)
                        Expanded(
                          child: Text(
                            '${DummyData.tiers[i].$1} · '
                            '${formatThousands(DummyData.tiers[i].$2)}',
                            textAlign: i == 0
                                ? TextAlign.start
                                : i == DummyData.tiers.length - 1
                                    ? TextAlign.end
                                    : TextAlign.center,
                            style: DummyData.tiers[i].$1 == DummyData.level
                                ? _text(10, FontWeight.w600,
                                    color: GreenLoopColors.lime)
                                : _text(10, FontWeight.w400,
                                    color: Colors.white),
                          ),
                        ),
                    ],
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

// ---------------------------------------------------------------------------
// Katalog voucher
// ---------------------------------------------------------------------------

class _VoucherOfferCard extends StatelessWidget {
  const _VoucherOfferCard({
    required this.voucher,
    required this.enabled,
    required this.onRedeem,
  });

  final DummyVoucher voucher;
  final bool enabled;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final premium = voucher.premium;
    final accent = premium ? GreenLoopColors.lime : GreenLoopColors.green700;
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GreenLoopColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: premium ? GreenLoopColors.green900 : GreenLoopColors.green100,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.ticket, size: 13, color: accent),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        voucher.category,
                        overflow: TextOverflow.ellipsis,
                        style: _text(10, FontWeight.w500, color: accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  voucher.value,
                  style: _text(17, FontWeight.w700,
                      color: premium
                          ? GreenLoopColors.lime
                          : GreenLoopColors.green900,
                      height: 1.3),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatThousands(voucher.cost)} poin',
                    style: _text(12, FontWeight.w700),
                  ),
                ),
                Material(
                  color: enabled
                      ? GreenLoopColors.green700
                      : GreenLoopColors.cardBorder,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: enabled ? onRedeem : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text(
                        'Tukar',
                        style: _text(11, FontWeight.w600,
                            color: enabled
                                ? Colors.white
                                : GreenLoopColors.textMuted,
                            height: 1.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Voucher Saya
// ---------------------------------------------------------------------------

void _copyCode(BuildContext context, String code) {
  Clipboard.setData(ClipboardData(text: code));
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(content: Text('Kode $code disalin')),
  );
}

class _OwnedVoucherCard extends StatelessWidget {
  const _OwnedVoucherCard({required this.voucher});

  final OwnedVoucher voucher;

  @override
  Widget build(BuildContext context) {
    return GLDashedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  voucher.label,
                  style: _text(13, FontWeight.w700,
                      color: GreenLoopColors.green700),
                ),
              ),
              const GLStatusBadge(label: 'Aktif', fontSize: 11),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: GreenLoopColors.cardBorder),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _copyCode(context, voucher.code),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(voucher.code,
                            style: _text(12, FontWeight.w600, height: 1.3)),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.copy,
                            size: 13, color: GreenLoopColors.green700),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pakai di checkout · s.d. ${voucher.validUntil}',
                  style: _text(10, FontWeight.w400,
                      color: GreenLoopColors.textMuted, height: 1.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Riwayat poin
// ---------------------------------------------------------------------------

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entries});

  final List<PointEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GreenLoopColors.cardBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              const Divider(
                  height: 1, thickness: 1, color: GreenLoopColors.cardBorder),
            _HistoryRow(entry: entries[i]),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final PointEntry entry;

  @override
  Widget build(BuildContext context) {
    final gained = entry.points >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: _text(12, FontWeight.w600)),
                const SizedBox(height: 2),
                Text(entry.date,
                    style: _text(10, FontWeight.w400,
                        color: GreenLoopColors.textMuted)),
              ],
            ),
          ),
          Text(
            gained
                ? '+${formatThousands(entry.points)}'
                : '−${formatThousands(-entry.points)}',
            style: _text(14, FontWeight.w700,
                color: gained ? GreenLoopColors.green500 : GreenLoopColors.red),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// M24 · Tukar Voucher Berhasil
// ---------------------------------------------------------------------------

/// Bottom sheet setelah voucher berhasil ditukar. Mengembalikan `true` kalau
/// mitra memilih "Pakai di Katalog".
class VoucherRedeemedSheet extends StatelessWidget {
  const VoucherRedeemedSheet({
    required this.voucher,
    required this.owned,
    required this.remainingPoints,
    super.key,
  });

  final DummyVoucher voucher;
  final OwnedVoucher owned;
  final int remainingPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 34),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: GreenLoopColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: GreenLoopColors.lime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.check,
                    size: 36, color: GreenLoopColors.green900),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Voucher Berhasil Ditukar!',
              textAlign: TextAlign.center,
              style: _text(20, FontWeight.w700,
                  color: GreenLoopColors.green900, height: 1.3),
            ),
            const SizedBox(height: 14),
            Text(
              'Voucher sudah masuk ke akunmu dan bisa dipakai saat checkout.',
              textAlign: TextAlign.center,
              style: _text(12, FontWeight.w400,
                  color: GreenLoopColors.textMuted, height: 1.45),
            ),
            const SizedBox(height: 14),
            GLDashedBox(
              color: GreenLoopColors.green100,
              borderColor: GreenLoopColors.green700,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          voucher.title,
                          style: _text(15, FontWeight.w700,
                              color: GreenLoopColors.green900),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '−${formatThousands(voucher.cost)} poin',
                          style: _text(11, FontWeight.w600,
                              color: GreenLoopColors.green700, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            owned.code,
                            key: const Key('redeemed-code'),
                            style: _text(16, FontWeight.w700, height: 1.3),
                          ),
                        ),
                        InkWell(
                          onTap: () => _copyCode(context, owned.code),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.copy,
                                  size: 14, color: GreenLoopColors.green700),
                              const SizedBox(width: 4),
                              Text('Salin',
                                  style: _text(12, FontWeight.w600,
                                      color: GreenLoopColors.green700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Berlaku s.d. ${owned.validUntil} · Sisa saldo '
                    '${formatThousands(remainingPoints)} poin',
                    style: _text(11, FontWeight.w400,
                        color: GreenLoopColors.green700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GreenLoopButton(
              label: 'Pakai di Katalog',
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 14),
            GreenLoopButton(
              label: 'Tutup',
              secondary: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
