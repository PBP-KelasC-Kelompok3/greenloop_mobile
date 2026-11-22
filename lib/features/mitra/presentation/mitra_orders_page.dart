import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/theme/greenloop_theme.dart';
import '../data/mitra_shop_service.dart';

class MitraOrdersPage extends StatefulWidget {
  const MitraOrdersPage({required this.service, super.key});
  final MitraShopService service;
  @override
  State<MitraOrdersPage> createState() => _MitraOrdersPageState();
}

class _MitraOrdersPageState extends State<MitraOrdersPage> {
  List<ShopOrder> _orders = const [];
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
      final orders = await widget.service.orders();
      if (mounted) setState(() => _orders = orders);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshPayment(ShopOrder order) async {
    try {
      await widget.service.refreshPayment(order.id);
      await _load();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _pay(ShopOrder order) async {
    final uri = Uri.tryParse(order.snapUrl);
    if (uri == null || order.snapUrl.isEmpty) {
      await _refreshPayment(order);
      return;
    }
    await launchUrl(
      uri,
      webOnlyWindowName: kIsWeb ? '_blank' : null,
      mode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GreenLoopColors.surface,
    appBar: AppBar(
      title: const Text('Riwayat Pesanan'),
      actions: [
        IconButton(
          onPressed: _loading ? null : _load,
          tooltip: 'Muat ulang',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? ListView(
              children: const [
                SizedBox(height: 230),
                Center(child: CircularProgressIndicator()),
              ],
            )
          : _error != null
          ? ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _Notice(
                  title: 'Riwayat belum dapat dimuat',
                  message: _error!,
                  action: TextButton(
                    onPressed: _load,
                    child: const Text('Coba lagi'),
                  ),
                ),
              ],
            )
          : _orders.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(18),
              children: const [
                _Notice(
                  title: 'Belum ada pesanan',
                  message:
                      'Pesanan yang dibuat dari katalog akan tampil di sini.',
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final order in _orders)
                  _OrderCard(
                    order: order,
                    onRefreshPayment: () => _refreshPayment(order),
                    onPay: () => _pay(order),
                  ),
              ],
            ),
    ),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onRefreshPayment,
    required this.onPay,
  });
  final ShopOrder order;
  final VoidCallback onRefreshPayment;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final status = _status(order.status);
    final isPickup = order.fulfillmentMethod == 'self_pickup';
    final steps = isPickup
        ? const [
            'PAID',
            'PROCESSING',
            'PACKED',
            'READY_FOR_PICKUP',
            'PICKED_UP',
          ]
        : const [
            'PAID',
            'PROCESSING',
            'PACKED',
            'COURIER_BOOKED',
            'SHIPPED',
            'DELIVERED',
          ];
    final current = steps.indexOf(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GreenLoopColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan ${_shortId(order.id)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: GreenLoopColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: status.$2.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.$1,
                  style: TextStyle(
                    color: status.$2,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} × ${item.quantity}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    _rupiah(item.unitPrice * item.quantity),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 20),
          _detail(
            Icons.inventory_2_outlined,
            isPickup
                ? 'Ambil sendiri di pabrik'
                : '${order.courierName} ${order.courierService}'.trim(),
          ),
          if (isPickup && order.pickupDate.isNotEmpty)
            _detail(
              Icons.calendar_month_outlined,
              'Rencana ambil: ${order.pickupDate}',
            ),
          if (isPickup && order.destination.isNotEmpty)
            _detail(Icons.location_on_outlined, order.destination),
          if (!isPickup && order.destination.isNotEmpty)
            _detail(Icons.location_on_outlined, order.destination),
          if (order.trackingNumber.isNotEmpty)
            _detail(
              Icons.local_shipping_outlined,
              'No. resi: ${order.trackingNumber}',
            ),
          if (order.status != 'CANCELLED' && order.paymentStatus == 'PAID') ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 8,
              children: [
                for (var i = 0; i < steps.length; i++)
                  _StepDot(label: _stepLabel(steps[i]), active: current >= i),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total dibayar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                _rupiah(order.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: GreenLoopColors.forest2,
                ),
              ),
            ],
          ),
          if (order.paymentStatus == 'PENDING') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRefreshPayment,
                    child: const Text('Cek pembayaran'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: order.snapUrl.isEmpty ? null : onPay,
                    child: const Text('Bayar sekarang'),
                  ),
                ),
              ],
            ),
          ],
          if (order.status == 'CANCELLED')
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Pembayaran gagal atau kedaluwarsa; stok pesanan sudah dilepas.',
                style: TextStyle(color: GreenLoopColors.muted, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.label, required this.active});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: active ? GreenLoopColors.mint : GreenLoopColors.surface,
      border: Border.all(
        color: active ? GreenLoopColors.forest2 : GreenLoopColors.border,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 9,
        color: active ? GreenLoopColors.forest2 : GreenLoopColors.muted,
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.title, required this.message, this.action});
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: GreenLoopColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.receipt_long_outlined,
          color: GreenLoopColors.forest2,
          size: 35,
        ),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: GreenLoopColors.muted, fontSize: 12),
        ),
        if (action != null) action!,
      ],
    ),
  );
}

Widget _detail(IconData icon, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 15, color: GreenLoopColors.forest2),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(fontSize: 11, color: GreenLoopColors.muted),
        ),
      ),
    ],
  ),
);
String _stepLabel(String value) => switch (value) {
  'PAID' => 'Dibayar',
  'PROCESSING' => 'Diproses',
  'PACKED' => 'Dikemas',
  'READY_FOR_PICKUP' => 'Siap diambil',
  'COURIER_BOOKED' => 'Siap diserahkan',
  'SHIPPED' => 'Dikirim',
  'PICKED_UP' => 'Diambil',
  'DELIVERED' => 'Diterima',
  _ => value,
};
(String, Color) _status(String value) => switch (value) {
  'PENDING' => ('Menunggu bayar', const Color(0xFFB87400)),
  'PAID' => ('Dibayar', GreenLoopColors.forest2),
  'PROCESSING' => ('Diproses', GreenLoopColors.forest2),
  'PACKED' => ('Dikemas', GreenLoopColors.forest2),
  'READY_FOR_PICKUP' => ('Siap diambil', GreenLoopColors.forest2),
  'COURIER_BOOKED' => ('Siap diserahkan', GreenLoopColors.forest2),
  'SHIPPED' => ('Dalam pengiriman', GreenLoopColors.forest2),
  'DELIVERED' => ('Terkirim', GreenLoopColors.forest2),
  'PICKED_UP' => ('Sudah diambil', GreenLoopColors.forest2),
  'CANCELLED' => ('Dibatalkan', Colors.redAccent),
  _ => (value, GreenLoopColors.muted),
};
String _shortId(String value) => value.length > 12
    ? value.substring(0, 12).toUpperCase()
    : value.toUpperCase();
String _formatDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null
      ? value
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _rupiah(int value) =>
    'Rp ${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
