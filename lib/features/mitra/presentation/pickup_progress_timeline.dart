import 'package:flutter/material.dart';

import '../../../shared/theme/greenloop_theme.dart';

/// Shows the pickup lifecycle using the status returned by the Django API.
class PickupProgressTimeline extends StatelessWidget {
  const PickupProgressTimeline({
    required this.status,
    this.courierName,
    super.key,
  });

  final String status;
  final String? courierName;

  static const _steps = ['Diajukan', 'Verifikasi', 'Kurir', 'Dijemput', 'Selesai'];

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    if (normalized == 'REJECTED' || normalized == 'CANCELLED') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEEE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: Color(0xFFC74646)),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                normalized == 'REJECTED'
                    ? 'Pengajuan ditolak admin.'
                    : 'Pengajuan dibatalkan.',
                style: const TextStyle(fontSize: 11, color: Color(0xFFC74646)),
              ),
            ),
          ],
        ),
      );
    }

    final completed = switch (normalized) {
      'APPROVED' => 2,
      'SCHEDULED' => 3,
      'IN_PROGRESS' => 3,
      'COMPLETED' => 5,
      _ => 1,
    };
    final currentLabel = switch (normalized) {
      'PENDING' => 'Menunggu verifikasi foto oleh admin',
      'APPROVED' => courierName == null
          ? 'Disetujui · menunggu kurir tersedia'
          : 'Disetujui · kurir $courierName ditugaskan',
      'SCHEDULED' => courierName == null
          ? 'Kurir sudah ditugaskan'
          : 'Kurir $courierName sudah ditugaskan',
      'IN_PROGRESS' => 'Kurir sedang menuju lokasi penjemputan',
      'COMPLETED' => 'Penjemputan selesai',
      _ => 'Status: $status',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              _ProgressDot(done: i < completed, active: i == completed),
              if (i < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < completed - 1
                        ? GreenLoopColors.forest2
                        : GreenLoopColors.border,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++)
              Expanded(
                child: Text(
                  _steps[i],
                  textAlign: i == 0
                      ? TextAlign.left
                      : i == _steps.length - 1
                          ? TextAlign.right
                          : TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    color: i < completed
                        ? GreenLoopColors.forest2
                        : GreenLoopColors.muted,
                    fontWeight: i < completed ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          currentLabel,
          style: const TextStyle(
            fontSize: 10,
            color: GreenLoopColors.forest2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.done, required this.active});

  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done || active ? GreenLoopColors.forest2 : Colors.white,
          border: Border.all(
            color: done || active ? GreenLoopColors.forest2 : GreenLoopColors.border,
            width: 1.5,
          ),
        ),
        child: done
            ? const Icon(Icons.check, size: 8, color: Colors.white)
            : null,
      );
}
