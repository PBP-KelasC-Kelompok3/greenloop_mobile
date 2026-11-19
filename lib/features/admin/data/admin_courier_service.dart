import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../auth/services/auth_service.dart';

class AdminCourierItem {
  const AdminCourierItem({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.plateNumber,
    required this.vehicleType,
    required this.isApproved,
    required this.isOnDuty,
  });

  final int id;
  final String username;
  final String fullName;
  final String email;
  final String plateNumber;
  final String vehicleType;
  final bool isApproved;
  final bool isOnDuty;

  factory AdminCourierItem.fromJson(Map<String, dynamic> json) =>
      AdminCourierItem(
        id: json['id'] as int,
        username: json['username'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        plateNumber: json['plate_number'] as String? ?? '',
        vehicleType: json['vehicle_type_label'] as String? ?? '',
        isApproved: json['is_approved'] as bool? ?? false,
        isOnDuty: json['is_on_duty'] as bool? ?? false,
      );
}

class AdminCourierService {
  AdminCourierService(this._authService);

  final AuthService _authService;

  Future<List<AdminCourierItem>> list() async {
    final response = await _authService.apiClient.get('/api/admin/couriers/');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final rows = payload['results'] as List<dynamic>? ?? const [];
      return rows
          .cast<Map<String, dynamic>>()
          .map(AdminCourierItem.fromJson)
          .toList(growable: false);
    }
    throw ApiException.fromResponse(response);
  }

  Future<String> approve(int courierId) async {
    final response = await _authService.apiClient.post(
      '/api/admin/couriers/$courierId/approve/',
      body: const <String, dynamic>{},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      return payload['detail'] as String? ?? 'Akun kurir disetujui.';
    }
    throw ApiException.fromResponse(response);
  }
}
