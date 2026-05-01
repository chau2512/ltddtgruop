import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
  };
}

class QuizModel {
  final String quizId;
  final String title;
  final String topic;
  final String difficulty;
  final List<QuestionModel> questions;
  final String createdBy;
  final DateTime createdAt;

  QuizModel({
    required this.quizId,
    required this.title,
    required this.topic,
    required this.difficulty,
    required this.questions,
    required this.createdBy,
    required this.createdAt,
  });

  // Sửa hàm fromJson để nhận thêm tham số id từ Firestore Document
  factory QuizModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return QuizModel(
      quizId: id ?? json['quizId'] ?? '',
      title: json['title'] ?? '',
      topic: json['topic'] ?? '',
      difficulty: json['difficulty'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList() ?? [],
      createdBy: json['createdBy'] ?? '',
      // Gọi hàm static bên dưới để xử lý ngày tháng linh hoạt
      createdAt: _parseDate(json['createdAt']),
    );
  }

  // Hàm helper quan trọng để tránh crash app do sai kiểu ngày tháng
  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate(); // Dành cho Firebase Mobile/Web
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now(); // Dành cho JSON string
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'quizId': quizId,
    'title': title,
    'topic': topic,
    'difficulty': difficulty,
    'questions': questions.map((q) => q.toJson()).toList(),
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
  };
}