import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'firebase_options.dart';
import 'config/app_config.dart';
import 'services/revenuecat_service.dart';
import 'services/fashion_state.dart';

import 'package:go_router/go_router.dart';

import 'core/router.dart';
import 'core/providers/theme_state.dart';
import 'core/providers/user_profile_state.dart';
import 'core/providers/avatar_state.dart';
import 'core/providers/avatar_profiles_state.dart';
import 'core/providers/usage_limits_state.dart';
import 'core/providers/saved_avatars_state.dart';
import 'core/providers/garment_state.dart';

// Supply these only for a build that should use real purchases:
//   flutter run --dart-define=REVENUECAT_ANDROID_API_KEY=goog_...
// Use RevenueCat's *public* SDK key here, never its secret API key.
const _revenueCatIosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');

late final RevenueCatService revenueCatService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.demoMode) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (error) {
      debugPrint('Firebase initialization failed: $error');
    }
  }

  await _configureRevenueCat();

  // Check disk for an existing profile before the app builds, so a
  // returning user skips onboarding entirely instead of seeing it flash by.
  final existingProfile = await UserProfileState.loadFromDisk();
  final fashionProfile = await FashionProfileState.load();
  final initialLocation = fashionProfile != null ? '/avatar' : '/onboarding';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<RevenueCatService>.value(
          value: revenueCatService,
        ),
        ChangeNotifierProvider(
          create: (_) => FashionProfileState(fashionProfile),
        ),
        ChangeNotifierProvider(create: (_) => SavedLooksState()),
        ChangeNotifierProvider(create: (_) => ThemeModeState()),
        ChangeNotifierProvider(create: (_) => AvatarMeasurementsState()),
        ChangeNotifierProvider(
          create: (_) => UserProfileState(existingProfile),
        ),
        ChangeNotifierProvider(create: (_) => UsageLimitsState()),
        ChangeNotifierProvider(create: (_) => SavedAvatarsState()),
        ChangeNotifierProvider(create: (_) => SelectedGarmentState()),
        ChangeNotifierProvider(create: (_) => CatalogState()),
        ChangeNotifierProxyProvider<
          AvatarMeasurementsState,
          AvatarProfilesState
        >(
          create: (context) =>
              AvatarProfilesState(context.read<AvatarMeasurementsState>()),
          update: (_, measurements, current) =>
              current ?? AvatarProfilesState(measurements),
        ),
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
    revenueCatService = RevenueCatService(
      enabled: false,
      initialError: 'RevenueCat is unavailable on web.',
    );
    return;
  }

  final apiKey = Platform.isAndroid
      ? revenueCatAndroidApiKey
      : _revenueCatIosKey;

  if (Platform.isAndroid && AppConfig.useRevenueCat && !AppConfig.demoMode) {
    RevenueCatService.validateAndroidApiKey(apiKey);
  }

  // A blank key is the normal local/demo configuration. The rest of the app
  // still runs, while purchases remain intentionally unavailable until the
  // team configures its RevenueCat project.
  if (!AppConfig.useRevenueCat || apiKey.isEmpty) {
    debugPrint('RevenueCat not configured; running in local demo mode.');
    revenueCatService = RevenueCatService(
      enabled: false,
      initialError: !AppConfig.useRevenueCat
          ? 'RevenueCat is disabled for this build.'
          : 'RevenueCat API key is missing for this platform.',
    );
    return;
  }
  try {
    if (kDebugMode) await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(apiKey));
    revenueCatService = RevenueCatService(enabled: true);
    revenueCatService.listenForUpdates();
  } catch (error) {
    debugPrint('RevenueCat initialization failed: $error');
    revenueCatService = RevenueCatService(
      enabled: false,
      initialError: 'RevenueCat initialization failed. Check the Test Store API key and platform configuration.',
    );
  }
}

class TwinlyApp extends StatefulWidget {
  const TwinlyApp({super.key, required this.initialLocation});

  final String initialLocation;

  @override
  State<TwinlyApp> createState() => _TwinlyAppState();
}

class _TwinlyAppState extends State<TwinlyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(initialLocation: widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeModeState>().mode;

    return MaterialApp.router(
      title: 'Twinly',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAF6F1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA06B5B),
          brightness: Brightness.light,
          surface: const Color(0xFFFFFCF9),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF6F1),
          foregroundColor: Color(0xFF2B2622),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF211D1A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA06B5B),
          brightness: Brightness.dark,
          surface: const Color(0xFF161616),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF161616),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Colors.white10),
          ),
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
