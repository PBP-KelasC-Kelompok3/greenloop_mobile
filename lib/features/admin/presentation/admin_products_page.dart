import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../core/widgets/greenloop_widgets.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../data/admin_dummy.dart';
import 'admin_widgets.dart';

/// Hasil dari form produk (M33).
sealed class ProductFormResult {
  const ProductFormResult();
}

class ProductSaved extends ProductFormResult {
  const ProductSaved(this.product);

  final AdminProduct product;
}

class ProductDeleted extends ProductFormResult {
  const ProductDeleted();
}

/// M32 · Kelola Produk (tab Produk Admin).
class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({
    this.products = AdminDummy.products,
    this.onPreview,
    super.key,
  });

  final List<AdminProduct> products;

  /// Membuka katalog seperti yang dilihat konsumen.
  final VoidCallback? onPreview;

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  late final List<AdminProduct> _products = [...widget.products];
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openForm([AdminProduct? product]) async {
    final result = await Navigator.of(context).push<ProductFormResult>(
      MaterialPageRoute(builder: (_) => AdminProductFormPage(product: product)),
    );
    if (result == null || !mounted) return;
    setState(() {
      switch (result) {
        case ProductSaved(product: final saved):
          final i = product == null ? -1 : _products.indexOf(product);
          if (i >= 0) {
            _products[i] = saved;
          } else {
            _products.insert(0, saved);
          }
        case ProductDeleted():
          if (product != null) _products.remove(product);
      }
    });
  }

  Future<void> _confirmDelete(AdminProduct product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('${product.name} akan dihapus dari katalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: GreenLoopColors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) setState(() => _products.remove(product));
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final shown = query.isEmpty
        ? _products
        : _products.where((p) => p.name.toLowerCase().contains(query)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GLScreenHeader(
          title: 'Katalog Produk',
          subtitle: '${_products.length} produk · tambah, ubah, hapus',
          trailing: AdminSolidIconButton(
            icon: LucideIcons.plus,
            tooltip: 'Tambah produk',
            onTap: () => _openForm(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: AdminSearchField(
                  controller: _search,
                  hint: 'Cari produk...',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: GreenLoopColors.green100,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onPreview,
                  child: SizedBox(
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.eye,
                              size: 16, color: GreenLoopColors.green700),
                          const SizedBox(width: 6),
                          Text('Preview',
                              style: adminText(12, FontWeight.w600,
                                  color: GreenLoopColors.green700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            itemCount: shown.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _ProductRow(
              product: shown[i],
              onEdit: () => _openForm(shown[i]),
              onDelete: () => _confirmDelete(shown[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: adminCardDecoration(),
      child: Row(
        children: [
          ProductThumb(tint: product.tint),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    overflow: TextOverflow.ellipsis,
                    style: adminText(12, FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'B2C ${rupiahSpaced(product.priceB2c)} · '
                  'B2B ${rupiahSpaced(product.priceB2b)}',
                  style: adminText(10, FontWeight.w500,
                      color: GreenLoopColors.green700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok ${product.stock} · ${thousands(product.weightGrams)} g',
                  style: adminText(10, FontWeight.w400,
                      color: GreenLoopColors.textMuted),
                ),
              ],
            ),
          ),
          AdminSmallIconButton(
            icon: LucideIcons.pencil,
            tooltip: 'Ubah',
            onTap: onEdit,
          ),
          const SizedBox(width: 2),
          AdminSmallIconButton(
            icon: LucideIcons.trash2,
            tooltip: 'Hapus',
            color: GreenLoopColors.red,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

/// M33 · Ubah Produk (juga dipakai untuk tambah produk baru).
class AdminProductFormPage extends StatefulWidget {
  const AdminProductFormPage({this.product, super.key});

  /// null = tambah produk baru.
  final AdminProduct? product;

  @override
  State<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage> {
  late final AdminProduct? _p = widget.product;
  late final _name = TextEditingController(text: _p?.name);
  late final _description = TextEditingController(text: _p?.description);
  late final _priceB2c =
      TextEditingController(text: _p == null ? '' : thousands(_p.priceB2c));
  late final _priceB2b =
      TextEditingController(text: _p == null ? '' : thousands(_p.priceB2b));
  late final _stock = TextEditingController(text: _p?.stock.toString());
  late final _weight = TextEditingController(text: _p?.weightGrams.toString());

  @override
  void dispose() {
    for (final c in [_name, _description, _priceB2c, _priceB2b, _stock, _weight]) {
      c.dispose();
    }
    super.dispose();
  }

  int _number(TextEditingController c) =>
      int.tryParse(c.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  void _save() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama produk wajib diisi.')),
      );
      return;
    }
    final base = _p ??
        const AdminProduct(
          name: '',
          description: '',
          priceB2c: 0,
          priceB2b: 0,
          stock: 0,
          weightGrams: 0,
        );
    Navigator.of(context).pop(ProductSaved(base.copyWith(
      name: _name.text.trim(),
      description: _description.text.trim(),
      priceB2c: _number(_priceB2c),
      priceB2b: _number(_priceB2b),
      stock: _number(_stock),
      weightGrams: _number(_weight),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final editing = _p != null;
    return Scaffold(
      backgroundColor: GreenLoopColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GLScreenHeader(
              title: editing ? 'Ubah Produk' : 'Tambah Produk',
              subtitle: editing ? _p.name : 'Produk baru di katalog',
              showBack: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  Row(
                    children: [
                      ProductThumb(
                          tint: _p?.tint ?? ProductTint.green, size: 84),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Foto Produk',
                                style: adminText(13, FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text('JPG/PNG, maks. 2 MB',
                                style: adminText(11, FontWeight.w400,
                                    color: GreenLoopColors.textMuted)),
                            const SizedBox(height: 6),
                            Material(
                              color: GreenLoopColors.green100,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.upload,
                                          size: 14,
                                          color: GreenLoopColors.green700),
                                      const SizedBox(width: 6),
                                      Text('Ganti Foto',
                                          style: adminText(12, FontWeight.w600,
                                              color: GreenLoopColors.green700,
                                              height: 1.3)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AdminFormField(label: 'Nama Produk', controller: _name),
                  const SizedBox(height: 12),
                  AdminFormField(
                    label: 'Deskripsi',
                    controller: _description,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AdminFormField(
                          label: 'Harga B2C (Rp)',
                          controller: _priceB2c,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AdminFormField(
                          label: 'Harga B2B (Rp)',
                          controller: _priceB2b,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AdminFormField(
                          label: 'Stok',
                          controller: _stock,
                          icon: LucideIcons.package,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AdminFormField(
                          label: 'Berat (gram)',
                          controller: _weight,
                          icon: LucideIcons.scale,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Berat dipakai untuk hitung ongkir RajaOngkir.',
                      style: adminText(11, FontWeight.w400,
                          color: GreenLoopColors.textMuted)),
                ],
              ),
            ),
            GLBottomActionBar(
              child: Row(
                children: [
                  if (editing) ...[
                    SizedBox(
                      width: 108,
                      height: 52,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pop(const ProductDeleted()),
                        style: FilledButton.styleFrom(
                          backgroundColor: GreenLoopColors.red100,
                          foregroundColor: GreenLoopColors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Hapus',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: GreenLoopButton(
                      label: 'Simpan Produk',
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
