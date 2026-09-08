import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twinly/core/providers/theme_state.dart';
import 'package:twinly/features/onboarding/screen.dart';

void main() {
  group('Onboarding & Authentication Screen Tests', () {
    testWidgets('Renders Create Account with password, confirm password, and theme toggle', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header & brand
      expect(find.text('Welcome to Twinly'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Verify password & confirm password fields exist in Create Account
      expect(find.textContaining('Create Password'), findsOneWidget);
      expect(find.textContaining('Confirm Password'), findsOneWidget);

      // Verify theme toggle button exists (by type or tooltip)
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

      // Verify Guest bypass is removed
      expect(find.text('Skip (Guest)'), findsNothing);
    });

    testWidgets('Tapping theme toggle switches between Dark and Light mode', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              capturedRef = ref;
              return const MaterialApp(
                home: OnboardingScreen(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(capturedRef.read(themeModeProvider), ThemeMode.dark);

      // Tap theme toggle button
      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pumpAndSettle();

      expect(capturedRef.read(themeModeProvider), ThemeMode.light);
    });

    testWidgets('Validates authentication rules on empty / invalid inputs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: OnboardingScreen()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final buttonFinder = find.textContaining('Create Account & Start Fitting');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Should show validation error snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('at least 2 characters'), findsOneWidget);
    });

    testWidgets('Switches between Create Account and Sign In tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Sign In tab
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In to Your Account'), findsOneWidget);
      expect(find.text('Sign In to Twinly'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
    });
  });
}
