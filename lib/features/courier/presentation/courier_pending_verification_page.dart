import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';

class CourierPendingVerificationPage extends StatefulWidget {
  const CourierPendingVerificationPage({
    required this.authService,
    required this.onApproved,
    required this.onLogout,
    super.key,
  });

  final AuthService authService;
  final VoidCallback onApproved;
  final Future<void> Function() onLogout;

  @override
  State<CourierPendingVerificationPage> createState() =>
      _CourierPendingVerificationPageState();
}

class _CourierPendingVerificationPageState
    extends State<CourierPendingVerificationPage> {
  bool _checking = false;
  String? _message;

  Future<void> _checkApproval() async {
    setState(() {
      _checking = true;
      _message = null;
    });
    try {
      final profile = await widget.authService.fetchProfile();
      if (!mounted) return;
      if (profile.courierProfile?.isApproved == true) {
        widget.onApproved();
      } else {
        setState(() {
          _message = 'Akunmu masih menunggu pemeriksaan admin.';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = 'Status belum dapat diperiksa: $error';
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: GreenLoopColors.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: GreenLoopColors.border),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          color: GreenLoopColors.mint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          size: 34,
                          color: GreenLoopColors.forest2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Menunggu Verifikasi Admin',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Halo ${widget.authService.currentUser?.user.displayName ?? 'Kurir'}, akun kurirmu sudah terdaftar. Admin perlu memeriksa data kendaraan sebelum kamu dapat membuka dashboard kurir.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: GreenLoopColors.muted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: GreenLoopColors.forest2,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _checking ? null : _checkApproval,
                          icon: _checking
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(
                            _checking ? 'Memeriksa…' : 'Periksa status',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: widget.onLogout,
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Keluar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
