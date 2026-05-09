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

    test('Level 4 generates mixed operations (a + b×c or a - b×c)', () {
      for (int i = 0; i < 50; i++) {
        final q = MathGenerator.generateQuestion(4);

        // Phải có customQuestionText (dạng hỗn hợp)
        expect(q.customQuestionText, isNotNull);
        expect(q.questionText, contains('×'));

        // Đáp án đúng phải dương
        expect(q.correctAnswer, greaterThan(0));

        // Phải có đúng 4 đáp án và không trùng
        expect(q.options.length, 4);
        expect(q.options.toSet().length, 4, reason: 'Options must be unique');

        // Đáp án đúng phải nằm trong danh sách lựa chọn
        expect(q.options.contains(q.correctAnswer), isTrue);

        // Kiểm tra dạng câu hỏi khớp với đáp án
        final text = q.questionText; // VD: "5 + 3 × 4 = ?"
        final parts = text.replaceAll(' = ?', '').split(' ');
        if (parts[1] == '+') {
          final a = int.parse(parts[0]);
          final b = int.parse(parts[2]);
          final c = int.parse(parts[4]);
          expect(a + b * c, q.correctAnswer);
        } else if (parts[1] == '-') {
          final a = int.parse(parts[0]);
          final b = int.parse(parts[2]);
          final c = int.parse(parts[4]);
          expect(a - b * c, q.correctAnswer);
        }
      }
    });
  });
}
