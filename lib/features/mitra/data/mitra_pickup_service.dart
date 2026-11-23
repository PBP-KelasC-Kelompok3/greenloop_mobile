import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../auth/services/auth_service.dart';

class MitraPickupItem {
  const MitraPickupItem({
    required this.id,
    required this.wasteType,
    required this.wasteTypeLabel,
    required this.estimatedWeight,
    required this.pickupDate,
    required this.timeSlot,
    required this.vehicle,
    required this.status,
    required this.statusLabel,
    this.notes = '',
  });

  final int id;
  final String wasteType;
  final String wasteTypeLabel;
  final double estimatedWeight;
  final DateTime pickupDate;
  final String timeSlot;
  final String vehicle;
  final String status;
  final String statusLabel;
  final String notes;

  String get code => 'PK-${id.toString().padLeft(4, '0')}';

  factory MitraPickupItem.fromJson(Map<String, dynamic> json) => MitraPickupItem(
        id: json['id'] as int,
        wasteType: json['waste_type'] as String? ?? '',
        wasteTypeLabel: json['waste_type_label'] as String? ?? 'Limbah organik',
        estimatedWeight: (json['estimated_weight'] as num).toDouble(),
        pickupDate: DateTime.parse(json['pickup_date'] as String),
        timeSlot: json['pickup_time_slot'] as String? ?? '',
        vehicle: json['armada'] as String? ?? '',
        status: json['status'] as String? ?? 'PENDING',
        statusLabel: json['status_label'] as String? ?? 'Menunggu Verifikasi',
        notes: json['notes'] as String? ?? '',
      );
}

class MitraPickupService {
  MitraPickupService(this._authService);

  final AuthService _authService;

  Future<MitraPickupItem> create({
    required Map<String, String> fields,
    required List<int> photoBytes,
    required String filename,
  }) async {
    final response = await _authService.apiClient.postMultipart(
      '/api/pickups/',
      fields: fields,
      fileField: 'waste_photo',
      fileBytes: photoBytes,
      filename: filename,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      return MitraPickupItem.fromJson(payload['pickup'] as Map<String, dynamic>);
    }
    throw ApiException.fromResponse(response);
  }

  Future<List<MitraPickupItem>> history() async {
    final response = await _authService.apiClient.get('/api/pickups/');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final items = payload['results'] as List<dynamic>? ?? const [];
      return items
          .cast<Map<String, dynamic>>()
          .map(MitraPickupItem.fromJson)
          .toList(growable: false);
    }
    throw ApiException.fromResponse(response);
  }
}
