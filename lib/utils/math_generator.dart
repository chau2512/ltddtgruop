import 'dart:math';
import '../models/question.dart';

class MathGenerator {
  static final _random = Random();

  // Tạo câu hỏi ngẫu nhiên theo Level
  // Level 1: Cộng/trừ phạm vi 10
  // Level 2: Cộng/trừ phạm vi 100
  // Level 3: Nhân/chia cơ bản (bảng cửu chương 2-10)
  // Level 4: Hỗn hợp — a + b×c hoặc a - b×c (ưu tiên nhân trước)
  static Question generateQuestion(int level) {
    if (level == 1) return _generateAdditionOrSubtraction(10);
    if (level == 2) return _generateAdditionOrSubtraction(100);
    if (level == 3) return _generateMultiplicationOrDivision();
    if (level == 4) return _generateMixed();
    return _generateAdditionOrSubtraction(10); // fallback
  }

  static Question _generateAdditionOrSubtraction(int maxVal) {
    bool isAddition = _random.nextBool();
    if (isAddition) {
      // Đảm bảo tổng <= maxVal, A và B > 0
      int a = _random.nextInt(maxVal - 1) + 1;
      int b = _random.nextInt(maxVal - a) + 1;
      int answer = a + b;
      return _buildQuestion(a, b, '+', answer);
    } else {
      // Đảm bảo A > B để kết quả luôn dương (thích hợp với cấp 1)
      int a = _random.nextInt(maxVal - 1) + 2; 
      int b = _random.nextInt(a - 1) + 1; 
      int answer = a - b;
      return _buildQuestion(a, b, '-', answer);
    }
  }

  static Question _generateMultiplicationOrDivision() {
    bool isMultiplication = _random.nextBool();
    if (isMultiplication) {
      int a = _random.nextInt(9) + 2; // 2 tới 10
      int b = _random.nextInt(9) + 2; // 2 tới 10
      int answer = a * b;
      return _buildQuestion(a, b, 'x', answer);
    } else {
      int b = _random.nextInt(9) + 2; // Số chia (2 tới 10)
      int answer = _random.nextInt(9) + 2; // Kết quả (Thương số)
      int a = b * answer; // Đảm bảo phép chia luôn tròn
      return _buildQuestion(a, b, '÷', answer);
    }
  }

  static Question _buildQuestion(int a, int b, String op, int answer) {
    List<int> options = [answer];
    while (options.length < 4) {
      // Sinh câu trả lời sai (gần giống đáp án thật để đánh lừa)
      int offset = _random.nextInt(11) - 5; // Từ -5 tới +5
      if (offset == 0) offset = 6; // Không trùng nếu offset = 0
      
      int fake = answer + offset;
      if (fake >= 0 && !options.contains(fake)) {
        options.add(fake);
      }
    }
    // Đảo ngẫu nhiên vị trí các đáp án
    options.shuffle(_random);
    
    return Question(
      numA: a,
      numB: b,
      operatorSymbol: op,
      correctAnswer: answer,
      options: options,
    );
  }

  /// Level 4: Phép tính hỗn hợp — ưu tiên nhân trước cộng/trừ
  /// Dạng 1: a + b × c = ?
  /// Dạng 2: a - b × c = ? (đảm bảo kết quả dương)
  static Question _generateMixed() {
    final bool isAddition = _random.nextBool();

    // b, c nhỏ để tránh số quá lớn (2–6 × 2–6 = 4–36)
    int b = _random.nextInt(5) + 2; // 2..6
    int c = _random.nextInt(5) + 2; // 2..6
    int bc = b * c; // tích b×c, tối đa 36

    int a;
    int answer;
    String questionText;

    if (isAddition) {
      // a + b×c — a từ 1..20
      a = _random.nextInt(20) + 1;
      answer = a + bc;
      questionText = '$a + $b × $c = ?';
    } else {
      // a - b×c — a phải > bc để kết quả dương
      a = bc + _random.nextInt(20) + 1; // a = bc + 1..20
      answer = a - bc;
      questionText = '$a - $b × $c = ?';
    }

    // Tạo 3 đáp án sai gần đáp án đúng (offset ±1..8)
    List<int> options = [answer];
    while (options.length < 4) {
      int offset = _random.nextInt(8) + 1; // 1..8
      if (_random.nextBool()) offset = -offset;
      int fake = answer + offset;
      if (fake > 0 && !options.contains(fake)) {
        options.add(fake);
      }
    }
    options.shuffle(_random);

    return Question(
      numA: a,
      numB: b,
      operatorSymbol: 'x',
      correctAnswer: answer,
      options: options,
      customQuestionText: questionText, // Hiển thị đúng dạng hỗn hợp
    );
  }
}
