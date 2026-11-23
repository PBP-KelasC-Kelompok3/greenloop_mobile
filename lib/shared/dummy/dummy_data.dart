/// Data contoh untuk mockup UI GreenLoop Mobile.
///
/// Semua isi file ini diambil dari teks di Figma "GreenLoop Mobile" supaya
/// tampilan app sama dengan desain. Pemilik modul nanti mengganti pemakaian
/// data ini dengan data dari API Django masing-masing.
library;

// ---------------------------------------------------------------------------
// Status
// ---------------------------------------------------------------------------

/// Status penjemputan, mengikuti `scheduling.PickupSchedule` di repo web.
enum PickupStatus {
  pending('Menunggu Verifikasi'),
  approved('Disetujui'),
  rejected('Ditolak'),
  scheduled('Dijadwalkan'),
  inProgress('Dalam Perjalanan'),
  completed('Selesai'),
  cancelled('Dibatalkan');

  const PickupStatus(this.label);

  final String label;
}

/// Status pesanan e-commerce, mengikuti app `catalog` di repo web.
enum OrderStatus {
  awaitingPayment('Menunggu Pembayaran'),
  paid('Dibayar'),
  preparing('Sedang Disiapkan'),
  shipping('Dalam Pengiriman'),
  delivered('Terkirim'),
  cancelled('Dibatalkan');

  const OrderStatus(this.label);

  final String label;
}

// ---------------------------------------------------------------------------
// Model sederhana
// ---------------------------------------------------------------------------

class DummyMitra {
  const DummyMitra({
    required this.businessName,
    required this.shortName,
    required this.initials,
    required this.businessType,
    required this.picName,
    required this.phone,
    required this.address,
    required this.kecamatan,
    required this.kota,
    required this.openingHours,
    required this.courierNote,
    required this.username,
    required this.email,
  });

  final String businessName;
  final String shortName;
  final String initials;
  final String businessType;
  final String picName;
  final String phone;
  final String address;
  final String kecamatan;
  final String kota;
  final String openingHours;
  final String courierNote;
  final String username;
  final String email;
}

class DummyPickup {
  const DummyPickup({
    required this.code,
    required this.wasteType,
    required this.date,
    required this.timeSlot,
    required this.estimatedKg,
    required this.status,
    this.actualKg,
    this.points,
    this.armada = 'Motor Box',
    this.note,
    this.rejectReason,
    this.courierName,
    this.hasCertificate = false,
  });

  final String code;
  final String wasteType;
  final String date;
  final String timeSlot;
  final double estimatedKg;
  final PickupStatus status;
  final double? actualKg;
  final int? points;
  final String armada;
  final String? note;
  final String? rejectReason;
  final String? courierName;
  final bool hasCertificate;
}

class DummyVoucher {
  const DummyVoucher({
    required this.title,
    required this.description,
    required this.cost,
    required this.category,
    required this.value,
    required this.codePrefix,
    this.premium = false,
    this.validDays = 30,
  });

  /// Nama lengkap, dipakai di daftar tukar M24 ("Diskon Rp10.000").
  final String title;
  final String description;
  final int cost;

  /// Label kecil di kartu voucher M07 ("Diskon", "Gratis Ongkir").
  final String category;

  /// Nilai besar di kartu voucher M07 ("Rp 10.000", "15%").
  final String value;

  /// Awalan kode voucher hasil tukar ("GLV-10K").
  final String codePrefix;

  /// Kartu gelap (hijau tua + lime) untuk voucher grosir B2B.
  final bool premium;
  final int validDays;
}

class DummyPointHistory {
  const DummyPointHistory({
    required this.title,
    required this.date,
    required this.points,
  });

  final String title;
  final String date;

  /// Positif = poin masuk, negatif = poin ditukar.
  final int points;
}

class DummyProduct {
  const DummyProduct({
    required this.name,
    required this.category,
    required this.size,
    required this.priceB2c,
    required this.priceB2b,
    required this.stock,
    required this.description,
    this.rating = 4.8,
    this.sold = 0,
  });

  final String name;
  final String category;
  final String size;
  final int priceB2c;
  final int priceB2b;
  final int stock;
  final String description;
  final double rating;
  final int sold;
}

class DummyCartItem {
  const DummyCartItem({required this.product, required this.quantity});

  final DummyProduct product;
  final int quantity;

  int get subtotal => product.priceB2c * quantity;
}

class DummyOrder {
  const DummyOrder({
    required this.code,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    this.courier = 'JNE REG',
    this.trackingNumber,
  });

  final String code;
  final String date;
  final String items;
  final int total;
  final OrderStatus status;
  final String courier;
  final String? trackingNumber;
}

/// Satu langkah di timeline Lacak Pesanan (M14).
class DummyTrackingStep {
  const DummyTrackingStep({required this.status, required this.detail});

  final OrderStatus status;
  final String detail;
}

/// Satu baris "Isi paket" di M14.
class DummyOrderLine {
  const DummyOrderLine({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final int price;
}

class DummyTrackedOrder {
  const DummyTrackedOrder({
    required this.code,
    required this.status,
    required this.courier,
    required this.trackingNumber,
    required this.payment,
    required this.steps,
    required this.lines,
    required this.wasteSavedKg,
  });

  final String code;

  /// Status terkini; langkah sebelumnya dianggap selesai.
  final OrderStatus status;
  final String courier;
  final String trackingNumber;
  final String payment;
  final List<DummyTrackingStep> steps;
  final List<DummyOrderLine> lines;
  final double wasteSavedKg;
}

class DummyCourier {
  const DummyCourier({
    required this.name,
    required this.initials,
    required this.plateNumber,
    required this.vehicleType,
    required this.phone,
    this.verified = true,
    this.onDuty = true,
  });

  final String name;
  final String initials;
  final String plateNumber;
  final String vehicleType;
  final String phone;
  final bool verified;
  final bool onDuty;
}

class DummyRouteStop {
  const DummyRouteStop({
    required this.mitraName,
    required this.address,
    required this.timeSlot,
    required this.wasteType,
    required this.estimatedKg,
    required this.done,
  });

  final String mitraName;
  final String address;
  final String timeSlot;
  final String wasteType;
  final double estimatedKg;
  final bool done;
}

class DummyWeightLog {
  const DummyWeightLog({
    required this.mitraName,
    required this.date,
    required this.time,
    required this.weightKg,
    required this.wasteType,
  });

  final String mitraName;
  final String date;
  final String time;
  final double weightKg;
  final String wasteType;
}

// ---------------------------------------------------------------------------
// Data contoh
// ---------------------------------------------------------------------------

class DummyData {
  DummyData._();

  // --- Pilihan form (sama dengan repo web) --------------------------------

  static const wasteTypes = [
    'Sisa Makanan / Dapur',
    'Ampas Kopi',
    'Sisa Buah & Sayur',
    'Organik Campuran',
  ];

  static const timeSlots = [
    '08:00 - 10:00 WIB',
    '10:00 - 12:00 WIB',
    '13:00 - 15:00 WIB',
    '15:00 - 17:00 WIB',
  ];

  static const armadaOptions = ['Motor Box', 'Pickup Bak'];

  static const businessTypes = [
    'Kafe / Coffee Shop',
    'Restoran',
    'Hotel',
    'Katering',
  ];

  static const kecamatanDepok = [
    'Beji',
    'Pancoran Mas',
    'Sukmajaya',
    'Cimanggis',
    'Tapos',
    'Limo',
  ];

  // --- Mitra ---------------------------------------------------------------

  static const mitra = DummyMitra(
    businessName: 'Kafe Senja Margonda',
    shortName: 'Kafe Senja',
    initials: 'KS',
    businessType: 'Kafe / Coffee Shop',
    picName: 'Nadia Putri',
    phone: '0812-3456-7890',
    address: 'Jl. Margonda Raya No. 21, Pondok Cina, Beji, Kota Depok',
    kecamatan: 'Beji',
    kota: 'Kota Depok',
    openingHours: '07:00 - 22:00',
    courierNote: 'Masuk lewat pintu belakang dapur',
    username: 'kafesenja',
    email: 'kafe@senja.id',
  );

  // --- Waste & Reward -----------------------------------------------------

  /// 1 kg limbah terverifikasi = 5 poin, dibulatkan ke bawah.
  static const pointsPerKg = 5;

  static const points = 2430;
  static const level = 'Silver';
  static const nextLevel = 'Gold';
  static const nextLevelPoints = 3000;

  static const tiers = [
    ('Bronze', 0),
    ('Silver', 1000),
    ('Gold', 3000),
  ];

  static const impactWasteKg = 486;
  static const impactCo2Kg = 58;
  static const impactSoap = 24;

  static const vouchers = [
    DummyVoucher(
      title: 'Diskon Rp10.000',
      description: 'Min. belanja Rp50.000',
      cost: 200,
      category: 'Diskon',
      value: 'Rp 10.000',
      codePrefix: 'GLV-10K',
    ),
    DummyVoucher(
      title: 'Gratis Ongkir s.d. Rp15.000',
      description: 'Semua kurir',
      cost: 300,
      category: 'Gratis Ongkir',
      value: 's.d. Rp 15.000',
      codePrefix: 'GLV-ONG',
    ),
    DummyVoucher(
      title: 'Diskon Rp25.000',
      description: 'Min. belanja Rp100.000',
      cost: 450,
      category: 'Diskon',
      value: 'Rp 25.000',
      codePrefix: 'GLV-25K',
    ),
    DummyVoucher(
      title: 'Diskon Grosir B2B 15%',
      description: 'Khusus pembelian grosir mitra',
      cost: 1000,
      category: 'Diskon Grosir B2B',
      value: '15%',
      codePrefix: 'GLV-B2B',
      premium: true,
    ),
  ];

  /// Riwayat poin terbaru di atas (M07).
  static const pointHistory = [
    DummyPointHistory(
      title: 'Setoran PK-0931 · 35,2 kg',
      date: '26 Sep',
      points: 176,
    ),
    DummyPointHistory(
      title: 'Tukar voucher Diskon Rp 10.000',
      date: '25 Sep',
      points: -200,
    ),
    DummyPointHistory(
      title: 'Setoran PK-0927 · 48,0 kg',
      date: '12 Sep',
      points: 240,
    ),
  ];

  /// Voucher yang sudah dimiliki mitra (kartu "Voucher Saya" di M07).
  static const activeVoucherCode = 'GLV-10K-8FQ2';
  static const activeVoucherUntil = '25 Des 2026';

  // --- Penjemputan --------------------------------------------------------

  static const pickups = [
    DummyPickup(
      code: 'PK-0936',
      wasteType: 'Sisa Buah & Sayur',
      date: 'Sab, 15 Nov',
      timeSlot: '08:00 - 10:00',
      estimatedKg: 40,
      status: PickupStatus.pending,
      note: 'Limbah di pintu belakang dapur',
    ),
    DummyPickup(
      code: 'PK-0935',
      wasteType: 'Ampas Kopi',
      date: 'Jum, 14 Nov',
      timeSlot: '10:00 - 12:00',
      estimatedKg: 16,
      status: PickupStatus.scheduled,
      courierName: 'Budi Santoso',
    ),
    DummyPickup(
      code: 'PK-0931',
      wasteType: 'Sisa Makanan / Dapur',
      date: 'Jum, 26 Sep',
      timeSlot: '08:00 - 10:00',
      estimatedKg: 35,
      actualKg: 35.2,
      points: 176,
      status: PickupStatus.completed,
      courierName: 'Budi Santoso',
      hasCertificate: true,
    ),
    DummyPickup(
      code: 'PK-0917',
      wasteType: 'Organik Campuran',
      date: 'Jum, 12 Sep',
      timeSlot: '13:00 - 15:00',
      estimatedKg: 20,
      status: PickupStatus.rejected,
      rejectReason: 'Foto tidak layak (tercampur plastik)',
    ),
  ];

  static DummyPickup get activePickup => pickups.first;

  static const pickupSteps = [
    'Verifikasi foto',
    'Kurir ditugaskan',
    'Dijemput',
    'Selesai',
  ];

  // --- Katalog & pesanan --------------------------------------------------

  static const products = [
    DummyProduct(
      name: 'Sabun Cuci Piring Eco-Enzyme',
      category: 'Sabun Cuci Piring',
      size: '500 ml · stand pouch',
      priceB2c: 32000,
      priceB2b: 27000,
      stock: 120,
      description:
          'Sabun cuci piring alami dari fermentasi eco-enzyme limbah buah. '
          'Ampuh angkat lemak, lembut di tangan, aman untuk saluran air.',
      rating: 4.9,
      sold: 312,
    ),
    DummyProduct(
      name: 'Sabun Mandi Batang Kopi',
      category: 'Sabun Mandi',
      size: '100 g',
      priceB2c: 28000,
      priceB2b: 23000,
      stock: 80,
      description: 'Sabun batang dengan ampas kopi untuk eksfoliasi lembut.',
      rating: 4.8,
      sold: 204,
    ),
    DummyProduct(
      name: 'Sabun Mandi Batang Jeruk',
      category: 'Sabun Mandi',
      size: '100 g',
      priceB2c: 29000,
      priceB2b: 24000,
      stock: 64,
      description: 'Sabun batang aroma jeruk segar dari kulit jeruk fermentasi.',
      rating: 4.7,
      sold: 158,
    ),
    DummyProduct(
      name: 'Paket Amenitas Hotel',
      category: 'Grosir B2B',
      size: '50 pcs',
      priceB2c: 55000,
      priceB2b: 48000,
      stock: 40,
      description: 'Sabun batang mini untuk amenitas kamar hotel.',
      rating: 4.9,
      sold: 37,
    ),
  ];

  static const productCategories = [
    'Semua',
    'Sabun Cuci Piring',
    'Sabun Mandi',
    'Grosir B2B',
  ];

  static final cart = [
    DummyCartItem(product: products[0], quantity: 2),
    DummyCartItem(product: products[1], quantity: 1),
  ];

  static const shippingCost = 12000;

  static const orders = [
    DummyOrder(
      code: 'GL-ORD-2611',
      date: '16 Nov 2026',
      items: 'Sabun Cuci Piring Eco-Enzyme ×2, Sabun Mandi Batang Kopi ×1',
      total: 104000,
      status: OrderStatus.shipping,
      trackingNumber: 'JNE0123456789',
    ),
    DummyOrder(
      code: 'GL-ORD-2598',
      date: '02 Nov 2026',
      items: 'Sabun Mandi Batang Jeruk ×2',
      total: 70000,
      status: OrderStatus.delivered,
      trackingNumber: 'JNE0123450001',
    ),
    DummyOrder(
      code: 'GL-ORD-2620',
      date: '18 Nov 2026',
      items: 'Paket Amenitas Hotel ×1',
      total: 67000,
      status: OrderStatus.awaitingPayment,
    ),
  ];

  /// Konsumen contoh di Figma (M26).
  static const consumerName = 'Nadia Putri';
  static const consumerInitials = 'NP';
  static const consumerUsername = 'nadiaputri';
  static const consumerEmail = 'nadia.putri@gmail.com';
  static const consumerJoined = '2 Nov 2026';
  static const consumerAddress = 'Jl. Kenanga No. 8, Sukmajaya, Kota Depok';

  /// Pesanan yang dilacak di M14.
  static const trackedOrder = DummyTrackedOrder(
    code: '#GL-260926-0142',
    status: OrderStatus.shipping,
    courier: 'JNE REG',
    trackingNumber: 'JNE0123456789',
    payment: 'QRIS · Lunas',
    steps: [
      DummyTrackingStep(
        status: OrderStatus.awaitingPayment,
        detail: '26 Sep, 10.12 · Midtrans Snap',
      ),
      DummyTrackingStep(
        status: OrderStatus.paid,
        detail: 'QRIS · 26 Sep, 10.14',
      ),
      DummyTrackingStep(
        status: OrderStatus.preparing,
        detail: 'Gudang GreenLoop Beji · 26 Sep, 15.40',
      ),
      DummyTrackingStep(
        status: OrderStatus.shipping,
        detail: 'JNE Depok · resi JNE0123456789',
      ),
      DummyTrackingStep(
        status: OrderStatus.delivered,
        detail: 'Estimasi 30 Sep 2026',
      ),
    ],
    lines: [
      DummyOrderLine(
          name: 'Sabun Cuci Piring Jeruk Nipis 500 ml',
          quantity: 2,
          price: 32000),
      DummyOrderLine(
          name: 'Sabun Mandi Serai & Jeruk 100 g', quantity: 1, price: 28000),
      DummyOrderLine(name: 'Refill Pouch 1 L', quantity: 1, price: 55000),
    ],
    wasteSavedKg: 4.6,
  );

  // --- Kurir --------------------------------------------------------------

  static const courier = DummyCourier(
    name: 'Budi Santoso',
    initials: 'BS',
    plateNumber: 'B 1234 KZT',
    vehicleType: 'Motor Box',
    phone: '0813-2222-4545',
  );

  static const routeSummary = '4 titik · 12,4 km · ±48 menit';

  static const routeStops = [
    DummyRouteStop(
      mitraName: 'Kafe Senja Margonda',
      address: 'Jl. Margonda Raya No. 21, Beji',
      timeSlot: '08:00 - 10:00',
      wasteType: 'Ampas Kopi',
      estimatedKg: 14.2,
      done: true,
    ),
    DummyRouteStop(
      mitraName: 'Hotel Arya Depok',
      address: 'Jl. Arif Rahman Hakim No. 5, Beji',
      timeSlot: '10:00 - 12:00',
      wasteType: 'Sisa Makanan / Dapur',
      estimatedKg: 55,
      done: false,
    ),
    DummyRouteStop(
      mitraName: 'Resto Sunda Cibubur',
      address: 'Jl. Raya Bogor Km 30, Cimanggis',
      timeSlot: '13:00 - 15:00',
      wasteType: 'Sisa Buah & Sayur',
      estimatedKg: 22,
      done: false,
    ),
    DummyRouteStop(
      mitraName: 'Kedai Kopi Tapos',
      address: 'Jl. Raya Tapos No. 12, Tapos',
      timeSlot: '15:00 - 17:00',
      wasteType: 'Ampas Kopi',
      estimatedKg: 9,
      done: false,
    ),
  ];

  static const weightLogs = [
    DummyWeightLog(
      mitraName: 'Kafe Senja Margonda',
      date: '18 Nov 2026',
      time: '09:12',
      weightKg: 14.2,
      wasteType: 'Ampas Kopi',
    ),
    DummyWeightLog(
      mitraName: 'Hotel Arya Depok',
      date: '17 Nov 2026',
      time: '11:24',
      weightKg: 58.6,
      wasteType: 'Sisa Makanan / Dapur',
    ),
    DummyWeightLog(
      mitraName: 'Resto Sunda Cibubur',
      date: '17 Nov 2026',
      time: '14:05',
      weightKg: 21.4,
      wasteType: 'Sisa Buah & Sayur',
    ),
  ];

  static const weeklyWeightKg = 214.3;
  static const weeklyPickups = 9;

  // --- Admin --------------------------------------------------------------

  static const pendingCouriers = [
    DummyCourier(
      name: 'Dimas Pratama',
      initials: 'DP',
      plateNumber: 'B 4521 KJA',
      vehicleType: 'Pickup Bak',
      phone: '0857-1111-2020',
      verified: false,
      onDuty: false,
    ),
    DummyCourier(
      name: 'Sari Wulandari',
      initials: 'SW',
      plateNumber: 'B 3310 TPS',
      vehicleType: 'Motor Box',
      phone: '0812-9090-3131',
      verified: false,
      onDuty: false,
    ),
  ];

  static const activeCouriers = [courier];

  static const adminPendingPickups = 3;
}

/// Format angka rupiah sederhana: 32000 → "Rp32.000".
String formatRupiah(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}Rp$buffer';
}

/// Format angka ribuan: 2430 → "2.430".
String formatThousands(int value) =>
    formatRupiah(value).replaceFirst('Rp', '');

/// Format berat: 35.2 → "35,2 kg".
String formatKg(double value) {
  final text = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return '${text.replaceAll('.', ',')} kg';
}
