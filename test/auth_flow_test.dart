import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabali/main.dart';

/// The auth screens animate forever (floating bag, pulse rings), so
/// pumpAndSettle never returns — advance a fixed number of frames instead.
Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

/// The default 800x600 test surface is wider and much shorter than a phone,
/// which pushes the auth forms out of the viewport. Use a phone-shaped window.
Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2700); // 400 x 900 logical
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const ProviderScope(child: DabaliApp()));
  await _advance(tester);
}

/// Scrolls the target into view before tapping it. A row far down a lazy list
/// has no element yet, so scroll the page until it is built.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    final scrollable = find.byWidgetPredicate(
      (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(finder, 250, scrollable: scrollable.first);
    await _advance(tester);
  }

  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _advance(tester);
}

Future<void> _openLogin(WidgetTester tester) =>
    _tap(tester, find.widgetWithText(TextButton, 'Se connecter'));

Future<void> _signIn(WidgetTester tester, String email) async {
  await _openLogin(tester);

  await tester.enterText(find.byType(TextFormField).first, email);
  await tester.enterText(find.byType(TextFormField).last, 'motdepasse123');
  await _advance(tester);

  await _tap(tester, find.widgetWithText(ElevatedButton, 'Se connecter'));
}

void main() {
  testWidgets('a regular email lands in the client space with its tabs', (tester) async {
    await _pumpApp(tester);
    await _signIn(tester, 'marie@exemple.com');

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Commandes'), findsOneWidget);
    expect(find.text('The Burger Lab'), findsOneWidget);
  });

  testWidgets('an admin email lands in the admin space', (tester) async {
    await _pumpApp(tester);
    await _signIn(tester, 'admin@dabali.com');

    expect(find.text('Espace Admin'), findsOneWidget);
  });

  testWidgets('a livreur email lands in the livreur space', (tester) async {
    await _pumpApp(tester);
    await _signIn(tester, 'livreur@dabali.com');

    expect(find.text('Espace Livreur'), findsOneWidget);
  });

  testWidgets('signing in requires an email and a password', (tester) async {
    await _pumpApp(tester);
    await _openLogin(tester);

    await _tap(tester, find.widgetWithText(ElevatedButton, 'Se connecter'));

    expect(find.text('Renseigne ton email'), findsOneWidget);
    expect(find.text('Renseigne ton mot de passe'), findsOneWidget);
  });

  testWidgets('switching client tabs keeps the shell mounted', (tester) async {
    await _pumpApp(tester);
    await _signIn(tester, 'marie@exemple.com');

    await tester.tap(find.text('Commandes'));
    await _advance(tester);

    expect(find.text('Mes commandes'), findsOneWidget);
    // Tabs remain visible: the shell was not replaced.
    expect(find.text('Accueil'), findsOneWidget);
  });

  testWidgets('signing out from the profile tab returns to welcome', (tester) async {
    await _pumpApp(tester);
    await _signIn(tester, 'marie@exemple.com');

    await tester.tap(find.text('Profil'));
    await _advance(tester);

    await _tap(tester, find.text('Se déconnecter'));

    expect(find.text('Commencer'), findsOneWidget);
  });

  testWidgets('signing up is blocked until the terms are accepted', (tester) async {
    await _pumpApp(tester);
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Commencer'));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Marie Koffi');
    await tester.enterText(fields.at(1), 'marie@exemple.com');
    await tester.enterText(fields.at(2), '+33 6 12 34 56 78');
    await tester.enterText(fields.at(3), 'motdepasse123');
    await _advance(tester);

    await _tap(tester, find.widgetWithText(ElevatedButton, 'Créer mon compte'));
    expect(find.text('Tu dois accepter les conditions pour continuer'), findsOneWidget);

    await _tap(tester, find.byType(Checkbox));
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Créer mon compte'));

    // New accounts are clients for now.
    expect(find.text('Accueil'), findsOneWidget);
  });
}
