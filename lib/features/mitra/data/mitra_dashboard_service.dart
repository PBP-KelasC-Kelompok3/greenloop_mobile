import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../auth/services/auth_service.dart';

/// Dashboard data returned by the authenticated Mitra dashboard endpoint.
class MitraDashboardSummary {
  const MitraDashboardSummary({
    required this.points,
    required this.currentTier,
    required this.nextTier,
    required this.levelProgress,
    required this.targetPoints,
    required this.totalWasteKg,
    required this.co2SavedKg,
    required this.completedPickups,
    required this.activePickup,
  });

  final int points;
  final String currentTier;
  final String nextTier;
  final int levelProgress;
  final int targetPoints;
  final double totalWasteKg;
  final double co2SavedKg;
  final int completedPickups;
  final MitraActivePickup? activePickup;

  factory MitraDashboardSummary.fromJson(Map<String, dynamic> json) {
    final active = json['active_pickup'];
    return MitraDashboardSummary(
      points: _int(json['points'] ?? json['waste_points']),
      currentTier: '${json['current_tier'] ?? json['level'] ?? 'Bronze'}',
      nextTier: '${json['next_tier'] ?? 'Silver'}',
      levelProgress: _int(json['level_progress']),
      targetPoints: _int(json['target_points']),
      totalWasteKg: _double(json['total_waste_kg'] ?? json['total_waste']),
      co2SavedKg: _double(json['co2_saved_kg'] ?? json['co2_saved']),
      completedPickups: _int(json['completed_pickups']),
      activePickup: active is Map
          ? MitraActivePickup.fromJson(Map<String, dynamic>.from(active))
          : null,
    );
  }
}

class MitraActivePickup {
  const MitraActivePickup({
    required this.id,
    required this.wasteTypeLabel,
    required this.estimatedWeight,
    required this.pickupDate,
    required this.timeSlot,
    required this.status,
    required this.statusLabel,
    this.courierName,
  });

  final int id;
  final String wasteTypeLabel;
  final double estimatedWeight;
  final DateTime pickupDate;
  final String timeSlot;
  final String status;
  final String statusLabel;
  final String? courierName;

  String get code => 'PK-${id.toString().padLeft(4, '0')}';

  factory MitraActivePickup.fromJson(Map<String, dynamic> json) =>
      MitraActivePickup(
        id: _int(json['id']),
        wasteTypeLabel:
            '${json['waste_type_label'] ?? json['waste_type'] ?? 'Limbah organik'}',
        estimatedWeight:
            _double(json['estimated_weight'] ?? json['estimated_weight_kg']),
        pickupDate: DateTime.tryParse('${json['pickup_date'] ?? ''}') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        timeSlot: '${json['pickup_time_slot'] ?? json['time_slot'] ?? ''}',
        status: '${json['status'] ?? ''}',
        statusLabel: '${json['status_label'] ?? json['status'] ?? ''}',
        courierName: json['courier_name'] as String?,
      );
}

class MitraDashboardService {
  MitraDashboardService(AuthService authService)
      : _api = authService.apiClient;

  final ApiClient _api;

  Future<MitraDashboardSummary> fetch() async {
    final response = await _api.get('/api/mitra/dashboard/');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Format data dashboard mitra tidak valid.');
    }
    final payload = Map<String, dynamic>.from(decoded);
    final summary = payload['summary'];
    return MitraDashboardSummary.fromJson(
      summary is Map ? Map<String, dynamic>.from(summary) : payload,
    );
  }
}

int _int(dynamic value) =>
    value is num ? value.round() : int.tryParse('$value') ?? 0;

double _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
