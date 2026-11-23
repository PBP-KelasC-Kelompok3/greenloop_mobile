import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../shared/theme/greenloop_theme.dart';

/// Komponen dasar GreenLoop Mobile, diambil dari file Figma
/// "GreenLoop Mobile" (frame M01–M37, 390×844).
///
/// Semua komponen di sini murni tampilan. Data dan aksi dikirim dari luar,
/// jadi pemilik modul tinggal mengganti data dummy dengan data dari API.

// ---------------------------------------------------------------------------
// Tone warna
// ---------------------------------------------------------------------------

/// Pasangan warna (latar lembut + warna utama) yang dipakai badge, ikon,
/// dan tombol lembut di Figma.
enum GLTone { green, lime, amber, red, blue, neutral }

extension GLToneColors on GLTone {
  Color get background => switch (this) {
        GLTone.green => GreenLoopColors.green100,
        GLTone.lime => GreenLoopColors.lime,
        GLTone.amber => GreenLoopColors.amber100,
        GLTone.red => GreenLoopColors.red100,
        GLTone.blue => GreenLoopColors.blue100,
        GLTone.neutral => GreenLoopColors.background,
      };

  Color get foreground => switch (this) {
        GLTone.green => GreenLoopColors.green700,
        GLTone.lime => GreenLoopColors.green900,
        GLTone.amber => GreenLoopColors.amber,
        GLTone.red => GreenLoopColors.red,
        GLTone.blue => GreenLoopColors.blue,
        GLTone.neutral => GreenLoopColors.textMuted,
      };
}

TextStyle _poppins(
  double size,
  FontWeight weight, {
  Color color = GreenLoopColors.textInk,
  double? height,
}) {
  return GreenLoopTypography.style(size, weight, color: color, height: height ?? 1.5);
}

// ---------------------------------------------------------------------------
// Layout halaman
// ---------------------------------------------------------------------------

/// Header halaman. Contoh: "Ajukan Penjemputan" (M05) dengan tombol kembali,
/// atau "Riwayat Penjemputan" (M06) dengan tombol aksi di kanan.
class GLScreenHeader extends StatelessWidget {
  const GLScreenHeader({
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          if (showBack) ...[
            GLIconButton(
              icon: LucideIcons.chevronLeft,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              tooltip: 'Kembali',
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _poppins(20, FontWeight.w700,
                      color: GreenLoopColors.green900, height: 1.3),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: _poppins(11, FontWeight.w400,
                        color: GreenLoopColors.textMuted),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

/// Tombol ikon persegi 40×40 dengan border (tombol kembali, kalender, edit,
/// notifikasi di Figma).
class GLIconButton extends StatelessWidget {
  const GLIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.showDot = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: GreenLoopColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: GreenLoopColors.textInk),
              if (showDot)
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: GreenLoopColors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Judul seksi + link aksi di kanan ("Penjemputan Aktif · Lihat riwayat").
class GLSectionHeader extends StatelessWidget {
  const GLSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: _poppins(16, FontWeight.w700, color: GreenLoopColors.green900),
          ),
        ),
        if (trailing != null) trailing!,
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: _poppins(12, FontWeight.w600, color: GreenLoopColors.green700),
            ),
          ),
      ],
    );
  }
}

/// Label kecil di atas field form ("Jenis limbah", "Estimasi berat").
class GLFieldLabel extends StatelessWidget {
  const GLFieldLabel(this.text, {this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: _poppins(13, FontWeight.w600)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Bar tombol utama yang menempel di bawah layar ("Kirim untuk Verifikasi",
/// "Daftar sebagai Mitra").
class GLBottomActionBar extends StatelessWidget {
  const GLBottomActionBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: GreenLoopColors.cardBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(top: false, child: child),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu & isi kartu
// ---------------------------------------------------------------------------

/// Kartu putih dengan border tipis dan sudut 16 (dipakai hampir di semua
/// layar).
class GLCard extends StatelessWidget {
  const GLCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color = Colors.white,
    this.borderColor = GreenLoopColors.cardBorder,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: borderColor),
    );
    return Material(
      color: color,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Badge status berbentuk pil ("Menunggu", "Selesai", "Ditolak", "Live").
class GLStatusBadge extends StatelessWidget {
  const GLStatusBadge({
    required this.label,
    this.tone = GLTone.green,
    this.fontSize = 10,
    super.key,
  });

  final String label;
  final GLTone tone;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize > 10 ? 10 : 8, vertical: 4),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: _poppins(fontSize, FontWeight.w600,
            color: tone.foreground, height: 1.2),
      ),
    );
  }
}

/// Kotak ikon berwarna lembut (ikon di kartu dampak, di kiri kartu riwayat).
class GLIconTile extends StatelessWidget {
  const GLIconTile({
    required this.icon,
    this.tone = GLTone.green,
    this.size = 32,
    this.iconSize,
    this.solid = false,
    super.key,
  });

  final IconData icon;
  final GLTone tone;
  final double size;
  final double? iconSize;

  /// true: latar warna utama + ikon putih (dipakai stepper aktif).
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: solid ? tone.foreground : tone.background,
        borderRadius: BorderRadius.circular(size * 0.31),
      ),
      child: Icon(
        icon,
        size: iconSize ?? size / 2,
        color: solid ? Colors.white : tone.foreground,
      ),
    );
  }
}

/// Avatar inisial bulat ("KS" untuk Kafe Senja).
class GLAvatar extends StatelessWidget {
  const GLAvatar({
    required this.initials,
    this.size = 44,
    this.color = GreenLoopColors.green700,
    super.key,
  });

  final String initials;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initials,
        style: _poppins(size * 0.34, FontWeight.w700, color: Colors.white, height: 1),
      ),
    );
  }
}

/// Kartu statistik kecil ("486 kg · limbah", "58 kg · CO2e dicegah").
class GLStatCard extends StatelessWidget {
  const GLStatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.tone = GLTone.green,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;
  final GLTone tone;

  @override
  Widget build(BuildContext context) {
    return GLCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GLIconTile(icon: icon, tone: tone),
          const SizedBox(height: 6),
          Text(value, style: _poppins(16, FontWeight.w700, height: 1.3)),
          Text(
            label,
            style: _poppins(10, FontWeight.w400, color: GreenLoopColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Tombol pintasan 56×56 dengan label di bawah ("Ajukan", "Riwayat",
/// "Tukar Poin", "Belanja" di M04).
class GLQuickAction extends StatelessWidget {
  const GLQuickAction({
    required this.icon,
    required this.label,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      child: Column(
        children: [
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: GreenLoopColors.cardBorder),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(icon, size: 24, color: GreenLoopColors.green700),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: _poppins(12, FontWeight.w500, height: 1.3),
          ),
        ],
      ),
    );
  }
}

/// Baris info berikon di kartu profil ("No. WhatsApp · 0812-3456-7890").
class GLInfoRow extends StatelessWidget {
  const GLInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            GLIconTile(icon: icon, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: _poppins(10, FontWeight.w400,
                        color: GreenLoopColors.textMuted, height: 1.3),
                  ),
                  Text(value, style: _poppins(13, FontWeight.w600, height: 1.4)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Kartu berisi beberapa [GLInfoRow] dengan garis pemisah.
class GLInfoGroup extends StatelessWidget {
  const GLInfoGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GLCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: GreenLoopColors.cardBorder),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Progress bar tipis (progress poin ke level berikutnya).
class GLProgressBar extends StatelessWidget {
  const GLProgressBar({
    required this.value,
    this.height = 6,
    this.trackColor = GreenLoopColors.green700,
    this.fillColor = GreenLoopColors.lime,
    super.key,
  });

  /// 0.0 – 1.0
  final double value;
  final double height;
  final Color trackColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: trackColor)),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: ColoredBox(color: fillColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status penjemputan
// ---------------------------------------------------------------------------

/// Stepper status pikap: Verifikasi foto → Kurir ditugaskan → Dijemput →
/// Selesai (M04, M22).
class GLStatusStepper extends StatelessWidget {
  const GLStatusStepper({
    required this.steps,
    required this.currentIndex,
    this.currentIcon = LucideIcons.hourglass,
    this.currentTone = GLTone.amber,
    super.key,
  });

  final List<String> steps;

  /// Langkah yang sedang berjalan. Langkah sebelumnya dianggap selesai.
  final int currentIndex;
  final IconData currentIcon;
  final GLTone currentTone;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(child: _step(i)),
      ],
    );
  }

  Widget _step(int i) {
    final done = i < currentIndex;
    final current = i == currentIndex;

    Widget dot;
    if (done) {
      dot = _circle(GreenLoopColors.green700,
          const Icon(LucideIcons.check, size: 12, color: Colors.white));
    } else if (current) {
      dot = _circle(currentTone.foreground,
          Icon(currentIcon, size: 12, color: Colors.white));
    } else {
      dot = _circle(
        GreenLoopColors.green100,
        Text('${i + 1}',
            style: _poppins(10, FontWeight.w700,
                color: GreenLoopColors.textMuted, height: 1)),
      );
    }

    return Column(
      children: [
        dot,
        const SizedBox(height: 6),
        Text(
          steps[i],
          textAlign: TextAlign.center,
          style: _poppins(
            9,
            FontWeight.w500,
            color: done || current ? GreenLoopColors.textInk : GreenLoopColors.textMuted,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _circle(Color color, Widget child) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Tombol & pilihan
// ---------------------------------------------------------------------------

/// Tombol lembut berwarna ("Ubah jadwal" hijau, "Batalkan" merah di M06,
/// "Hapus akun" di M08).
class GLSoftButton extends StatelessWidget {
  const GLSoftButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = GLTone.green,
    this.outlined = false,
    this.height = 40,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GLTone tone;

  /// true: latar putih + border (tombol "Keluar" di M08).
  final bool outlined;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fg = outlined ? GreenLoopColors.textInk : tone.foreground;
    return SizedBox(
      height: height,
      child: Material(
        color: outlined ? Colors.white : tone.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: outlined
              ? const BorderSide(color: GreenLoopColors.cardBorder)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(13, FontWeight.w600, color: fg, height: 1.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Deretan chip filter horizontal ("Semua · Menunggu · Dijadwalkan ·
/// Selesai" di M06).
class GLFilterChips extends StatelessWidget {
  const GLFilterChips({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _chip(i),
          ],
        ],
      ),
    );
  }

  Widget _chip(int i) {
    final selected = i == selectedIndex;
    return Material(
      color: selected ? GreenLoopColors.green700 : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? GreenLoopColors.green700 : GreenLoopColors.cardBorder,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => onSelected(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            labels[i],
            style: _poppins(12, selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : GreenLoopColors.textInk, height: 1.3),
          ),
        ),
      ),
    );
  }
}

/// Kotak pilihan (jenis limbah, slot waktu, armada di M05; role di M03).
/// Saat terpilih: latar hijau muda + border hijau tua.
class GLOptionTile extends StatelessWidget {
  const GLOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.vertical = false,
    this.centered = false,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? subtitle;

  /// true: ikon di atas teks, rata tengah (kartu role di M03).
  final bool vertical;

  /// true: ikon + teks di tengah (pilihan armada di M03b dan M05).
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? GreenLoopColors.green700 : GreenLoopColors.textInk;
    final labelStyle = _poppins(
      12,
      vertical ? FontWeight.w700 : (selected ? FontWeight.w600 : FontWeight.w500),
      color: fg,
      height: 1.3,
    );

    final Widget content;
    if (vertical) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            selected
                ? GLIconTile(icon: icon!, size: 32, solid: true)
                : GLIconTile(icon: icon!, size: 32),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: labelStyle),
          if (subtitle != null)
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: _poppins(10, FontWeight.w400,
                  color: GreenLoopColors.textMuted, height: 1.3),
            ),
        ],
      );
    } else {
      final text = Text(label, style: labelStyle);
      content = Row(
        mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
          ],
          if (centered) Flexible(child: text) else Expanded(child: text),
        ],
      );
    }

    final radius = BorderRadius.circular(vertical ? 14 : 12);
    return Material(
      color: selected ? GreenLoopColors.green100 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? GreenLoopColors.green700 : GreenLoopColors.cardBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: vertical
              ? const EdgeInsets.all(10)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: content,
        ),
      ),
    );
  }
}

/// Kotak isian bergaya Figma: ikon di kiri + nilai, bisa diketuk
/// (estimasi berat, tanggal, dropdown kota).
class GLValueField extends StatelessWidget {
  const GLValueField({
    required this.value,
    this.icon,
    this.onTap,
    this.showDropdown = false,
    this.placeholder = false,
    super.key,
  });

  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool showDropdown;

  /// true: teks abu-abu (belum diisi).
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: GreenLoopColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: GreenLoopColors.textInk),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  value,
                  style: _poppins(
                    13,
                    FontWeight.w500,
                    color: placeholder ? GreenLoopColors.textMuted : GreenLoopColors.textInk,
                    height: 1.3,
                  ),
                ),
              ),
              if (showDropdown)
                const Icon(LucideIcons.chevronDown,
                    size: 18, color: GreenLoopColors.textInk),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kotak upload bergaris putus-putus ("Upload foto limbah" di M05).
class GLUploadBox extends StatelessWidget {
  const GLUploadBox({
    required this.title,
    this.subtitle,
    this.icon = LucideIcons.camera,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: GreenLoopColors.green700.withValues(alpha: 0.5),
        radius: 14,
      ),
      child: Material(
        color: GreenLoopColors.green100.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: GreenLoopColors.green700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: _poppins(13, FontWeight.w600, height: 1.3)),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: _poppins(10, FontWeight.w400,
                              color: GreenLoopColors.textMuted, height: 1.3),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

// ---------------------------------------------------------------------------
// Peta (tiruan statis)
// ---------------------------------------------------------------------------

/// Peta statis bergaya OpenStreetMap untuk mockup (profil mitra, rute
/// kurir). Pemilik modul Courier & Route nanti menggantinya dengan peta asli.
class GLMapPlaceholder extends StatelessWidget {
  const GLMapPlaceholder({
    this.height = 120,
    this.pins = const [Offset(0.5, 0.45)],
    this.showRoute = false,
    this.borderRadius = 12,
    super.key,
  });

  final double height;

  /// Posisi pin relatif (0–1) terhadap lebar dan tinggi peta.
  final List<Offset> pins;

  /// true: gambar garis rute yang menghubungkan pin.
  final bool showRoute;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MapPainter(pins: pins, showRoute: showRoute)),
            ),
            for (var i = 0; i < pins.length; i++)
              Positioned.fill(
                child: Align(
                  alignment: Alignment(pins[i].dx * 2 - 1, pins[i].dy * 2 - 1),
                  child: Transform.translate(
                    offset: const Offset(0, -14),
                    child: Icon(
                      Icons.location_on,
                      size: 32,
                      color: i == 0 ? GreenLoopColors.green700 : GreenLoopColors.amber,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 6,
              bottom: 4,
              child: Text(
                '© OpenStreetMap',
                style: _poppins(8, FontWeight.w400, color: GreenLoopColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.pins, required this.showRoute});

  final List<Offset> pins;
  final bool showRoute;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEFF1EA));

    final park = Paint()..color = const Color(0xFFCDE8B5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.06, size.height * 0.12, size.width * 0.22, size.height * 0.22),
        const Radius.circular(4),
      ),
      park,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.66, size.height * 0.08, size.width * 0.26, size.height * 0.24),
        const Radius.circular(4),
      ),
      park,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.62, size.height * 0.66, size.width * 0.3, size.height * 0.22),
        const Radius.circular(4),
      ),
      park,
    );

    final road = Paint()
      ..color = const Color(0xFFF7D9A8)
      ..strokeWidth = 10;
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), road);
    canvas.drawLine(Offset(size.width * 0.58, 0), Offset(size.width * 0.58, size.height), road);

    final river = Paint()
      ..color = const Color(0xFFA9D4E6)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final riverPath = Path()
      ..moveTo(0, size.height * 0.62)
      ..cubicTo(size.width * 0.3, size.height * 0.5, size.width * 0.6, size.height * 0.62,
          size.width, size.height * 0.48);
    canvas.drawPath(riverPath, river);

    if (showRoute && pins.length > 1) {
      final route = Paint()
        ..color = GreenLoopColors.green700
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final points = pins.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, route);
    }
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) =>
      oldDelegate.pins != pins || oldDelegate.showRoute != showRoute;
}

// ---------------------------------------------------------------------------
// Tab bar per role
// ---------------------------------------------------------------------------

/// Role yang punya tab bar sendiri di Figma.
enum GLTabRole { mitra, konsumen, kurir, admin }

class GLTabItem {
  const GLTabItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Isi tab per role, sesuai komponen "Mobile / Tab Bar ..." di Figma.
const Map<GLTabRole, List<GLTabItem>> glTabsByRole = {
  GLTabRole.mitra: [
    GLTabItem('Beranda', LucideIcons.house),
    GLTabItem('Jemput', LucideIcons.truck),
    GLTabItem('Reward', LucideIcons.gift),
    GLTabItem('Belanja', LucideIcons.shoppingCart),
    GLTabItem('Profil', LucideIcons.user),
  ],
  GLTabRole.konsumen: [
    GLTabItem('Beranda', LucideIcons.house),
    GLTabItem('Katalog', LucideIcons.box),
    GLTabItem('Keranjang', LucideIcons.shoppingCart),
    GLTabItem('Pesanan', LucideIcons.list),
    GLTabItem('Profil', LucideIcons.user),
  ],
  GLTabRole.kurir: [
    GLTabItem('Dashboard', LucideIcons.house),
    GLTabItem('Rute', LucideIcons.map),
    GLTabItem('Rekap', LucideIcons.scale),
    GLTabItem('Profil', LucideIcons.user),
  ],
  GLTabRole.admin: [
    GLTabItem('Beranda', LucideIcons.house),
    GLTabItem('Pikap', LucideIcons.camera),
    GLTabItem('Kurir', LucideIcons.truck),
    GLTabItem('Produk', LucideIcons.box),
    GLTabItem('Pesanan', LucideIcons.list),
  ],
};

/// Tab bar bawah GreenLoop. Tab aktif: pil hijau muda di belakang ikon,
/// label SemiBold hijau tua. Tab lain: ikon & label abu-abu.
class GLTabBar extends StatelessWidget {
  const GLTabBar({
    required this.role,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final GLTabRole role;
  final int currentIndex;
  final ValueChanged<int> onTap;

  List<GLTabItem> get items => glTabsByRole[role]!;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: GreenLoopColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                _GLTabButton(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GLTabButton extends StatelessWidget {
  const _GLTabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GLTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? GreenLoopColors.green700 : GreenLoopColors.textMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: SizedBox(
          width: 66,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? GreenLoopColors.green100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Icon(item.icon, size: 22, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: _poppins(11, selected ? FontWeight.w600 : FontWeight.w500,
                    color: color, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper kecil untuk blur dekoratif (lingkaran di kartu poin M04).
class GLDecorCircle extends StatelessWidget {
  const GLDecorCircle({
    this.size = 180,
    this.color = GreenLoopColors.green700,
    this.blur = 0,
    super.key,
  });

  final double size;
  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    if (blur == 0) return circle;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: circle,
    );
  }
}
