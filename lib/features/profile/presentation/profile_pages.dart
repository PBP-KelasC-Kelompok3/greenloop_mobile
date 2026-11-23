import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_pages.dart' show WelcomePage;
import '../../auth/services/auth_service.dart';
import '../../courier/presentation/courier_page.dart';
import '../../mitra/data/mitra_shop_service.dart';
import '../../mitra/presentation/mitra_edit_profile_page.dart';
import '../../mitra/presentation/mitra_faq_page.dart';
import '../../mitra/presentation/mitra_orders_page.dart';
import '../../mitra/presentation/mitra_reward_page.dart';

export '../../auth/data/auth_models.dart' show UserRole, UserRoleData;

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.role, this.authService, super.key});

  final UserRole role;
  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    final auth = authService ?? defaultAuthService;
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: auth.currentUserNotifier,
      builder: (context, profile, _) {
        final isMitra = role == UserRole.mitra;
        final account = profile?.user;
        final mitra = profile?.mitraProfile;
        final businessName = mitra?.businessName?.trim() ?? '';
        final displayName = isMitra && businessName.isNotEmpty
            ? businessName
            : (account?.displayName ?? role.label);
        final email = account?.email ?? '';
        final subtitle = isMitra
            ? [mitra?.businessType, mitra?.picName]
                  .where((value) => value?.trim().isNotEmpty == true)
                  .join(' · ')
            : email;
        final menu = _menuFor(role);

        return Scaffold(
          backgroundColor: GreenLoopColors.surface,
          appBar: AppBar(
            title: const Text('Profil'),
            actions: [
              IconButton(
                tooltip: 'Edit profil',
                onPressed: () => _openEdit(context, auth, role),
                icon: const Icon(Icons.edit_outlined),
                color: GreenLoopColors.forest2,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
            children: [
              _IdentityCard(
                name: displayName,
                subtitle: subtitle.isEmpty
                    ? (isMitra ? 'Profil usaha mitra' : 'Data akun GreenLoop')
                    : subtitle,
                badge: isMitra ? 'Mitra B2B' : role.label,
              ),
              if (isMitra) ...[
                const SizedBox(height: 10),
                _MitraAddressCard(
                  profile: mitra,
                  onEdit: () => _openEdit(context, auth, role),
                ),
              ],
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: GreenLoopColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      for (var index = 0; index < menu.length; index++) ...[
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 1,
                          ),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: GreenLoopColors.mint,
                            child: Icon(
                              menu[index].icon,
                              size: 19,
                              color: GreenLoopColors.forest2,
                            ),
                          ),
                          title: Text(
                            menu[index].title,
                            style: const TextStyle(
                              color: GreenLoopColors.textInk,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            menu[index].subtitle,
                            style: const TextStyle(
                              color: GreenLoopColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: GreenLoopColors.muted,
                          ),
                          onTap: () => _openMenu(
                            context,
                            auth,
                            role,
                            menu[index].title,
                          ),
                        ),
                        if (index < menu.length - 1)
                          const Divider(
                            height: 1,
                            indent: 58,
                            color: GreenLoopColors.border,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () => _confirmLogout(context, auth),
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFCE9E8),
                    foregroundColor: const Color(0xFFE9534F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static List<_ProfileMenuData> _menuFor(UserRole role) {
    if (role == UserRole.mitra) {
      return const [
        _ProfileMenuData(Icons.business_outlined, 'Data Usaha', 'Informasi usaha'),
        _ProfileMenuData(Icons.confirmation_num_outlined, 'Voucher Saya', 'Voucher dan reward'),
        _ProfileMenuData(Icons.inventory_2_outlined, 'Pesanan Saya', 'Riwayat pesanan'),
        _ProfileMenuData(Icons.info_outline, 'Bantuan & FAQ', 'Pusat bantuan'),
      ];
    }
    if (role == UserRole.courier) {
      return const [
        _ProfileMenuData(Icons.directions_car_outlined, 'Informasi Kendaraan', 'Data kendaraan'),
        _ProfileMenuData(Icons.receipt_long_outlined, 'Riwayat Jemput', 'Riwayat penjemputan'),
        _ProfileMenuData(Icons.info_outline, 'Bantuan & FAQ', 'Pusat bantuan'),
      ];
    }
    return const [
      _ProfileMenuData(Icons.shopping_bag_outlined, 'Pesanan Saya', 'Riwayat pesanan'),
      _ProfileMenuData(Icons.card_giftcard_outlined, 'Reward Saya', 'Poin dan reward'),
      _ProfileMenuData(Icons.info_outline, 'Bantuan & FAQ', 'Pusat bantuan'),
    ];
  }

  static void _openEdit(BuildContext context, AuthService auth, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => role == UserRole.mitra
            ? MitraEditProfilePage(authService: auth)
            : EditProfilePage(role: role, authService: auth),
      ),
    );
  }

  static void _openMenu(
    BuildContext context,
    AuthService auth,
    UserRole role,
    String title,
  ) {
    if (role == UserRole.mitra) {
      switch (title) {
        case 'Data Usaha':
          _openEdit(context, auth, role);
          return;
        case 'Voucher Saya':
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const MitraRewardPage()),
          );
          return;
        case 'Pesanan Saya':
          // Reuse the same authenticated API service and order page as Belanja.
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MitraOrdersPage(
                service: MitraShopService(auth),
              ),
            ),
          );
          return;
        case 'Bantuan & FAQ':
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const MitraFaqPage()),
          );
          return;
      }
    }
    if (role == UserRole.courier && title == 'Informasi Kendaraan') {
      _openEdit(context, auth, role);
      return;
    }
    if (role == UserRole.courier && title == 'Riwayat Jemput') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CourierDashboardPage(
            authService: auth,
            mode: CourierPageMode.recap,
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title belum tersedia untuk akun ini.')),
    );
  }

  static Future<void> _confirmLogout(
    BuildContext context,
    AuthService auth,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu masuk kembali untuk membuka profil.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await auth.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => WelcomePage(authService: auth, skipSessionCheck: true),
        ),
        (_) => false,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal keluar: $error')),
      );
    }
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.name, required this.subtitle, required this.badge});

  final String name;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'G' : name.trim()[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GreenLoopColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: GreenLoopColors.forest2,
            child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: GreenLoopColors.ink)),
                const SizedBox(height: 2),
                Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: GreenLoopColors.muted)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: const BoxDecoration(color: GreenLoopColors.mint, borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GreenLoopColors.forest2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MitraAddressCard extends StatelessWidget {
  const _MitraAddressCard({required this.profile, required this.onEdit});

  final MitraProfileData? profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final latitude = profile?.latitude;
    final longitude = profile?.longitude;
    final hasPoint = latitude != null && longitude != null;
    final point = hasPoint ? LatLng(latitude, longitude) : const LatLng(-6.3627, 106.82715);
    final address = [
      profile?.addressDetail,
      profile?.kelurahan,
      profile?.kecamatan,
      profile?.kota,
      profile?.provinsi,
    ].where((part) => part?.trim().isNotEmpty == true).join(', ');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GreenLoopColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 190,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasPoint
                  ? FlutterMap(
                      options: MapOptions(
                        initialCenter: point,
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.greenloop.mobile',
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            point: point,
                            width: 42,
                            height: 48,
                            child: const Icon(Icons.location_pin, size: 42, color: GreenLoopColors.forest2),
                          ),
                        ]),
                        const RichAttributionWidget(
                          attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
                        ),
                      ],
                    )
                  : Container(
                      color: GreenLoopColors.mint,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined, size: 34, color: GreenLoopColors.forest2),
                          SizedBox(height: 5),
                          Text('Titik alamat belum disimpan', style: TextStyle(color: GreenLoopColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline, size: 17, color: GreenLoopColors.forest2),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address.isEmpty ? 'Alamat usaha belum tersedia.' : address,
                  style: const TextStyle(fontSize: 12, height: 1.4, color: GreenLoopColors.muted),
                ),
              ),
            ],
          ),
          if (profile?.courierNotes?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text('Catatan kurir: ${profile!.courierNotes}', style: const TextStyle(fontSize: 11, color: GreenLoopColors.forest2)),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuData {
  const _ProfileMenuData(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({required this.role, this.authService, super.key});

  final UserRole role;
  final AuthService? authService;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _plateNumber = TextEditingController();
  late final AuthService _auth;
  String _vehicleType = 'pickup_bak';
  bool _saving = false;

  bool get _isCourier => widget.role == UserRole.courier;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? defaultAuthService;
    final account = _auth.currentUser?.user;
    _firstName.text = account?.firstName ?? '';
    _lastName.text = account?.lastName ?? '';
    _email.text = account?.email ?? '';
    final courier = _auth.currentUser?.courierProfile;
    _plateNumber.text = courier?.plateNumber ?? '';
    if (courier?.vehicleType == 'motor_box' || courier?.vehicleType == 'pickup_bak') {
      _vehicleType = courier!.vehicleType!;
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _plateNumber.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final payload = <String, dynamic>{
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'email': _email.text.trim(),
      if (_isCourier) ...{
        'plate_number': _plateNumber.text.trim().toUpperCase(),
        'vehicle_type': _vehicleType,
      },
    };
    try {
      await _auth.updateProfile(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui.')));
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    } catch (error) {
      if (mounted) _showError('Gagal menyimpan profil: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(title: const Text('Edit Profil')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _ProfileField(label: 'Nama depan', controller: _firstName),
          const SizedBox(height: 12),
          _ProfileField(label: 'Nama belakang', controller: _lastName),
          const SizedBox(height: 12),
          _ProfileField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty || !text.contains('@')) return 'Masukkan email yang valid.';
              return null;
            },
          ),
          if (_isCourier) ...[
            const SizedBox(height: 12),
            _ProfileField(label: 'Nomor kendaraan', controller: _plateNumber),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _vehicleType,
              decoration: const InputDecoration(labelText: 'Jenis kendaraan'),
              items: const [
                DropdownMenuItem(value: 'motor_box', child: Text('Motor Box')),
                DropdownMenuItem(value: 'pickup_bak', child: Text('Pickup Bak')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _vehicleType = value);
              },
            ),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Simpan perubahan'),
          ),
        ],
      ),
    ),
  );
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(labelText: label),
  );
}