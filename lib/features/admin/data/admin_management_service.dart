import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../auth/services/auth_service.dart';

class AdminCourierItem {
  const AdminCourierItem({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.plateNumber,
    required this.vehicleType,
    required this.isApproved,
    required this.isOnDuty,
  });
  final int id;
  final String username;
  final String name;
  final String email;
  final String plateNumber;
  final String vehicleType;
  final bool isApproved;
  final bool isOnDuty;
  factory AdminCourierItem.fromJson(Map<String, dynamic> json) =>
      AdminCourierItem(
        id: _int(json['id']),
        username: '${json['username'] ?? ''}',
        name: '${json['name'] ?? ''}',
        email: '${json['email'] ?? ''}',
        plateNumber: '${json['plate_number'] ?? ''}',
        vehicleType: '${json['vehicle_type'] ?? ''}',
        isApproved: json['is_approved'] == true,
        isOnDuty: json['is_on_duty'] == true,
      );
}

class AdminProduct {
  const AdminProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.weightGrams,
  });
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final int price;
  final int stock;
  final int weightGrams;
  factory AdminProduct.fromJson(Map<String, dynamic> json, String baseUrl) {
    final image = json['image_url'] as String?;
    final uri = image == null ? null : Uri.tryParse(image);
    return AdminProduct(
      id: _int(json['id']),
      name: '${json['name'] ?? ''}',
      description: '${json['description'] ?? ''}',
      imageUrl: image == null
          ? null
          : (uri?.hasScheme == true
                ? image
                : Uri.parse(baseUrl).resolve(image).toString()),
      price: _int(json['price_b2c'] ?? json['price']),
      stock: _int(json['stock']),
      weightGrams: _int(json['weight_grams']),
    );
  }
}

class AdminShopOrder {
  const AdminShopOrder({
    required this.id,
    required this.username,
    required this.buyerName,
    required this.paymentStatus,
    required this.status,
    required this.method,
    required this.amount,
    required this.courierName,
    required this.courierService,
    required this.trackingNumber,
    required this.pickupDate,
    required this.items,
  });
  final String id;
  final String username;
  final String buyerName;
  final String paymentStatus;
  final String status;
  final String method;
  final int amount;
  final String courierName;
  final String courierService;
  final String trackingNumber;
  final String pickupDate;
  final List<String> items;
  factory AdminShopOrder.fromJson(Map<String, dynamic> json) => AdminShopOrder(
    id: '${json['order_id'] ?? ''}',
    username: '${json['username'] ?? ''}',
    buyerName: '${json['buyer_name'] ?? ''}',
    paymentStatus: '${json['payment_status'] ?? ''}',
    status: '${json['status'] ?? ''}',
    method: '${json['fulfillment_method'] ?? 'courier'}',
    amount: _int(json['amount']),
    courierName: '${json['courier_name'] ?? ''}',
    courierService: '${json['courier_service'] ?? ''}',
    trackingNumber: '${json['tracking_number'] ?? ''}',
    pickupDate: '${json['pickup_date'] ?? ''}',
    items: (json['items'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => '${item['name'] ?? ''} × ${item['quantity'] ?? 0}')
        .toList(growable: false),
  );
}

class AdminManagementService {
  AdminManagementService(this._auth);
  final AuthService _auth;
  ApiClient get _api => _auth.apiClient;

  Future<List<AdminCourierItem>> couriers() async {
    final response = await _api.get('/api/admin/couriers/');
    final payload = _decodeMap(response);
    return (payload['results'] as List? ?? const [])
        .whereType<Map>()
        .map((row) => AdminCourierItem.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<String> approveCourier(int id) async {
    final response = await _api.post(
      '/api/admin/couriers/$id/approve/',
      body: const {},
    );
    return _decodeMap(response)['detail'] as String? ?? 'Kurir disetujui.';
  }

  Future<List<AdminProduct>> products() async {
    final response = await _api.get('/katalog/api/products/');
    final payload = _decodeMap(response);
    return (payload['products'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (row) => AdminProduct.fromJson(
            Map<String, dynamic>.from(row),
            _api.baseUrl,
          ),
        )
        .toList(growable: false);
  }

  Future<void> saveProduct({
    int? id,
    required Map<String, String> fields,
    List<int>? imageBytes,
    String? filename,
  }) async {
    final price = fields['price_b2c'] ?? '0';
    final payload = {...fields, 'price_b2b': price};
    final path = id == null
        ? '/katalog/api/products/add/'
        : '/katalog/api/products/edit/$id/';
    final response = imageBytes == null
        ? await _api.postForm(path, fields: payload, requireCsrf: false)
        : await _api.postMultipart(
            path,
            fields: payload,
            fileField: 'image',
            fileBytes: imageBytes,
            filename: filename ?? 'product.jpg',
            requireCsrf: false,
          );
    _decodeMap(response);
  }

  Future<void> deleteProduct(int id) async => _decodeMap(
    await _api.post('/katalog/api/products/delete/$id/', body: const {}),
  );

  Future<List<AdminShopOrder>> orders() async {
    final payload = _decodeMap(await _api.get('/katalog/api/admin/orders/'));
    return (payload['results'] as List? ?? const [])
        .whereType<Map>()
        .map((row) => AdminShopOrder.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<String> updateOrder(
    AdminShopOrder order,
    String status, {
    String? trackingNumber,
  }) async {
    final payload = <String, dynamic>{'status': status};
    if (trackingNumber != null) payload['tracking_number'] = trackingNumber;
    final decoded = _decodeMap(
      await _api.post('/katalog/api/admin/orders/${order.id}/', body: payload),
    );
    return decoded['detail'] as String? ?? 'Status pesanan diperbarui.';
  }

  Map<String, dynamic> _decodeMap(dynamic response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final errors = decoded['errors'];
        if (errors is Map) {
          final messages = <String>[];
          for (final entry in errors.entries) {
            final value = entry.value;
            if (value is List)
              messages.add(
                '${entry.key}: ${value.map((e) => e is Map ? e['message'] : e).join(', ')}',
              );
          }
          if (messages.isNotEmpty)
            throw ApiException(
              statusCode: response.statusCode,
              message: messages.join('\n'),
            );
        }
        throw ApiException(
          statusCode: response.statusCode,
          message:
              '${decoded['detail'] ?? decoded['error'] ?? 'Permintaan Admin gagal.'}',
        );
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      // Fall through to common API error message.
    }
    throw ApiException.fromResponse(response);
  }
}

int _int(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
