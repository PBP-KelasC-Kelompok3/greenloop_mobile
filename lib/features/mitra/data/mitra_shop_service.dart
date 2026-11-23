import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../auth/services/auth_service.dart';

class ShopProduct {
  const ShopProduct({
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

  factory ShopProduct.fromJson(Map<String, dynamic> json, String baseUrl) =>
      ShopProduct(
        id: _integer(json['id']),
        name: '${json['name'] ?? ''}',
        description: '${json['description'] ?? ''}',
        imageUrl: _absoluteUrl(json['image_url'] as String?, baseUrl),
        price: _integer(json['price']),
        stock: _integer(json['stock']),
        weightGrams: _integer(json['weight_grams']),
      );
}

class ShopCartLine {
  const ShopCartLine({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.stock,
    required this.weightGrams,
  });
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final int unitPrice;
  final int quantity;
  final int lineTotal;
  final int stock;
  final int weightGrams;
  factory ShopCartLine.fromJson(Map<String, dynamic> json, String baseUrl) =>
      ShopCartLine(
        id: _integer(json['id']),
        name: '${json['name'] ?? ''}',
        description: '${json['description'] ?? ''}',
        imageUrl: _absoluteUrl(json['image_url'] as String?, baseUrl),
        unitPrice: _integer(json['unit_price']),
        quantity: _integer(json['quantity']),
        lineTotal: _integer(json['line_total']),
        stock: _integer(json['stock']),
        weightGrams: _integer(json['weight_grams']),
      );
}

class ShopCart {
  const ShopCart({
    required this.items,
    required this.count,
    required this.subtotal,
    required this.weightGrams,
  });
  final List<ShopCartLine> items;
  final int count;
  final int subtotal;
  final int weightGrams;
}

class ShopDestination {
  const ShopDestination({required this.id, required this.label});
  final String id;
  final String label;
  factory ShopDestination.fromJson(Map<String, dynamic> json) =>
      ShopDestination(
        id: '${json['id'] ?? ''}',
        label: '${json['label'] ?? ''}',
      );
}

class ShopShippingOption {
  const ShopShippingOption({
    required this.courierCode,
    required this.courierName,
    required this.service,
    required this.description,
    required this.eta,
    required this.cost,
  });
  final String courierCode;
  final String courierName;
  final String service;
  final String description;
  final String eta;
  final int cost;
  factory ShopShippingOption.fromJson(Map<String, dynamic> json) =>
      ShopShippingOption(
        courierCode: '${json['courier_code'] ?? ''}',
        courierName: '${json['courier_name'] ?? ''}',
        service: '${json['service'] ?? ''}',
        description: '${json['description'] ?? ''}',
        eta: '${json['etd'] ?? ''}',
        cost: _integer(json['cost']),
      );
}

class ShopOrderItem {
  const ShopOrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });
  final String name;
  final int quantity;
  final int unitPrice;
}

class ShopOrder {
  const ShopOrder({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.fulfillmentMethod,
    required this.shippingCost,
    required this.destination,
    required this.courierName,
    required this.courierService,
    required this.trackingNumber,
    required this.pickupDate,
    required this.createdAt,
    required this.snapUrl,
    required this.items,
  });
  final String id;
  final int amount;
  final String status;
  final String paymentStatus;
  final String fulfillmentMethod;
  final int shippingCost;
  final String destination;
  final String courierName;
  final String courierService;
  final String trackingNumber;
  final String pickupDate;
  final String createdAt;
  final String snapUrl;
  final List<ShopOrderItem> items;

  factory ShopOrder.fromJson(Map<String, dynamic> json) => ShopOrder(
    id: '${json['order_id'] ?? ''}',
    amount: _integer(json['amount']),
    status: '${json['status_code'] ?? ''}',
    paymentStatus: '${json['payment_status_code'] ?? ''}',
    fulfillmentMethod: '${json['fulfillment_method'] ?? 'courier'}',
    shippingCost: _integer(json['shipping_cost']),
    destination: '${json['destination_label'] ?? ''}',
    courierName: '${json['courier_name'] ?? ''}',
    courierService: '${json['courier_service'] ?? ''}',
    trackingNumber: '${json['tracking_number'] ?? ''}',
    pickupDate: '${json['pickup_date'] ?? ''}',
    createdAt: '${json['created_at'] ?? ''}',
    snapUrl: '${json['snap_url'] ?? ''}',
    items: (json['products'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (e) => ShopOrderItem(
            name: '${e['name'] ?? ''}',
            quantity: _integer(e['quantity']),
            unitPrice: _integer(e['unit_price']),
          ),
        )
        .toList(growable: false),
  );
}

class ShopCheckoutResult {
  const ShopCheckoutResult({
    required this.orderUrl,
    required this.paymentUrl,
    required this.totalAmount,
  });
  final String orderUrl;
  final String paymentUrl;
  final int totalAmount;
}

class MitraShopService {
  MitraShopService(AuthService authService) : _api = authService.apiClient;
  final ApiClient _api;
  String get baseUrl => _api.baseUrl;

  Future<List<ShopProduct>> products({String search = ''}) async {
    final path = Uri(
      path: '/katalog/api/products/',
      queryParameters: search.trim().isEmpty ? null : {'search': search.trim()},
    ).toString();
    final response = await _api.get(path);
    final data = _decode(response);
    return (data['products'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              ShopProduct.fromJson(Map<String, dynamic>.from(item), baseUrl),
        )
        .toList(growable: false);
  }

  Future<ShopCart> cart() async {
    final data = _decode(await _api.get('/katalog/api/cart/'));
    return ShopCart(
      items: (data['items'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                ShopCartLine.fromJson(Map<String, dynamic>.from(item), baseUrl),
          )
          .toList(growable: false),
      count: _integer(data['count']),
      subtotal: _integer(data['subtotal']),
      weightGrams: _integer(data['weight_grams']),
    );
  }

  Future<void> add(int productId, {int quantity = 1}) async => _decode(
    await _api.post(
      '/katalog/api/cart/add/',
      body: {'product_id': productId, 'quantity': quantity},
    ),
  );
  Future<void> updateQuantity(int productId, int quantity) async => _decode(
    await _api.post(
      '/katalog/api/cart/$productId/',
      body: {'quantity': quantity},
    ),
  );
  Future<void> remove(int productId) async => _decode(
    await _api.post('/katalog/api/cart/$productId/', body: {'remove': true}),
  );

  Future<List<ShopDestination>> searchDestinations(String query) async {
    final uri = Uri(
      path: '/katalog/api/shipping/destinations/',
      queryParameters: {'q': query},
    );
    final response = await _api.get(uri.toString());
    final data = _decode(response);
    return (data['destinations'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) => ShopDestination.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<List<ShopShippingOption>> shippingOptions(String destinationId) async {
    final data = _decode(
      await _api.post(
        '/katalog/api/shipping/calculate/',
        body: {'destination_id': destinationId},
      ),
    );
    return (data['options'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              ShopShippingOption.fromJson(Map<String, dynamic>.from(item)),
        )
        .where(
          (option) =>
              const {'jne', 'jnt'}.contains(option.courierCode.toLowerCase()),
        )
        .toList(growable: false);
  }

  Future<ShopCheckoutResult> checkout({
    required String recipient,
    required String phone,
    required String method,
    String address = '',
    String destinationId = '',
    String destinationLabel = '',
    ShopShippingOption? shipping,
    DateTime? pickupDate,
    String voucherCode = '',
  }) async {
    final fields = <String, String>{
      'recipient_name': recipient.trim(),
      'phone': phone.trim(),
      'fulfillment_method': method,
    };
    if (voucherCode.trim().isNotEmpty) {
      fields['voucher_code'] = voucherCode.trim().toUpperCase();
    }
    if (method == 'self_pickup') {
      if (pickupDate != null)
        fields['pickup_date'] =
            '${pickupDate.year.toString().padLeft(4, '0')}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}';
    } else {
      fields.addAll({
        'shipping_address': address.trim(),
        'destination_id': destinationId,
        'destination_label': destinationLabel,
        'courier_code': shipping?.courierCode ?? '',
        'courier_service': shipping?.service ?? '',
      });
    }
    final data = _decode(
      await _api.postForm('/katalog/api/orders/create/', fields: fields),
    );
    final token = '${data['snap_url'] ?? ''}';
    if (token.isEmpty || token == 'null')
      throw ApiException(
        statusCode: 502,
        message: 'Tautan pembayaran dari server belum tersedia. Pesanan mungkin belum dibuat; periksa Riwayat Pesanan sebelum mengulangi checkout.',
      );
    return ShopCheckoutResult(
      orderUrl: '${data['order_url'] ?? ''}',
      paymentUrl: _absoluteUrl(token, baseUrl) ?? token,
      totalAmount: _integer(data['total_amount']),
    );
  }

  Future<List<ShopOrder>> orders() async {
    final response = await _api.get('/katalog/api/orders/');
    if (response.statusCode < 200 || response.statusCode >= 300)
      _decode(response);
    final list = jsonDecode(response.body);
    return (list as List)
        .whereType<Map>()
        .map((e) => ShopOrder.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<void> refreshPayment(String orderId) async => _decode(
    await _api.post(
      '/katalog/api/orders/$orderId/refresh-payment/',
      body: const {},
    ),
  );

  Map<String, dynamic> _decode(dynamic response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    }
    String message = 'Permintaan gagal (${response.statusCode}).';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map)
        message = '${decoded['error'] ?? decoded['detail'] ?? message}';
    } catch (_) {
      if (response.statusCode == 403)
        message = 'Sesi login tidak berlaku atau akses katalog ditolak.';
    }
    throw ApiException(statusCode: response.statusCode, message: message);
  }
}

int _integer(dynamic value) =>
    value is num ? value.round() : int.tryParse('$value') ?? 0;

String? _absoluteUrl(String? value, String baseUrl) {
  if (value == null || value.isEmpty || value == 'null') return null;
  final uri = Uri.tryParse(value);
  if (uri == null) return null;
  return uri.hasScheme ? value : Uri.parse(baseUrl).resolve(value).toString();
}
