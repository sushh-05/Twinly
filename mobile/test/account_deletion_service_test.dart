import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twinly/services/account_deletion_service.dart';

const twinlyKeys = [
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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      for (final key in twinlyKeys) key: 'test-value',
    });
  });

  test('successful deletion clears server, Firebase, and local data', () async {
    var serverCalled = false;
    var firebaseCalled = false;
    final service = AccountDeletionService(
      idToken: () async => 'token',
      serverDelete: (_) async => serverCalled = true,
      firebaseDelete: (_) async => firebaseCalled = true,
      hasAuthenticatedUser: () => true,
    );

    final result = await service.deleteAccount(demoMode: false);
    final prefs = await SharedPreferences.getInstance();

    expect(result.isComplete, isTrue);
    expect(serverCalled, isTrue);
    expect(firebaseCalled, isTrue);
    for (final key in twinlyKeys) {
      expect(prefs.containsKey(key), isFalse, reason: key);
    }
  });

  test('Firebase deletion failure is reported after server deletion', () async {
    final result = await AccountDeletionService(
      serverDelete: (_) async {},
      firebaseDelete: (_) async => throw FirebaseAuthException(code: 'unknown'),
      hasAuthenticatedUser: () => true,
    ).deleteAccount(demoMode: false);

    expect(result.serverDeleted, isTrue);
    expect(result.firebaseDeleted, isFalse);
    expect(result.localDeleted, isTrue);
    expect(result.isComplete, isFalse);
  });

  test('recent-login failure requests reauthentication', () async {
    final result = await AccountDeletionService(
      serverDelete: (_) async {},
      firebaseDelete: (_) async => throw FirebaseAuthException(
        code: 'requires-recent-login',
      ),
      hasAuthenticatedUser: () => true,
    ).deleteAccount(demoMode: false);

    expect(result.requiresReauthentication, isTrue);
    expect(result.isComplete, isFalse);
  });

  test('server deletion failure keeps Firebase account for retry', () async {
    var firebaseCalled = false;
    final result = await AccountDeletionService(
      serverDelete: (_) async => throw StateError('offline'),
      firebaseDelete: (_) async => firebaseCalled = true,
      hasAuthenticatedUser: () => true,
    ).deleteAccount(demoMode: false);

    expect(result.serverDeleted, isFalse);
    expect(result.firebaseDeleted, isFalse);
    expect(firebaseCalled, isFalse);
    expect(result.localDeleted, isTrue);
    expect(result.isComplete, isFalse);
  });

  test('repeated deletion is idempotent when no Firebase user remains', () async {
    final result = await AccountDeletionService(
      hasAuthenticatedUser: () => false,
    ).deleteAccount(demoMode: false);

    expect(result.isComplete, isTrue);
  });

  test('Demo Mode only clears local data', () async {
    var serverCalled = false;
    var firebaseCalled = false;
    final result = await AccountDeletionService(
      serverDelete: (_) async => serverCalled = true,
      firebaseDelete: (_) async => firebaseCalled = true,
    ).deleteAccount(demoMode: true);

    expect(result.isComplete, isTrue);
    expect(serverCalled, isFalse);
    expect(firebaseCalled, isFalse);
  });
}
