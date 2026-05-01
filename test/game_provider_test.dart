import 'package:flutter_test/flutter_test.dart';
import 'package:matchquizapp/providers/game_provider.dart';

void main() {
  group('GameProvider Tests', () {
    late GameProvider provider;

    setUp(() {
      provider = GameProvider();
    });

    test('Initial state is correct', () {
      expect(provider.score, 0);
      expect(provider.questionCount, 0);
      expect(provider.isGameOver, false);
      expect(provider.currentQuestion, isNull);
    });

    test('startGame sets up correctly', () {
      provider.startGame(1);
      expect(provider.level, 1);
      expect(provider.score, 0);
      expect(provider.questionCount, 1);
      expect(provider.isGameOver, false);
      expect(provider.currentQuestion, isNotNull);
    });

    test('checkAnswer updates score for correct answer and moves to next question', () {
      provider.startGame(1);
      final firstQuestion = provider.currentQuestion!;
      
      provider.checkAnswer(firstQuestion.correctAnswer);
      expect(provider.score, 10);
      expect(provider.questionCount, 2);
    });

    test('checkAnswer ignores score for wrong answer but still moves to next question', () {
      provider.startGame(1);
      final firstQuestion = provider.currentQuestion!;
      
      final wrongAnswer = firstQuestion.options.firstWhere((opt) => opt != firstQuestion.correctAnswer);
      provider.checkAnswer(wrongAnswer);
      expect(provider.score, 0);
      expect(provider.questionCount, 2);
    });

    test('Game over after max questions', () {
      provider.startGame(1);
      for (int i = 0; i < provider.maxQuestions; i++) {
        expect(provider.isGameOver, false);
        provider.checkAnswer(0);
      }
      expect(provider.isGameOver, true);
    });
  });
}
