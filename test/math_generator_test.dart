import 'package:flutter_test/flutter_test.dart';
import 'package:matchquizapp/utils/math_generator.dart';

void main() {
  group('MathGenerator Tests', () {
    test('Level 1 generates addition/subtraction within 10', () {
      for (int i = 0; i < 50; i++) {
        final q = MathGenerator.generateQuestion(1);
        expect(q.options.length, 4);
        expect(q.options.toSet().length, 4, reason: 'Options must be unique');
        expect(q.options.contains(q.correctAnswer), isTrue);

        if (q.operatorSymbol == '+') {
          expect(q.numA + q.numB, q.correctAnswer);
          expect(q.correctAnswer, lessThanOrEqualTo(10));
        } else if (q.operatorSymbol == '-') {
          expect(q.numA - q.numB, q.correctAnswer);
          expect(q.correctAnswer, greaterThanOrEqualTo(0));
          expect(q.numA, greaterThan(q.numB));
        }
      }
    });

    test('Level 2 generates addition/subtraction within 100', () {
      final q = MathGenerator.generateQuestion(2);
      expect(q.options.length, 4);
      if (q.operatorSymbol == '+') {
        expect(q.numA + q.numB, q.correctAnswer);
      } else {
        expect(q.numA - q.numB, q.correctAnswer);
      }
    });

    test('Level 3 generates multiplication/division', () {
      final q = MathGenerator.generateQuestion(3);
      expect(q.operatorSymbol, anyOf('x', '÷'));
      if (q.operatorSymbol == 'x') {
        expect(q.numA * q.numB, q.correctAnswer);
      } else {
        expect(q.numA / q.numB, q.correctAnswer);
      }
    });

    test('Level 4 generates mixed operations (+, -, ×, ÷)', () {
      for (int i = 0; i < 200; i++) {
        final q = MathGenerator.generateQuestion(4);

        // Phải có customQuestionText (dạng hỗn hợp)
        expect(q.customQuestionText, isNotNull);

        // Phải có 1 phép toán ưu tiên (× hoặc ÷) và 1 phép toán thường (+ hoặc -)
        final text = q.questionText;
        expect(text.contains('×') || text.contains('÷'), isTrue);
        expect(text.contains('+') || text.contains('-'), isTrue);

        // Đáp án đúng phải dương (hoặc bằng 0)
        expect(q.correctAnswer, greaterThanOrEqualTo(0));

        // Phải có đúng 4 đáp án và không trùng
        expect(q.options.length, 4);
        expect(q.options.toSet().length, 4, reason: 'Options must be unique');
        expect(q.options.contains(q.correctAnswer), isTrue);

        // Parse biểu thức (VD: "5 + 3 × 4 = ?")
        final parts = text.replaceAll(' = ?', '').split(' ');
        expect(parts.length, 5); // num1 op1 num2 op2 num3

        final num1 = int.parse(parts[0]);
        final op1 = parts[1];
        final num2 = int.parse(parts[2]);
        final op2 = parts[3];
        final num3 = int.parse(parts[4]);

        int calculatedResult = 0;

        // Xử lý ưu tiên (Nhân chia trước, cộng trừ sau)
        if (op1 == '×') {
          calculatedResult = num1 * num2;
          if (op2 == '+') calculatedResult += num3;
          if (op2 == '-') calculatedResult -= num3;
        } else if (op1 == '÷') {
          expect(num1 % num2, 0, reason: 'Phép chia phải tròn');
          calculatedResult = num1 ~/ num2;
          if (op2 == '+') calculatedResult += num3;
          if (op2 == '-') calculatedResult -= num3;
        } else if (op2 == '×') {
          final temp = num2 * num3;
          if (op1 == '+') calculatedResult = num1 + temp;
          if (op1 == '-') calculatedResult = num1 - temp;
        } else if (op2 == '÷') {
          expect(num2 % num3, 0, reason: 'Phép chia phải tròn');
          final temp = num2 ~/ num3;
          if (op1 == '+') calculatedResult = num1 + temp;
          if (op1 == '-') calculatedResult = num1 - temp;
        }

        expect(q.correctAnswer, calculatedResult, reason: 'Kết quả tính toán không khớp với correctAnswer cho biểu thức $text');
      }
    });

    test('No negative numbers in any level', () {
      for (int level = 1; level <= 4; level++) {
        for (int i = 0; i < 100; i++) {
          final q = MathGenerator.generateQuestion(level);
          expect(q.correctAnswer, greaterThanOrEqualTo(0), reason: 'Level $level: correctAnswer must be >= 0');
          expect(q.options.every((o) => o >= 0), isTrue, reason: 'Level $level: all options must be >= 0');
        }
      }
    });

    test('Options are always unique across all levels (100 iterations)', () {
      for (int level = 1; level <= 4; level++) {
        for (int i = 0; i < 100; i++) {
          final q = MathGenerator.generateQuestion(level);
          expect(q.options.toSet().length, 4, reason: 'Level $level: options must be unique');
        }
      }
    });
  });
}
