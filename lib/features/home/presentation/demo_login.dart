import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/data/auth_models.dart';
import 'role_navigation_page.dart';

/// Tombol "Masuk demo" untuk mencoba semua flow UI tanpa backend.
///
/// Hanya tampil di mode debug (`flutter run`), tidak ikut ke build release
/// atau APK yang dikumpulkan.
class DemoLoginButton extends StatelessWidget {
  const DemoLoginButton({super.key});

  static const _roles = [
    (UserRole.mitra, 'Mitra B2B', LucideIcons.store),
    (UserRole.consumer, 'Konsumen', LucideIcons.shoppingCart),
    (UserRole.courier, 'Kurir', LucideIcons.truck),
    (UserRole.admin, 'Admin', LucideIcons.shield),
  ];

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return TextButton.icon(
      onPressed: () => _showRolePicker(context),
      icon: const Icon(LucideIcons.flaskConical, size: 16),
      label: const Text('Masuk demo (tanpa backend)'),
      style: TextButton.styleFrom(foregroundColor: GreenLoopColors.textMuted),
    );
  }

  Future<void> _showRolePicker(BuildContext context) async {
    final role = await showModalBottomSheet<UserRole>(
      context: context,
      backgroundColor: GreenLoopColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Masuk demo sebagai',
                style: GreenLoopTypography.style(16, FontWeight.w700),
              ),
              Text(
                'Data contoh, tidak terhubung ke server.',
                style: GreenLoopTypography.style(
                  12,
                  FontWeight.w400,
                  color: GreenLoopColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              for (final (role, label, icon) in _roles) ...[
                GLOptionTile(
                  label: label,
                  icon: icon,
                  selected: false,
                  onTap: () => Navigator.of(sheetContext).pop(role),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );

    if (role == null || !context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => RoleNavigationPage(role: role)),
      (_) => false,
    );
  }
}
