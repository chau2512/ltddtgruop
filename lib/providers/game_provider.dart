import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/custom_question.dart';
import '../utils/math_generator.dart';
import '../services/database_service.dart';

class GameProvider extends ChangeNotifier {
  final DatabaseService _dbService;

  GameProvider({DatabaseService? databaseService}) 
    : _dbService = databaseService ?? DatabaseService();

  int _score = 0;
  int _level = 1;
  int _questionCount = 0;
  final int _maxQuestions = 10; // Tổng số câu hỏi mỗi vòng
  
  Question? _currentQuestion;
  bool _isGameOver = false;
  String _userId = 'guest_user'; // Sẽ được cập nhật từ UserProvider

  // Custom questions từ Firestore
  List<CustomQuestion> _customQuestions = [];
  int _customQuestionIndex = 0;

  int get score => _score;
  int get level => _level;
  int get questionCount => _questionCount;
  int get maxQuestions => _maxQuestions;
  Question? get currentQuestion => _currentQuestion;
  bool get isGameOver => _isGameOver;

  /// Cập nhật userId từ UserProvider
  void setUserId(String userId) {
    _userId = userId;
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Bắt đầu game: tải câu hỏi tùy chỉnh trước, rồi generate
  Future<void> startGame(int level) async {
    _level = level;
    _score = 0;
    _questionCount = 0;
    _isGameOver = false;
    _customQuestionIndex = 0;
    _isLoading = true;
    notifyListeners(); // UI hiển thị loading ngay

    // Tải câu hỏi custom từ Firestore cho level này
    _customQuestions = await _dbService.getActiveQuestions(level);
    _customQuestions.shuffle(); // Xáo trộn thứ tự

    _isLoading = false;
    _generateNextQuestion();
  }

  void _generateNextQuestion() {
    _questionCount++;
    if (_questionCount > _maxQuestions) {
      _isGameOver = true;
      // Save session to Database với userId thực
      _dbService.saveGameSession(
        userId: 'test_user', // TODO: Lấy từ UserProvider thực tế
        level: _level,
        score: _score,
      );
    } else {
      // Ưu tiên câu hỏi tùy chỉnh, nếu hết → fallback auto-generate
      if (_customQuestionIndex < _customQuestions.length) {
        final cq = _customQuestions[_customQuestionIndex];
        _customQuestionIndex++;
        _currentQuestion = Question(
          numA: 0, // Không dùng cho custom question
          numB: 0,
          operatorSymbol: '',
          correctAnswer: cq.correctAnswer,
          options: List<int>.from(cq.options)..shuffle(),
          customQuestionText: cq.questionText,
        );
      } else {
        _currentQuestion = MathGenerator.generateQuestion(_level);
      }
    }
    notifyListeners();
  }

  void checkAnswer(int selectedAnswer, {double timeLeftRatio = 0.0}) {
    if (_currentQuestion != null && selectedAnswer == _currentQuestion!.correctAnswer) {
      int baseScore = 10;
      int bonusScore = (timeLeftRatio * 10).round();
      _score += baseScore + bonusScore;
    }
    _generateNextQuestion();
  }
}
