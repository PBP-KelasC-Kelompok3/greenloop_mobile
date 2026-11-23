import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../data/auth_models.dart';

/// Service managing authentication lifecycle, session state, and profile requests.
/// Completely independent from UI presentation and navigation.
class AuthService {
  AuthService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;
  UserProfile? _currentUser;
  Future<UserProfile?>? _sessionCheckFuture;

  /// Notifier for listening to user auth state changes.
  final ValueNotifier<UserProfile?> currentUserNotifier =
      ValueNotifier<UserProfile?>(null);

  ApiClient get apiClient => _apiClient;

  UserProfile? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  void _setCurrentUser(UserProfile? profile) {
    _currentUser = profile;
    currentUserNotifier.value = profile;
  }

  /// Check whether an existing Django session is valid by calling GET /api/auth/profile/.
  /// Reuses in-flight or completed futures to avoid duplicate calls during startup.
  Future<UserProfile?> checkSession({bool force = false}) {
    if (_sessionCheckFuture != null && !force) {
      return _sessionCheckFuture!;
    }
    _sessionCheckFuture = _performSessionCheck();
    return _sessionCheckFuture!;
  }

  Future<UserProfile?> _performSessionCheck() async {
    try {
      final profile = await fetchProfile();
      return profile;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403 || e.statusCode == 404) {
        _setCurrentUser(null);
        return null;
      }
      _setCurrentUser(null);
      return null;
    } catch (_) {
      // Gracefully handle network/socket errors without crashing
      _setCurrentUser(null);
      return null;
    }
  }

  /// Authenticate an existing user with username and password.
  /// DRF login returns status 200, rotated CSRF token, and user profile data.
  Future<UserProfile> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/login/',
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(decoded);
      // Django rotates the CSRF secret when a session is authenticated.
      // Refresh it before the next PATCH/POST so profile updates do not send
      // the pre-login token.
      await _apiClient.fetchCsrfToken(force: true);
      _setCurrentUser(authResponse.profile);
      _sessionCheckFuture = Future.value(_currentUser);
      return _currentUser!;
    }

    throw ApiException.fromResponse(response);
  }

  /// Register a new user account with role-specific fields.
  /// On success, DRF automatically starts an authenticated session and returns 201.
  Future<UserProfile> register({
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/register/',
      body: data,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(decoded);
      // Registration also logs the user in and rotates Django's CSRF secret.
      await _apiClient.fetchCsrfToken(force: true);
      _setCurrentUser(authResponse.profile);
      _sessionCheckFuture = Future.value(_currentUser);
      return _currentUser!;
    }

    throw ApiException.fromResponse(response);
  }

  /// Terminate the active session via POST /api/auth/logout/.
  Future<void> logout() async {
    final response = await _apiClient.post(
      '/api/auth/logout/',
      body: const <String, dynamic>{},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _setCurrentUser(null);
      _sessionCheckFuture = Future.value(null);
      _apiClient.clearCsrfToken();
      return;
    }

    throw ApiException.fromResponse(response);
  }

  /// Fetch the current authenticated user's profile from GET /api/auth/profile/.
  Future<UserProfile> fetchProfile() async {
    final response = await _apiClient.get('/api/auth/profile/');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final profile = UserProfile.fromJson(decoded);
      _setCurrentUser(profile);
      return _currentUser!;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      _setCurrentUser(null);
    }

    throw ApiException.fromResponse(response);
  }

  /// Partially update profile fields via PATCH /api/auth/profile/.
  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '/api/auth/profile/',
      body: data,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final updatedProfile = UserProfile.fromJson(decoded);
      _setCurrentUser(updatedProfile);
      return _currentUser!;
    }

    throw ApiException.fromResponse(response);
  }

  /// Dispose resources when service is destroyed.
  void dispose() {
    currentUserNotifier.dispose();
  }
}

/// Global shared instance for the application.
final AuthService defaultAuthService = AuthService();

