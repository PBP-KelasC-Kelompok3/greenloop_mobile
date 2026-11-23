import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../auth/services/auth_service.dart';

class AdminPickupItem {
  const AdminPickupItem({
    required this.id,
    required this.mitraName,
    required this.mitraEmail,
    required this.businessName,
    required this.address,
    required this.wasteType,
    required this.wasteTypeLabel,
    required this.estimatedWeight,
    required this.pickupDate,
    required this.timeSlot,
    required this.vehicle,
    required this.notes,
    required this.status,
    required this.statusLabel,
    required this.photoUrl,
    required this.courierName,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String mitraName;
  final String mitraEmail;
  final String businessName;
  final String address;
  final String wasteType;
  final String wasteTypeLabel;
  final double estimatedWeight;
  final DateTime pickupDate;
  final String timeSlot;
  final String vehicle;
  final String notes;
  final String status;
  final String statusLabel;
  final String? photoUrl;
  final String? courierName;
  final double? latitude;
  final double? longitude;

  String get code => 'PK-${id.toString().padLeft(4, '0')}';

  factory AdminPickupItem.fromJson(Map<String, dynamic> json) =>
      AdminPickupItem(
        id: json['id'] as int,
        mitraName: json['mitra_name'] as String? ?? 'Mitra',
        mitraEmail: json['mitra_email'] as String? ?? '',
        businessName: json['business_name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        wasteType: json['waste_type'] as String? ?? '',
        wasteTypeLabel: json['waste_type_label'] as String? ?? 'Limbah',
        estimatedWeight: (json['estimated_weight'] as num).toDouble(),
        pickupDate: DateTime.parse(json['pickup_date'] as String),
        timeSlot: json['pickup_time_slot'] as String? ?? '',
        vehicle: json['armada'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        status: json['status'] as String? ?? 'PENDING',
        statusLabel: json['status_label'] as String? ?? 'Menunggu Verifikasi',
        photoUrl: json['photo_url'] as String?,
        courierName: json['courier_name'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}

class AdminPickupService {
  AdminPickupService(this._authService);

  final AuthService _authService;

  Future<List<AdminPickupItem>> list() async {
    final response = await _authService.apiClient.get('/api/admin/pickups/');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final rows = payload['results'] as List<dynamic>? ?? const [];
      return rows
          .cast<Map<String, dynamic>>()
          .map(AdminPickupItem.fromJson)
          .toList(growable: false);
    }
    throw ApiException.fromResponse(response);
  }

  Future<String> updateStatus(int pickupId, String action) async {
    final response = await _authService.apiClient.post(
      '/api/admin/pickups/$pickupId/review/',
      body: {'action': action},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      return payload['detail'] as String? ?? 'Status pengajuan diperbarui.';
    }
    throw ApiException.fromResponse(response);
  }
}
