import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/math_generator.dart';
import '../services/database_service.dart';

class GameProvider extends ChangeNotifier {
  int _score = 0;
  int _level = 1;
  int _questionCount = 0;
  final int _maxQuestions = 10; // Tổng số câu hỏi mỗi vòng
  
  Question? _currentQuestion;
  bool _isGameOver = false;

  int get score => _score;
  int get level => _level;
  int get questionCount => _questionCount;
  int get maxQuestions => _maxQuestions;
  Question? get currentQuestion => _currentQuestion;
  bool get isGameOver => _isGameOver;

  void startGame(int level) {
    _level = level;
    _score = 0;
    _questionCount = 0;
    _isGameOver = false;
    _generateNextQuestion();
  }

  void _generateNextQuestion() {
    _questionCount++;
    if (_questionCount > _maxQuestions) {
      _isGameOver = true;
      // Save session to Database
      DatabaseService().saveGameSession(
        userId: 'guest_user_123',
        level: _level,
        score: _score,
      );
    } else {
      _currentQuestion = MathGenerator.generateQuestion(_level);
    }
    notifyListeners();
  }

  void checkAnswer(int selectedAnswer) {
    if (_currentQuestion != null && selectedAnswer == _currentQuestion!.correctAnswer) {
      _score += 10;
    }
    _generateNextQuestion();
  }
}
