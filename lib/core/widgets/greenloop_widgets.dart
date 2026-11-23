import 'package:flutter/material.dart';

import '../../shared/theme/greenloop_theme.dart';

class GreenLoopButton extends StatelessWidget {
  const GreenLoopButton({
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.light = false,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool light;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    // Warna label mengikuti Figma:
    // - tombol primer: putih (deepForest untuk varian light)
    // - tombol sekunder: circleGreen (#1E5B2E), juga untuk varian light
    final primaryLabel = light ? GreenLoopColors.green900 : Colors.white;
    const secondaryLabel = GreenLoopColors.green700;

    final effectiveOnPressed = isLoading ? null : onPressed;

    final content = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: secondary ? secondaryLabel : primaryLabel,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              // Figma: teks tombol 15 / SemiBold
              Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: secondary
          ? OutlinedButton(
              onPressed: effectiveOnPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: secondaryLabel,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: light ? Colors.white : GreenLoopColors.green700,
                  width: 1.5,
                ),
                shape: shape,
              ),
              child: content,
            )
          : FilledButton(
              onPressed: effectiveOnPressed,
              style: FilledButton.styleFrom(
                foregroundColor: primaryLabel,
                backgroundColor: light
                    ? GreenLoopColors.lime
                    : GreenLoopColors.green700,
                elevation: 0,
                shape: shape,
              ),
              child: content,
            ),
    );
  }
}

class GreenLoopLogo extends StatelessWidget {
  const GreenLoopLogo({this.light = false, this.width = 190, super.key});

  final bool light;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/greenloop_logo_lockup.png',
      width: width,
      height: width * 0.19,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
      errorBuilder: (context, error, stackTrace) {
        final color = light ? Colors.white : GreenLoopColors.forest2;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.all_inclusive_rounded, size: 32, color: color),
            const SizedBox(width: 7),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'GREEN',
                    style: TextStyle(color: color),
                  ),
                  const TextSpan(
                    text: 'LOOP',
                    style: TextStyle(color: GreenLoopColors.leaf),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
          ],
        );
      },
    );
  }
}

class PageIntro extends StatelessWidget {
  const PageIntro({required this.title, required this.description, super.key});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 7),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: GreenLoopColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class AuthNotice extends StatelessWidget {
  const AuthNotice({
    required this.text,
    this.icon = Icons.info_outline,
    super.key,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GreenLoopColors.mint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: GreenLoopColors.forest2),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: GreenLoopColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class FormFieldTile extends StatelessWidget {
  const FormFieldTile({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffix,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        validator: validator,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(
              color: GreenLoopColors.textInk,
              fontWeight: FontWeight.w500,
            ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}

String? requiredField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Bagian ini wajib diisi.';
  }
  return null;
}

void showApiNotConnected(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text(
          'Validasi lokal berhasil. Koneksi API belum diimplementasikan.',
        ),
      ),
    );
}