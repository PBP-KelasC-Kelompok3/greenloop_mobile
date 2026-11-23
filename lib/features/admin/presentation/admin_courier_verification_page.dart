import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/widgets/gl_components.dart';
import '../../../shared/theme/greenloop_theme.dart';
import '../data/admin_dummy.dart';
import 'admin_widgets.dart';

/// M21 · Admin Verifikasi Kurir (tab Kurir).
class AdminCourierVerificationPage extends StatefulWidget {
  const AdminCourierVerificationPage({
    this.applicants = AdminDummy.applicants,
    this.onBack,
    super.key,
  });

  final List<CourierApplicant> applicants;
  final VoidCallback? onBack;

  @override
  State<AdminCourierVerificationPage> createState() =>
      _AdminCourierVerificationPageState();
}

class _AdminCourierVerificationPageState
    extends State<AdminCourierVerificationPage> {
  late final List<CourierApplicant> _applicants = [...widget.applicants];
  ApplicantStatus _filter = ApplicantStatus.waiting;

  int get _waitingCount =>
      _applicants.where((a) => a.status == ApplicantStatus.waiting).length;

  void _decide(CourierApplicant applicant, ApplicantStatus status) {
    setState(() {
      final i = _applicants.indexOf(applicant);
      _applicants[i] = applicant.copyWith(status: status);
    });
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text(status == ApplicantStatus.approved
          ? '${applicant.name} disetujui sebagai kurir.'
          : 'Pendaftaran ${applicant.name} ditolak.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final shown = _applicants.where((a) => a.status == _filter).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GLScreenHeader(
          title: 'Verifikasi Kurir',
          subtitle: 'Admin · $_waitingCount pendaftar baru',
          showBack: widget.onBack != null,
          onBack: widget.onBack,
        ),
        GLFilterChips(
          dense: true,
          labels: ['Menunggu ($_waitingCount)', 'Disetujui', 'Ditolak'],
          selectedIndex: ApplicantStatus.values.indexOf(_filter),
          onSelected: (i) =>
              setState(() => _filter = ApplicantStatus.values[i]),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada kurir di daftar ini.',
                    textAlign: TextAlign.center,
                    style: adminText(12, FontWeight.w400,
                        color: GreenLoopColors.textMuted),
                  ),
                ),
              for (final applicant in shown) ...[
                _ApplicantCard(
                  applicant: applicant,
                  onApprove: () => _decide(applicant, ApplicantStatus.approved),
                  onReject: () => _decide(applicant, ApplicantStatus.rejected),
                ),
                const SizedBox(height: 14),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GreenLoopColors.green100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.shieldCheck,
                        size: 18, color: GreenLoopColors.green700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Kurir yang disetujui bisa langsung login dan '
                        'mengaktifkan status bertugas.',
                        style: adminText(12, FontWeight.w400,
                            color: GreenLoopColors.green700, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({
    required this.applicant,
    required this.onApprove,
    required this.onReject,
  });

  final CourierApplicant applicant;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (applicant.status) {
      ApplicantStatus.waiting => ('Menunggu', GreenLoopColors.amber),
      ApplicantStatus.approved => ('Disetujui', GreenLoopColors.green700),
      ApplicantStatus.rejected => ('Ditolak', GreenLoopColors.red),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: adminCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GLAvatar(initials: applicant.initials, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applicant.name, style: adminText(14, FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Daftar ${applicant.registeredAt}',
                        style: adminText(11, FontWeight.w400,
                            color: GreenLoopColors.textMuted)),
                  ],
                ),
              ),
              SolidBadge(
                  label: label, color: color, horizontal: 10, vertical: 4),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
              height: 1, thickness: 1, color: GreenLoopColors.cardBorder),
          const SizedBox(height: 12),
          AdminInfoRow(label: 'No. Plat', value: applicant.plateNumber),
          const SizedBox(height: 12),
          AdminInfoRow(label: 'Jenis Kendaraan', value: applicant.vehicleType),
          if (applicant.status == ApplicantStatus.waiting) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DecisionButton(
                    label: 'Tolak',
                    icon: LucideIcons.x,
                    danger: true,
                    onTap: onReject,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DecisionButton(
                    label: 'Setujui',
                    icon: LucideIcons.check,
                    onTap: onApprove,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? GreenLoopColors.red : Colors.white;
    return Material(
      color: danger ? Colors.white : GreenLoopColors.green700,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: danger
            ? const BorderSide(color: GreenLoopColors.red)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(label,
                  style: adminText(13, FontWeight.w600, color: fg, height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}
