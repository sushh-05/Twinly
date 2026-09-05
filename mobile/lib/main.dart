import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'firebase_options.dart';

import 'core/router.dart';
import 'core/providers/user_profile_state.dart';

// TODO: replace with your actual RevenueCat public API keys
// (Project settings > API keys in the RevenueCat dashboard — use the
// platform-specific PUBLIC key, never the secret key, in client code)
const _revenueCatAndroidKey = 'goog_XXXXXXXXXXXXXXXXXXXXXXXXXXX';
const _revenueCatIosKey = 'appl_XXXXXXXXXXXXXXXXXXXXXXXXXXX';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _configureRevenueCat();

  // Check disk for an existing profile before the app builds, so a
  // returning user skips onboarding entirely instead of seeing it flash by.
  final existingProfile = await UserProfileNotifier.loadFromDisk();
  final initialLocation = existingProfile != null ? '/avatar' : '/onboarding';

  runApp(
    ProviderScope(
      overrides: [
        initialUserProfileProvider.overrideWithValue(existingProfile),
      ],
      child: TwinlyApp(initialLocation: initialLocation),
    ),
  );
}

Future<void> _configureRevenueCat() async {
  final apiKey = Platform.isAndroid ? _revenueCatAndroidKey : _revenueCatIosKey;

  await Purchases.setLogLevel(
    LogLevel.debug,
  ); // switch to LogLevel.info or remove before release
  await Purchases.configure(PurchasesConfiguration(apiKey));
}

class TwinlyApp extends StatelessWidget {
  const TwinlyApp({super.key, required this.initialLocation});

  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Twinly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: createRouter(initialLocation: initialLocation),
    );
  }
}