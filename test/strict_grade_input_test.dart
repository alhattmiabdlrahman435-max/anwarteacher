import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anwarteacher/features/grades/presentation/screens/grades_screen.dart';

void main() {
  group('StrictEnglishGradeInputFormatter Tests', () {
    final formatter15 = StrictEnglishGradeInputFormatter(maxValue: 15.0);
    final formatter50 = StrictEnglishGradeInputFormatter(maxValue: 50.0);

    test('Accepts valid English ASCII integers within range', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '15');
      final result = formatter15.formatEditUpdate(oldValue, newValue);
      expect(result.text, '15');
    });

    test('Accepts valid English ASCII decimal numbers within range', () {
      const oldValue = TextEditingValue(text: '1');
      const newValue = TextEditingValue(text: '12.5');
      final result = formatter15.formatEditUpdate(oldValue, newValue);
      expect(result.text, '12.5');
    });

    test('Accepts typing a single trailing dot during entry', () {
      const oldValue = TextEditingValue(text: '12');
      const newValue = TextEditingValue(text: '12.');
      final result = formatter15.formatEditUpdate(oldValue, newValue);
      expect(result.text, '12.');
    });

    test('Strictly rejects Eastern Arabic digits without converting (keeps oldValue)', () {
      const oldValue = TextEditingValue(text: '10');
      // User typed Eastern Arabic '٥' (5)
      const newValue = TextEditingValue(text: '10٥');
      final result = formatter15.formatEditUpdate(oldValue, newValue);
      expect(result.text, '10'); // Must strictly remain oldValue!
    });

    test('Strictly rejects Eastern Arabic digits in empty field (keeps empty)', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '١٥');
      final result = formatter15.formatEditUpdate(oldValue, newValue);
      expect(result.text, ''); // Rejection keeps oldValue
    });

    test('Strictly rejects Persian digits (keeps oldValue)', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '۴۵');
      final result = formatter50.formatEditUpdate(oldValue, newValue);
      expect(result.text, '');
    });

    test('Strictly rejects Arabic comma "،" and "٫"', () {
      const oldValue = TextEditingValue(text: '12');
      const newValueWithComma = TextEditingValue(text: '12،5');
      final result1 = formatter15.formatEditUpdate(oldValue, newValueWithComma);
      expect(result1.text, '12');

      const newValueWithDecimalComma = TextEditingValue(text: '12٫5');
      final result2 = formatter15.formatEditUpdate(oldValue, newValueWithDecimalComma);
      expect(result2.text, '12');
    });

    test('Strictly rejects numbers exceeding maxValue', () {
      const oldValue = TextEditingValue(text: '15');
      const newValue = TextEditingValue(text: '15.5');
      final result = formatter15.formatEditUpdate(oldValue, newValue);
      expect(result.text, '15'); // 15.5 > 15 -> rejects!

      const oldValue50 = TextEditingValue(text: '50');
      const newValue50 = TextEditingValue(text: '51');
      final result50 = formatter50.formatEditUpdate(oldValue50, newValue50);
      expect(result50.text, '50'); // 51 > 50 -> rejects!
    });

    test('Allows clearing the field to empty', () {
      const oldValue = TextEditingValue(text: '15');
      const newValue = TextEditingValue.empty;
      final result = formatter15.formatEditUpdate(oldValue, newValue);
      expect(result.text, '');
    });

    test('Strictly rejects letters and symbols', () {
      const oldValue = TextEditingValue(text: '10');
      const newValue = TextEditingValue(text: '10a');
      final result = formatter15.formatEditUpdate(oldValue, newValue);
      expect(result.text, '10');

      const newValueSymbol = TextEditingValue(text: '10#');
      final resultSymbol = formatter15.formatEditUpdate(oldValue, newValueSymbol);
      expect(resultSymbol.text, '10');
    });
  });
}
