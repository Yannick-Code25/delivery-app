import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabali/main.dart';

void main() {
  testWidgets('App boots on the welcome screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DabaliApp()));
    await tester.pump();

    expect(find.textContaining('Dabali'), findsWidgets);
    expect(find.text('Commencer'), findsOneWidget);
  });
}
