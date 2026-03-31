import 'dart:math';
import '../models/question.dart';

class MathGenerator {
  static final _random = Random();

  // Tạo câu hỏi ngẫu nhiên theo Level
  // Level 1: Cộng/trừ phạm vi 10
  // Level 2: Cộng/trừ phạm vi 100
  // Level 3: Nhân/chia cơ bản (bảng cửu chương 2-10)
  static Question generateQuestion(int level) {
    if (level == 1) return _generateAdditionOrSubtraction(10);
    if (level == 2) return _generateAdditionOrSubtraction(100);
    if (level == 3) return _generateMultiplicationOrDivision();
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
}
