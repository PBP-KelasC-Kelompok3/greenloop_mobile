import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../auth/data/auth_models.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/theme/greenloop_theme.dart';
import 'mitra_location_picker.dart';

class MitraEditProfilePage extends StatefulWidget {
  const MitraEditProfilePage({this.authService, super.key});

  final AuthService? authService;

  @override
  State<MitraEditProfilePage> createState() => _MitraEditProfilePageState();
}

class _MitraEditProfilePageState extends State<MitraEditProfilePage> {
  static const _businessTypes = [
    'Kafe / Coffee Shop',
    'Restoran',
    'Hotel',
    'Katering',
    'Lainnya',
  ];

  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _picName = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _operationalHours = TextEditingController();
  final _province = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _village = TextEditingController();
  final _address = TextEditingController();
  final _courierNotes = TextEditingController();

  late final AuthService _auth;
  String? _businessType;
  bool _saving = false;
  bool _locationEditable = true;
  bool _locationWithinBoundary = false;
  bool _locationAddressResolved = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? defaultAuthService;
    final profile = _auth.currentUser?.mitraProfile;
    _latitude = profile?.latitude;
    _longitude = profile?.longitude;
    _locationWithinBoundary = _latitude != null && _longitude != null;
    _locationAddressResolved = _latitude != null &&
        _longitude != null &&
        profile?.addressDetail?.trim().isNotEmpty == true;
    _locationEditable = !(profile?.locationLocked == true &&
        _latitude != null && _longitude != null);
    _businessName.text = profile?.businessName ?? '';
    _businessType = _normalizeBusinessType(profile?.businessType);
    _picName.text = profile?.picName ?? '';
    _phoneNumber.text = profile?.phoneNumber ?? '';
    _operationalHours.text = profile?.operationalHours ?? '';
    _province.text = profile?.provinsi ?? '';
    _city.text = profile?.kota ?? '';
    _district.text = profile?.kecamatan ?? '';
    _village.text = profile?.kelurahan ?? '';
    _address.text = profile?.addressDetail ?? '';
    _courierNotes.text = profile?.courierNotes ?? '';
  }

  @override
  void dispose() {
    _businessName.dispose();
    _picName.dispose();
    _phoneNumber.dispose();
    _operationalHours.dispose();
    _province.dispose();
    _city.dispose();
    _district.dispose();
    _village.dispose();
    _address.dispose();
    _courierNotes.dispose();
    super.dispose();
  }

  String? _normalizeBusinessType(String? value) {
    final type = value?.trim().toLowerCase();
    if (type == null || type.isEmpty) return null;
    if (type.contains('kafe') || type.contains('cafe') || type.contains('coffee')) {
      return 'Kafe / Coffee Shop';
    }
    if (type.contains('restoran') || type.contains('restaurant')) return 'Restoran';
    if (type.contains('hotel')) return 'Hotel';
    if (type.contains('katering') || type.contains('catering')) return 'Katering';
    return 'Lainnya';
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_latitude == null || _longitude == null ||
        !_locationWithinBoundary || !_locationAddressResolved) {
      _showMessage('Pilih titik peta dan tunggu alamatnya terisi otomatis sebelum menyimpan.');
      return;
    }
    setState(() => _saving = true);
    try {
      final payload = <String, dynamic>{
        'business_name': _businessName.text.trim(),
        'business_type': _businessType ?? '',
        'pic_name': _picName.text.trim(),
        'phone_number': _phoneNumber.text.trim(),
        'operational_hours': _operationalHours.text.trim(),
        'provinsi': _province.text.trim(),
        'kota': _city.text.trim(),
        'kecamatan': _district.text.trim(),
        'kelurahan': _village.text.trim(),
        'address_detail': _address.text.trim(),
        'courier_notes': _courierNotes.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'location_locked': true,
      };
      await _auth.updateProfile(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil usaha berhasil diperbarui.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Gagal menyimpan profil: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onLocationChanged(MitraLocationSelection selection) {
    setState(() {
      _latitude = selection.point.latitude;
      _longitude = selection.point.longitude;
      _locationAddressResolved = selection.address?.trim().isNotEmpty == true;
      if (selection.province?.isNotEmpty == true) _province.text = selection.province!;
      if (selection.city?.isNotEmpty == true) _city.text = selection.city!;
      if (selection.district?.isNotEmpty == true) _district.text = selection.district!;
      if (selection.village?.isNotEmpty == true) _village.text = selection.village!;
      if (selection.address?.isNotEmpty == true) _address.text = selection.address!;
    });
  }

  void _onLocationValidityChanged(bool isValid) {
    if (_locationWithinBoundary == isValid) return;
    setState(() => _locationWithinBoundary = isValid);
  }

  void _onLocationNeedsResolution() {
    if (!_locationAddressResolved) return;
    setState(() => _locationAddressResolved = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final account = _auth.currentUser?.user;
    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(
        backgroundColor: GreenLoopColors.surface,
        title: const Text(
          'Edit Profil Mitra',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            _IdentityCard(
              name: _businessName.text.isEmpty ? 'Nama usaha' : _businessName.text,
              email: account?.email ?? '',
            ),
            const SizedBox(height: 14),
            const _FormSectionTitle('Informasi usaha'),
            const SizedBox(height: 8),
            _FormCard(
              children: [
                _MobileInput(label: 'Nama usaha', controller: _businessName, required: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _businessType,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Jenis usaha', filled: true, fillColor: Colors.white),
                  hint: const Text('Pilih jenis usaha'),
                  items: [
                    for (final type in _businessTypes)
                      DropdownMenuItem(
                        value: type,
                        child: Text(type, style: const TextStyle(fontSize: 12)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _businessType = value),
                ),
                const SizedBox(height: 12),
                _MobileInput(label: 'Nama penanggung jawab', controller: _picName, required: true),
                const SizedBox(height: 12),
                _MobileInput(label: 'No. WhatsApp', controller: _phoneNumber, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _MobileInput(label: 'Jam operasional', controller: _operationalHours, hint: 'Contoh: 07.00–22.00 WIB'),
              ],
            ),
            const SizedBox(height: 16),
            const _FormSectionTitle('Alamat penjemputan'),
            const SizedBox(height: 8),
            _FormCard(
              children: [
                Row(children: [
                  const Expanded(child: Text('Titik Penjemputan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                  if (!_locationEditable)
                    TextButton.icon(
                      onPressed: () => setState(() => _locationEditable = true),
                      icon: const Icon(Icons.edit_location_alt_outlined, size: 17),
                      label: const Text('Ubah titik'),
                    )
                  else
                    const Chip(avatar: Icon(Icons.lock_open, size: 15), label: Text('Atur titik')),
                ]),
                const SizedBox(height: 8),
                MitraLocationPicker(
                  initialPoint: _latitude != null && _longitude != null
                      ? LatLng(_latitude!, _longitude!)
                      : depokMapCenter,
                  editable: _locationEditable,
                  onPointChanged: _onLocationChanged,
                  onLocationValidityChanged: _onLocationValidityChanged,
                  onLocationNeedsResolution: _onLocationNeedsResolution,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _FormCard(
              children: [
                _MobileInput(label: 'Provinsi', controller: _province, readOnly: true),
                const SizedBox(height: 12),
                _MobileInput(label: 'Kota / Kabupaten', controller: _city, readOnly: true),
                const SizedBox(height: 12),
                _MobileInput(label: 'Kecamatan', controller: _district, readOnly: true),
                const SizedBox(height: 12),
                _MobileInput(label: 'Kelurahan', controller: _village, readOnly: true),
                const SizedBox(height: 12),
                _MobileInput(label: 'Alamat lengkap', controller: _address, maxLines: 3, readOnly: true),
                const SizedBox(height: 12),
                _MobileInput(label: 'Catatan untuk kurir', controller: _courierNotes, hint: 'Patokan atau akses menuju lokasi', maxLines: 2),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Email akun tidak dapat diubah dari halaman ini.',
              style: TextStyle(fontSize: 10, color: GreenLoopColors.muted),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: GreenLoopColors.border)),
          ),
          child: SizedBox(
            height: 46,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: GreenLoopColors.circleGreen),
              child: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan Perubahan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.name, required this.email});
  final String name;
  final String email;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GreenLoopColors.border), borderRadius: BorderRadius.circular(15)),
    child: Row(children: [
      CircleAvatar(radius: 22, backgroundColor: GreenLoopColors.circleGreen, child: Text(name.isEmpty ? 'M' : name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        if (email.isNotEmpty) Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
        const Text('Mitra B2B', style: TextStyle(fontSize: 9, color: GreenLoopColors.circleGreen, fontWeight: FontWeight.w600)),
      ])),
    ]),
  );
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700));
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GreenLoopColors.border), borderRadius: BorderRadius.circular(15)),
    child: Column(children: children),
  );
}

class _MobileInput extends StatelessWidget {
  const _MobileInput({required this.label, required this.controller, this.hint, this.keyboardType, this.maxLines = 1, this.required = false, this.readOnly = false});
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool required;
  final bool readOnly;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    readOnly: readOnly,
    keyboardType: keyboardType,
    maxLines: maxLines,
    validator: required ? (value) => value == null || value.trim().isEmpty ? '$label wajib diisi.' : null : null,
    decoration: InputDecoration(labelText: label, hintText: hint, filled: true, fillColor: Colors.white, isDense: true),
    style: const TextStyle(fontSize: 12),
  );
}
