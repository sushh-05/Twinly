import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:twinly/features/onboarding/screen.dart';
import 'package:twinly/core/providers/avatar_profiles_state.dart';
import 'package:twinly/core/providers/avatar_state.dart';
import 'package:twinly/core/providers/garment_state.dart';
import 'package:twinly/core/providers/saved_avatars_state.dart';
import 'package:twinly/core/providers/theme_state.dart';
import 'package:twinly/core/providers/usage_limits_state.dart';
import 'package:twinly/core/providers/user_profile_state.dart';
import 'package:twinly/services/revenuecat_service.dart';

Widget authApp() => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => RevenueCatService(enabled: false)),
    ChangeNotifierProvider(create: (_) => ThemeModeState()),
    ChangeNotifierProvider(create: (_) => AvatarMeasurementsState()),
    ChangeNotifierProvider(create: (_) => UserProfileState()),
    ChangeNotifierProvider(create: (_) => UsageLimitsState()),
    ChangeNotifierProvider(create: (_) => SavedAvatarsState()),
    ChangeNotifierProvider(create: (_) => SelectedGarmentState()),
    ChangeNotifierProvider(create: (_) => CatalogState()),
    ChangeNotifierProxyProvider<AvatarMeasurementsState, AvatarProfilesState>(
      create: (context) =>
          AvatarProfilesState(context.read<AvatarMeasurementsState>()),
      update: (_, m, current) => current ?? AvatarProfilesState(m),
    ),
  ],
  child: const MaterialApp(home: OnboardingScreen()),
);

void main() {
  testWidgets('renders signup fields', (tester) async {
    await tester.pumpWidget(authApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Twinly'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.textContaining('Create Password'), findsOneWidget);
    expect(find.textContaining('Confirm Password'), findsOneWidget);
  });

  testWidgets('validates empty signup', (tester) async {
    await tester.pumpWidget(authApp());
    await tester.pumpAndSettle();
    final button = find.textContaining('Create Account & Start Fitting');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
