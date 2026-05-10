import 'package:flutter_test/flutter_test.dart';
import 'package:matchquizapp/providers/game_provider.dart';
import 'package:matchquizapp/services/database_service.dart';
import 'package:matchquizapp/models/custom_question.dart';

class MockDatabaseService implements DatabaseService {
  @override
  Future<List<CustomQuestion>> getActiveQuestions(int level) async => [];

  @override
  Future<void> saveGameSession({required String userId, required int level, required int score}) async {}

  // Override other required methods if necessary, or use a proper mocking library
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GameProvider Tests', () {
    late GameProvider provider;
    late MockDatabaseService mockDb;

    setUp(() {
      mockDb = MockDatabaseService();
      provider = GameProvider(databaseService: mockDb);
    });

    test('Initial state is correct', () {
      expect(provider.score, 0);
      expect(provider.questionCount, 0);
      expect(provider.isGameOver, false);
      expect(provider.currentQuestion, isNull);
    });

    test('startGame sets up correctly', () async {
      await provider.startGame(1);
      expect(provider.level, 1);
      expect(provider.score, 0);
      expect(provider.questionCount, 1);
      expect(provider.isGameOver, false);
      expect(provider.currentQuestion, isNotNull);
    });

    test('checkAnswer updates score for correct answer and moves to next question', () async {
      await provider.startGame(1);
      final firstQuestion = provider.currentQuestion!;
      
      provider.checkAnswer(firstQuestion.correctAnswer);
      expect(provider.score, 10);
      expect(provider.questionCount, 2);
    });

    test('checkAnswer ignores score for wrong answer but still moves to next question', () async {
      await provider.startGame(1);
      final firstQuestion = provider.currentQuestion!;
      
      final wrongAnswer = firstQuestion.options.firstWhere((opt) => opt != firstQuestion.correctAnswer);
      provider.checkAnswer(wrongAnswer);
      expect(provider.score, 0);
      expect(provider.questionCount, 2);
    });

    test('Game over after max questions', () async {
      await provider.startGame(1);
      for (int i = 0; i < provider.maxQuestions; i++) {
        expect(provider.isGameOver, false);
        provider.checkAnswer(0);
      }
      expect(provider.isGameOver, true);
    });

    test('startGame với level 4 sinh câu hỏi hỗn hợp', () async {
      await provider.startGame(4);
      expect(provider.level, 4);
      expect(provider.currentQuestion, isNotNull);
    });

    test('Score không vượt maxScore', () async {
      await provider.startGame(1);
      for (int i = 0; i < 15; i++) { // Thử trả lời nhiều hơn 10 câu
        if (!provider.isGameOver) {
          provider.checkAnswer(provider.currentQuestion!.correctAnswer, timeLeftRatio: 1.0);
        }
      }
      expect(provider.score, lessThanOrEqualTo(provider.maxQuestions * 20));
      expect(provider.questionCount, provider.maxQuestions + 1);
    });

    test('checkAnswer với timeLeftRatio = 1.0 cho điểm tối đa (20)', () async {
      await provider.startGame(1);
      final before = provider.score;
      provider.checkAnswer(provider.currentQuestion!.correctAnswer, timeLeftRatio: 1.0);
      expect(provider.score - before, 20); // 10 base + 10 bonus
    });

    test('checkAnswer với timeLeftRatio = 0.5 cho điểm trung bình (15)', () async {
      await provider.startGame(1);
      final before = provider.score;
      provider.checkAnswer(provider.currentQuestion!.correctAnswer, timeLeftRatio: 0.5);
      expect(provider.score - before, 15); // 10 base + 5 bonus
    });
  });
}
