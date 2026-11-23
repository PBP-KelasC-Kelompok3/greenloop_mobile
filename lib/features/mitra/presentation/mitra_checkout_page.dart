import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../data/mitra_shop_service.dart';

class MitraCheckoutPage extends StatefulWidget {
  const MitraCheckoutPage({
    required this.service,
    required this.cart,
    super.key,
  });
  final MitraShopService service;
  final ShopCart cart;
  @override
  State<MitraCheckoutPage> createState() => _MitraCheckoutPageState();
}

class _MitraCheckoutPageState extends State<MitraCheckoutPage> {
  static const _factoryAddress =
      'Jl. Prof. Dr. Sudjono D. Pusponegoro (Jl. Prof. Dr. Nugroho Notosusanto), Pondok Cina, Kecamatan Beji, Kota Depok, Jawa Barat 16424/16425';
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _destinationSearch = TextEditingController();
  Timer? _searchDebounce;
  String _method = 'courier';
  DateTime? _pickupDate;
  List<ShopDestination> _destinations = const [];
  ShopDestination? _destination;
  List<ShopShippingOption> _options = const [];
  ShopShippingOption? _selectedOption;
  bool _searching = false;
  bool _quoting = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _destinationSearch.dispose();
    super.dispose();
  }

  void _search(String value) {
    _searchDebounce?.cancel();
    _destination = null;
    _options = const [];
    _selectedOption = null;
    if (value.trim().length < 2) {
      setState(() => _destinations = const []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() {
        _searching = true;
        _error = null;
      });
      try {
        final results = await widget.service.searchDestinations(value.trim());
        if (mounted)
          setState(
            () => _destinations = results
                .where((d) => d.label.toLowerCase().contains('depok'))
                .toList(growable: false),
          );
      } catch (error) {
        if (mounted)
          setState(() {
            _destinations = const [];
            _error = '$error';
          });
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  Future<void> _getQuotes() async {
    if (_destination == null) return;
    setState(() {
      _quoting = true;
      _error = null;
      _options = const [];
      _selectedOption = null;
    });
    try {
      final options = await widget.service.shippingOptions(_destination!.id);
      if (mounted)
        setState(() {
          _options = options;
          if (options.isEmpty) _error = 'Belum ada layanan ekspedisi untuk alamat ini. Periksa konfigurasi RajaOngkir.';
        });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _quoting = false);
    }
  }

  Future<void> _choosePickupDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? today.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
      helpText: 'Pilih tanggal pengambilan',
    );
    if (picked != null) setState(() => _pickupDate = picked);
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      setState(
        () => _error = 'Isi nama penerima dan nomor WhatsApp terlebih dahulu.',
      );
      return;
    }
    if (_method == 'courier' &&
        (_destination == null ||
            _address.text.trim().isEmpty ||
            _selectedOption == null)) {
      setState(
        () => _error = 'Pilih alamat Depok, isi alamat lengkap, lalu pilih layanan pengiriman.',
      );
      return;
    }
    if (_method == 'self_pickup' && _pickupDate == null) {
      setState(() => _error = 'Pilih tanggal rencana pengambilan di pabrik.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await widget.service.checkout(
        recipient: _name.text,
        phone: _phone.text,
        method: _method,
        address: _address.text,
        destinationId: _destination?.id ?? '',
        destinationLabel: _destination?.label ?? '',
        shipping: _selectedOption,
        pickupDate: _pickupDate,
      );
      if (!mounted) return;
      final uri = Uri.tryParse(result.paymentUrl);
      var opened = false;
      try {
        opened =
            uri != null &&
            await launchUrl(
              uri,
              webOnlyWindowName: kIsWeb ? '_self' : null,
              mode: kIsWeb
                  ? LaunchMode.platformDefault
                  : LaunchMode.externalApplication,
            );
      } catch (_) {
        opened = false;
      }
      if (!mounted) return;
      if (!opened)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pesanan tersimpan, tetapi halaman pembayaran tidak dapat dibuka. Cek Riwayat Pesanan.',
            ),
          ),
        );
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(title: const Text('Checkout')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _section(
          'Ringkasan pesanan',
          Column(
            children: [
              for (final line in widget.cart.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${line.name}  ×  ${line.quantity}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        _rupiah(line.lineTotal),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              _row('Subtotal produk', _rupiah(widget.cart.subtotal)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _section(
          'Data penerima',
          Column(
            children: [
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nama penerima'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor WhatsApp'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _section(
          'Cara menerima pesanan',
          Column(
            children: [
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: 'courier',
                groupValue: _method,
                onChanged: _submitting
                    ? null
                    : (v) => setState(() {
                        _method = v!;
                        _error = null;
                      }),
                title: const Text('Kirim dengan JNE / J&T'),
                subtitle: const Text(
                  'Layanan dan ongkir mengikuti hasil RajaOngkir',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: 'self_pickup',
                groupValue: _method,
                onChanged: _submitting
                    ? null
                    : (v) => setState(() {
                        _method = v!;
                        _error = null;
                      }),
                title: const Text('Ambil sendiri di pabrik'),
                subtitle: const Text(
                  'Tanpa ongkir. Admin akan mengonfirmasi kesiapan barang.',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_method == 'courier')
          _section(
            'Alamat pengiriman Mitra Depok',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _destinationSearch,
                  onChanged: _search,
                  decoration: InputDecoration(
                    labelText: 'Cari kelurahan atau kecamatan di Depok',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                ),
                if (_destinations.isNotEmpty && _destination == null)
                  ..._destinations.map(
                    (d) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(
                        d.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        setState(() {
                          _destination = d;
                          _destinationSearch.text = d.label;
                          _destinations = const [];
                        });
                      },
                    ),
                  ),
                if (_destination != null) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _address,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Alamat lengkap, nomor, patokan',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _quoting ? null : _getQuotes,
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: Text(
                      _quoting
                          ? 'Menghitung ongkir...'
                          : 'Lihat layanan dan ongkir',
                    ),
                  ),
                  for (final option in _options)
                    RadioListTile<ShopShippingOption>(
                      contentPadding: EdgeInsets.zero,
                      value: option,
                      groupValue: _selectedOption,
                      onChanged: (value) =>
                          setState(() => _selectedOption = value),
                      title: Text(
                        '${option.courierName} ${option.service}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${option.description}${option.eta.isNotEmpty ? ' · ${option.eta} hari' : ''}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      secondary: Text(
                        _rupiah(option.cost),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          )
        else
          _section(
            'Lokasi pengambilan',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.factory_outlined,
                  color: GreenLoopColors.forest2,
                ),
                const SizedBox(height: 8),
                const Text(
                  _factoryAddress,
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Jam pengambilan akan dikonfirmasi Admin. Pilih tanggal rencana agar Admin dapat menyiapkan pesanan.',
                  style: TextStyle(
                    color: GreenLoopColors.muted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _choosePickupDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    _pickupDate == null
                        ? 'Pilih tanggal pengambilan'
                        : _date(_pickupDate!),
                  ),
                ),
              ],
            ),
          ),
        if (_error != null) ...[const SizedBox(height: 12), _errorBox(_error!)],
        const SizedBox(height: 12),
        _section(
          'Pembayaran',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pembayaran diproses lewat halaman Midtrans setelah pesanan dibuat.',
                style: TextStyle(
                  fontSize: 12,
                  color: GreenLoopColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              _row(
                'Ongkir',
                _method == 'self_pickup'
                    ? 'Gratis'
                    : _selectedOption == null
                    ? 'Dihitung dari alamat'
                    : _rupiah(_selectedOption!.cost),
              ),
              _row(
                'Total sementara',
                _rupiah(
                  widget.cart.subtotal +
                      (_method == 'courier' ? (_selectedOption?.cost ?? 0) : 0),
                ),
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_outline),
            label: Text(
              _submitting ? 'Membuat pesanan...' : 'Buat pesanan & bayar',
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _section(String title, Widget child) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: GreenLoopColors.border),
    borderRadius: BorderRadius.circular(15),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      child,
    ],
  ),
);
Widget _row(String label, String value, {bool bold = false}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          color: bold ? GreenLoopColors.forest2 : null,
        ),
      ),
    ],
  ),
);
Widget _errorBox(String message) => Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: const Color(0xFFFFE9E7),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFFFC4BE)),
  ),
  child: Text(
    message,
    style: const TextStyle(color: Color(0xFFB83D35), fontSize: 12),
  ),
);
String _rupiah(int value) =>
    'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
