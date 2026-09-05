import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String email;
  final bool isFeminine;

  const UserProfile({
    required this.name,
    required this.email,
    required this.isFeminine,
  });
}

// Seeded in main.dart (before runApp) with whatever was found on disk,
// or null on first launch. Read once by UserProfileNotifier.build().
final initialUserProfileProvider = Provider<UserProfile?>((ref) {
  throw UnimplementedError(
    'initialUserProfileProvider must be overridden in main.dart before runApp',
  );
});

class UserProfileNotifier extends Notifier<UserProfile?> {
  static const _keyName = 'user_name';
  static const _keyEmail = 'user_email';
  static const _keyIsFeminine = 'user_is_feminine';

  @override
  UserProfile? build() {
    return ref.read(initialUserProfileProvider);
  }

  Future<void> save({
    required String name,
    required String email,
    required bool isFeminine,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setBool(_keyIsFeminine, isFeminine);
    state = UserProfile(name: name, email: email, isFeminine: isFeminine);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyIsFeminine);
    state = null;
  }

  // Called once at app startup, before runApp, to check what's on disk.
  static Future<UserProfile?> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyName);
    final email = prefs.getString(_keyEmail);
    final isFeminine = prefs.getBool(_keyIsFeminine);
    if (name == null || email == null || isFeminine == null) return null;
    return UserProfile(name: name, email: email, isFeminine: isFeminine);
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);
