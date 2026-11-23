import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/gl_components.dart';
import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/dummy/dummy_data.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../home/presentation/demo_login.dart';
import '../../home/presentation/role_navigation_page.dart';
import '../services/auth_service.dart';
import 'courier_pending_page.dart';

enum PublicRegistrationRole { consumer, mitra, courier }

extension PublicRegistrationRoleLabel on PublicRegistrationRole {
  String get label => switch (this) {
    PublicRegistrationRole.consumer => 'Konsumen',
    PublicRegistrationRole.mitra => 'Mitra B2B',
    PublicRegistrationRole.courier => 'Kurir',
  };

  /// Label pendek untuk tombol "Daftar sebagai ...".
  String get shortLabel => switch (this) {
    PublicRegistrationRole.consumer => 'Konsumen',
    PublicRegistrationRole.mitra => 'Mitra',
    PublicRegistrationRole.courier => 'Kurir',
  };

  String get description => switch (this) {
    PublicRegistrationRole.consumer => 'Belanja sabun',
    PublicRegistrationRole.mitra => 'Kafe / hotel',
    PublicRegistrationRole.courier => 'Jemput limbah',
  };

  IconData get icon => switch (this) {
    PublicRegistrationRole.consumer => LucideIcons.shoppingCart,
    PublicRegistrationRole.mitra => LucideIcons.building2,
    PublicRegistrationRole.courier => LucideIcons.truck,
  };

  String get backendValue => switch (this) {
    PublicRegistrationRole.consumer => 'consumer',
    PublicRegistrationRole.mitra => 'mitra',
    PublicRegistrationRole.courier => 'courier',
  };
}

TextStyle _text(
  double size,
  FontWeight weight, {
  Color color = GreenLoopColors.textInk,
  double height = 1.5,
}) => GreenLoopTypography.style(size, weight, color: color, height: height);

// =====================================================
// WELCOME / ONBOARDING - M01
// =====================================================

class WelcomePage extends StatefulWidget {
  const WelcomePage({
    this.authService,
    this.skipSessionCheck = false,
    super.key,
  });

  final AuthService? authService;
  final bool skipSessionCheck;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  AuthService get _effectiveAuth => widget.authService ?? defaultAuthService;

  @override
  void initState() {
    super.initState();
    if (!widget.skipSessionCheck) {
      _restoreSession();
    }
  }

  Future<void> _restoreSession() async {
    final profile = await _effectiveAuth.checkSession();
    if (profile != null && mounted) {
      final navigator = Navigator.of(context);
      navigator.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => RoleNavigationPage(
            role: profile.role,
            authService: _effectiveAuth,
          ),
        ),
      );
    }
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegisterPage(
          authService: _effectiveAuth,
          initialRole: PublicRegistrationRole.mitra,
        ),
      ),
    );
  }

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(authService: _effectiveAuth),
      ),
    );
  }

  void _openCatalog() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PublicCatalogPage()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.green900,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _OnboardingHero(),
                const SizedBox(height: 14),

                // Badge pilot project
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: GreenLoopColors.lime,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        size: 12,
                        color: GreenLoopColors.green900,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pilot Project · Kota Depok',
                        style: _text(11, FontWeight.w600,
                            color: GreenLoopColors.green900, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'Ubah Limbah Organik Jadi Sabun yang Bermakna',
                  style: _text(28, FontWeight.w700, color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 14),
                Text(
                  'Kafe & hotel jadwalkan penjemputan limbah, kumpulkan Waste '
                  'Points, lalu tukar jadi voucher belanja sabun eco-enzyme.',
                  style: _text(14, FontWeight.w400, color: Colors.white),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final (value, label) in const [
                      ('12.480 kg', 'limbah diselamatkan'),
                      ('38', 'mitra aktif'),
                      ('9,3 ton', 'CO2e dicegah'),
                    ])
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _ImpactStat(value: value, label: label),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                GreenLoopButton(
                  label: 'Daftar Akun',
                  light: true,
                  onPressed: _openRegister,
                ),
                const SizedBox(height: 14),
                GreenLoopButton(
                  label: 'Masuk',
                  secondary: true,
                  onPressed: _openLogin,
                ),
                const SizedBox(height: 14),

                Center(
                  child: GestureDetector(
                    onTap: _openCatalog,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Mau belanja aja? '),
                          TextSpan(
                            text: 'Lihat Katalog',
                            style: _text(12, FontWeight.w600,
                                color: GreenLoopColors.lime),
                          ),
                        ],
                      ),
                      style: _text(12, FontWeight.w400, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Ilustrasi hero M01: lingkaran hijau, kemasan sabun, dan dua kartu
/// melayang (+176 poin, Pikap terjadwal).
class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Posisi di Figma dihitung untuk lebar 342.
          final scale = constraints.maxWidth / 342;
          double x(double v) => v * scale;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: x(48),
                top: 2,
                child: Container(
                  width: 246,
                  height: 246,
                  decoration: const BoxDecoration(
                    color: GreenLoopColors.green700,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: x(48) + 33,
                top: 35,
                child: const _SoapPackage(),
              ),
              Positioned(
                left: x(200),
                top: 14,
                child: const _FloatingInfoCard(
                  icon: LucideIcons.gift,
                  tone: GLTone.amber,
                  title: '+176 poin',
                  subtitle: '35,2 kg disetor',
                  titleBold: true,
                ),
              ),
              const Positioned(
                left: 0,
                top: 176,
                child: _FloatingInfoCard(
                  icon: LucideIcons.truck,
                  tone: GLTone.green,
                  title: 'Pikap terjadwal',
                  subtitle: '08:00 - 10:00 WIB',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SoapPackage extends StatelessWidget {
  const _SoapPackage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: const BoxDecoration(
        color: GreenLoopColors.lime,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 90,
        height: 121.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.2),
          gradient: const LinearGradient(
            colors: [Color(0xFFC2C7C7), Color(0xFFF7F7F7), Color(0xFFB2B8B8)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A123B21),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(9, 36.5, 9, 18),
        child: Container(
          decoration: BoxDecoration(
            color: GreenLoopColors.green700,
            borderRadius: BorderRadius.circular(3),
          ),
          padding: const EdgeInsets.only(top: 6.7),
          child: Column(
            children: [
              Container(
                width: 12.6,
                height: 12.6,
                decoration: const BoxDecoration(
                  color: GreenLoopColors.lime,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Sabun Cuci\nPiring',
                textAlign: TextAlign.center,
                style: _text(8, FontWeight.w600, color: Colors.white, height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingInfoCard extends StatelessWidget {
  const _FloatingInfoCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    this.titleBold = false,
  });

  final IconData icon;
  final GLTone tone;
  final String title;
  final String subtitle;
  final bool titleBold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x1A123B21), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GLIconTile(icon: icon, tone: tone),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: titleBold
                    ? _text(13, FontWeight.w700,
                        color: GreenLoopColors.green900, height: 1.3)
                    : _text(12, FontWeight.w600, height: 1.3),
              ),
              Text(
                subtitle,
                style: _text(10, FontWeight.w400,
                    color: GreenLoopColors.textMuted, height: 1.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  const _ImpactStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: _text(18, FontWeight.w700, color: GreenLoopColors.lime, height: 1.3),
      ),
      Text(
        label,
        style: _text(10, FontWeight.w400, color: Colors.white, height: 1.3),
      ),
    ],
  );
}

/// Katalog publik dari link "Lihat Katalog" di M01. Isinya dibangun di
/// commit katalog (M09); sementara menampilkan placeholder modul.
class PublicCatalogPage extends StatelessWidget {
  const PublicCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: GreenLoopColors.background,
      body: SafeArea(
        child: ModulePlaceholderPage(
          title: 'Katalog',
          module: 'E-Commerce',
          icon: LucideIcons.box,
          showBack: true,
        ),
      ),
    );
  }
}

// =====================================================
// LOGIN - M02
// =====================================================

class LoginPage extends StatefulWidget {
  const LoginPage({this.authService, super.key});

  final AuthService? authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthService get _effectiveAuth => widget.authService ?? defaultAuthService;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final profile = await _effectiveAuth.login(
          username: _username.text.trim(),
          password: _password.text,
        );

        if (!mounted) return;

        // Role diambil dari backend untuk menentukan dashboard tujuan.
        final navigator = Navigator.of(context);
        navigator.pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => RoleNavigationPage(
              role: profile.role,
              authService: _effectiveAuth,
            ),
          ),
          (route) => false,
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (e) {
        if (!mounted) return;
        final msg = 'Terjadi kesalahan saat masuk: $e';
        setState(() {
          _errorMessage = msg;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.background,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GreenLoopLogo(width: 163),
                const SizedBox(height: 18),

                Text(
                  'Masuk ke GreenLoop',
                  style: _text(26, FontWeight.w700,
                      color: GreenLoopColors.green900, height: 1.3),
                ),
                const SizedBox(height: 6),
                Text(
                  'Satu akun untuk Mitra, Kurir, Konsumen, dan Admin. '
                  'Halaman tujuan menyesuaikan peran akunmu.',
                  style: _text(13, FontWeight.w400, color: GreenLoopColors.textMuted),
                ),
                const SizedBox(height: 18),

                if (_errorMessage != null) ...[
                  _ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 18),
                ],

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GLFieldLabel('Username'),
                      TextFormField(
                        key: const Key('login-email'),
                        controller: _username,
                        keyboardType: TextInputType.text,
                        style: _fieldTextStyle,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan username',
                          prefixIcon: Icon(LucideIcons.user, size: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      const GLFieldLabel('Kata sandi'),
                      TextFormField(
                        key: const Key('login-password'),
                        controller: _password,
                        obscureText: !_passwordVisible,
                        style: _fieldTextStyle,
                        decoration: InputDecoration(
                          hintText: 'Masukkan kata sandi',
                          prefixIcon: const Icon(LucideIcons.lock, size: 18),
                          suffixIcon: IconButton(
                            tooltip: _passwordVisible
                                ? 'Sembunyikan kata sandi'
                                : 'Tampilkan kata sandi',
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            icon: Icon(
                              _passwordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                              size: 18,
                            ),
                          ),
                        ),
                        validator: requiredField,
                      ),
                      const SizedBox(height: 18),

                      GreenLoopButton(
                        label: 'Masuk',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    const Expanded(child: Divider(color: GreenLoopColors.cardBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'belum punya akun?',
                        style: _text(12, FontWeight.w400,
                            color: GreenLoopColors.textMuted),
                      ),
                    ),
                    const Expanded(child: Divider(color: GreenLoopColors.cardBorder)),
                  ],
                ),
                const SizedBox(height: 18),

                GreenLoopButton(
                  label: 'Daftar Akun Baru',
                  secondary: true,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RegisterPage(
                          authService: _effectiveAuth,
                          initialRole: PublicRegistrationRole.mitra,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),

                const _RoleDestinationCard(),
                const SizedBox(height: 8),
                const Center(child: DemoLoginButton()),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

TextStyle get _fieldTextStyle => _text(14, FontWeight.w500, height: 1.3);

/// Kartu "Setelah masuk, kamu diarahkan ke:" di M02.
class _RoleDestinationCard extends StatelessWidget {
  const _RoleDestinationCard();

  static const _rows = [
    (LucideIcons.building2, 'Mitra B2B', 'Dashboard Mitra & penjemputan'),
    (LucideIcons.truck, 'Kurir', 'Dashboard Kurir (perlu verifikasi admin)'),
    (LucideIcons.shoppingCart, 'Konsumen', 'Katalog & pesanan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GreenLoopColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Setelah masuk, kamu diarahkan ke:',
              style: _text(12, FontWeight.w600, height: 1.3)),
          for (final (icon, title, subtitle) in _rows) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F8EF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 15, color: GreenLoopColors.green700),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: _text(12, FontWeight.w600, height: 1.3)),
                      Text(
                        subtitle,
                        style: _text(10, FontWeight.w400,
                            color: GreenLoopColors.textMuted, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GreenLoopColors.red100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GreenLoopColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.circleAlert, color: GreenLoopColors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: _text(13, FontWeight.w500, color: GreenLoopColors.red, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak info kecil berwarna (catatan API Wilayah, peringatan verifikasi
/// kurir).
class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.text, this.tone = GLTone.green});

  final String text;
  final GLTone tone;

  @override
  Widget build(BuildContext context) {
    final background = tone == GLTone.green ? const Color(0xFFF3F8EF) : tone.background;
    final foreground = tone == GLTone.amber ? GreenLoopColors.textInk : tone.foreground;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 14, color: tone.foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: _text(10, FontWeight.w500, color: foreground, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// REGISTER - M03 (Mitra) & M03b (Kurir)
// =====================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    this.authService,
    this.initialRole = PublicRegistrationRole.consumer,
    super.key,
  });

  final AuthService? authService;
  final PublicRegistrationRole initialRole;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _controllers = {
    for (final key in [
      'username',
      'email',
      'password1',
      'password2',
      'business_name',
      'pic_name',
      'phone_number',
      'kelurahan',
      'address_detail',
      'full_name',
      'plate_number',
    ])
      key: TextEditingController(),
  };

  late PublicRegistrationRole _role;
  String? _businessType;
  String? _kecamatan;
  String _vehicleType = DummyData.armadaOptions.last; // Pickup Bak (Figma)
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  static const _businessTypes = ['Kafe / Coffee Shop', 'Restoran', 'Hotel'];

  AuthService get _effectiveAuth => widget.authService ?? defaultAuthService;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _c(String key) => _controllers[key]!;

  String _normalizeBusinessType(String val) {
    final lower = val.toLowerCase().trim();
    if (lower.contains('kafe') || lower == 'cafe') return 'cafe';
    if (lower.contains('restoran') || lower == 'restaurant') return 'restaurant';
    if (lower.contains('hotel')) return 'hotel';
    return lower;
  }

  String _normalizeVehicleType(String val) {
    final lower = val.toLowerCase().trim();
    if (lower.contains('motor')) return 'motor';
    if (lower.contains('mobil') || lower.contains('pickup')) return 'mobil';
    return lower;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final payload = <String, dynamic>{
          'username': _c('username').text.trim(),
          'email': _c('email').text.trim(),
          'password1': _c('password1').text,
          'password2': _c('password2').text,
          'role': _role.backendValue,
        };

        if (_role == PublicRegistrationRole.mitra) {
          payload['business_name'] = _c('business_name').text.trim();
          payload['business_type'] = _normalizeBusinessType(_businessType ?? '');
          payload['pic_name'] = _c('pic_name').text.trim();
          payload['phone_number'] = _c('phone_number').text.trim();
          payload['provinsi'] = 'Jawa Barat';
          payload['kota'] = 'Depok';
          payload['kecamatan'] = _kecamatan ?? '';
          payload['kelurahan'] = _c('kelurahan').text.trim();
          payload['address_detail'] = _c('address_detail').text.trim();
        } else if (_role == PublicRegistrationRole.courier) {
          payload['full_name'] = _c('full_name').text.trim();
          payload['plate_number'] = _c('plate_number').text.trim().toUpperCase();
          payload['vehicle_type'] = _normalizeVehicleType(_vehicleType);
        }

        final profile = await _effectiveAuth.register(data: payload);

        if (!mounted) return;

        // Kurir baru harus disetujui admin dulu (M15).
        final Widget destination = _role == PublicRegistrationRole.courier
            ? CourierPendingPage(
                authService: _effectiveAuth,
                name: _c('full_name').text.trim(),
                email: _c('email').text.trim(),
                plateNumber: _c('plate_number').text.trim().toUpperCase(),
                vehicleType: _vehicleType,
              )
            : RoleNavigationPage(role: profile.role, authService: _effectiveAuth);

        final navigator = Navigator.of(context);
        navigator.pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => destination),
          (route) => false,
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (e) {
        if (!mounted) return;
        final msg = 'Terjadi kesalahan saat mendaftar: $e';
        setState(() {
          _errorMessage = msg;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // --- Builder field -------------------------------------------------------

  Widget _field(
    String key,
    String label, {
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GLFieldLabel(label),
        TextFormField(
          key: Key('register-$key'),
          controller: _c(key),
          keyboardType: keyboardType,
          obscureText: obscure && !_passwordVisible,
          style: _fieldTextStyle,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 18),
            suffixIcon: obscure && key == 'password1'
                ? IconButton(
                    tooltip: _passwordVisible
                        ? 'Sembunyikan kata sandi'
                        : 'Tampilkan kata sandi',
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                    icon: Icon(
                      _passwordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 18,
                    ),
                  )
                : null,
          ),
          validator: validator ?? requiredField,
        ),
      ],
    );
  }

  Widget _dropdown({
    required String keyName,
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String?> onChanged,
    String hint = 'Pilih',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GLFieldLabel(label),
        DropdownButtonFormField<String>(
          key: Key('register-$keyName'),
          initialValue: value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 18),
          style: _fieldTextStyle,
          decoration: InputDecoration(hintText: hint),
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option,
                child: Text(option, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
          validator: (v) => v == null ? 'Pilih $label.' : null,
        ),
      ],
    );
  }

  Widget _row(Widget left, Widget right) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: left),
      const SizedBox(width: 10),
      Expanded(child: right),
    ],
  );

  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GreenLoopColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: GreenLoopColors.green900),
              const SizedBox(width: 6),
              Flexible(
                child: Text(title,
                    style: _text(13, FontWeight.w700,
                        color: GreenLoopColors.green900, height: 1.3)),
              ),
            ],
          ),
          for (final child in children) ...[const SizedBox(height: 10), child],
        ],
      ),
    );
  }

  String? _validatePasswordConfirm(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    if (value != _c('password1').text) return 'Kata sandi tidak sama.';
    return null;
  }

  List<Widget> _accountFields() => [
    _row(
      _field('username', 'Username', hint: 'kafesenja'),
      _field('email', 'Email',
          hint: 'kafe@senja.id', keyboardType: TextInputType.emailAddress),
    ),
    _row(
      _field('password1', 'Kata sandi', obscure: true),
      _field('password2', 'Ulangi sandi',
          obscure: true, validator: _validatePasswordConfirm),
    ),
  ];

  List<Widget> _roleFields() {
    switch (_role) {
      case PublicRegistrationRole.consumer:
        return const [];

      case PublicRegistrationRole.mitra:
        return [
          _section(
            icon: LucideIcons.building2,
            title: 'Data Usaha (khusus Mitra)',
            children: [
              _row(
                _field('business_name', 'Nama usaha', hint: 'Kafe Senja Margonda'),
                _dropdown(
                  keyName: 'business_type',
                  label: 'Jenis usaha',
                  options: _businessTypes,
                  value: _businessType,
                  onChanged: (v) => setState(() => _businessType = v),
                ),
              ),
              _row(
                _field('pic_name', 'Penanggung jawab', hint: 'Nadia Putri'),
                _field('phone_number', 'No. WhatsApp',
                    hint: '0812-3456-7890', keyboardType: TextInputType.phone),
              ),
              _row(
                _dropdown(
                  keyName: 'kota',
                  label: 'Kota',
                  options: const ['Kota Depok'],
                  value: 'Kota Depok',
                  onChanged: (_) {},
                ),
                _dropdown(
                  keyName: 'kecamatan',
                  label: 'Kecamatan',
                  options: DummyData.kecamatanDepok,
                  value: _kecamatan,
                  onChanged: (v) => setState(() => _kecamatan = v),
                ),
              ),
              _row(
                _field('kelurahan', 'Kelurahan', hint: 'Pondok Cina'),
                _field('address_detail', 'Alamat lengkap', hint: 'Jl. Margonda No. 21'),
              ),
              const _NoteBox(
                text: 'Wilayah dari API Wilayah · layanan pikap khusus Kota Depok',
              ),
            ],
          ),
        ];

      case PublicRegistrationRole.courier:
        return [
          _section(
            icon: LucideIcons.truck,
            title: 'Data Kendaraan (khusus Kurir)',
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GLFieldLabel('Jenis armada'),
                  Row(
                    children: [
                      for (final option in DummyData.armadaOptions.reversed) ...[
                        if (option != DummyData.armadaOptions.last)
                          const SizedBox(width: 10),
                        Expanded(
                          child: GLOptionTile(
                            label: option,
                            icon: LucideIcons.truck,
                            selected: _vehicleType == option,
                            centered: true,
                            onTap: () => setState(() => _vehicleType = option),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              _field('plate_number', 'Nomor polisi', hint: 'B 1234 KZT'),
            ],
          ),
          const _NoteBox(
            tone: GLTone.amber,
            text: 'Akun kurir perlu disetujui admin dulu sebelum bisa menerima '
                'tugas penjemputan.',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const GLFieldLabel('Daftar sebagai'),
      Row(
        children: [
          for (final role in PublicRegistrationRole.values) ...[
            if (role != PublicRegistrationRole.values.first) const SizedBox(width: 8),
            Expanded(
              child: GLOptionTile(
                key: Key('register-role-${role.backendValue}'),
                label: role.label,
                subtitle: role.description,
                icon: role.icon,
                vertical: true,
                selected: _role == role,
                onTap: () => setState(() => _role = role),
              ),
            ),
          ],
        ],
      ),
      if (_errorMessage != null) _ErrorBanner(message: _errorMessage!),
      if (_role == PublicRegistrationRole.courier)
        _field('full_name', 'Nama lengkap', hint: 'Budi Santoso', icon: LucideIcons.user),
      ..._accountFields(),
      ..._roleFields(),
    ];

    return Scaffold(
      backgroundColor: GreenLoopColors.background,
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const GLScreenHeader(
                title: 'Daftar Akun',
                subtitle: 'Langkah 1 dari 1 · pilih peranmu',
                showBack: true,
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  itemCount: children.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => children[i],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GLBottomActionBar(
        child: GreenLoopButton(
          key: const Key('register-submit'),
          label: 'Daftar sebagai ${_role.shortLabel}',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _submit,
        ),
      ),
    );
  }
}
