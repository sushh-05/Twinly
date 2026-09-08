import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twinly/main.dart';

void main() {
  testWidgets('Twinly app smoke test', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TwinlyApp(initialLocation: '/onboarding')),
    );

    await tester.pump();

    expect(find.text('Welcome to Twinly'), findsOneWidget);
  });
}
