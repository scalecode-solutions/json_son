import 'package:json_son/json_son.dart';
import 'package:test/test.dart';

void main() {
  group('Required (non-nullable) functions', () {
    test('flexibleRequiredIntFromJson returns 0 for null', () {
      expect(flexibleRequiredIntFromJson(null), equals(0));
    });

    test('flexibleRequiredIntFromJson returns parsed value for valid input',
        () {
      expect(flexibleRequiredIntFromJson(42), equals(42));
      expect(flexibleRequiredIntFromJson('42'), equals(42));
      expect(flexibleRequiredIntFromJson(42.5), equals(42));
    });

    test('flexibleRequiredDoubleFromJson returns 0.0 for null', () {
      expect(flexibleRequiredDoubleFromJson(null), equals(0.0));
    });

    test('flexibleRequiredDoubleFromJson returns parsed value for valid input',
        () {
      expect(flexibleRequiredDoubleFromJson(42.5), equals(42.5));
      expect(flexibleRequiredDoubleFromJson('42.5'), equals(42.5));
      expect(flexibleRequiredDoubleFromJson(42), equals(42.0));
    });

    test('flexibleRequiredStringFromJson returns empty string for null', () {
      expect(flexibleRequiredStringFromJson(null), equals(''));
    });

    test('flexibleRequiredStringFromJson returns string for valid input', () {
      expect(flexibleRequiredStringFromJson('hello'), equals('hello'));
      expect(flexibleRequiredStringFromJson(42), equals('42'));
      expect(flexibleRequiredStringFromJson(true), equals('true'));
    });

    test('flexibleRequiredBoolFromJson returns false for null', () {
      expect(flexibleRequiredBoolFromJson(null), equals(false));
    });

    test('flexibleRequiredBoolFromJson returns parsed value for valid input',
        () {
      expect(flexibleRequiredBoolFromJson(true), equals(true));
      expect(flexibleRequiredBoolFromJson('true'), equals(true));
      expect(flexibleRequiredBoolFromJson(1), equals(true));
      expect(flexibleRequiredBoolFromJson(false), equals(false));
      expect(flexibleRequiredBoolFromJson('false'), equals(false));
      expect(flexibleRequiredBoolFromJson(0), equals(false));
    });

    test('flexibleRequiredListFromJson returns empty list for null', () {
      expect(flexibleRequiredListFromJson(null, flexibleIntFromJson), isEmpty);
    });

    test('flexibleRequiredListFromJson returns parsed list for valid input',
        () {
      expect(
        flexibleRequiredListFromJson([1, 2, 3], flexibleIntFromJson),
        equals([1, 2, 3]),
      );
      expect(
        flexibleRequiredListFromJson(['1', '2', '3'], flexibleIntFromJson),
        equals([1, 2, 3]),
      );
      expect(
        flexibleRequiredListFromJson(42, flexibleIntFromJson),
        equals([42]),
      );
    });
  });
}
