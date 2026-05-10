import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:matchquizapp/screens/result_screen.dart';
import 'package:matchquizapp/providers/game_provider.dart';
import 'package:matchquizapp/services/database_service.dart';
import 'package:matchquizapp/models/custom_question.dart';

class MockDatabaseService implements DatabaseService {
  @override
  Future<List<CustomQuestion>> getActiveQuestions(int level) async => [];
  @override
  Future<void> saveGameSession({required String userId, required int level, required int score}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildTestApp(GameProvider gameProvider) {
    return MaterialApp(
      home: ChangeNotifierProvider<GameProvider>.value(
        value: gameProvider,
        child: const ResultScreen(),
      ),
    );
  }

  group('ResultScreen Widget Tests', () {
    late GameProvider gameProvider;
    late MockDatabaseService mockDb;

    setUp(() {
      mockDb = MockDatabaseService();
      gameProvider = GameProvider(databaseService: mockDb);
    });

    testWidgets('Hiển thị "TUYỆT VỜI!" khi điểm cao (100/100)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Giả lập trạng thái game hoàn thành với điểm tối đa
      await gameProvider.startGame(1);
      for (int i = 0; i < 10; i++) {
        gameProvider.checkAnswer(gameProvider.currentQuestion!.correctAnswer, timeLeftRatio: 1.0);
      }
      expect(gameProvider.isGameOver, true);
      expect(gameProvider.score, 200); // 10 * (10+10)

      await tester.pumpWidget(buildTestApp(gameProvider));
      await tester.pump(const Duration(milliseconds: 100)); // Start animations

      expect(find.text('TUYỆT VỜI!'), findsOneWidget);
      expect(find.text('200 / 100'), findsOneWidget); // maxQuestions=10 * 10 = 100 base
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Hiển thị "CỐ GẮNG LÊN NÀO!" khi điểm thấp (0/100)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await gameProvider.startGame(1);
      for (int i = 0; i < 10; i++) {
        gameProvider.checkAnswer(-1); // Trả lời sai
      }
      expect(gameProvider.score, 0);

      await tester.pumpWidget(buildTestApp(gameProvider));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('CỐ GẮNG LÊN NÀO!'), findsOneWidget);
      expect(find.text('0 / 100'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Nút "VỀ MÀN HÌNH CHÍNH" hoạt động', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await gameProvider.startGame(1);
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => buildTestApp(gameProvider))),
            child: const Text('Go'),
          ),
        ),
      ));
      
      await tester.tap(find.text('Go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ResultScreen), findsOneWidget);
      
      await tester.tap(find.text('VỀ MÀN HÌNH CHÍNH'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ResultScreen), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
