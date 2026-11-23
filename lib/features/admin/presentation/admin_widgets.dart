import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../data/admin_dummy.dart';

/// Widget kecil yang dipakai beberapa layar Admin (M21, M32–M37).

TextStyle adminText(double size, FontWeight weight,
        {Color color = GreenLoopColors.textInk, double height = 1.5}) =>
    GreenLoopTypography.style(size, weight, color: color, height: height);

/// "Rp 1.250.000"
String rupiahSpaced(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return 'Rp $buffer';
}

/// "1.000"
String thousands(int value) => rupiahSpaced(value).substring(3);

/// Tombol ikon kecil 28×28 berlatar abu muda (edit, hapus, arsip).
class AdminSmallIconButton extends StatelessWidget {
  const AdminSmallIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color = GreenLoopColors.textInk,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: GreenLoopColors.background,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, size: 14, color: color),
          ),
        ),
      ),
    );
  }
}

/// Tombol persegi 40×40 hijau tua dengan ikon putih ("+" di M32, M35).
class AdminSolidIconButton extends StatelessWidget {
  const AdminSolidIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: GreenLoopColors.green700,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Thumbnail kemasan sabun: latar hijau muda, botol abu, label berwarna.
class ProductThumb extends StatelessWidget {
  const ProductThumb({required this.tint, this.size = 52, super.key});

  final ProductTint tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size / 52;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFDBEBD1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 21.84 * s,
        height: 31.2 * s,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: const Alignment(0, 0.25),
        child: Container(
          width: 17.68 * s,
          height: 15.6 * s,
          decoration: BoxDecoration(
            color: tint == ProductTint.amber
                ? GreenLoopColors.amber
                : GreenLoopColors.green700,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

/// Badge pil berwarna solid dengan teks putih ("Menunggu", "Dibayar").
class SolidBadge extends StatelessWidget {
  const SolidBadge({
    required this.label,
    required this.color,
    this.horizontal = 8,
    this.vertical = 3,
    super.key,
  });

  final String label;
  final Color color;
  final double horizontal;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label,
          style: adminText(10, FontWeight.w600,
              color: Colors.white, height: 1.2)),
    );
  }
}

/// Badge kecil 9px ("Lunas", "Aktif", "Menunggu").
class TinyBadge extends StatelessWidget {
  const TinyBadge({
    required this.label,
    this.background = GreenLoopColors.green100,
    this.foreground = GreenLoopColors.green700,
    super.key,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label,
          style: adminText(9, FontWeight.w600, color: foreground, height: 1.2)),
    );
  }
}

/// Baris "label ........ nilai" di kartu informasi.
class AdminInfoRow extends StatelessWidget {
  const AdminInfoRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: adminText(12, FontWeight.w400,
                color: GreenLoopColors.textMuted)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: adminText(12, FontWeight.w600)),
        ),
      ],
    );
  }
}

/// Label 13/SemiBold + field teks bertema GreenLoop (form M33, M36).
class AdminFormField extends StatelessWidget {
  const AdminFormField({
    required this.label,
    required this.controller,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.hint,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: adminText(13, FontWeight.w600)),
        const SizedBox(height: 6),
        // Figma: tinggi field 46, deskripsi multi-baris 76.
        SizedBox(
          height: maxLines > 1 ? 76 : 46,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            expands: maxLines > 1,
            maxLines: maxLines > 1 ? null : 1,
            textAlignVertical: maxLines > 1
                ? TextAlignVertical.top
                : TextAlignVertical.center,
            style: adminText(13, FontWeight.w500, height: 1.45),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: adminText(13, FontWeight.w400,
                  color: GreenLoopColors.textMuted),
              contentPadding: maxLines > 1
                  ? const EdgeInsets.fromLTRB(14, 12, 14, 12)
                  : const EdgeInsets.symmetric(horizontal: 14),
              prefixIcon: icon == null ? null : _FieldIcon(icon!),
              prefixIconConstraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Ikon di kiri field: 18px, jarak 14 dari tepi dan 10 ke teks (Figma).
class _FieldIcon extends StatelessWidget {
  const _FieldIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, size: 18, color: GreenLoopColors.textInk),
      );
}

/// Kolom pencarian 44px ("Cari produk...", "Cari voucher...").
class AdminSearchField extends StatelessWidget {
  const AdminSearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: adminText(13, FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              adminText(13, FontWeight.w400, color: GreenLoopColors.textMuted),
          contentPadding: const EdgeInsets.only(right: 14),
          prefixIcon: const _FieldIcon(LucideIcons.search),
          prefixIconConstraints: const BoxConstraints(),
        ),
      ),
    );
  }
}

/// Kartu putih dengan border, sudut 16.
BoxDecoration adminCardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: GreenLoopColors.cardBorder),
    );
