import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabali/features/splash/presentation/splash_screen.dart';
import 'package:dabali/main.dart';

void main() {
  testWidgets('the app opens on the launch animation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DabaliApp()));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Commencer'), findsNothing);
  });

  testWidgets('the launch animation hands over to the welcome screen',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DabaliApp()));
    await tester.pump();
    await tester.pump(SplashScreen.duration + const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Dabali'), findsWidgets);
    expect(find.text('Commencer'), findsOneWidget);
  });

  testWidgets('tapping the launch animation skips it', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DabaliApp()));
    await tester.pump();

    await tester.tap(find.byType(SplashScreen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Commencer'), findsOneWidget);
  });
}
