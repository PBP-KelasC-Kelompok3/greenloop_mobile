import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../shared/dummy/dummy_data.dart';
import '../../../shared/theme/greenloop_theme.dart';

TextStyle _text(double size, FontWeight weight,
        {Color color = GreenLoopColors.textInk, double height = 1.5}) =>
    GreenLoopTypography.style(size, weight, color: color, height: height);

/// M14 · Lacak Pesanan (Konsumen).
///
/// Data masih dummy ([DummyData.trackedOrder]). [onRefresh] disiapkan untuk
/// memuat ulang status dari API e-commerce.
class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({
    this.order = DummyData.trackedOrder,
    this.onRefresh,
    super.key,
  });

  final DummyTrackedOrder order;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenLoopColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GLScreenHeader(
              title: 'Lacak Pesanan',
              showBack: true,
              trailing: GLIconButton(
                icon: LucideIcons.refreshCw,
                onTap: onRefresh ?? () {},
                tooltip: 'Muat ulang',
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                children: [
                  _SummaryCard(order: order),
                  const SizedBox(height: 12),
                  _TimelineCard(order: order),
                  const SizedBox(height: 12),
                  _PackageCard(lines: order.lines),
                  const SizedBox(height: 12),
                  _ImpactNote(kg: order.wasteSavedKg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

GLTone _toneFor(OrderStatus status) => switch (status) {
      OrderStatus.awaitingPayment => GLTone.amber,
      OrderStatus.paid || OrderStatus.preparing => GLTone.green,
      OrderStatus.shipping => GLTone.blue,
      OrderStatus.delivered => GLTone.green,
      OrderStatus.cancelled => GLTone.red,
    };

IconData _iconFor(OrderStatus status) => switch (status) {
      OrderStatus.awaitingPayment => LucideIcons.clock,
      OrderStatus.paid => LucideIcons.wallet,
      OrderStatus.preparing => LucideIcons.package,
      OrderStatus.shipping => LucideIcons.truck,
      OrderStatus.delivered => LucideIcons.circleCheck,
      OrderStatus.cancelled => LucideIcons.circleX,
    };

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.order});

  final DummyTrackedOrder order;

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(order.status);
    return GLCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pesanan',
                        style: _text(10, FontWeight.w400,
                            color: GreenLoopColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(order.code, style: _text(14, FontWeight.w700)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tone.background,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconFor(order.status),
                        size: 12, color: tone.foreground),
                    const SizedBox(width: 4),
                    Text(order.status.label,
                        style: _text(11, FontWeight.w600,
                            color: tone.foreground, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GreenLoopColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(child: _Fact(label: 'Kurir', value: order.courier)),
                Expanded(
                  child: _Fact(label: 'No. Resi', value: order.trackingNumber),
                ),
                Expanded(
                  child: _Fact(
                    label: 'Pembayaran',
                    value: order.payment,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.alignEnd = false});

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: _text(10, FontWeight.w400, color: GreenLoopColors.textMuted)),
        const SizedBox(height: 2),
        Text(value,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: _text(11, FontWeight.w600)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline status
// ---------------------------------------------------------------------------

enum _StepState { done, current, upcoming }

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.order});

  final DummyTrackedOrder order;

  @override
  Widget build(BuildContext context) {
    final currentIndex =
        order.steps.indexWhere((step) => step.status == order.status);
    return GLCard(
      child: Column(
        children: [
          for (var i = 0; i < order.steps.length; i++)
            _TimelineRow(
              step: order.steps[i],
              state: i < currentIndex
                  ? _StepState.done
                  : i == currentIndex
                      ? _StepState.current
                      : _StepState.upcoming,
              isLast: i == order.steps.length - 1,
              nextReached: i < currentIndex,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.state,
    required this.isLast,
    required this.nextReached,
  });

  final DummyTrackingStep step;
  final _StepState state;
  final bool isLast;

  /// true: garis ke langkah berikutnya hijau (langkah berikut sudah dicapai).
  final bool nextReached;

  @override
  Widget build(BuildContext context) {
    final upcoming = state == _StepState.upcoming;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                _Dot(state: state),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      constraints: const BoxConstraints(minHeight: 26),
                      color: nextReached
                          ? GreenLoopColors.green700
                          : GreenLoopColors.cardBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          step.status.label,
                          style: upcoming
                              ? _text(13, FontWeight.w500,
                                  color: GreenLoopColors.textMuted,
                                  height: 1.3)
                              : _text(13, FontWeight.w600, height: 1.3),
                        ),
                      ),
                      if (state == _StepState.current) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: GreenLoopColors.lime,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text('Terkini',
                              style: _text(9, FontWeight.w600,
                                  color: GreenLoopColors.green900,
                                  height: 1.4)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(step.detail,
                      style: _text(11, FontWeight.w400,
                          color: GreenLoopColors.textMuted, height: 1.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.state});

  final _StepState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      _StepState.done => Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: GreenLoopColors.green700,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.check, size: 12, color: Colors.white),
        ),
      _StepState.current => Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: GreenLoopColors.lime,
            shape: BoxShape.circle,
            border: Border.all(color: GreenLoopColors.green700, width: 2),
          ),
        ),
      _StepState.upcoming => Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: GreenLoopColors.cardBorder, width: 1.5),
          ),
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Isi paket & dampak
// ---------------------------------------------------------------------------

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.lines});

  final List<DummyOrderLine> lines;

  @override
  Widget build(BuildContext context) {
    return GLCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Isi paket', style: _text(13, FontWeight.w700)),
          for (final line in lines) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(line.name, style: _text(11, FontWeight.w500)),
                ),
                const SizedBox(width: 8),
                Text(
                  '${line.quantity} × Rp ${formatThousands(line.price)}',
                  style: _text(11, FontWeight.w400,
                      color: GreenLoopColors.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ImpactNote extends StatelessWidget {
  const _ImpactNote({required this.kg});

  final double kg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GreenLoopColors.green50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GreenLoopColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.leaf, size: 16, color: GreenLoopColors.green700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pesanan ini membantu menyelamatkan ±${formatKg(kg)} limbah '
              'organik dari TPA.',
              style: _text(11, FontWeight.w400,
                  color: GreenLoopColors.green700, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
