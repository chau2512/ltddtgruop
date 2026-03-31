class Question {
  final int numA;
  final int numB;
  final String operatorSymbol;
  final int correctAnswer;
  final List<int> options;

  Question({
    required this.numA,
    required this.numB,
    required this.operatorSymbol,
    required this.correctAnswer,
    required this.options,
  });

  String get questionText => '$numA $operatorSymbol $numB = ?';
}
