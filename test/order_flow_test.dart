import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dabali/core/models/user_role.dart';
import 'package:dabali/core/session/session_providers.dart';
import 'package:dabali/core/utils/money.dart';
import 'package:dabali/main.dart';

/// Screens animate forever (floating bag, pulsing courier), so pumpAndSettle
/// never returns — advance a fixed number of frames instead.
Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Boots straight into the client space, skipping the sign-in form.
Future<void> _pumpSignedIn(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2700); // 400 x 900 logical
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [currentRoleProvider.overrideWith((ref) => UserRole.client)],
      child: const DabaliApp(),
    ),
  );
  await _advance(tester);
}

/// The vertical list of the current screen. Horizontal rows (filters, category
/// tabs) are Scrollables too, so match on direction rather than taking the first.
Finder _verticalScrollable() => find.byWidgetPredicate(
      (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );

/// Long lists build lazily, so an off-screen row has no element yet and no
/// finder can reach it. Scroll until it exists, then let the caller act on it.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;

  final scrollable = _verticalScrollable().first;

  // Jump back to the top first: the target may sit above the current offset, and
  // scrollUntilVisible only searches one direction.
  await tester.drag(scrollable, const Offset(0, 4000));
  await _advance(tester);
  if (finder.evaluate().isNotEmpty) return;

  await tester.scrollUntilVisible(finder, 250, scrollable: scrollable, maxScrolls: 30);
  await _advance(tester);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _advance(tester);
}

/// Prices render with a non-breaking thousands separator, so build the expected
/// text through the formatter rather than hardcoding the character.
Finder _price(int amount) => find.textContaining(Money.groupThousands(amount));

/// Adds a dish straight from the menu, via the button's accessible label.
Future<void> _addDish(WidgetTester tester, String dishName) =>
    _tap(tester, find.byTooltip('Ajouter $dishName'));

/// Puts one California Roll in the cart and opens the cart screen.
Future<void> _fillCartFromSushiMaster(WidgetTester tester) async {
  await _tap(tester, find.text('Sushi Master'));
  await _addDish(tester, 'California Roll (8 pièces)');
  await _tap(tester, find.text('Voir le panier'));
}

void main() {
  testWidgets('tapping a restaurant opens its menu', (tester) async {
    await _pumpSignedIn(tester);

    await _tap(tester, find.text('Le Petit Bistro Gourmet'));

    expect(find.text('Entrées'), findsWidgets);
    expect(find.text('Burrata des Pouilles'), findsOneWidget);
  });

  testWidgets('adding a plain dish shows the cart bar with its price', (tester) async {
    await _pumpSignedIn(tester);
    await _tap(tester, find.text('Le Petit Bistro Gourmet'));

    await _addDish(tester, 'Burrata des Pouilles');

    expect(find.text('Voir le panier'), findsOneWidget);
    expect(_price(4500), findsWidgets);
  });

  testWidgets('a customisable dish opens the options screen and totals them up',
      (tester) async {
    await _pumpSignedIn(tester);
    await _tap(tester, find.text('Pizzaria Milano'));
    await _tap(tester, find.byTooltip('Personnaliser Pizza Margherita'));

    expect(find.text('Choisir la taille'), findsOneWidget);
    expect(find.text('Suppléments'), findsOneWidget);

    // Médium is 4 000, large 5 000, double cheese +700.
    await _tap(tester, find.text('Large (40cm)'));
    await _tap(tester, find.text('Double Fromage'));

    expect(_price(5700), findsWidgets);
  });

  testWidgets('the cart totals items, delivery and service fees', (tester) async {
    await _pumpSignedIn(tester);
    await _fillCartFromSushiMaster(tester);

    expect(find.text('Votre commande'), findsOneWidget);

    await _tap(tester, find.textContaining('Continuer'));

    expect(find.text('Sous-total'), findsOneWidget);
    // Sushi Master delivers free, so 3 500 + 0 + 200 service = 3 700.
    expect(find.text('Gratuite'), findsOneWidget);
    expect(_price(3700), findsWidgets);
  });

  testWidgets('confirming an order clears the cart and opens tracking', (tester) async {
    await _pumpSignedIn(tester);
    await _fillCartFromSushiMaster(tester);
    await _tap(tester, find.textContaining('Continuer'));
    await _tap(tester, find.text('Confirmer la commande'));

    expect(find.text('Suivi en direct'), findsOneWidget);
    expect(find.textContaining('est en route'), findsOneWidget);
    // The cart emptied, so its bar is gone.
    expect(find.text('Voir le panier'), findsNothing);
  });

  testWidgets('a delivered order can be reviewed', (tester) async {
    await _pumpSignedIn(tester);
    await _fillCartFromSushiMaster(tester);
    await _tap(tester, find.textContaining('Continuer'));
    await _tap(tester, find.text('Confirmer la commande'));

    // Walk the order to "Arrivée" via the simulation button.
    await _tap(tester, find.text('Simuler l\'étape suivante'));
    await _tap(tester, find.text('Simuler l\'étape suivante'));

    await _tap(tester, find.text('Noter ma commande'));
    expect(find.text('Comment était votre repas ?'), findsOneWidget);

    // Submitting without a food rating is refused.
    await _tap(tester, find.text('Envoyer mon avis'));
    expect(find.text('Note ton repas pour continuer'), findsOneWidget);
  });

  testWidgets('changing the delivery address updates the cart', (tester) async {
    await _pumpSignedIn(tester);
    await _fillCartFromSushiMaster(tester);

    expect(find.text('Rue 12, Point E'), findsOneWidget);

    await _tap(tester, find.text('Modifier'));
    await _tap(tester, find.text('Bureau'));

    expect(find.text('Immeuble Horizon, Plateau'), findsOneWidget);
  });

  testWidgets('search matches restaurants by dish name', (tester) async {
    await _pumpSignedIn(tester);

    await _tap(tester, find.text('Recherche'));
    await tester.enterText(find.byType(TextField).first, 'Risotto');
    await _advance(tester);

    expect(find.text('Le Petit Bistro Gourmet'), findsOneWidget);
    expect(find.text('Sushi Master'), findsNothing);
  });

  testWidgets('a cart holds one restaurant at a time', (tester) async {
    await _pumpSignedIn(tester);

    await _tap(tester, find.text('Sushi Master'));
    await _addDish(tester, 'California Roll (8 pièces)');
    await _tap(tester, find.byIcon(Icons.arrow_back));

    await _tap(tester, find.text('The Burger Lab'));
    await _addDish(tester, 'Frites maison');

    expect(find.textContaining('Panier remplacé'), findsOneWidget);
  });
}
