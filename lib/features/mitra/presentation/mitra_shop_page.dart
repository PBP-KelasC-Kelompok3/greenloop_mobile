import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../data/mitra_shop_service.dart';
import 'mitra_cart_page.dart';
import 'mitra_orders_page.dart';

class MitraShopPage extends StatefulWidget {
  const MitraShopPage({this.authService, super.key});
  final AuthService? authService;

  @override
  State<MitraShopPage> createState() => _MitraShopPageState();
}

class _MitraShopPageState extends State<MitraShopPage> {
  late final MitraShopService _service;
  final _search = TextEditingController();
  List<ShopProduct> _products = const [];
  bool _loading = true;
  String? _error;
  int? _adding;

  @override
  void initState() {
    super.initState();
    _service = MitraShopService(widget.authService ?? defaultAuthService);
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await _service.products(search: _search.text);
      if (mounted) setState(() => _products = products);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add(ShopProduct product) async {
    setState(() => _adding = product.id);
    try {
      await _service.add(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} masuk ke keranjang')),
      );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _adding = null);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(
      backgroundColor: GreenLoopColors.surface,
      title: const Text(
        'Belanja Produk',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          tooltip: 'Riwayat pesanan',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MitraOrdersPage(service: _service),
            ),
          ),
          icon: const Icon(Icons.receipt_long_outlined),
        ),
        IconButton(
          tooltip: 'Keranjang',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MitraCartPage(service: _service)),
          ),
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Text(
            'Produk GreenLoop',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari sabun GreenLoop',
              suffixIcon: IconButton(
                onPressed: _load,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(36),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _ShopNotice(
              icon: Icons.cloud_off_outlined,
              title: 'Katalog belum dapat dimuat',
              message: _error!,
              action: TextButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            )
          else if (_products.isEmpty)
            const _ShopNotice(
              icon: Icons.storefront_outlined,
              title: 'Belum ada produk tersedia',
              message: 'Produk dan harga Mitra akan tampil setelah Admin menambahkan katalog atau mengisi stok.',
            )
          else
            ..._products.map(
              (product) => _ProductCard(
                product: product,
                adding: _adding == product.id,
                onAdd: () => _add(product),
              ),
            ),
        ],
      ),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.adding,
    required this.onAdd,
  });
  final ShopProduct product;
  final bool adding;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.imageUrl != null)
          Image.network(
            product.imageUrl!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const _ProductImagePlaceholder(),
          )
        else
          const _ProductImagePlaceholder(),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (product.description.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: GreenLoopColors.muted,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _rupiah(product.price),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: GreenLoopColors.forest2,
                      ),
                    ),
                  ),
                  Text(
                    'Stok ${product.stock}',
                    style: TextStyle(
                      fontSize: 11,
                      color: product.stock > 0
                          ? GreenLoopColors.muted
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: product.stock < 1 || adding ? null : onAdd,
                  icon: adding
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_shopping_cart),
                  label: Text(
                    product.stock < 1 ? 'Stok habis' : 'Tambah ke keranjang',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();
  @override
  Widget build(BuildContext context) => Container(
    height: 150,
    width: double.infinity,
    color: GreenLoopColors.mint,
    child: const Icon(
      Icons.soap_outlined,
      size: 48,
      color: GreenLoopColors.forest2,
    ),
  );
}

class _ShopNotice extends StatelessWidget {
  const _ShopNotice({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        CircleAvatar(
          backgroundColor: GreenLoopColors.mint,
          child: Icon(icon, color: GreenLoopColors.forest2),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            height: 1.5,
            color: GreenLoopColors.muted,
          ),
        ),
        if (action != null) action!,
      ],
    ),
  );
}

String _rupiah(int value) =>
    'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
