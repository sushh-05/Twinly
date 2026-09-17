import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'auth_service.dart';

class AccountDeletionResult {
  const AccountDeletionResult({
    required this.demoMode,
    required this.serverDeleted,
    required this.firebaseDeleted,
    required this.localDeleted,
    this.requiresReauthentication = false,
    this.errors = const [],
  });

  final bool demoMode;
  final bool serverDeleted;
  final bool firebaseDeleted;
  final bool localDeleted;
  final bool requiresReauthentication;
  final List<String> errors;

  bool get isComplete =>
      localDeleted &&
      (demoMode || (serverDeleted && firebaseDeleted)) &&
      errors.isEmpty;
}

class AccountDeletionService {
  AccountDeletionService({
    AuthService? authService,
    Future<String> Function()? idToken,
    Future<void> Function(String token)? serverDelete,
    Future<void> Function(String? password)? firebaseDelete,
    Future<void> Function()? localClear,
    bool Function()? hasAuthenticatedUser,
  })  : _authService = authService,
        _idToken = idToken,
        _serverDelete = serverDelete,
        _firebaseDelete = firebaseDelete,
        _localClear = localClear,
        _hasAuthenticatedUser = hasAuthenticatedUser;

  AuthService? _authService;
  final Future<String> Function()? _idToken;
  final Future<void> Function(String token)? _serverDelete;
  final Future<void> Function(String? password)? _firebaseDelete;
  final Future<void> Function()? _localClear;
  final bool Function()? _hasAuthenticatedUser;

  static const _localKeys = [
    'user_name',
    'user_email',
    'user_is_feminine',
    'twinly.fashion_profile',
    'twinly.fashion_saved_looks',
    'twinly_saved_profiles_json',
    'twinly_active_profile_id',
    'usage_tries',
    'usage_saves',
    'usage_last_garment',
  ];

  Future<AccountDeletionResult> deleteAccount({
    required bool demoMode,
    String? reauthenticationPassword,
  }) async {
    if (demoMode) {
      await (_localClear ?? clearLocalData)();
      return const AccountDeletionResult(
        demoMode: true,
        serverDeleted: true,
        firebaseDeleted: true,
        localDeleted: true,
      );
    }

    if (!(_hasAuthenticatedUser?.call() ?? (_auth.currentUser != null))) {
      await (_localClear ?? clearLocalData)();
      return const AccountDeletionResult(
        demoMode: false,
        serverDeleted: true,
        firebaseDeleted: true,
        localDeleted: true,
      );
    }

    var serverDeleted = false;
    var firebaseDeleted = false;
    var requiresReauthentication = false;
    final errors = <String>[];

    // Delete server data first. This keeps a Firebase account available for
    // retry if the authenticated server deletion fails.
    try {
      await _deleteServer();
      serverDeleted = true;
    } catch (_) {
      errors.add('Your online profile could not be deleted.');
    }

    if (serverDeleted) {
      try {
        await _deleteFirebase(reauthenticationPassword);
        firebaseDeleted = true;
      } on FirebaseAuthException catch (error) {
        requiresReauthentication = error.code == 'requires-recent-login';
        errors.add(
          requiresReauthentication
              ? 'Please re-enter your password to confirm account deletion.'
              : 'Your Firebase account could not be deleted.',
        );
      } catch (_) {
        errors.add('Your Firebase account could not be deleted.');
      }
    } else {
      errors.add('Your Firebase account was kept so deletion can be retried.');
    }

    var localDeleted = false;
    try {
      await (_localClear ?? clearLocalData)();
      localDeleted = true;
    } catch (_) {
      errors.add('Some data on this device could not be cleared.');
    }

    return AccountDeletionResult(
      demoMode: false,
      serverDeleted: serverDeleted,
      firebaseDeleted: firebaseDeleted,
      localDeleted: localDeleted,
      requiresReauthentication: requiresReauthentication,
      errors: errors,
    );
  }

  Future<void> deleteServerProfile() async {
    final token = await (_idToken ?? _auth.idToken)();
    final response = await http.delete(
      Uri.parse('${AppConfig.apiBaseUrl}/api/account'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Server deletion failed: ${response.statusCode}');
    }
  }

  Future<void> _deleteServer() {
    return _serverDelete == null ? deleteServerProfile() : _serverDelete!('');
  }

  Future<void> _deleteFirebase(String? password) {
    return _firebaseDelete == null
        ? _auth.deleteAccount(password: password)
        : _firebaseDelete!(password);
  }

  AuthService get _auth => _authService ??= AuthService();

  Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _localKeys) {
      await prefs.remove(key);
    }
  }
}
