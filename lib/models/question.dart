class Question {
  final int numA;
  final int numB;
  final String operatorSymbol;
  final int correctAnswer;
  final List<int> options;
  final String? customQuestionText; // Cho câu hỏi tùy chỉnh từ Admin

  Question({
    required this.numA,
    required this.numB,
    required this.operatorSymbol,
    required this.correctAnswer,
    required this.options,
    this.customQuestionText,
  });

  /// Nếu có customQuestionText → dùng nó, nếu không → tạo từ numA/numB
  String get questionText => customQuestionText ?? '$numA $operatorSymbol $numB = ?';
}
