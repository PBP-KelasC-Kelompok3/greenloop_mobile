import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../home/presentation/role_navigation_page.dart';
import '../services/auth_service.dart';

enum PublicRegistrationRole { consumer, mitra, courier }

extension PublicRegistrationRoleLabel on PublicRegistrationRole {
  String get label => switch (this) {
    PublicRegistrationRole.consumer => 'Consumer',
    PublicRegistrationRole.mitra => 'Mitra',
    PublicRegistrationRole.courier => 'Courier',
  };

  String get backendValue => switch (this) {
    PublicRegistrationRole.consumer => 'consumer',
    PublicRegistrationRole.mitra => 'mitra',
    PublicRegistrationRole.courier => 'courier',
  };
}

Future<void> _logoutToLogin(
  AuthService authService,
  NavigatorState navigator,
) async {
  try {
    await authService.logout();
  } catch (_) {
    // Still let the user return to the login page when the API is unavailable.
  }
  navigator.pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => LoginPage(authService: authService),
    ),
    (route) => false,
  );
}

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
            onLogout: () => _logoutToLogin(_effectiveAuth, navigator),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.deepForest,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 5, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: constraints.maxHeight < 700 ? 205 : 245,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/onboarding_hero_art.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.eco_outlined,
                                size: 76,
                                color: GreenLoopColors.leaf,
                              ),
                            ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    // PILOT PROJECT BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: GreenLoopColors.leaf,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 13,
                            color: GreenLoopColors.deepForest,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Pilot Project · Kota Depok',
                            style: TextStyle(
                              color: GreenLoopColors.deepForest,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // HEADLINE
                    const Text(
                      'Ubah Limbah Organik Jadi Sabun yang Bermakna',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 9),

                    // DESCRIPTION
                    const Text(
                      'Jadwalkan penjemputan limbah dapur, '
                      'kumpulkan Waste Points, dan belanja sabun '
                      'eco-enzyme di satu aplikasi.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // FIGMA PREVIEW METRICS
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ImpactStat(
                            value: '12.480 kg',
                            label: 'limbah diselamatkan',
                          ),
                        ),
                        Expanded(
                          child: _ImpactStat(value: '38', label: 'mitra aktif'),
                        ),
                        Expanded(
                          child: _ImpactStat(
                            value: '9,3 ton',
                            label: 'CO2e dicegah',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // PAGE INDICATOR
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PageDot(active: true),
                        SizedBox(width: 6),
                        _PageDot(),
                        SizedBox(width: 6),
                        _PageDot(),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // REGISTER MITRA
                    GreenLoopButton(
                      label: 'Daftar sebagai Mitra',
                      light: true,
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

                    const SizedBox(height: 11),

                    // LOGIN
                    GreenLoopButton(
                      label: 'Saya sudah punya akun',
                      light: true,
                      secondary: true,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LoginPage(
                              authService: _effectiveAuth,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
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
        style: const TextStyle(
          color: GreenLoopColors.leaf,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.35),
      ),
    ],
  );
}

class _PageDot extends StatelessWidget {
  const _PageDot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    width: active ? 22 : 8,
    height: 8,
    decoration: BoxDecoration(
      color: active ? GreenLoopColors.leaf : const Color(0xFF43804B),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}

// =====================================================
// LOGIN ROLE SELECTOR
// =====================================================

enum _LoginRole { mitra, courier, consumer, admin }

extension on _LoginRole {
  String get label => switch (this) {
    _LoginRole.mitra => 'Mitra B2B',
    _LoginRole.courier => 'Kurir',
    _LoginRole.consumer => 'Konsumen',
    _LoginRole.admin => 'Admin',
  };
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
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  _LoginRole _selectedRole = _LoginRole.mitra;

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

        // Use the actual role returned by the backend to navigate to dashboard
        final navigator = Navigator.of(context);
        navigator.pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => RoleNavigationPage(
              role: profile.role,
              authService: _effectiveAuth,
              onLogout: () => _logoutToLogin(_effectiveAuth, navigator),
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
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(leading: const BackButton()),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GreenLoopLogo(width: 210),

                const SizedBox(height: 22),

                const Text(
                  'Selamat datang kembali',
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Masuk untuk lanjut kelola limbah dan Waste Points kamu.',
                  style: TextStyle(
                    color: GreenLoopColors.textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // ROLE SELECTOR (Preserved from Figma UI design; backend determines actual role)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: GreenLoopColors.mint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: SegmentedButton<_LoginRole>(
                    segments: _LoginRole.values
                        .map(
                          (role) => ButtonSegment(
                            value: role,
                            label: Text(role.label),
                          ),
                        )
                        .toList(),
                    selected: {_selectedRole},
                    onSelectionChanged: (values) {
                      setState(() {
                        _selectedRole = values.first;
                      });
                    },
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        return states.contains(WidgetState.selected)
                            ? Colors.white
                            : Colors.transparent;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        return states.contains(WidgetState.selected)
                            ? GreenLoopColors.circleGreen
                            : GreenLoopColors.textMuted;
                      }),
                      side: WidgetStateProperty.all(BorderSide.none),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
                      ),
                      textStyle: WidgetStateProperty.resolveWith((states) {
                        return TextStyle(
                          fontFamily: GreenLoopTypography.fontFamily,
                          fontSize: 13,
                          letterSpacing: 0,
                          fontWeight: states.contains(WidgetState.selected)
                              ? FontWeight.w600
                              : FontWeight.w500,
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 19),

                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE8E7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFD9534F).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFD9534F),
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFD9534F),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Username'),

                      TextFormField(
                        key: const Key('login-email'),
                        controller: _username,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Masukkan username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username wajib diisi.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      const _FieldLabel('Kata sandi'),

                      TextFormField(
                        key: const Key('login-password'),
                        controller: _password,
                        obscureText: !_passwordVisible,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukkan kata sandi',
                          prefixIcon: const Icon(Icons.lock_outline),
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
                              _passwordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: requiredField,
                      ),

                      const SizedBox(height: 5),

                      // REMEMBER ME AND FORGOT PASSWORD
                      Row(
                        children: [
                          SizedBox(
                            width: 28,
                            height: 34,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: GreenLoopColors.forest2,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: const Text(
                                'Ingat saya',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Fitur lupa kata sandi belum tersedia.',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Lupa kata sandi?',
                              style: TextStyle(
                                color: GreenLoopColors.circleGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      GreenLoopButton(
                        label: 'Masuk',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 17),

                const Row(
                  children: [
                    Expanded(child: Divider(color: GreenLoopColors.border)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'atau',
                        style: TextStyle(
                          fontSize: 12,
                          color: GreenLoopColors.textMuted,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: GreenLoopColors.border)),
                  ],
                ),

                const SizedBox(height: 16),

                GreenLoopButton(
                  label: 'Daftar Mitra Baru',
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

                const SizedBox(height: 16),

                const AuthNotice(
                  icon: Icons.location_on_outlined,
                  text: 'Layanan penjemputan saat ini khusus wilayah Kota Depok, Jawa Barat.',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );
}

// =====================================================
// REGISTER
// =====================================================

class _RegisterField {
  const _RegisterField(this.keyName, this.label, {this.keyboardType});

  final String keyName;
  final String label;
  final TextInputType? keyboardType;
}

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
      'business_type',
      'pic_name',
      'phone_number',
      'provinsi',
      'kota',
      'kecamatan',
      'kelurahan',
      'address_detail',
      'full_name',
      'plate_number',
      'vehicle_type',
    ])
      key: TextEditingController(),
  };

  late PublicRegistrationRole _role;
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

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

  List<_RegisterField> get _roleFields => switch (_role) {
    PublicRegistrationRole.consumer => const [],

    PublicRegistrationRole.mitra => const [
      _RegisterField('business_name', 'Nama Usaha'),
      _RegisterField('business_type', 'Jenis Usaha'),
      _RegisterField('pic_name', 'Nama Penanggung Jawab'),
      _RegisterField(
        'phone_number',
        'No. WhatsApp',
        keyboardType: TextInputType.phone,
      ),
      _RegisterField('provinsi', 'Provinsi'),
      _RegisterField('kota', 'Kota / Kabupaten'),
      _RegisterField('kecamatan', 'Kecamatan'),
      _RegisterField('kelurahan', 'Kelurahan'),
      _RegisterField('address_detail', 'Alamat Lengkap'),
    ],

    PublicRegistrationRole.courier => const [
      _RegisterField('full_name', 'Nama Lengkap'),
      _RegisterField('plate_number', 'Plat Nomor'),
      _RegisterField('vehicle_type', 'Jenis Armada'),
    ],
  };

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
    if (lower.contains('mobil')) return 'mobil';
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
          'username': _controllers['username']!.text.trim(),
          'email': _controllers['email']!.text.trim(),
          'password1': _controllers['password1']!.text,
          'password2': _controllers['password2']!.text,
          'role': _role.backendValue,
        };

        if (_role == PublicRegistrationRole.mitra) {
          payload['business_name'] = _controllers['business_name']!.text.trim();
          payload['business_type'] =
              _normalizeBusinessType(_controllers['business_type']!.text);
          payload['pic_name'] = _controllers['pic_name']!.text.trim();
          payload['phone_number'] = _controllers['phone_number']!.text.trim();
          payload['provinsi'] = _controllers['provinsi']!.text.trim().isNotEmpty
              ? _controllers['provinsi']!.text.trim()
              : 'Jawa Barat';
          payload['kota'] = _controllers['kota']!.text.trim().isNotEmpty
              ? _controllers['kota']!.text.trim()
              : 'Depok';
          payload['kecamatan'] = _controllers['kecamatan']!.text.trim();
          payload['kelurahan'] = _controllers['kelurahan']!.text.trim();
          payload['address_detail'] = _controllers['address_detail']!.text.trim();
        } else if (_role == PublicRegistrationRole.courier) {
          payload['full_name'] = _controllers['full_name']!.text.trim();
          payload['plate_number'] =
              _controllers['plate_number']!.text.trim().toUpperCase();
          payload['vehicle_type'] =
              _normalizeVehicleType(_controllers['vehicle_type']!.text);
        }

        final profile = await _effectiveAuth.register(data: payload);

        if (!mounted) return;

        final navigator = Navigator.of(context);
        navigator.pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => RoleNavigationPage(
              role: profile.role,
              authService: _effectiveAuth,
              onLogout: () => _logoutToLogin(_effectiveAuth, navigator),
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

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(title: const Text('Buat akun')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
            children: [
              const GreenLoopLogo(width: 185),

              const SizedBox(height: 18),

              const PageIntro(
                title: 'Gabung dengan GreenLoop',
                description: 'Pilih jenis akun. Admin tidak tersedia untuk pendaftaran publik.',
              ),

              const SizedBox(height: 20),

              const _FieldLabel('Daftar sebagai'),

              SegmentedButton<PublicRegistrationRole>(
                segments: PublicRegistrationRole.values
                    .map(
                      (role) =>
                          ButtonSegment(value: role, label: Text(role.label)),
                    )
                    .toList(),
                selected: {_role},
                onSelectionChanged: (values) {
                  setState(() {
                    _role = values.first;
                  });
                },
                showSelectedIcon: false,
              ),

              const SizedBox(height: 18),

              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE8E7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD9534F).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFD9534F),
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFD9534F),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              FormFieldTile(
                controller: _controllers['username']!,
                label: 'Username',
                validator: requiredField,
              ),

              FormFieldTile(
                controller: _controllers['email']!,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final required = requiredField(value);
                  if (required != null) return required;

                  return value!.contains('@') && value.contains('.')
                      ? null
                      : 'Masukkan email yang valid.';
                },
              ),

              FormFieldTile(
                controller: _controllers['password1']!,
                label: 'Kata sandi',
                validator: (value) {
                  final required = requiredField(value);
                  if (required != null) return required;

                  return value!.length >= 8
                      ? null
                      : 'Gunakan sedikitnya 8 karakter.';
                },
                obscureText: !_passwordVisible,
                suffix: IconButton(
                  tooltip: _passwordVisible
                      ? 'Sembunyikan kata sandi'
                      : 'Tampilkan kata sandi',
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  icon: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),

              FormFieldTile(
                controller: _controllers['password2']!,
                label: 'Ulangi kata sandi',
                obscureText: !_passwordVisible,
                validator: (value) {
                  final required = requiredField(value);
                  if (required != null) return required;

                  return value == _controllers['password1']!.text
                      ? null
                      : 'Kata sandi belum sama.';
                },
              ),

              if (_roleFields.isNotEmpty) ...[
                const SizedBox(height: 3),
                const Text(
                  'Informasi tambahan',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                for (final field in _roleFields)
                  FormFieldTile(
                    controller: _controllers[field.keyName]!,
                    label: field.label,
                    keyboardType: field.keyboardType,
                    validator: requiredField,
                    maxLines: field.keyName == 'address_detail' ? 3 : 1,
                  ),
              ],

              if (_role == PublicRegistrationRole.mitra)
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: AuthNotice(
                    text:
                        'Pendaftaran Mitra saat ini dibatasi untuk Kota Depok.',
                  ),
                ),

              GreenLoopButton(
                label: 'Daftar',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LoginPage(authService: _effectiveAuth),
                    ),
                  );
                },
                child: const Text('Sudah punya akun? Masuk'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
