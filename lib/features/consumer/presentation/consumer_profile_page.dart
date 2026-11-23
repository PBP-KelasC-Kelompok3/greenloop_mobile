import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../shared/dummy/dummy_data.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/presentation/auth_pages.dart';
import '../../auth/services/auth_service.dart';

TextStyle _text(double size, FontWeight weight,
        {Color color = GreenLoopColors.textInk, double height = 1.5}) =>
    GreenLoopTypography.style(size, weight, color: color, height: height);

/// M26 · Profil Konsumen.
///
/// Nama, username, dan email diambil dari user yang sedang login. Kalau
/// belum ada (mode demo), memakai contoh dari Figma.
class ConsumerProfilePage extends StatelessWidget {
  const ConsumerProfilePage({
    this.authService,
    this.onOpenOrders,
    this.onOpenCart,
    this.onOpenCatalog,
    super.key,
  });

  final AuthService? authService;
  final VoidCallback? onOpenOrders;
  final VoidCallback? onOpenCart;
  final VoidCallback? onOpenCatalog;

  AuthService get _auth => authService ?? defaultAuthService;

  Future<void> _logout(BuildContext context) async {
    final auth = _auth;
    try {
      await auth.logout();
    } catch (_) {
      // Tetap kembali ke onboarding walau server tidak bisa dihubungi.
    }
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => WelcomePage(authService: auth, skipSessionCheck: true),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser?.user;
    final name = _or(user?.displayName, DummyData.consumerName);
    final email = _or(user?.email, DummyData.consumerEmail);
    final username = _or(user?.username, DummyData.consumerUsername);
    final initials = user == null ? DummyData.consumerInitials : _initials(name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GLScreenHeader(title: 'Profil'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
            children: [
              GLCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GLAvatar(initials: initials, size: 60),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: _text(16, FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(email,
                              style: _text(11, FontWeight.w400,
                                  color: GreenLoopColors.textMuted)),
                          const SizedBox(height: 4),
                          const GLStatusBadge(label: 'Konsumen'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GLCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Akun', style: _text(13, FontWeight.w600)),
                    const SizedBox(height: 10),
                    const Divider(
                        height: 1,
                        thickness: 1,
                        color: GreenLoopColors.cardBorder),
                    for (final (label, value) in [
                      ('Username', username),
                      ('Email', email),
                      ('Role', 'Konsumen'),
                      ('Bergabung', DummyData.consumerJoined),
                    ]) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(label,
                              style: _text(12, FontWeight.w400,
                                  color: GreenLoopColors.textMuted)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              value,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: _text(12, FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _MenuCard(items: [
                _MenuItem(LucideIcons.list, 'Pesanan Saya', onOpenOrders),
                _MenuItem(LucideIcons.shoppingCart, 'Keranjang', onOpenCart),
                _MenuItem(LucideIcons.box, 'Katalog Produk', onOpenCatalog),
              ]),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(LucideIcons.logOut, size: 16),
              label: Text('Keluar',
                  style: _text(14, FontWeight.w600,
                      color: GreenLoopColors.red, height: 1.2)),
              style: OutlinedButton.styleFrom(
                foregroundColor: GreenLoopColors.red,
                backgroundColor: Colors.white,
                side: const BorderSide(color: GreenLoopColors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _or(String? value, String fallback) =>
    value == null || value.trim().isEmpty ? fallback : value;

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  final letters = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
  return letters.toUpperCase();
}

class _MenuItem {
  const _MenuItem(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return GLCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(
                  height: 1, thickness: 1, color: GreenLoopColors.cardBorder),
            InkWell(
              onTap: items[i].onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    GLIconTile(icon: items[i].icon, size: 34, iconSize: 17),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          Text(items[i].label, style: _text(13, FontWeight.w500)),
                    ),
                    const Icon(LucideIcons.chevronRight,
                        size: 16, color: GreenLoopColors.textInk),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
