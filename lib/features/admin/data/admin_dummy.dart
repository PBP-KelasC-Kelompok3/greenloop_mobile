/// Data contoh layar Admin (M21, M32–M37), diambil dari Figma.
///
/// Semua kelas di sini immutable; layar menyimpan salinannya di state dan
/// mengganti item lewat [copyWith]. Saat API admin siap, ganti sumber data
/// awal dengan service.
library;

enum ApplicantStatus { waiting, approved, rejected }

class CourierApplicant {
  const CourierApplicant({
    required this.name,
    required this.initials,
    required this.registeredAt,
    required this.plateNumber,
    required this.vehicleType,
    this.status = ApplicantStatus.waiting,
  });

  final String name;
  final String initials;
  final String registeredAt;
  final String plateNumber;
  final String vehicleType;
  final ApplicantStatus status;

  CourierApplicant copyWith({ApplicantStatus? status}) => CourierApplicant(
        name: name,
        initials: initials,
        registeredAt: registeredAt,
        plateNumber: plateNumber,
        vehicleType: vehicleType,
        status: status ?? this.status,
      );
}

/// Warna kemasan di thumbnail produk.
enum ProductTint { green, amber }

class AdminProduct {
  const AdminProduct({
    required this.name,
    required this.description,
    required this.priceB2c,
    required this.priceB2b,
    required this.stock,
    required this.weightGrams,
    this.tint = ProductTint.green,
  });

  final String name;
  final String description;
  final int priceB2c;
  final int priceB2b;
  final int stock;
  final int weightGrams;
  final ProductTint tint;

  AdminProduct copyWith({
    String? name,
    String? description,
    int? priceB2c,
    int? priceB2b,
    int? stock,
    int? weightGrams,
  }) =>
      AdminProduct(
        name: name ?? this.name,
        description: description ?? this.description,
        priceB2c: priceB2c ?? this.priceB2c,
        priceB2b: priceB2b ?? this.priceB2b,
        stock: stock ?? this.stock,
        weightGrams: weightGrams ?? this.weightGrams,
        tint: tint,
      );
}

enum AdminOrderStatus {
  awaitingPayment('Menunggu Pembayaran'),
  paid('Dibayar'),
  preparing('Sedang Disiapkan'),
  shipping('Dalam Pengiriman'),
  delivered('Terkirim');

  const AdminOrderStatus(this.label);

  final String label;
}

class AdminOrder {
  const AdminOrder({
    required this.code,
    required this.customer,
    required this.customerType,
    required this.itemCount,
    required this.courier,
    required this.total,
    required this.status,
    this.trackingNumber,
  });

  final String code;
  final String customer;
  final String customerType;
  final int itemCount;
  final String courier;
  final int total;
  final AdminOrderStatus status;
  final String? trackingNumber;

  bool get isPaid => status != AdminOrderStatus.awaitingPayment;

  AdminOrder copyWith({AdminOrderStatus? status, String? trackingNumber}) =>
      AdminOrder(
        code: code,
        customer: customer,
        customerType: customerType,
        itemCount: itemCount,
        courier: courier,
        total: total,
        status: status ?? this.status,
        trackingNumber: trackingNumber ?? this.trackingNumber,
      );
}

enum VoucherKind {
  discount('Diskon', 'Diskon'),
  freeShipping('Gratis Ongkir', 'Gratis ongkir'),
  wholesale('Grosir B2B', 'Diskon grosir B2B');

  const VoucherKind(this.label, this.summaryLabel);

  /// Label di pilihan jenis (M36).
  final String label;

  /// Label di baris ringkasan kartu (M35).
  final String summaryLabel;
}

class AdminVoucher {
  const AdminVoucher({
    required this.title,
    required this.slug,
    required this.kind,
    required this.valueLabel,
    required this.cost,
    this.validDays = 30,
    this.order = 1,
    this.description = '',
    this.redeemed = 0,
    this.active = true,
  });

  final String title;
  final String slug;
  final VoucherKind kind;
  final String valueLabel;
  final int cost;
  final int validDays;
  final int order;
  final String description;
  final int redeemed;
  final bool active;

  AdminVoucher copyWith({bool? active}) => AdminVoucher(
        title: title,
        slug: slug,
        kind: kind,
        valueLabel: valueLabel,
        cost: cost,
        validDays: validDays,
        order: order,
        description: description,
        redeemed: redeemed,
        active: active ?? this.active,
      );
}

class AdminDummy {
  AdminDummy._();

  static const applicants = [
    CourierApplicant(
      name: 'Budi Santoso',
      initials: 'BS',
      registeredAt: '18 Nov 2026',
      plateNumber: 'B 1234 KZT',
      vehicleType: 'Motor Box',
    ),
    CourierApplicant(
      name: 'Agus Pratama',
      initials: 'AP',
      registeredAt: '17 Nov 2026',
      plateNumber: 'B 9087 PQR',
      vehicleType: 'Pickup Bak',
    ),
  ];

  static const products = [
    AdminProduct(
      name: 'Sabun Cuci Piring Eco-Enzyme',
      description: 'Dibuat dari eco-enzyme hasil fermentasi limbah buah mitra '
          'GreenLoop. 500 ml.',
      priceB2c: 32000,
      priceB2b: 26000,
      stock: 120,
      weightGrams: 500,
    ),
    AdminProduct(
      name: 'Sabun Mandi Batang Serai',
      description: 'Sabun batang serai untuk mandi, 100 g.',
      priceB2c: 28000,
      priceB2b: 22000,
      stock: 85,
      weightGrams: 100,
      tint: ProductTint.amber,
    ),
    AdminProduct(
      name: 'Sabun Mandi Batang Jeruk',
      description: 'Sabun batang jeruk untuk mandi, 100 g.',
      priceB2c: 29000,
      priceB2b: 23000,
      stock: 64,
      weightGrams: 100,
      tint: ProductTint.amber,
    ),
    AdminProduct(
      name: 'Refill Pouch 1L',
      description: 'Isi ulang sabun cuci piring eco-enzyme, 1 liter.',
      priceB2c: 55000,
      priceB2b: 45000,
      stock: 40,
      weightGrams: 1000,
    ),
    AdminProduct(
      name: 'Paket Amenitas Hotel',
      description: 'Paket sabun dan amenitas untuk kamar hotel.',
      priceB2c: 1250000,
      priceB2b: 1050000,
      stock: 12,
      weightGrams: 5000,
    ),
  ];

  static const orders = [
    AdminOrder(
      code: '#GL-261118-0157',
      customer: 'Nadia Putri',
      customerType: 'Konsumen',
      itemCount: 3,
      courier: 'JNE REG',
      total: 152000,
      status: AdminOrderStatus.paid,
    ),
    AdminOrder(
      code: '#GL-261118-0153',
      customer: 'Kafe Senja Margonda',
      customerType: 'Mitra B2B',
      itemCount: 12,
      courier: 'J&T EZ',
      total: 318000,
      status: AdminOrderStatus.preparing,
    ),
    AdminOrder(
      code: '#GL-261117-0149',
      customer: 'Rizky Hidayat',
      customerType: 'Konsumen',
      itemCount: 1,
      courier: 'SiCepat',
      total: 41000,
      status: AdminOrderStatus.awaitingPayment,
    ),
  ];

  static const vouchers = [
    AdminVoucher(
      title: 'Diskon Rp10.000',
      slug: 'diskon-10k',
      kind: VoucherKind.discount,
      valueLabel: 'Rp10.000',
      cost: 200,
      order: 1,
      redeemed: 128,
    ),
    AdminVoucher(
      title: 'Diskon Rp25.000',
      slug: 'diskon-25k',
      kind: VoucherKind.discount,
      valueLabel: 'Rp25.000',
      cost: 450,
      order: 2,
      redeemed: 64,
    ),
    AdminVoucher(
      title: 'Gratis Ongkir s.d. Rp15.000',
      slug: 'gratis-ongkir-15k',
      kind: VoucherKind.freeShipping,
      valueLabel: 'Rp15.000',
      cost: 300,
      order: 3,
      redeemed: 91,
    ),
    AdminVoucher(
      title: 'Diskon Grosir B2B 15%',
      slug: 'grosir-b2b-15',
      kind: VoucherKind.wholesale,
      valueLabel: '15%',
      cost: 1000,
      order: 4,
      redeemed: 17,
    ),
    AdminVoucher(
      title: 'Diskon Rp5.000',
      slug: 'diskon-5k',
      kind: VoucherKind.discount,
      valueLabel: 'Rp5.000',
      cost: 100,
      order: 5,
      redeemed: 342,
      active: false,
    ),
  ];

  static const adminName = 'Admin GreenLoop';
  static const adminUsername = 'admin';
  static const adminEmail = 'admin@greenloop.id';
  static const pilotArea = 'Kota Depok';
}
