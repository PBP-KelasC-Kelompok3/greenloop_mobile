import 'dart:async';

import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../mitra/data/mitra_shop_service.dart';

/// Consumer-facing commerce screens. Catalog/cart/order data are loaded from
/// the same authenticated Django endpoints used by the Mitra shop.
class ConsumerCatalogPage extends StatefulWidget {
  const ConsumerCatalogPage({required this.authService, super.key});
  final AuthService? authService;

  @override
  State<ConsumerCatalogPage> createState() => _ConsumerCatalogPageState();
}

class _ConsumerCatalogPageState extends State<ConsumerCatalogPage> {
  late final MitraShopService _service =
      MitraShopService(widget.authService ?? defaultAuthService);
  final _search = TextEditingController();
  Timer? _debounce;
  List<ShopProduct> _products = const [];
  int _cartCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _service.products(search: _search.text),
        _service.cart(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = results[0] as List<ShopProduct>;
        _cartCount = (results[1] as ShopCart).count;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  Future<void> _add(ShopProduct product) async {
    try {
      await _service.add(product.id);
      if (mounted) {
        setState(() => _cartCount++);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
        );
      }
    } catch (e) {
      if (mounted) _message('$e');
    }
  }

  void _message(String value) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Katalog Produk'),
        Text('Produk GreenLoop', style: Theme.of(context).textTheme.labelSmall),
      ]),
      actions: [
        IconButton(
          tooltip: 'Keranjang ($_cartCount)',
          onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
            builder: (_) => ConsumerCartPage(authService: widget.authService),
          )).then((_) => _load()),
          icon: Badge(label: Text('$_cartCount'), child: const Icon(Icons.shopping_cart_outlined)),
        ),
      ],
    ),
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextField(
          controller: _search,
          onChanged: _searchChanged,
          decoration: InputDecoration(
            hintText: 'Cari sabun, pouch, paket...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(onPressed: _load, icon: const Icon(Icons.tune)),
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: GreenLoopColors.mint, borderRadius: BorderRadius.circular(12)),
        child: const Row(children: [
          Icon(Icons.info_outline, size: 17, color: GreenLoopColors.forest2),
          SizedBox(width: 8),
          Expanded(child: Text('Harga katalog berlaku untuk semua pelanggan. Voucher Waste Points khusus Mitra.', style: TextStyle(fontSize: 11, height: 1.35, color: GreenLoopColors.forest2))),
        ]),
      ),
      Expanded(child: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? _empty('Katalog belum dapat dimuat', _error!, retry: _load)
          : _products.isEmpty
            ? _empty('Produk belum tersedia', 'Produk yang diterbitkan Admin akan tampil di sini.')
            : RefreshIndicator(
                onRefresh: _load,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 18),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                    childAspectRatio: .73,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return _ProductCard(
                      product: product,
                      onOpen: () => showModalBottomSheet<void>(
                        context: context, isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _ProductDetail(product: product, onAdd: () async {
                          Navigator.pop(context); await _add(product);
                        }),
                      ),
                      onAdd: () => _add(product),
                    );
                  },
                ),
              )),
    ]),
  );
}

class ConsumerCartPage extends StatefulWidget {
  const ConsumerCartPage({required this.authService, super.key});
  final AuthService? authService;
  @override
  State<ConsumerCartPage> createState() => _ConsumerCartPageState();
}

class _ConsumerCartPageState extends State<ConsumerCartPage> {
  late final _service = MitraShopService(widget.authService ?? defaultAuthService);
  ShopCart? _cart;
  String? _error;
  bool _loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try { final value = await _service.cart(); if (mounted) setState(() => _cart = value); }
    catch (e) { if (mounted) setState(() => _error = '$e'); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  Future<void> _quantity(ShopCartLine line, int amount) async {
    try {
      if (amount <= 0) { await _service.remove(line.id); }
      else { await _service.updateQuantity(line.id, amount); }
      await _load();
    } catch (e) { if (mounted) _showMessage(context, '$e'); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(title: const Text('Keranjang')),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : _error != null ? _empty('Keranjang belum dapat dimuat', _error!, retry: _load)
      : _cart!.items.isEmpty ? _empty('Keranjang masih kosong', 'Pilih produk dari katalog untuk mulai belanja.')
      : Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
          for (final line in _cart!.items)
            Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(10), decoration: _cardDecoration(), child: Row(children: [
              _ProductImage(url: line.imageUrl, size: 62), const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(line.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 4), Text('${line.weightGrams} g', style: const TextStyle(color: GreenLoopColors.muted, fontSize: 10)),
                Text(_money(line.lineTotal), style: const TextStyle(fontWeight: FontWeight.w700, color: GreenLoopColors.forest2)),
              ])),
              _QuantityControl(value: line.quantity, minus: () => _quantity(line, line.quantity - 1), plus: () => _quantity(line, line.quantity + 1)),
            ])),
          Container(padding: const EdgeInsets.all(13), decoration: _cardDecoration(), child: Column(children: [
            _priceRow('Subtotal', _money(_cart!.subtotal)),
            _priceRow('Ongkir', 'Dihitung saat checkout'),
            const Divider(), _priceRow('Total sementara', _money(_cart!.subtotal), bold: true),
          ])),
        ])),
        SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(14), child: SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () => Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ConsumerCheckoutPage(service: _service, cart: _cart!))).then((success) { if (success == true) _load(); }),
          child: const Text('Lanjut ke Checkout'),
        )))),
      ]),
  );
}

class ConsumerCheckoutPage extends StatefulWidget {
  const ConsumerCheckoutPage({required this.service, required this.cart, super.key});
  final MitraShopService service;
  final ShopCart cart;
  @override
  State<ConsumerCheckoutPage> createState() => _ConsumerCheckoutPageState();
}

class _ConsumerCheckoutPageState extends State<ConsumerCheckoutPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _destinationQuery = TextEditingController();
  Timer? _timer;
  List<ShopDestination> _destinations = const [];
  ShopDestination? _destination;
  List<ShopShippingOption> _options = const [];
  ShopShippingOption? _selected;
  bool _searching = false, _quoting = false, _submitting = false;
  String? _error;
  @override
  void dispose() { _timer?.cancel(); _name.dispose(); _phone.dispose(); _address.dispose(); _destinationQuery.dispose(); super.dispose(); }
  void _search(String query) {
    _timer?.cancel(); setState(() { _destination = null; _options = const []; _selected = null; });
    if (query.trim().length < 2) { setState(() => _destinations = const []); return; }
    _timer = Timer(const Duration(milliseconds: 350), () async {
      setState(() { _searching = true; _error = null; });
      try { final found = await widget.service.searchDestinations(query.trim()); if (mounted) setState(() => _destinations = found); }
      catch (e) { if (mounted) setState(() { _destinations = const []; _error = '$e'; }); }
      finally { if (mounted) setState(() => _searching = false); }
    });
  }
  Future<void> _quote() async {
    if (_destination == null) return;
    setState(() { _quoting = true; _error = null; _options = const []; _selected = null; });
    try { final options = await widget.service.allShippingOptions(_destination!.id); if (mounted) setState(() { _options = options; if (options.isEmpty) _error = 'Tidak ada layanan kurir untuk tujuan ini.'; }); }
    catch (e) { if (mounted) setState(() => _error = '$e'); }
    finally { if (mounted) setState(() => _quoting = false); }
  }
  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty || _address.text.trim().isEmpty || _destination == null || _selected == null) {
      setState(() => _error = 'Lengkapi nama, nomor telepon, alamat, tujuan, dan kurir.'); return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final result = await widget.service.checkout(recipient: _name.text, phone: _phone.text, method: 'courier', address: _address.text, destinationId: _destination!.id, destinationLabel: _destination!.label, shipping: _selected);
      if (!mounted) return;
      await _showPaymentLink(context, result.paymentUrl);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) { if (mounted) setState(() => _error = '$e'); }
    finally { if (mounted) setState(() => _submitting = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(title: const Text('Checkout')),
    body: ListView(padding: const EdgeInsets.all(15), children: [
      _section('Penerima', Column(children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama penerima')),
        const SizedBox(height: 9), TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'No. WhatsApp')),
      ])),
      const SizedBox(height: 10),
      _section('Alamat pengiriman', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: _destinationQuery, onChanged: _search, decoration: InputDecoration(labelText: 'Cari kota/kecamatan tujuan', prefixIcon: const Icon(Icons.search), suffixIcon: _searching ? const Padding(padding: EdgeInsets.all(13), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))) : null)),
        if (_destinations.isNotEmpty) ...[
          const SizedBox(height: 5),
          ..._destinations.take(6).map((d) => ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.location_on_outlined), title: Text(d.label, style: const TextStyle(fontSize: 12)), onTap: () { setState(() { _destination = d; _destinationQuery.text = d.label; _destinations = const []; }); _quote(); })),
        ],
        const SizedBox(height: 8), TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(labelText: 'Alamat lengkap, nomor rumah, patokan')),
      ])),
      const SizedBox(height: 10),
      _section('Kurir · RajaOngkir', Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (_destination == null) const Text('Pilih tujuan untuk melihat pilihan layanan dan ongkir.', style: TextStyle(color: GreenLoopColors.muted, fontSize: 12))
        else if (_quoting) const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
        else if (_options.isNotEmpty) ..._options.map((option) => RadioListTile<ShopShippingOption>(contentPadding: EdgeInsets.zero, value: option, groupValue: _selected, onChanged: (value) => setState(() => _selected = value), title: Text('${option.courierName} ${option.service}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), subtitle: Text(option.eta.isEmpty ? option.description : '${option.eta} hari · ${option.description}', style: const TextStyle(fontSize: 11)), secondary: Text(_money(option.cost), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))))
        else TextButton.icon(onPressed: _quote, icon: const Icon(Icons.refresh), label: const Text('Hitung ongkir')),
      ])),
      const SizedBox(height: 10),
      _section('Ringkasan pembayaran', Column(children: [
        _priceRow('Produk (${widget.cart.count} item)', _money(widget.cart.subtotal)),
        _priceRow('Ongkir', _selected == null ? 'Pilih kurir' : _money(_selected!.cost)),
        const Divider(), _priceRow('Total', _money(widget.cart.subtotal + (_selected?.cost ?? 0)), bold: true),
        const SizedBox(height: 6), const Text('Pembayaran diproses melalui halaman Midtrans Sandbox. Voucher Waste Points hanya tersedia untuk Mitra.', style: TextStyle(color: GreenLoopColors.muted, fontSize: 11, height: 1.4)),
      ])),
      if (_error != null) ...[const SizedBox(height: 10), _errorBox(_error!)],
      const SizedBox(height: 14),
      FilledButton.icon(onPressed: _submitting ? null : _submit, icon: _submitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock_outline), label: Text(_submitting ? 'Membuat pesanan...' : 'Buat pesanan & bayar')),
      const SizedBox(height: 18),
    ]),
  );
}

/// Orders are account-scoped by Django. The shared order view can therefore
/// safely render the consumer's own payment and shipping status.
class ConsumerOrdersPage extends StatelessWidget {
  const ConsumerOrdersPage({
    required this.authService,
    this.includeSelfPickup = false,
    this.pageTitle = 'Pesanan Saya',
    super.key,
  });
  final AuthService? authService;
  final bool includeSelfPickup;
  final String pageTitle;
  @override
  Widget build(BuildContext context) => _ConsumerOrdersScreen(
    authService: authService,
    includeSelfPickup: includeSelfPickup,
    pageTitle: pageTitle,
  );
}

class _ConsumerOrdersScreen extends StatefulWidget {
  const _ConsumerOrdersScreen({
    required this.authService,
    required this.includeSelfPickup,
    required this.pageTitle,
  });
  final AuthService? authService;
  final bool includeSelfPickup;
  final String pageTitle;
  @override
  State<_ConsumerOrdersScreen> createState() => _ConsumerOrdersScreenState();
}

class _ConsumerOrdersScreenState extends State<_ConsumerOrdersScreen> {
  late final _service = MitraShopService(widget.authService ?? defaultAuthService);
  List<ShopOrder> _orders = const [];
  bool _loading = true;
  String? _error;
  String _filter = 'Semua';
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final value = await _service.orders();
      if (mounted) {
        setState(() => _orders = widget.includeSelfPickup
            ? value
            : value.where((o) => o.fulfillmentMethod == 'courier').toList());
      }
    }
    catch (e) { if (mounted) setState(() => _error = '$e'); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) {
    final shown = _orders.where((o) => switch (_filter) {
      'Belum Bayar' => o.paymentStatus == 'PENDING',
      'Diproses' => {'PAID', 'PROCESSING', 'PACKED', 'COURIER_BOOKED'}.contains(o.status),
      'Dikirim' => o.status == 'SHIPPED',
      'Terkirim' => o.status == 'DELIVERED',
      _ => true,
    }).toList();
    return Scaffold(
      backgroundColor: GreenLoopColors.surface,
      appBar: AppBar(title: Text(widget.pageTitle), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: Column(children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), child: Row(children: ['Semua', 'Belum Bayar', 'Diproses', 'Dikirim', 'Terkirim'].map((f) => Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(f), selected: _filter == f, onSelected: (_) => setState(() => _filter = f)))).toList())),
        Expanded(child: _buildOrdersContent(shown)),
      ]),
    );
  }

  Widget _buildOrdersContent(List<ShopOrder> shown) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _empty('Pesanan gagal dimuat', _error!, retry: _load);
    }
    if (shown.isEmpty) {
      return _empty(
        'Belum ada pesanan',
        'Pesanan yang dibuat dari akun ini akan muncul di sini.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
        children: shown
            .map(
              (order) => _ConsumerOrderCard(
                order: order,
                service: _service,
                onChanged: _load,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ConsumerOrderCard extends StatelessWidget {
  const _ConsumerOrderCard({required this.order, required this.service, required this.onChanged});
  final ShopOrder order;
  final MitraShopService service;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) {
    final state = _orderStatus(order);
    return InkWell(
      onTap: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _TrackingSheet(order: order)),
      child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(13), decoration: _cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text('#GL-${order.id.toUpperCase()}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))), _statusPill(state.$1, state.$2)]),
        const SizedBox(height: 5), Text(_date(order.createdAt), style: const TextStyle(fontSize: 10, color: GreenLoopColors.muted)),
        const SizedBox(height: 6), Text('${order.items.length} produk · ${order.items.take(2).map((i) => i.name).join(', ')}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
        const Divider(height: 17),
        Row(children: [Expanded(child: Text('Total  ${_money(order.amount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
          if (order.paymentStatus == 'PENDING' && order.status != 'CANCELLED') TextButton(onPressed: () async { try { await service.refreshPayment(order.id); onChanged(); } catch (e) { _showMessage(context, '$e'); } }, child: const Text('Cek bayar')),
          if (order.paymentStatus == 'PENDING' && order.status != 'CANCELLED' && order.snapUrl.isNotEmpty) FilledButton(onPressed: () => _showPaymentLink(context, order.snapUrl), child: const Text('Bayar')),
          if (order.status == 'SHIPPED') OutlinedButton(onPressed: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _TrackingSheet(order: order)), child: const Text('Lacak')),
        ]),
      ])),
    );
  }
}

class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({required this.order});
  final ShopOrder order;
  static const _steps = ['PAID', 'PROCESSING', 'PACKED', 'COURIER_BOOKED', 'SHIPPED', 'DELIVERED'];
  @override
  Widget build(BuildContext context) {
    final progress = _steps.indexOf(order.status);
    return SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Lacak Pesanan', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 10),
      Text('#GL-${order.id.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w700)),
      Text('${order.courierName} ${order.courierService}'.trim(), style: const TextStyle(color: GreenLoopColors.muted)),
      if (order.trackingNumber.isNotEmpty) Text('No. resi: ${order.trackingNumber}', style: const TextStyle(fontWeight: FontWeight.w600)),
      const Divider(height: 25),
      for (var i = 0; i < _steps.length; i++) ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Icon(i <= progress ? Icons.check_circle : Icons.radio_button_unchecked, color: i <= progress ? GreenLoopColors.forest2 : GreenLoopColors.muted), title: Text(_stepText(_steps[i]), style: TextStyle(fontWeight: i == progress ? FontWeight.w700 : FontWeight.w400)), subtitle: i == progress ? Text('Status terakhir dari server · ${_date(order.createdAt)}') : null),
      const Text('Status diperbarui oleh sistem/admin. Lokasi kurir langsung belum tersedia dari layanan pengiriman.', style: TextStyle(color: GreenLoopColors.muted, fontSize: 11)),
    ])));
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onOpen, required this.onAdd});
  final ShopProduct product; final VoidCallback onOpen, onAdd;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onOpen, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.all(8), decoration: _cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: Center(child: _ProductImage(url: product.imageUrl, size: 112))),
    Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    const SizedBox(height: 3), Text(_money(product.price), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
    Row(children: [Expanded(child: Text('Stok ${product.stock}', style: const TextStyle(fontSize: 9, color: GreenLoopColors.muted))), IconButton(onPressed: product.stock > 0 ? onAdd : null, visualDensity: VisualDensity.compact, icon: const Icon(Icons.add_circle, color: GreenLoopColors.forest2))]),
  ])));
}

class _ProductDetail extends StatelessWidget {
  const _ProductDetail({required this.product, required this.onAdd});
  final ShopProduct product; final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => SafeArea(top: false, child: Container(height: MediaQuery.sizeOf(context).height * .82, padding: const EdgeInsets.all(18), decoration: const BoxDecoration(color: GreenLoopColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(22))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Center(child: _ProductImage(url: product.imageUrl, size: 170)), const SizedBox(height: 14),
    Text('Stok ${product.stock} · ${product.weightGrams} g', style: const TextStyle(fontSize: 11, color: GreenLoopColors.muted)),
    const SizedBox(height: 5), Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    const SizedBox(height: 5), Text(_money(product.price), style: const TextStyle(fontSize: 17, color: GreenLoopColors.forest2, fontWeight: FontWeight.w700)),
    const Divider(height: 24), Expanded(child: SingleChildScrollView(child: Text(product.description.isEmpty ? 'Informasi produk belum ditambahkan.' : product.description, style: const TextStyle(fontSize: 13, height: 1.5, color: GreenLoopColors.muted)))),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: product.stock > 0 ? onAdd : null, icon: const Icon(Icons.shopping_cart_outlined), label: const Text('Tambah ke Keranjang'))),
  ])));
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url, required this.size});
  final String? url; final double size;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: GreenLoopColors.mint, borderRadius: BorderRadius.circular(12)), child: url == null ? const Icon(Icons.eco_outlined, size: 38, color: GreenLoopColors.forest2) : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.eco_outlined, size: 38, color: GreenLoopColors.forest2))));
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.value, required this.minus, required this.plus});
  final int value; final VoidCallback minus, plus;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: minus, visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove, size: 17)), Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)), IconButton(onPressed: plus, visualDensity: VisualDensity.compact, icon: const Icon(Icons.add, size: 17))]);
}

Widget _empty(String title, String message, {VoidCallback? retry}) => ListView(children: [const SizedBox(height: 110), Center(child: Container(margin: const EdgeInsets.all(18), padding: const EdgeInsets.all(24), decoration: _cardDecoration(), child: Column(children: [const Icon(Icons.storefront_outlined, size: 38, color: GreenLoopColors.forest2), const SizedBox(height: 10), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: GreenLoopColors.muted, fontSize: 12)), if (retry != null) TextButton(onPressed: retry, child: const Text('Coba lagi'))])))]);
BoxDecoration _cardDecoration() => BoxDecoration(color: Colors.white, border: Border.all(color: GreenLoopColors.border), borderRadius: BorderRadius.circular(15));
Widget _section(String title, Widget child) => Container(padding: const EdgeInsets.all(13), decoration: _cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10), child]));
Widget _errorBox(String message) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFFFFE8E7), borderRadius: BorderRadius.circular(10)), child: Text(message, style: const TextStyle(color: Colors.redAccent, fontSize: 12)));
Widget _statusPill(String value, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(18)), child: Text(value, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)));
Widget _priceRow(String title, String value, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Expanded(child: Text(title, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w400))), Text(value, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w500))]));
void _showMessage(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
Future<void> _showPaymentLink(BuildContext context, String url) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: const Text('Lanjutkan pembayaran'),
    content: SelectableText(url),
    actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Tutup'))],
  ),
);
String _money(int value) => 'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
String _date(String value) { final d = DateTime.tryParse(value); return d == null ? value : '${d.day} ${_month(d.month)} ${d.year}'; }
String _month(int m) => const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][m.clamp(1, 12).toInt()];
(String, Color) _orderStatus(ShopOrder order) => switch (order.status) {
  'PENDING' => ('Menunggu Pembayaran', const Color(0xFFB87400)), 'PAID' || 'PROCESSING' || 'PACKED' || 'COURIER_BOOKED' => ('Diproses', GreenLoopColors.forest2), 'SHIPPED' => ('Dalam Pengiriman', const Color(0xFF3280C5)), 'DELIVERED' => ('Terkirim', GreenLoopColors.forest2), 'CANCELLED' => ('Dibatalkan', Colors.red), _ => (order.status, GreenLoopColors.muted),
};
String _stepText(String step) => switch (step) { 'PAID' => 'Dibayar', 'PROCESSING' => 'Sedang disiapkan', 'PACKED' => 'Pesanan dikemas', 'COURIER_BOOKED' => 'Kurir menerima pesanan', 'SHIPPED' => 'Dalam pengiriman', 'DELIVERED' => 'Pesanan diterima', _ => step };
