import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../data/admin_management_service.dart';

class AdminCatalogPage extends StatefulWidget {
  const AdminCatalogPage({this.authService, super.key});
  final AuthService? authService;
  @override
  State<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends State<AdminCatalogPage> {
  late final AdminManagementService _service;
  List<AdminProduct> _products = const [];
  List<AdminShopOrder> _orders = const [];
  bool _loading = true;
  String? _error;
  int _section = 0;
  @override
  void initState() {
    super.initState();
    _service = AdminManagementService(widget.authService ?? defaultAuthService);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _service.products();
      if (mounted) setState(() => _products = rows);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _service.orders();
      if (mounted) setState(() => _orders = rows);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSelected() => _section == 0 ? _load() : _loadOrders();

  Future<void> _edit([AdminProduct? product]) async {
    final result = await showModalBottomSheet<_CatalogFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CatalogForm(product: product),
    );
    if (result == null) return;
    try {
      await _service.saveProduct(
        id: product?.id,
        fields: result.fields,
        imageBytes: result.imageBytes,
        filename: result.filename,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product == null
                ? 'Produk ditambahkan ke katalog.'
                : 'Produk berhasil diperbarui.',
          ),
        ),
      );
      await _load();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _delete(AdminProduct product) async {
    final okay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text(
          '${product.name} akan dihapus dari katalog dan tidak bisa dipesan lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (okay != true) return;
    try {
      await _service.deleteProduct(product.id);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk dihapus dari katalog.')),
        );
      await _load();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _advanceOrder(AdminShopOrder order) async {
    final next = _nextStatus(order);
    if (next == null) return;
    String? tracking;
    if (next == 'SHIPPED') {
      final controller = TextEditingController(text: order.trackingNumber);
      tracking = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Masukkan nomor resi'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Resi JNE/J&T'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (tracking == null || tracking.trim().isEmpty) return;
    }
    try {
      final message = await _service.updateOrder(
        order,
        next,
        trackingNumber: tracking,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      await _loadOrders();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Katalog'),
          Text(
            'Produk untuk Mitra dan Konsumen',
            style: TextStyle(fontSize: 11, color: GreenLoopColors.muted),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _loading ? null : _load,
          tooltip: 'Muat ulang',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: _section == 0
        ? FloatingActionButton.extended(
            onPressed: () => _edit(),
            backgroundColor: GreenLoopColors.forest2,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Tambah produk'),
          )
        : null,
    body: RefreshIndicator(
      onRefresh: _loadSelected,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: GreenLoopColors.mint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: GreenLoopColors.forest2),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Satu harga katalog berlaku untuk Mitra dan Konsumen. Voucher khusus Mitra digunakan saat checkout.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: GreenLoopColors.forest2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Produk')),
              ButtonSegment(value: 1, label: Text('Pesanan')),
            ],
            selected: {_section},
            onSelectionChanged: (value) {
              setState(() => _section = value.first);
              _loadSelected();
            },
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(36),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _empty(
              _section == 0
                  ? 'Katalog belum dapat dimuat'
                  : 'Pesanan belum dapat dimuat',
              _error!,
              action: TextButton(
                onPressed: _loadSelected,
                child: const Text('Coba lagi'),
              ),
            )
          else if (_section == 0 && _products.isEmpty)
            _empty(
              'Katalog masih kosong',
              'Tambah produk di sini. Produk yang sama akan muncul di belanja Mitra dan Konsumen.',
            )
          else if (_section == 0)
            for (final product in _products)
              _ProductAdminCard(
                product: product,
                onEdit: () => _edit(product),
                onDelete: () => _delete(product),
              )
          else if (_orders.isEmpty)
            _empty(
              'Belum ada pesanan',
              'Pesanan produk setelah dibayar akan muncul di sini untuk diproses Admin.',
            )
          else
            for (final order in _orders)
              _ShopOrderCard(
                order: order,
                onAdvance: () => _advanceOrder(order),
              ),
        ],
      ),
    ),
  );
}

String? _nextStatus(AdminShopOrder order) => switch (order.status) {
  'PAID' => 'PROCESSING',
  'PROCESSING' => 'PACKED',
  'PACKED' =>
    order.method == 'self_pickup' ? 'READY_FOR_PICKUP' : 'COURIER_BOOKED',
  'COURIER_BOOKED' => 'SHIPPED',
  'SHIPPED' => 'DELIVERED',
  'READY_FOR_PICKUP' => 'PICKED_UP',
  _ => null,
};

String _statusLabel(String status) => switch (status) {
  'PENDING' => 'Menunggu pembayaran',
  'PAID' => 'Pembayaran lunas',
  'PROCESSING' => 'Sedang diproses',
  'PACKED' => 'Sudah dikemas',
  'COURIER_BOOKED' => 'Siap diserahkan ke ekspedisi',
  'SHIPPED' => 'Dalam pengiriman',
  'DELIVERED' => 'Terkirim',
  'READY_FOR_PICKUP' => 'Siap diambil Mitra',
  'PICKED_UP' => 'Sudah diambil',
  'CANCELLED' => 'Dibatalkan',
  _ => status,
};

String? _nextLabel(String? status) => status == null
    ? null
    : switch (status) {
        'PROCESSING' => 'Mulai proses',
        'PACKED' => 'Tandai sudah dikemas',
        'COURIER_BOOKED' => 'Siap diserahkan ke ekspedisi',
        'SHIPPED' => 'Masukkan resi & kirim',
        'DELIVERED' => 'Tandai terkirim',
        'READY_FOR_PICKUP' => 'Siap diambil Mitra',
        'PICKED_UP' => 'Tandai sudah diambil',
        _ => null,
      };

class _ShopOrderCard extends StatelessWidget {
  const _ShopOrderCard({required this.order, required this.onAdvance});
  final AdminShopOrder order;
  final VoidCallback onAdvance;
  @override
  Widget build(BuildContext context) {
    final next = _nextStatus(order);
    final pickup = order.method == 'self_pickup';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GreenLoopColors.border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pesanan ${order.id.length > 10 ? order.id.substring(0, 10).toUpperCase() : order.id.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _statusPill(_statusLabel(order.status)),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${order.buyerName} · @${order.username}',
            style: const TextStyle(fontSize: 11, color: GreenLoopColors.muted),
          ),
          const Divider(height: 20),
          Text(order.items.join(', '), style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            _price(order.amount),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: GreenLoopColors.forest2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pickup
                ? 'Ambil sendiri${order.pickupDate.isEmpty ? '' : ' · ${order.pickupDate}'}'
                : '${order.courierName} ${order.courierService}'.trim(),
            style: const TextStyle(fontSize: 11, color: GreenLoopColors.muted),
          ),
          if (order.trackingNumber.isNotEmpty)
            Text(
              'Resi: ${order.trackingNumber}',
              style: const TextStyle(
                fontSize: 11,
                color: GreenLoopColors.muted,
              ),
            ),
          if (order.paymentStatus != 'PAID')
            const Padding(
              padding: EdgeInsets.only(top: 7),
              child: Text(
                'Pesanan baru dapat diproses setelah pembayaran terkonfirmasi.',
                style: TextStyle(fontSize: 11, color: Color(0xFF9A6500)),
              ),
            )
          else if (next != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAdvance,
                child: Text(_nextLabel(next)!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _statusPill(String label) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
  decoration: BoxDecoration(
    color: GreenLoopColors.mint,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    label,
    style: const TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: GreenLoopColors.forest2,
    ),
  ),
);

class _CatalogFormResult {
  const _CatalogFormResult({
    required this.fields,
    this.imageBytes,
    this.filename,
  });
  final Map<String, String> fields;
  final List<int>? imageBytes;
  final String? filename;
}

class _CatalogForm extends StatefulWidget {
  const _CatalogForm({this.product});
  final AdminProduct? product;
  @override
  State<_CatalogForm> createState() => _CatalogFormState();
}

class _CatalogFormState extends State<_CatalogForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _description = TextEditingController(
    text: widget.product?.description ?? '',
  );
  late final _price = TextEditingController(
    text: widget.product == null ? '' : '${widget.product!.price}',
  );
  late final _stock = TextEditingController(
    text: widget.product == null ? '' : '${widget.product!.stock}',
  );
  late final _weight = TextEditingController(
    text: widget.product == null ? '' : '${widget.product!.weightGrams}',
  );
  List<int>? _imageBytes;
  String? _filename;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1400,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (mounted)
      setState(() {
        _imageBytes = bytes;
        _filename = picked.name;
      });
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi' : null;
  String? _positive(String? value) {
    final n = int.tryParse(value ?? '');
    return n == null || n < 1 ? 'Masukkan angka lebih dari 0' : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    Navigator.pop(
      context,
      _CatalogFormResult(
        fields: {
          'name': _name.text.trim(),
          'description': _description.text.trim(),
          'price_b2c': _price.text.trim(),
          'price_b2b': _price.text.trim(),
          'stock': _stock.text.trim(),
          'weight_grams': _weight.text.trim(),
        },
        imageBytes: _imageBytes,
        filename: _filename,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      18,
      4,
      18,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product == null ? 'Tambah produk' : 'Edit produk',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nama produk'),
              validator: _required,
            ),
            const SizedBox(height: 9),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              validator: _required,
            ),
            const SizedBox(height: 9),
            TextFormField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga katalog (sama untuk Mitra dan Konsumen)',
                prefixText: 'Rp ',
              ),
              validator: _positive,
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      suffixText: 'unit',
                    ),
                    validator: _positive,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _weight,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Berat per unit',
                      suffixText: 'gram',
                    ),
                    validator: _positive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _filename ??
                    (widget.product?.imageUrl == null
                        ? 'Pilih foto produk (opsional)'
                        : 'Ganti foto produk'),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(
                  widget.product == null
                      ? 'Simpan ke katalog'
                      : 'Simpan perubahan',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProductAdminCard extends StatelessWidget {
  const _ProductAdminCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });
  final AdminProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: product.imageUrl == null
              ? Container(
                  width: 68,
                  height: 68,
                  color: GreenLoopColors.mint,
                  child: const Icon(
                    Icons.soap_outlined,
                    color: GreenLoopColors.forest2,
                  ),
                )
              : Image.network(
                  product.imageUrl!,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 68,
                    height: 68,
                    color: GreenLoopColors.mint,
                    child: const Icon(Icons.soap_outlined),
                  ),
                ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _price(product.price),
                style: const TextStyle(
                  color: GreenLoopColors.forest2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Stok ${product.stock} · ${product.weightGrams} gram/unit',
                style: const TextStyle(
                  fontSize: 10,
                  color: GreenLoopColors.muted,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ],
    ),
  );
}

Widget _empty(String title, String body, {Widget? action}) => Container(
  padding: const EdgeInsets.all(22),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: GreenLoopColors.border),
    borderRadius: BorderRadius.circular(15),
  ),
  child: Column(
    children: [
      const Icon(
        Icons.inventory_2_outlined,
        color: GreenLoopColors.forest2,
        size: 34,
      ),
      const SizedBox(height: 10),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      Text(
        body,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: GreenLoopColors.muted),
      ),
      if (action != null) action,
    ],
  ),
);
String _price(int value) =>
    'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
