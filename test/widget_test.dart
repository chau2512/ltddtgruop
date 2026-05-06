import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchquizapp/main.dart';
import 'package:matchquizapp/providers/game_provider.dart';
import 'package:matchquizapp/screens/game_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame. Ensure Provider wraps the test app.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameProvider()),
        ],
        child: const MathQuizApp(),
      ),
    );

    // Verify Main Screen
    expect(find.text('Toán Trắc Nghiệm'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Cấp 1'), findsOneWidget);

    // Tap level 1 to start game
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cấp 1'));
    await tester.pumpAndSettle();

    // Verify Game Screen is active
    expect(find.textContaining('1/10'), findsOneWidget);
    expect(find.text('⭐ 0'), findsOneWidget);

    // Find the answer choices (ElevatedButton) on the GameScreen
    final answerButtons = find.descendant(
      of: find.byType(GridView),
      matching: find.byType(ElevatedButton),
    );
    expect(answerButtons, findsWidgets);

    // Tap first answer to proceed
    await tester.tap(answerButtons.first);
    await tester.pump(const Duration(milliseconds: 1500));

    // Should be on Question 2
    expect(find.textContaining('2/10'), findsOneWidget);

    // Pump time to let flutter_animate entrance animations finish for Question 2
    await tester.pump(const Duration(milliseconds: 1500));

    // Unmount to dispose AnimationController and clear pending timers
    await tester.pumpWidget(const SizedBox());
  });
}
