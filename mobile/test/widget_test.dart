import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twinly/main.dart';
import 'package:twinly/core/providers/theme_state.dart';

void main() {
  testWidgets('Twinly app smoke test', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ThemeModeState())],
        child: const TwinlyApp(initialLocation: '/onboarding'),
      ),
    );

    await tester.pump();

    expect(find.text('Welcome to Twinly'), findsOneWidget);
  });
}
