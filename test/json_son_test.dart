import 'package:test/test.dart';
import 'package:json_son/json_son.dart';

void main() {
  group('JSON Son Helper Functions', () {
    group('flexibleIntFromJson', () {
      test('parses integer string', () {
        expect(flexibleIntFromJson('123'), 123);
      });

      test('handles integer input', () {
        expect(flexibleIntFromJson(456), 456);
      });

      test('converts double to int (truncates)', () {
        expect(flexibleIntFromJson(789.9), 789);
      });

      test('returns null for invalid string', () {
        expect(flexibleIntFromJson('abc'), null);
      });

      test('returns null for null input', () {
        expect(flexibleIntFromJson(null), null);
      });

      test('returns null for empty string', () {
        expect(flexibleIntFromJson(''), null);
      });
    });

    group('flexibleDoubleFromJson', () {
      test('parses double string', () {
        expect(flexibleDoubleFromJson('123.45'), 123.45);
      });

      test('handles double input', () {
        expect(flexibleDoubleFromJson(456.78), 456.78);
      });

      test('converts int to double', () {
        expect(flexibleDoubleFromJson(789), 789.0);
      });

      test('returns null for invalid string', () {
        expect(flexibleDoubleFromJson('abc'), null);
      });

      test('returns null for null input', () {
        expect(flexibleDoubleFromJson(null), null);
      });

      test('returns null for empty string', () {
        expect(flexibleDoubleFromJson(''), null);
      });
    });

    group('flexibleBoolFromJson', () {
      test('parses boolean string "true"', () {
        expect(flexibleBoolFromJson('true'), true);
      });

      test('parses boolean string "false"', () {
        expect(flexibleBoolFromJson('false'), false);
      });

      test('parses numeric string "1" as true', () {
        expect(flexibleBoolFromJson('1'), true);
      });

      test('parses numeric string "0" as false', () {
        expect(flexibleBoolFromJson('0'), false);
      });

      test('handles boolean true', () {
        expect(flexibleBoolFromJson(true), true);
      });

      test('handles boolean false', () {
        expect(flexibleBoolFromJson(false), false);
      });

      test('handles int 1 as true', () {
        expect(flexibleBoolFromJson(1), true);
      });

      test('handles int 0 as false', () {
        expect(flexibleBoolFromJson(0), false);
      });

      test('returns null for invalid string', () {
        expect(flexibleBoolFromJson('not a bool'), null);
      });

      test('returns null for null input', () {
        expect(flexibleBoolFromJson(null), null);
      });

      test('returns null for empty string', () {
        expect(flexibleBoolFromJson(''), null);
      });
    });

    group('flexibleStringFromJson', () {
      test('handles string input', () {
        expect(flexibleStringFromJson('hello'), 'hello');
      });

      test('converts int to string', () {
        expect(flexibleStringFromJson(123), '123');
      });

      test('converts double to string', () {
        expect(flexibleStringFromJson(123.45), '123.45');
      });

      test('converts boolean to string', () {
        expect(flexibleStringFromJson(true), 'true');
        expect(flexibleStringFromJson(false), 'false');
      });

      test('returns null for null input', () {
        expect(flexibleStringFromJson(null), null);
      });
    });

    group('flexibleNumFromJson', () {
      test('parses integer string', () {
        expect(flexibleNumFromJson('123'), 123);
      });

      test('parses double string', () {
        expect(flexibleNumFromJson('123.45'), 123.45);
      });

      test('handles int input', () {
        expect(flexibleNumFromJson(456), 456);
      });

      test('handles double input', () {
        expect(flexibleNumFromJson(456.78), 456.78);
      });

      test('returns null for invalid string', () {
        expect(flexibleNumFromJson('abc'), null);
      });

      test('returns null for null input', () {
        expect(flexibleNumFromJson(null), null);
      });

      test('returns null for empty string', () {
        expect(flexibleNumFromJson(''), null);
      });
    });

    group('flexibleDateTimeFromJson', () {
      test('parses ISO 8601 string', () {
        final date = flexibleDateTimeFromJson('2023-05-24T12:34:56.789Z');
        expect(date, isA<DateTime>());
        expect(date!.toIso8601String(), '2023-05-24T12:34:56.789Z');
      });

      test('parses milliseconds since epoch as int', () {
        final date = flexibleDateTimeFromJson(1684931696789);
        expect(date, isA<DateTime>());
        expect(date!.millisecondsSinceEpoch, 1684931696789);
      });

      test('parses milliseconds since epoch as string', () {
        final date = flexibleDateTimeFromJson('1684931696789');
        expect(date, isA<DateTime>());
        expect(date!.millisecondsSinceEpoch, 1684931696789);
      });

      test('returns null for invalid string', () {
        expect(flexibleDateTimeFromJson('not a date'), null);
      });

      test('returns null for null input', () {
        expect(flexibleDateTimeFromJson(null), null);
      });

      test('returns null for empty string', () {
        expect(flexibleDateTimeFromJson(''), null);
      });
    });

    group('flexibleUriFromJson', () {
      test('parses valid URI string', () {
        final uri = flexibleUriFromJson('https://example.com/path?query=1');
        expect(uri, isA<Uri>());
        expect(uri.toString(), 'https://example.com/path?query=1');
      });

      test('handles URI object input', () {
        final inputUri = Uri.parse('https://example.com');
        final uri = flexibleUriFromJson(inputUri);
        expect(uri, equals(inputUri));
      });

      test('attempts to parse invalid URI string', () {
        // Note: Uri.tryParse returns a Uri object even for invalid URIs
        final uri = flexibleUriFromJson('not a uri');
        expect(uri, isA<Uri>());
        expect(uri.toString(), 'not%20a%20uri');
      });

      test('returns null for null input', () {
        expect(flexibleUriFromJson(null), null);
      });

      test('returns null for empty string', () {
        expect(flexibleUriFromJson(''), null);
      });
    });

    group('flexibleTrimmedStringFromJson', () {
      test('trims whitespace from string', () {
        expect(flexibleTrimmedStringFromJson('  hello  '), 'hello');
      });

      test('returns null for whitespace-only string', () {
        expect(flexibleTrimmedStringFromJson('   '), null);
      });

      test('converts non-string to string and trims', () {
        expect(flexibleTrimmedStringFromJson(123), '123');
        expect(flexibleTrimmedStringFromJson(true), 'true');
      });

      test('returns null for null input', () {
        expect(flexibleTrimmedStringFromJson(null), null);
      });

      test('returns null for empty string', () {
        expect(flexibleTrimmedStringFromJson(''), null);
      });
    });

    group('flexibleLowerStringFromJson', () {
      test('converts string to lowercase', () {
        expect(flexibleLowerStringFromJson('HeLLo'), 'hello');
      });

      test('trims whitespace and converts to lowercase', () {
        expect(flexibleLowerStringFromJson('  HeLLo  '), 'hello');
      });

      test('converts non-string to lowercase string', () {
        expect(flexibleLowerStringFromJson(123), '123');
        expect(flexibleLowerStringFromJson(true), 'true');
      });

      test('returns null for null input', () {
        expect(flexibleLowerStringFromJson(null), null);
      });

      test('returns null for empty string', () {
        expect(flexibleLowerStringFromJson(''), null);
      });
    });

    group('flexibleUpperStringFromJson', () {
      test('converts string to uppercase', () {
        expect(flexibleUpperStringFromJson('HeLLo'), 'HELLO');
      });

      test('trims whitespace and converts to uppercase', () {
        expect(flexibleUpperStringFromJson('  HeLLo  '), 'HELLO');
      });

      test('converts non-string to uppercase string', () {
        expect(flexibleUpperStringFromJson(123), '123');
        expect(flexibleUpperStringFromJson(true), 'TRUE');
      });

      test('returns null for null input', () {
        expect(flexibleUpperStringFromJson(null), null);
      });

      test('returns null for empty string', () {
        expect(flexibleUpperStringFromJson(''), null);
      });
    });

    group('flexibleListFromJson', () {
      test('handles list of strings', () {
        final result = flexibleListFromJson(['a', 'b', 'c'], (e) => e as String);
        expect(result, equals(['a', 'b', 'c']));
      });

      test('handles list of parsed values', () {
        final result = flexibleListFromJson(['1', '2', '3'], (e) => int.tryParse(e));
        expect(result, equals([1, 2, 3]));
      });

      test('filters out null values', () {
        final result = flexibleListFromJson(['1', 'a', '3'], (e) => int.tryParse(e));
        expect(result, equals([1, 3]));
      });

      test('handles single item as list', () {
        final result = flexibleListFromJson('hello', (e) => e as String);
        expect(result, equals(['hello']));
      });

      test('returns null for null input', () {
        expect(flexibleListFromJson(null, (e) => e), null);
      });
    });

    group('flexibleListNotNullFromJson', () {
      test('returns empty list for null input', () {
        final result = flexibleListNotNullFromJson(null, (e) => e);
        expect(result, isEmpty);
      });

      test('returns empty list for empty list', () {
        final result = flexibleListNotNullFromJson([], (e) => e);
        expect(result, isEmpty);
      });

      test('returns empty list when all items parse to null', () {
        final result = flexibleListNotNullFromJson(
          ['a', 'b'], 
          (e) => e == 'a' ? null : null
        );
        expect(result, isEmpty);
      });

      test('handles single item as list', () {
        final result = flexibleListNotNullFromJson('hello', (e) => e as String);
        expect(result, equals(['hello']));
      });
    });

    group('flexibleMapFromJson', () {
      test('handles map with string keys and values', () {
        final input = {'a': '1', 'b': '2'};
        final result = flexibleMapFromJson(
          input,
          (k, v) => MapEntry(k, int.tryParse(v)),
        );
        expect(result, equals({'a': 1, 'b': 2}));
      });

      test('filters out null values', () {
        final input = {'a': '1', 'b': 'x', 'c': '3'};
        final result = flexibleMapFromJson(
          input,
          (k, v) => k == 'b' ? null : MapEntry(k, int.tryParse(v)),
        );
        expect(result, equals({'a': 1, 'c': 3}));
      });

      test('returns null for null input', () {
        expect(flexibleMapFromJson(null, (k, v) => MapEntry(k, v)), null);
      });
    });

    group('flexibleMapNotNullFromJson', () {
      test('returns empty map for null input', () {
        final result = flexibleMapNotNullFromJson(
          null,
          (k, v) => MapEntry(k, v),
        );
        expect(result, isEmpty);
      });

      test('returns empty map for empty map', () {
        final result = flexibleMapNotNullFromJson(
          {},
          (k, v) => MapEntry(k, v),
        );
        expect(result, isEmpty);
      });

      test('filters out null values', () {
        final input = {'a': '1', 'b': 'x', 'c': '3'};
        final result = flexibleMapNotNullFromJson(
          input,
          (k, v) {
            final value = int.tryParse(v);
            return value != null ? MapEntry(k, value) : null;
          },
        );
        expect(result, equals({'a': 1, 'c': 3}));
      });
    });
  });
}
