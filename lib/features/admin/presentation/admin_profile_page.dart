import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/presentation/auth_pages.dart';
import '../../auth/services/auth_service.dart';
import '../data/admin_dummy.dart';
import 'admin_vouchers_page.dart';
import 'admin_widgets.dart';

/// M37 · Profil Admin.
///
/// Username dan email diambil dari user yang login; kalau tidak ada (mode
/// demo) memakai contoh dari Figma.
class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({this.authService, this.onBack, super.key});

  final AuthService? authService;
  final VoidCallback? onBack;

  AuthService get _auth => authService ?? defaultAuthService;

  Future<void> _logout(BuildContext context) async {
    final auth = _auth;
    try {
      await auth.logout();
    } catch (_) {
      // Tetap kembali ke onboarding walau server tidak bisa dihubungi.
    }
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => WelcomePage(authService: auth, skipSessionCheck: true),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser?.user;
    String or(String? v, String fallback) =>
        v == null || v.trim().isEmpty ? fallback : v;
    final username = or(user?.username, AdminDummy.adminUsername);
    final email = or(user?.email, AdminDummy.adminEmail);
    final name = or(user?.displayName, AdminDummy.adminName);

    return Scaffold(
      backgroundColor: GreenLoopColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GLScreenHeader(
              title: 'Profil Admin',
              subtitle: 'Akun yang mengelola GreenLoop',
              showBack: true,
              onBack: onBack,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: adminCardDecoration(),
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: const BoxDecoration(
                            color: GreenLoopColors.green900,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.shieldCheck,
                              size: 34, color: GreenLoopColors.lime),
                        ),
                        const SizedBox(height: 8),
                        Text(name, style: adminText(17, FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(email,
                            style: adminText(12, FontWeight.w400,
                                color: GreenLoopColors.textMuted)),
                        const SizedBox(height: 8),
                        const GLStatusBadge(
                          label: 'Administrator',
                          tone: GLTone.lime,
                          fontSize: 11,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: adminCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informasi Akun',
                            style: adminText(13, FontWeight.w600)),
                        const SizedBox(height: 10),
                        const Divider(
                            height: 1,
                            thickness: 1,
                            color: GreenLoopColors.cardBorder),
                        for (final (label, value) in [
                          ('Username', username),
                          ('Email', email),
                          ('Role', 'Administrator'),
                          ('Area Pilot', AdminDummy.pilotArea),
                        ]) ...[
                          const SizedBox(height: 10),
                          AdminInfoRow(label: label, value: value),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: adminCardDecoration(),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          _MenuRow(
                            icon: LucideIcons.ticket,
                            label: 'Voucher Reward',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const AdminVouchersPage()),
                            ),
                          ),
                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: GreenLoopColors.cardBorder),
                          _MenuRow(
                            icon: LucideIcons.logOut,
                            label: 'Keluar',
                            danger: true,
                            onTap: () => _logout(context),
                          ),
                        ],
                      ),
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

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            danger
                ? Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: GreenLoopColors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 17, color: Colors.white),
                  )
                : GLIconTile(icon: icon, size: 34, iconSize: 17),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: adminText(13, FontWeight.w500,
                      color: danger
                          ? GreenLoopColors.red
                          : GreenLoopColors.textInk)),
            ),
            const Icon(LucideIcons.chevronRight,
                size: 16, color: GreenLoopColors.textInk),
          ],
        ),
      ),
    );
  }
}
