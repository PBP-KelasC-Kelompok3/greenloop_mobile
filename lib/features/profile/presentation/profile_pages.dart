import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_pages.dart' show WelcomePage;
import '../../auth/services/auth_service.dart';
import '../../mitra/presentation/mitra_faq_page.dart';
import '../../consumer/presentation/consumer_shop_pages.dart';

export '../../auth/data/auth_models.dart' show UserRole, UserRoleData;

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.role,
    this.authService,
    super.key,
  });

  final UserRole role;
  final AuthService? authService;

  void _notConnected(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature belum terhubung ke API.')));
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAuth = authService ?? defaultAuthService;
    final currentUser = effectiveAuth.currentUser;
    final userAccount = currentUser?.user;
    final isMitra = role == UserRole.mitra;

    final displayName = userAccount != null && userAccount.displayName.isNotEmpty
        ? userAccount.displayName
        : (isMitra ? 'Profil Mitra' : 'Profil ${role.label}');

    final displayEmail = userAccount != null && userAccount.email.isNotEmpty
        ? userAccount.email
        : 'Data akun akan tampil setelah API tersambung';

    final avatarLetter = userAccount != null && userAccount.displayName.isNotEmpty
        ? userAccount.displayName.substring(0, 1).toUpperCase()
        : (isMitra ? 'M' : role.label.substring(0, 1));

    final menu = isMitra
        ? const [
            _ProfileMenuData(
              Icons.business_outlined,
              'Data Usaha',
              'Informasi usaha',
            ),
            _ProfileMenuData(
              Icons.confirmation_num_outlined,
              'Voucher Saya',
              'Voucher dan reward',
            ),
            _ProfileMenuData(
              Icons.inventory_2_outlined,
              'Pesanan Saya',
              'Riwayat pesanan',
            ),
            _ProfileMenuData(
              Icons.info_outline,
              'Bantuan & FAQ',
              'Pusat bantuan',
            ),
          ]
        : role == UserRole.courier
        ? const [
            _ProfileMenuData(
              Icons.local_shipping_outlined,
              'Informasi Kendaraan',
              'Data kendaraan',
            ),
            _ProfileMenuData(
              Icons.receipt_long_outlined,
              'Riwayat Jemput',
              'Riwayat penjemputan',
            ),
            _ProfileMenuData(
              Icons.info_outline,
              'Bantuan & FAQ',
              'Pusat bantuan',
            ),
          ]
        : const [
            _ProfileMenuData(
              Icons.shopping_bag_outlined,
              'Pesanan Saya',
              'Riwayat pesanan',
            ),
            _ProfileMenuData(
              Icons.card_giftcard_outlined,
              'Reward Saya',
              'Poin dan reward',
            ),
            _ProfileMenuData(
              Icons.info_outline,
              'Bantuan & FAQ',
              'Pusat bantuan',
            ),
          ];

    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EditProfilePage(
                    role: role,
                    authService: effectiveAuth,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: GreenLoopColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 5, 18, 22),
        children: [
          // PROFILE IDENTITY
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: GreenLoopColors.border),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: GreenLoopColors.forest2,
                  child: Text(
                    avatarLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GreenLoopColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: GreenLoopColors.mint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isMitra ? 'Mitra B2B' : role.label,
                    style: const TextStyle(
                      color: GreenLoopColors.circleGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isMitra) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: GreenLoopColors.border),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      _ProfileMetric(value: '—', label: 'pickup'),
                      _ProfileMetric(value: '—', label: 'limbah'),
                      _ProfileMetric(value: '—', label: 'poin'),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // PICKUP ADDRESS (MITRA)
          if (isMitra) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: GreenLoopColors.mint,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: GreenLoopColors.border),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: GreenLoopColors.leaf,
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: GreenLoopColors.forest2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.mitraProfile?.businessName ??
                              'Alamat penjemputan',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          currentUser?.mitraProfile?.courierNotes ??
                              currentUser?.mitraProfile?.phoneNumber ??
                              'Alamat usaha akan tampil setelah profil dimuat.',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: GreenLoopColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // PROFILE MENU
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: GreenLoopColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.white,
                child: Column(
                  children: [
                    for (var i = 0; i < menu.length; i++) ...[
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: GreenLoopColors.mint,
                          child: Icon(
                            menu[i].icon,
                            size: 19,
                            color: GreenLoopColors.forest2,
                          ),
                        ),
                        title: Text(
                          menu[i].title,
                          style: const TextStyle(
                            color: GreenLoopColors.textInk,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          menu[i].subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: GreenLoopColors.textMuted,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: GreenLoopColors.muted,
                          size: 20,
                        ),
                        onTap: () {
                          if (isMitra && menu[i].title == 'Data Usaha') {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => EditProfilePage(
                                  role: role,
                                  authService: effectiveAuth,
                                ),
                              ),
                            );
                          } else if (isMitra &&
                              menu[i].title == 'Bantuan & FAQ') {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const MitraFaqPage(),
                              ),
                            );
                          } else if (isMitra &&
                              menu[i].title == 'Pesanan Saya') {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ConsumerOrdersPage(
                                  authService: effectiveAuth,
                                  includeSelfPickup: true,
                                  pageTitle: 'Pesanan Mitra',
                                ),
                              ),
                            );
                          } else if (role == UserRole.consumer &&
                              menu[i].title == 'Pesanan Saya') {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ConsumerOrdersPage(
                                  authService: effectiveAuth,
                                ),
                              ),
                            );
                          } else {
                            _notConnected(context, menu[i].title);
                          }
                        },
                      ),
                      if (i != menu.length - 1)
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
          ),

          // LOGOUT
          const SizedBox(height: 10),
          SizedBox(
            height: 47,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Keluar dari Akun'),
                    content: const Text(
                      'Apakah kamu yakin ingin keluar dari GreenLoop?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD9534F),
                        ),
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );

                if (confirm != true || !context.mounted) return;

                try {
                  await effectiveAuth.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const WelcomePage(),
                    ),
                    (route) => false,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal logout: $e')),
                  );
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(
                'Keluar',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD9534F),
                backgroundColor: const Color(0xFFFBE8E7),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: GreenLoopColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

class _ProfileMenuData {
  const _ProfileMenuData(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

// EDIT PROFILE

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    required this.role,
    this.authService,
    super.key,
  });

  final UserRole role;
  final AuthService? authService;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final Map<String, TextEditingController> _fields = {
    for (final key in [
      'username',
      'email',
      'first_name',
      'last_name',
      'business_name',
      'business_type',
      'pic_name',
      'phone_number',
      'operational_hours',
      'courier_notes',
      'plate_number',
      'vehicle_type',
    ])
      key: TextEditingController(),
  };

  AuthService get _effectiveAuth => widget.authService ?? defaultAuthService;

  @override
  void initState() {
    super.initState();
    final current = _effectiveAuth.currentUser;
    if (current != null) {
      _fields['username']!.text = current.user.username;
      _fields['email']!.text = current.user.email;
      _fields['first_name']!.text = current.user.firstName;
      _fields['last_name']!.text = current.user.lastName;

      if (current.mitraProfile != null) {
        final m = current.mitraProfile!;
        _fields['business_name']!.text = m.businessName ?? '';
        _fields['business_type']!.text = m.businessType ?? '';
        _fields['pic_name']!.text = m.picName ?? '';
        _fields['phone_number']!.text = m.phoneNumber ?? '';
        _fields['operational_hours']!.text = m.operationalHours ?? '';
        _fields['courier_notes']!.text = m.courierNotes ?? '';
      }

      if (current.courierProfile != null) {
        final c = current.courierProfile!;
        _fields['plate_number']!.text = c.plateNumber ?? '';
        _fields['vehicle_type']!.text = c.vehicleType ?? '';
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final payload = <String, dynamic>{
          'username': _fields['username']!.text.trim(),
          'email': _fields['email']!.text.trim(),
          'first_name': _fields['first_name']!.text.trim(),
          'last_name': _fields['last_name']!.text.trim(),
        };

        if (widget.role == UserRole.mitra) {
          for (final key in [
            'business_name',
            'pic_name',
            'phone_number',
            'operational_hours',
            'courier_notes',
          ]) {
            payload[key] = _fields[key]!.text.trim();
          }

          final bType = _fields['business_type']!.text.trim();
          if (bType.isNotEmpty) {
            final lower = bType.toLowerCase();
            if (lower.contains('kafe') || lower.contains('coffee') || lower == 'cafe') {
              payload['business_type'] = 'Kafe / Coffee Shop';
            } else if (lower.contains('restoran') || lower == 'restaurant') {
              payload['business_type'] = 'Restoran';
            } else if (lower.contains('hotel')) {
              payload['business_type'] = 'Hotel';
            } else {
              payload['business_type'] = bType;
            }
          }
        } else if (widget.role == UserRole.courier) {
          payload['plate_number'] =
              _fields['plate_number']!.text.trim().toUpperCase();

          final vType = _fields['vehicle_type']!.text.trim().toLowerCase();
          if (vType.contains('motor')) {
            payload['vehicle_type'] = 'motor_box';
          } else if (vType.contains('mobil') || vType.contains('pickup')) {
            payload['vehicle_type'] = 'pickup_bak';
          } else {
            payload['vehicle_type'] = vType;
          }
        }

        await _effectiveAuth.updateProfile(payload);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui.')),
        );
        Navigator.of(context).pop();
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleFields = switch (widget.role) {
      UserRole.mitra => const [
        ('business_name', 'Nama Usaha'),
        ('business_type', 'Jenis Usaha'),
        ('pic_name', 'Nama Penanggung Jawab'),
        ('phone_number', 'No. WhatsApp'),
        ('operational_hours', 'Jam Operasional'),
        ('courier_notes', 'Catatan untuk Kurir'),
      ],
      UserRole.courier => const [
        ('plate_number', 'Plat Nomor'),
        ('vehicle_type', 'Jenis Armada'),
      ],
      _ => const <(String, String)>[],
    };

    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(title: const Text('Edit profil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'Informasi akun',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            FormFieldTile(
              controller: _fields['username']!,
              label: 'Username',
              validator: requiredField,
            ),
            FormFieldTile(
              controller: _fields['email']!,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi.';
                }
                return value.contains('@') && value.contains('.')
                    ? null
                    : 'Masukkan email yang valid.';
              },
            ),
            FormFieldTile(
              controller: _fields['first_name']!,
              label: 'Nama depan',
            ),
            FormFieldTile(
              controller: _fields['last_name']!,
              label: 'Nama belakang',
            ),
            if (roleFields.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Informasi ${widget.role.label}',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              for (final field in roleFields)
                FormFieldTile(
                  controller: _fields[field.$1]!,
                  label: field.$2,
                  keyboardType: field.$1 == 'phone_number'
                      ? TextInputType.phone
                      : null,
                  maxLines: field.$1 == 'courier_notes' ? 3 : 1,
                ),
            ],
            const AuthNotice(
              text: 'Role, status persetujuan, password, dan data sensitif tidak dapat diubah dari halaman ini.',
            ),
            const SizedBox(height: 14),
            GreenLoopButton(
              label: 'Simpan perubahan',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
