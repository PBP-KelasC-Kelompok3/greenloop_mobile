enum UserRole { consumer, mitra, courier, admin, unknown }

extension UserRoleData on UserRole {
  String get label => switch (this) {
        UserRole.consumer => 'Consumer',
        UserRole.mitra => 'Mitra',
        UserRole.courier => 'Courier',
        UserRole.admin => 'Admin',
        UserRole.unknown => 'Pengguna',
      };

  String get backendValue => switch (this) {
        UserRole.consumer => 'consumer',
        UserRole.mitra => 'mitra',
        UserRole.courier => 'courier',
        UserRole.admin => 'admin',
        UserRole.unknown => 'unknown',
      };

  static UserRole fromBackend(String? value) =>
      switch (value?.toLowerCase().trim()) {
        'consumer' => UserRole.consumer,
        'mitra' => UserRole.mitra,
        'courier' => UserRole.courier,
        'admin' => UserRole.admin,
        _ => UserRole.unknown,
      };
}

/// Representation of the standard Django User fields exposed by ProfileUserSerializer.
class UserAccount {
  const UserAccount({
    required this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isNotEmpty ? full : username;
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        id: json['id'] as int? ?? 0,
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      };

  UserAccount copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
  }) =>
      UserAccount(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
      );
}

/// Representation of MitraProfileReadSerializer fields.
class MitraProfileData {
  const MitraProfileData({
    this.businessName,
    this.businessType,
    this.picName,
    this.phoneNumber,
    this.operationalHours,
    this.courierNotes,
    this.provinsi,
    this.kota,
    this.kecamatan,
    this.kelurahan,
    this.addressDetail,
  });

  final String? businessName;
  final String? businessType;
  final String? picName;
  final String? phoneNumber;
  final String? operationalHours;
  final String? courierNotes;
  final String? provinsi;
  final String? kota;
  final String? kecamatan;
  final String? kelurahan;
  final String? addressDetail;

  factory MitraProfileData.fromJson(Map<String, dynamic> json) =>
      MitraProfileData(
        businessName: json['business_name'] as String?,
        businessType: json['business_type'] as String?,
        picName: json['pic_name'] as String?,
        phoneNumber: json['phone_number'] as String?,
        operationalHours: json['operational_hours'] as String?,
        courierNotes: json['courier_notes'] as String?,
        provinsi: json['provinsi'] as String?,
        kota: json['kota'] as String?,
        kecamatan: json['kecamatan'] as String?,
        kelurahan: json['kelurahan'] as String?,
        addressDetail: json['address_detail'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'business_name': ?businessName,
        'business_type': ?businessType,
        'pic_name': ?picName,
        'phone_number': ?phoneNumber,
        'operational_hours': ?operationalHours,
        'courier_notes': ?courierNotes,
        'provinsi': ?provinsi,
        'kota': ?kota,
        'kecamatan': ?kecamatan,
        'kelurahan': ?kelurahan,
        'address_detail': ?addressDetail,
      };

  MitraProfileData copyWith({
    String? businessName,
    String? businessType,
    String? picName,
    String? phoneNumber,
    String? operationalHours,
    String? courierNotes,
    String? provinsi,
    String? kota,
    String? kecamatan,
    String? kelurahan,
    String? addressDetail,
  }) =>
      MitraProfileData(
        businessName: businessName ?? this.businessName,
        businessType: businessType ?? this.businessType,
        picName: picName ?? this.picName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        operationalHours: operationalHours ?? this.operationalHours,
        courierNotes: courierNotes ?? this.courierNotes,
        provinsi: provinsi ?? this.provinsi,
        kota: kota ?? this.kota,
        kecamatan: kecamatan ?? this.kecamatan,
        kelurahan: kelurahan ?? this.kelurahan,
        addressDetail: addressDetail ?? this.addressDetail,
      );
}

/// Representation of CourierProfileReadSerializer fields.
class CourierProfileData {
  const CourierProfileData({
    this.plateNumber,
    this.vehicleType,
  });

  final String? plateNumber;
  final String? vehicleType;

  factory CourierProfileData.fromJson(Map<String, dynamic> json) =>
      CourierProfileData(
        plateNumber: json['plate_number'] as String?,
        vehicleType: json['vehicle_type'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'plate_number': ?plateNumber,
        'vehicle_type': ?vehicleType,
      };

  CourierProfileData copyWith({
    String? plateNumber,
    String? vehicleType,
  }) =>
      CourierProfileData(
        plateNumber: plateNumber ?? this.plateNumber,
        vehicleType: vehicleType ?? this.vehicleType,
      );
}

/// Representation of UserProfileReadSerializer.
class UserProfile {
  const UserProfile({
    required this.user,
    required this.role,
    this.mitraProfile,
    this.courierProfile,
  });

  final UserAccount user;
  final UserRole role;
  final MitraProfileData? mitraProfile;
  final CourierProfileData? courierProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final roleStr = json['role'] as String?;
    final role = UserRoleData.fromBackend(roleStr);

    final mitraMap = json['mitra_profile'] is Map<String, dynamic>
        ? json['mitra_profile'] as Map<String, dynamic>
        : null;

    final courierMap = json['courier_profile'] is Map<String, dynamic>
        ? json['courier_profile'] as Map<String, dynamic>
        : null;

    return UserProfile(
      user: UserAccount.fromJson(userMap),
      role: role,
      mitraProfile:
          mitraMap != null ? MitraProfileData.fromJson(mitraMap) : null,
      courierProfile:
          courierMap != null ? CourierProfileData.fromJson(courierMap) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'role': role.backendValue,
        'mitra_profile': ?mitraProfile?.toJson(),
        'courier_profile': ?courierProfile?.toJson(),
      };

  UserProfile copyWith({
    UserAccount? user,
    UserRole? role,
    MitraProfileData? mitraProfile,
    CourierProfileData? courierProfile,
  }) =>
      UserProfile(
        user: user ?? this.user,
        role: role ?? this.role,
        mitraProfile: mitraProfile ?? this.mitraProfile,
        courierProfile: courierProfile ?? this.courierProfile,
      );
}

/// Payload envelope returned by /api/auth/login/ and /api/auth/register/.
class AuthResponse {
  const AuthResponse({
    required this.detail,
    required this.profile,
    this.csrfToken,
  });

  final String detail;
  final UserProfile profile;
  final String? csrfToken;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final profileMap = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : json;

    return AuthResponse(
      detail: json['detail'] as String? ?? '',
      profile: UserProfile.fromJson(profileMap),
      csrfToken: json['csrf_token'] as String?,
    );
  }
}
