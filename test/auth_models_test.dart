import 'package:flutter_test/flutter_test.dart';
import 'package:greenloop_mobile/features/auth/data/auth_models.dart';

void main() {
  group('Auth & Profile Models', () {
    test('parses consumer registration / login response correctly', () {
      final json = {
        'detail': 'Login berhasil.',
        'profile': {
          'user': {
            'id': 10,
            'username': 'andi_consumer',
            'email': 'andi@example.com',
            'first_name': '',
            'last_name': '',
          },
          'role': 'consumer',
          'mitra_profile': null,
          'courier_profile': null,
        },
        'csrf_token': 'test-csrf-token',
      };

      final authResponse = AuthResponse.fromJson(json);
      expect(authResponse.detail, 'Login berhasil.');
      expect(authResponse.csrfToken, 'test-csrf-token');

      final profile = authResponse.profile;
      expect(profile.role, UserRole.consumer);
      expect(profile.role.label, 'Consumer');
      expect(profile.user.id, 10);
      expect(profile.user.username, 'andi_consumer');
      expect(profile.user.email, 'andi@example.com');
      expect(profile.user.displayName, 'andi_consumer');
      expect(profile.mitraProfile, isNull);
      expect(profile.courierProfile, isNull);
    });

    test('parses mitra profile response correctly', () {
      final json = {
        'user': {
          'id': 15,
          'username': 'kopi_berkah',
          'email': 'kopi@example.com',
          'first_name': 'Kopi',
          'last_name': 'Berkah',
        },
        'role': 'mitra',
        'mitra_profile': {
          'business_name': 'Kopi Berkah Depok',
          'business_type': 'Kafe',
          'pic_name': 'Afiqah',
          'phone_number': '081234567890',
          'operational_hours': '09:00 - 21:00',
          'courier_notes': 'Gedung warna hijau lantai 1',
        },
        'courier_profile': null,
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.role, UserRole.mitra);
      expect(profile.role.label, 'Mitra');
      expect(profile.user.displayName, 'Kopi Berkah');
      expect(profile.mitraProfile, isNotNull);
      expect(profile.mitraProfile!.businessName, 'Kopi Berkah Depok');
      expect(profile.mitraProfile!.businessType, 'Kafe');
      expect(profile.mitraProfile!.picName, 'Afiqah');
      expect(profile.mitraProfile!.phoneNumber, '081234567890');
      expect(profile.mitraProfile!.operationalHours, '09:00 - 21:00');
      expect(profile.mitraProfile!.courierNotes, 'Gedung warna hijau lantai 1');
      expect(profile.courierProfile, isNull);
    });

    test('parses courier profile response correctly', () {
      final json = {
        'user': {
          'id': 20,
          'username': 'kurir_cepat',
          'email': 'kurir@example.com',
          'first_name': 'Budi',
          'last_name': 'Santoso',
        },
        'role': 'courier',
        'mitra_profile': null,
        'courier_profile': {
          'plate_number': 'B 1234 KZT',
          'vehicle_type': 'Motor Box',
        },
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.role, UserRole.courier);
      expect(profile.role.label, 'Courier');
      expect(profile.user.displayName, 'Budi Santoso');
      expect(profile.courierProfile, isNotNull);
      expect(profile.courierProfile!.plateNumber, 'B 1234 KZT');
      expect(profile.courierProfile!.vehicleType, 'Motor Box');
      expect(profile.mitraProfile, isNull);
    });

    test('handles admin and unknown roles gracefully', () {
      final adminProfile = UserProfile.fromJson({
        'user': {'id': 1, 'username': 'admin'},
        'role': 'admin',
      });
      expect(adminProfile.role, UserRole.admin);
      expect(adminProfile.role.label, 'Admin');

      final unknownProfile = UserProfile.fromJson({
        'user': {'id': 99, 'username': 'guest'},
        'role': 'other_role',
      });
      expect(unknownProfile.role, UserRole.unknown);
      expect(unknownProfile.role.label, 'Pengguna');
    });

    test('handles missing and null fields safely', () {
      final emptyProfile = UserProfile.fromJson({});
      expect(emptyProfile.user.id, 0);
      expect(emptyProfile.user.username, '');
      expect(emptyProfile.user.email, '');
      expect(emptyProfile.role, UserRole.unknown);
      expect(emptyProfile.mitraProfile, isNull);
      expect(emptyProfile.courierProfile, isNull);
    });
  });
}
