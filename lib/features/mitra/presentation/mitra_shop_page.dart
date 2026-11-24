import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../../auth/services/auth_service.dart';
import '../data/mitra_shop_service.dart';

/// Mitra catalog keeps its existing Mitra cart and checkout flow.
class MitraShopPage extends StatefulWidget {
  const MitraShopPage({this.authService, super.key});
  final AuthService? authService;
  @override
  State<MitraShopPage> createState() => _MitraShopPageState();
}

class _MitraShopPageState extends State<MitraShopPage> {
  late final _service = MitraShopService(widget.authService ?? defaultAuthService);
  List<ShopProduct> _products = const [];
  int _cartCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final products = await _service.products();
      final cart = await _service.cart();
      if (mounted) setState(() { _products = products; _cartCount = cart.count; });
    } catch (e) { if (mounted) setState(() => _error = '$e'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _add(ShopProduct product) async {
    try { await _service.add(product.id); if (mounted) { setState(() => _cartCount++); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} ditambahkan'))); } }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(title: const Text('Belanja Produk'), actions: [
      IconButton(
        tooltip: 'Keranjang',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Keranjang Mitra'),
            content: Text(
              _cartCount == 0
                  ? 'Keranjang masih kosong.'
                  : 'Ada $_cartCount item di keranjang. Halaman keranjang belum tersedia di kode lokal ini.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
        icon: Badge(label: Text('$_cartCount'), child: const Icon(Icons.shopping_cart_outlined)),
      ),
    ]),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : _error != null ? _notice('Katalog belum dapat dimuat', _error!, _load)
      : _products.isEmpty ? _notice('Katalog belum tersedia', 'Produk yang diterbitkan Admin akan tampil di sini.', null)
      : RefreshIndicator(onRefresh: _load, child: GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .76, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: _products.length,
          itemBuilder: (_, index) {
            final product = _products[index];
            return Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GreenLoopColors.border), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Center(child: product.imageUrl == null ? const Icon(Icons.eco_outlined, size: 42, color: GreenLoopColors.forest2) : Image.network(product.imageUrl!, errorBuilder: (_, __, ___) => const Icon(Icons.eco_outlined, size: 42, color: GreenLoopColors.forest2)))),
              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              Text('Rp ${product.price}', style: const TextStyle(fontWeight: FontWeight.w700, color: GreenLoopColors.forest2)),
              Row(children: [Expanded(child: Text('Stok ${product.stock}', style: const TextStyle(fontSize: 10, color: GreenLoopColors.muted))), IconButton(onPressed: product.stock > 0 ? () => _add(product) : null, icon: const Icon(Icons.add_circle, color: GreenLoopColors.forest2))]),
            ]));
          },
        )),
  );
}

Widget _notice(String title, String message, VoidCallback? retry) => Center(child: Container(margin: const EdgeInsets.all(18), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GreenLoopColors.border), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.storefront_outlined, size: 38, color: GreenLoopColors.forest2), const SizedBox(height: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: GreenLoopColors.muted, fontSize: 12)), if (retry != null) TextButton(onPressed: retry, child: const Text('Coba lagi'))])));
