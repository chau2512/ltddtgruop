import 'package:cloud_firestore/cloud_firestore.dart';

class CustomQuestion {
  final String? id; // Firestore document ID (null khi tạo mới)
  final String questionText;
  final int correctAnswer;
  final List<int> options; // 4 đáp án (bao gồm đáp án đúng)
  final int level; // 1, 2, hoặc 3
  final bool isActive;
  final Timestamp? createdAt;

  CustomQuestion({
    this.id,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.level,
    this.isActive = true,
    this.createdAt,
  });

  /// Tạo từ Firestore document
  factory CustomQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomQuestion(
      id: doc.id,
      questionText: data['questionText'] ?? '',
      correctAnswer: data['correctAnswer'] ?? 0,
      options: List<int>.from(data['options'] ?? []),
      level: data['level'] ?? 1,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  /// Chuyển thành Map để lưu lên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'options': options,
      'level': level,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  CustomQuestion copyWith({
    String? id,
    String? questionText,
    int? correctAnswer,
    List<int>? options,
    int? level,
    bool? isActive,
  }) {
    return CustomQuestion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      level: level ?? this.level,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
