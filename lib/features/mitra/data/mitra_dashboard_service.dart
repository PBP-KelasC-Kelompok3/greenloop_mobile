import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../auth/services/auth_service.dart';

class MitraActivePickup {
  const MitraActivePickup({
    required this.id,
    required this.wasteTypeLabel,
    required this.estimatedWeight,
    required this.pickupDate,
    required this.timeSlot,
    required this.vehicle,
    required this.status,
    required this.statusLabel,
    this.courierName,
  });

  final int id;
  final String wasteTypeLabel;
  final double estimatedWeight;
  final DateTime pickupDate;
  final String timeSlot;
  final String vehicle;
  final String status;
  final String statusLabel;
  final String? courierName;

  String get code => 'PK-${id.toString().padLeft(4, '0')}';

  factory MitraActivePickup.fromJson(Map<String, dynamic> json) =>
      MitraActivePickup(
        id: json['id'] as int,
        wasteTypeLabel: json['waste_type_label'] as String? ?? 'Limbah organik',
        estimatedWeight: (json['estimated_weight'] as num? ?? 0).toDouble(),
        pickupDate: DateTime.parse(json['pickup_date'] as String),
        timeSlot: json['pickup_time_slot'] as String? ?? '',
        vehicle: json['armada'] as String? ?? '',
        status: json['status'] as String? ?? 'PENDING',
        statusLabel: json['status_label'] as String? ?? 'Menunggu Verifikasi',
        courierName: json['courier_name'] as String?,
      );
}

class MitraDashboardSummary {
  const MitraDashboardSummary({
    required this.points,
    required this.currentTier,
    required this.nextTier,
    required this.targetPoints,
    required this.levelProgress,
    required this.totalWasteKg,
    required this.co2SavedKg,
    required this.completedPickups,
    this.activePickup,
  });

  final int points;
  final String currentTier;
  final String nextTier;
  final int targetPoints;
  final int levelProgress;
  final double totalWasteKg;
  final double co2SavedKg;
  final int completedPickups;
  final MitraActivePickup? activePickup;

  factory MitraDashboardSummary.fromJson(Map<String, dynamic> json) {
    final pickupJson = json['active_pickup'];
    return MitraDashboardSummary(
      points: json['points'] as int? ?? 0,
      currentTier: json['current_tier'] as String? ?? 'Bronze',
      nextTier: json['next_tier'] as String? ?? 'Silver',
      targetPoints: json['target_points'] as int? ?? 1000,
      levelProgress: json['level_progress_pct'] as int? ?? 0,
      totalWasteKg: (json['total_waste_kg'] as num? ?? 0).toDouble(),
      co2SavedKg: (json['co2_saved_kg'] as num? ?? 0).toDouble(),
      completedPickups: json['completed_pickups'] as int? ?? 0,
      activePickup: pickupJson is Map<String, dynamic>
          ? MitraActivePickup.fromJson(pickupJson)
          : null,
    );
  }
}

class MitraDashboardService {
  MitraDashboardService(this._authService);

  final AuthService _authService;

  Future<MitraDashboardSummary> fetch() async {
    final response = await _authService.apiClient.get('/api/mitra/dashboard/');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return MitraDashboardSummary.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw ApiException.fromResponse(response);
  }
}
