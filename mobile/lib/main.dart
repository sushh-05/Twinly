import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'firebase_options.dart';

import 'core/router.dart';
import 'core/providers/user_profile_state.dart';

// Supply these only for a build that should use real purchases:
//   flutter run --dart-define=REVENUECAT_ANDROID_KEY=goog_...
// Use RevenueCat's *public* SDK key here, never its secret API key.
const _revenueCatAndroidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
const _revenueCatIosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');

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
  // purchases_flutter uses native store SDKs. A browser is useful for UI
  // development, but it cannot configure an Android or iOS purchase SDK.
  if (kIsWeb) {
    debugPrint('RevenueCat is unavailable on web; running in local demo mode.');
    return;
  }

  final apiKey = Platform.isAndroid ? _revenueCatAndroidKey : _revenueCatIosKey;

  // A blank key is the normal local/demo configuration. The rest of the app
  // still runs, while purchases remain intentionally unavailable until the
  // team configures its RevenueCat project.
  if (apiKey.isEmpty) {
    debugPrint('RevenueCat not configured; running in local demo mode.');
    return;
  }

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
