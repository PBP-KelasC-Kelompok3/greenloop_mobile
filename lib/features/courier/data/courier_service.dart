import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';

/// Data access for courier routes. The plan and pickup records are always read
/// from Django; this service does not create demo route stops.
class CourierService {
  CourierService(this._api);

  final ApiClient _api;

  Future<CourierPlan> fetchPlan({double? latitude, double? longitude}) async {
    final query = <String, String>{};
    if (latitude != null && longitude != null) {
      query['lat'] = latitude.toString();
      query['lng'] = longitude.toString();
    }
    final path = Uri(
      path: '/courier/route/data/',
      queryParameters: query.isEmpty ? null : query,
    ).toString();
    final response = await _api.get(path);
    return _planFromResponse(response);
  }

  Future<CourierPlan> setDuty(bool onDuty) async {
    final response = await _api.postForm(
      '/courier/duty/',
      fields: {'on_duty': onDuty ? 'true' : 'false'},
    );
    _decode(response);
    return fetchPlan();
  }

  Future<CourierPlan> startPickup(int id) async {
    final response = await _api.postForm(
      '/courier/route/$id/start/',
      fields: const {},
    );
    return _planFromResponse(response);
  }

  Future<CourierPlan> finishPickup({
    required int id,
    required String weightKg,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _api.postForm(
      '/courier/route/$id/finish/',
      fields: {
        'weight_kg': weightKg,
        'lat': latitude.toString(),
        'lng': longitude.toString(),
      },
    );
    return _planFromResponse(response);
  }

  CourierPlan _planFromResponse(http.Response response) {
    final body = _decode(response);
    final payload = body['plan'];
    if (payload is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 502,
        message: 'Server tidak mengirim data rute Kurir yang valid.',
      );
    }
    return CourierPlan.fromJson(payload);
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> &&
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['ok'] != false) {
        return decoded;
      }
      if (decoded is Map<String, dynamic>) {
        final errors = decoded['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            throw ApiException(
              statusCode: response.statusCode,
              message: '${first.first}',
            );
          }
        }
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      // Let the common API exception choose a status-specific fallback.
    }
    throw ApiException.fromResponse(response);
  }
}

class CourierPlan {
  const CourierPlan({
    required this.stops,
    required this.isOnDuty,
    required this.isApproved,
    required this.plateNumber,
    required this.vehicleType,
  });

  final List<CourierStop> stops;
  final bool isOnDuty;
  final bool isApproved;
  final String plateNumber;
  final String vehicleType;

  factory CourierPlan.fromJson(Map<String, dynamic> json) {
    final courier = json['courier'] is Map<String, dynamic>
        ? json['courier'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final rawStops = json['stops'] as List? ?? const [];
    return CourierPlan(
      stops: rawStops
          .whereType<Map>()
          .map((item) => CourierStop.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      isOnDuty: courier['isOnDuty'] as bool? ?? false,
      isApproved: courier['isApproved'] as bool? ?? false,
      plateNumber: courier['plateNumber'] as String? ?? '',
      vehicleType: courier['vehicleType'] as String? ?? '',
    );
  }
}

class CourierStop {
  const CourierStop({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.slot,
    required this.estimatedKg,
    required this.actualKg,
    required this.vehicle,
    required this.status,
    required this.photoNote,
  });

  final int id;
  final String code;
  final String name;
  final String address;
  final String slot;
  final double estimatedKg;
  final double? actualKg;
  final String vehicle;
  final String status;
  final String photoNote;

  bool get isDone => status == 'done';
  bool get isActive => status == 'active';

  factory CourierStop.fromJson(Map<String, dynamic> json) => CourierStop(
    id: _asInt(json['id']),
    code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    address: json['address'] as String? ?? '',
    slot: json['slot'] as String? ?? '',
    estimatedKg: _asDouble(json['estKg']),
    actualKg: json['actualKg'] == null ? null : _asDouble(json['actualKg']),
    vehicle: json['vehicle'] as String? ?? '',
    status: json['status'] as String? ?? 'next',
    photoNote: json['photoNote'] as String? ?? '',
  );
}

int _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
