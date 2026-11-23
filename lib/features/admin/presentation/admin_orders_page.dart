import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../data/admin_dummy.dart';
import 'admin_widgets.dart';

/// M34 · Kelola Pesanan (tab Pesanan Admin).
///
/// Admin memajukan status pesanan yang sudah dibayar: Dibayar → Sedang
/// Disiapkan → Dalam Pengiriman (wajib isi nomor resi) → Terkirim.
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({this.orders = AdminDummy.orders, super.key});

  final List<AdminOrder> orders;

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

/// Filter chip → status yang ditampilkan (null = semua).
const _filters = <AdminOrderStatus?>[
  null,
  AdminOrderStatus.paid,
  AdminOrderStatus.preparing,
  AdminOrderStatus.shipping,
  AdminOrderStatus.delivered,
];

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late final List<AdminOrder> _orders = [...widget.orders];
  int _filterIndex = 0;

  void _advance(AdminOrder order, {String? trackingNumber}) {
    final next = switch (order.status) {
      AdminOrderStatus.paid => AdminOrderStatus.preparing,
      AdminOrderStatus.preparing => AdminOrderStatus.shipping,
      AdminOrderStatus.shipping => AdminOrderStatus.delivered,
      _ => order.status,
    };
    setState(() {
      final i = _orders.indexOf(order);
      _orders[i] = order.copyWith(status: next, trackingNumber: trackingNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final paidCount =
        _orders.where((o) => o.status == AdminOrderStatus.paid).length;
    final filter = _filters[_filterIndex];
    final shown = filter == null
        ? _orders
        : _orders.where((o) => o.status == filter).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GLScreenHeader(
          title: 'Pesanan',
          subtitle: 'Pantau pembayaran & perbarui pengiriman',
        ),
        GLFilterChips(
          dense: true,
          labels: [
            'Semua',
            paidCount > 0 ? 'Dibayar $paidCount' : 'Dibayar',
            'Disiapkan',
            'Dikirim',
            'Terkirim',
          ],
          selectedIndex: _filterIndex,
          onSelected: (i) => setState(() => _filterIndex = i),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: shown.isEmpty
              ? Center(
                  child: Text('Tidak ada pesanan di status ini.',
                      style: adminText(12, FontWeight.w400,
                          color: GreenLoopColors.textMuted)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  itemCount: shown.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _OrderCard(
                    key: ValueKey(shown[i].code),
                    order: shown[i],
                    onAdvance: (resi) =>
                        _advance(shown[i], trackingNumber: resi),
                  ),
                ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order, required this.onAdvance, super.key});

  final AdminOrder order;
  final ValueChanged<String?> onAdvance;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  final _resi = TextEditingController();

  @override
  void dispose() {
    _resi.dispose();
    super.dispose();
  }

  Widget _statusBadge(AdminOrderStatus status) => switch (status) {
        AdminOrderStatus.paid =>
          SolidBadge(label: status.label, color: GreenLoopColors.blue),
        AdminOrderStatus.awaitingPayment =>
          SolidBadge(label: status.label, color: GreenLoopColors.amber),
        AdminOrderStatus.shipping => _SoftBadge(
            label: status.label,
            background: GreenLoopColors.blue100,
            foreground: GreenLoopColors.blue),
        _ => _SoftBadge(label: status.label),
      };

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: adminCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.code, style: adminText(13, FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${order.customer} · ${order.customerType}',
                        style: adminText(10, FontWeight.w400,
                            color: GreenLoopColors.textMuted)),
                  ],
                ),
              ),
              _statusBadge(order.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text('${order.itemCount} item · ${order.courier}',
                    style: adminText(11, FontWeight.w400)),
              ),
              Text(rupiahSpaced(order.total),
                  style: adminText(12, FontWeight.w700,
                      color: GreenLoopColors.green900)),
              const SizedBox(width: 6),
              order.isPaid
                  ? const TinyBadge(label: 'Lunas')
                  : const TinyBadge(
                      label: 'Menunggu',
                      background: GreenLoopColors.background,
                      foreground: GreenLoopColors.textMuted),
            ],
          ),
          ..._action(order),
        ],
      ),
    );
  }

  List<Widget> _action(AdminOrder order) {
    switch (order.status) {
      case AdminOrderStatus.awaitingPayment:
        return [
          const SizedBox(height: 10),
          Text('Menunggu konsumen membayar via Midtrans.',
              style: adminText(10, FontWeight.w400,
                  color: GreenLoopColors.textMuted)),
        ];
      case AdminOrderStatus.paid:
        return [
          const SizedBox(height: 10),
          _AdvanceButton(
            label: 'Lanjut ke Sedang Disiapkan',
            onTap: () => widget.onAdvance(null),
          ),
        ];
      case AdminOrderStatus.preparing:
        return [
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: TextField(
              controller: _resi,
              style: adminText(13, FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'No. resi',
                hintStyle: adminText(13, FontWeight.w400,
                    color: GreenLoopColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _AdvanceButton(
            label: 'Lanjut ke Dalam Pengiriman',
            onTap: () {
              final resi = _resi.text.trim();
              if (resi.isEmpty) {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  const SnackBar(
                      content: Text('Isi nomor resi sebelum mengirim.')),
                );
                return;
              }
              widget.onAdvance(resi);
            },
          ),
        ];
      case AdminOrderStatus.shipping:
        return [
          const SizedBox(height: 10),
          Text('Resi ${order.trackingNumber ?? '-'}',
              style: adminText(10, FontWeight.w400,
                  color: GreenLoopColors.textMuted)),
          const SizedBox(height: 10),
          _AdvanceButton(
            label: 'Tandai Terkirim',
            onTap: () => widget.onAdvance(null),
          ),
        ];
      case AdminOrderStatus.delivered:
        return const [];
    }
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({
    required this.label,
    this.background = GreenLoopColors.green100,
    this.foreground = GreenLoopColors.green700,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label,
          style: adminText(10, FontWeight.w600, color: foreground, height: 1.2)),
    );
  }
}

class _AdvanceButton extends StatelessWidget {
  const _AdvanceButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GreenLoopColors.green700,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: adminText(12, FontWeight.w600,
                        color: Colors.white, height: 1.3)),
              ),
              const SizedBox(width: 6),
              const Icon(LucideIcons.arrowRight, size: 14, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
