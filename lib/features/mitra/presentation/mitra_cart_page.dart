import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../data/mitra_shop_service.dart';
import 'mitra_checkout_page.dart';

class MitraCartPage extends StatefulWidget {
  const MitraCartPage({required this.service, super.key});
  final MitraShopService service;
  @override
  State<MitraCartPage> createState() => _MitraCartPageState();
}

class _MitraCartPageState extends State<MitraCartPage> {
  ShopCart? _cart;
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cart = await widget.service.cart();
      if (mounted) setState(() => _cart = cart);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _change(ShopCartLine line, int quantity) async {
    try {
      if (quantity < 1) {
        await widget.service.remove(line.id);
      } else {
        await widget.service.updateQuantity(line.id, quantity);
      }
      await _load();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(title: const Text('Keranjang')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? _notice('Keranjang belum dapat dimuat', _error!, onRetry: _load)
        : _cart!.items.isEmpty
        ? _notice(
            'Keranjang masih kosong',
            'Pilih produk dari katalog Admin untuk mulai membuat pesanan.',
          )
        : Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final line in _cart!.items)
                      _CartLine(
                        line: line,
                        onMinus: () => _change(line, line.quantity - 1),
                        onPlus: () => _change(line, line.quantity + 1),
                        onRemove: () => _change(line, 0),
                      ),
                    const SizedBox(height: 8),
                    _summaryRow('Subtotal produk', _rupiah(_cart!.subtotal)),
                    const SizedBox(height: 4),
                    const Text(
                      'Ongkir dihitung setelah alamat tujuan dipilih. Harga dan stok mengikuti katalog Admin.',
                      style: TextStyle(
                        fontSize: 12,
                        color: GreenLoopColors.muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: GreenLoopColors.border),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MitraCheckoutPage(
                              service: widget.service,
                              cart: _cart!,
                            ),
                          ),
                        );
                        if (changed == true && mounted) {
                          await _load();
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pesanan dibuat. Kamu bisa melihat status dan pembayaran di Riwayat Pesanan.',
                                ),
                              ),
                            );
                        }
                      },
                      child: const Text('Lanjut ke pengiriman'),
                    ),
                  ),
                ),
              ),
            ],
          ),
  );
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.line,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
  });
  final ShopCartLine line;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: line.imageUrl == null
              ? Container(
                  width: 62,
                  height: 62,
                  color: GreenLoopColors.mint,
                  child: const Icon(
                    Icons.soap_outlined,
                    color: GreenLoopColors.forest2,
                  ),
                )
              : Image.network(
                  line.imageUrl!,
                  width: 62,
                  height: 62,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 62,
                    height: 62,
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
                line.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                _rupiah(line.unitPrice),
                style: const TextStyle(
                  fontSize: 13,
                  color: GreenLoopColors.forest2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onMinus,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '${line.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: line.quantity >= line.stock ? null : onPlus,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Hapus',
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _notice(
  String title,
  String message, {
  Future<void> Function()? onRetry,
}) => Center(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GreenLoopColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 36,
            color: GreenLoopColors.forest2,
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: GreenLoopColors.muted, fontSize: 12),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    ),
  ),
);
Widget _summaryRow(String label, String amount) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  ),
);
String _rupiah(int value) =>
    'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
