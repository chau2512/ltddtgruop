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
  });
}
