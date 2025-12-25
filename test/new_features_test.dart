import 'package:json_son/json_son.dart';
import 'package:test/test.dart';

enum TestStatus { pending, active, completed, archived }

void main() {
  group('flexibleEnumFromJson', () {
    test('parses string to enum (case-insensitive)', () {
      expect(
          flexibleEnumFromJson('active', TestStatus.values), TestStatus.active);
      expect(
          flexibleEnumFromJson('ACTIVE', TestStatus.values), TestStatus.active);
      expect(
          flexibleEnumFromJson('Active', TestStatus.values), TestStatus.active);
    });

    test('parses int index to enum', () {
      expect(flexibleEnumFromJson(0, TestStatus.values), TestStatus.pending);
      expect(flexibleEnumFromJson(1, TestStatus.values), TestStatus.active);
      expect(flexibleEnumFromJson(2, TestStatus.values), TestStatus.completed);
    });

    test('returns fallback for invalid values', () {
      expect(
          flexibleEnumFromJson('invalid', TestStatus.values,
              fallback: TestStatus.pending),
          TestStatus.pending);
      expect(
          flexibleEnumFromJson(99, TestStatus.values,
              fallback: TestStatus.pending),
          TestStatus.pending);
      expect(
          flexibleEnumFromJson(null, TestStatus.values,
              fallback: TestStatus.pending),
          TestStatus.pending);
    });

    test('returns null for invalid values without fallback', () {
      expect(flexibleEnumFromJson('invalid', TestStatus.values), null);
      expect(flexibleEnumFromJson(null, TestStatus.values), null);
    });
  });

  group('flexibleBigIntFromJson', () {
    test('parses int to BigInt', () {
      expect(flexibleBigIntFromJson(123), BigInt.from(123));
    });

    test('parses string to BigInt', () {
      expect(flexibleBigIntFromJson('12345678901234567890'),
          BigInt.parse('12345678901234567890'));
    });

    test('returns null for invalid values', () {
      expect(flexibleBigIntFromJson(null), null);
      expect(flexibleBigIntFromJson(''), null);
      expect(flexibleBigIntFromJson('invalid'), null);
    });

    test('flexibleRequiredBigIntFromJson returns zero for null', () {
      expect(flexibleRequiredBigIntFromJson(null), BigInt.zero);
    });
  });

  group('flexibleDurationFromJson', () {
    test('parses int as milliseconds', () {
      expect(
          flexibleDurationFromJson(5000), const Duration(milliseconds: 5000));
    });

    test('parses ISO 8601 duration', () {
      expect(flexibleDurationFromJson('PT1H30M'),
          const Duration(hours: 1, minutes: 30));
      expect(flexibleDurationFromJson('P1D'), const Duration(days: 1));
      expect(flexibleDurationFromJson('PT30S'), const Duration(seconds: 30));
      expect(flexibleDurationFromJson('P1DT2H30M'),
          const Duration(days: 1, hours: 2, minutes: 30));
    });

    test('parses human-readable duration', () {
      expect(flexibleDurationFromJson('1h 30m'),
          const Duration(hours: 1, minutes: 30));
      expect(
          flexibleDurationFromJson('2d 5h'), const Duration(days: 2, hours: 5));
      expect(flexibleDurationFromJson('90s'), const Duration(seconds: 90));
      expect(
          flexibleDurationFromJson('500ms'), const Duration(milliseconds: 500));
    });

    test('parses map with duration components', () {
      expect(
        flexibleDurationFromJson({'hours': 2, 'minutes': 30}),
        const Duration(hours: 2, minutes: 30),
      );
      expect(
        flexibleDurationFromJson({'d': 1, 'h': 5}),
        const Duration(days: 1, hours: 5),
      );
    });

    test('returns null for invalid values', () {
      expect(flexibleDurationFromJson(null), null);
      expect(flexibleDurationFromJson(''), null);
      expect(flexibleDurationFromJson('invalid'), null);
    });
  });

  group('flexiblePhoneFromJson', () {
    test('normalizes phone numbers', () {
      expect(flexiblePhoneFromJson('(555) 123-4567'), '5551234567');
      expect(flexiblePhoneFromJson('+1 555 123 4567'), '+15551234567');
      expect(flexiblePhoneFromJson('555.123.4567'), '5551234567');
    });

    test('returns null for invalid values', () {
      expect(flexiblePhoneFromJson(null), null);
      expect(flexiblePhoneFromJson(''), null);
      expect(flexiblePhoneFromJson('abc'), null);
    });
  });

  group('flexibleSlugFromJson', () {
    test('converts strings to slugs', () {
      expect(flexibleSlugFromJson('Hello World'), 'hello-world');
      expect(flexibleSlugFromJson('Hello World! 123'), 'hello-world-123');
      expect(flexibleSlugFromJson('  Multiple   Spaces  '), 'multiple-spaces');
      expect(flexibleSlugFromJson('Under_Score'), 'under-score');
    });

    test('returns null for invalid values', () {
      expect(flexibleSlugFromJson(null), null);
      expect(flexibleSlugFromJson(''), null);
    });
  });

  group('flexibleCurrencyFromJson', () {
    test('parses number as currency', () {
      expect(flexibleCurrencyFromJson(100.50), const CurrencyValue(100.50));
    });

    test('parses string with currency symbol', () {
      final usd = flexibleCurrencyFromJson('\$1,234.56');
      expect(usd?.amount, 1234.56);
      expect(usd?.currencyCode, 'USD');

      final eur = flexibleCurrencyFromJson('€100');
      expect(eur?.amount, 100.0);
      expect(eur?.currencyCode, 'EUR');
    });

    test('parses string with currency code', () {
      final result = flexibleCurrencyFromJson('100.00 USD');
      expect(result?.amount, 100.0);
      expect(result?.currencyCode, 'USD');
    });

    test('parses map with amount and currency', () {
      final result =
          flexibleCurrencyFromJson({'amount': 50.0, 'currency': 'GBP'});
      expect(result?.amount, 50.0);
      expect(result?.currencyCode, 'GBP');
    });

    test('returns null for invalid values', () {
      expect(flexibleCurrencyFromJson(null), null);
      expect(flexibleCurrencyFromJson(''), null);
      expect(flexibleCurrencyFromJson('invalid'), null);
    });
  });

  group('JsonSon new getters', () {
    test('getEnum returns enum value', () {
      final json = JsonSon({'status': 'active'});
      expect(json.getEnum('status', TestStatus.values), TestStatus.active);
    });

    test('getDuration returns duration', () {
      final json = JsonSon({'timeout': 'PT1H30M'});
      expect(
          json.getDuration('timeout'), const Duration(hours: 1, minutes: 30));
    });

    test('getBigInt returns BigInt', () {
      final json = JsonSon({'large': '12345678901234567890'});
      expect(json.getBigInt('large'), BigInt.parse('12345678901234567890'));
    });

    test('getCurrency returns CurrencyValue', () {
      final json = JsonSon({'price': '\$99.99'});
      final currency = json.getCurrency('price');
      expect(currency?.amount, 99.99);
      expect(currency?.currencyCode, 'USD');
    });

    test('getPhone returns normalized phone', () {
      final json = JsonSon({'phone': '(555) 123-4567'});
      expect(json.getPhone('phone'), '5551234567');
    });

    test('getSlug returns slug', () {
      final json = JsonSon({'title': 'Hello World!'});
      expect(json.getSlug('title'), 'hello-world');
    });
  });

  group('JsonSon path-based list access', () {
    test('getListPath returns typed list at path', () {
      final json = JsonSon({
        'data': {
          'items': [1, 2, 3]
        }
      });
      expect(
          json.getListPath<int>('data.items', flexibleIntFromJson), [1, 2, 3]);
    });

    test('getListPathOrEmpty returns empty list for missing path', () {
      final json = JsonSon({'data': {}});
      expect(
          json.getListPathOrEmpty<int>('data.items', flexibleIntFromJson), []);
    });

    test('getDurationPath returns duration at path', () {
      final json = JsonSon({
        'config': {'timeout': 'PT30M'}
      });
      expect(
          json.getDurationPath('config.timeout'), const Duration(minutes: 30));
    });

    test('getBigIntPath returns BigInt at path', () {
      final json = JsonSon({
        'data': {'id': '12345678901234567890'}
      });
      expect(
          json.getBigIntPath('data.id'), BigInt.parse('12345678901234567890'));
    });
  });

  group('JsonSon deepMerge', () {
    test('recursively merges nested objects', () {
      final base = JsonSon({
        'a': 1,
        'nested': {'b': 2, 'c': 3}
      });
      final override = JsonSon({
        'nested': {'c': 30, 'd': 4}
      });
      final merged = base.deepMerge(override);

      expect(merged.getInt('a'), 1);
      expect(merged.getIntPath('nested.b'), 2);
      expect(merged.getIntPath('nested.c'), 30);
      expect(merged.getIntPath('nested.d'), 4);
    });
  });

  group('JsonSon diff', () {
    test('detects added, removed, and changed keys', () {
      final original = JsonSon({'a': 1, 'b': 2, 'c': 3});
      final modified = JsonSon({'a': 1, 'b': 20, 'd': 4});
      final result = original.diff(modified);

      expect(result['added'], {'d': 4});
      expect(result['removed'], {'c': 3});
      expect(result['changed'], {
        'b': {'from': 2, 'to': 20}
      });
    });
  });

  group('JsonSon pick', () {
    test('picks values at nested paths', () {
      final json = JsonSon({
        'user': {
          'name': 'John',
          'email': 'john@example.com',
          'address': {'city': 'NYC'}
        },
        'other': 'data'
      });
      final picked = json.pick(['user.name', 'user.address.city']);

      expect(picked.getStringPath('user.name'), 'John');
      expect(picked.getStringPath('user.address.city'), 'NYC');
      expect(picked.hasPath('user.email'), false);
      expect(picked.hasKey('other'), false);
    });
  });

  group('JsonSon flatten/unflatten', () {
    test('flatten converts nested to dot notation', () {
      final json = JsonSon({
        'a': {
          'b': {'c': 1}
        },
        'd': 2
      });
      final flat = json.flatten();

      expect(flat['a.b.c'], 1);
      expect(flat['d'], 2);
    });

    test('unflatten converts dot notation to nested', () {
      final flat = {'a.b.c': 1, 'd': 2};
      final json = JsonSon.unflatten(flat);

      expect(json.getIntPath('a.b.c'), 1);
      expect(json.getInt('d'), 2);
    });
  });

  group('JsonSon conditional getters', () {
    test('getIntIf returns value only if condition met', () {
      final json = JsonSon({'age': 25, 'score': 50});

      expect(json.getIntIf('age', (v) => v >= 18), 25);
      expect(json.getIntIf('score', (v) => v >= 60), null);
    });

    test('getStringIf returns value only if condition met', () {
      final json = JsonSon({'name': 'John', 'code': 'AB'});

      expect(json.getStringIf('name', (v) => v.length >= 3), 'John');
      expect(json.getStringIf('code', (v) => v.length >= 3), null);
    });
  });

  group('JsonSon toQueryString', () {
    test('converts simple map to query string', () {
      final json = JsonSon({'a': 1, 'b': 'hello'});
      expect(json.toQueryString(), 'a=1&b=hello');
    });

    test('handles nested objects', () {
      final json = JsonSon({
        'user': {'name': 'John'}
      });
      expect(json.toQueryString(), 'user[name]=John');
    });

    test('encodes special characters', () {
      final json = JsonSon({'q': 'hello world'});
      expect(json.toQueryString(), 'q=hello%20world');
    });
  });

  group('JsonSonValidator new methods', () {
    test('phone validates phone numbers', () {
      final validJson = JsonSon({'phone': '555-123-4567'});
      final invalidJson = JsonSon({'phone': '123'});

      expect(JsonSonValidator(validJson).phone('phone').isValid, true);
      expect(JsonSonValidator(invalidJson).phone('phone').isValid, false);
    });

    test('uuid validates UUID format', () {
      final validJson = JsonSon({'id': '550e8400-e29b-41d4-a716-446655440000'});
      final invalidJson = JsonSon({'id': 'not-a-uuid'});

      expect(JsonSonValidator(validJson).uuid('id').isValid, true);
      expect(JsonSonValidator(invalidJson).uuid('id').isValid, false);
    });

    test('creditCard validates credit card numbers', () {
      final validJson = JsonSon({'card': '4532015112830366'}); // Valid Luhn
      final invalidJson = JsonSon({'card': '1234567890123456'});

      expect(JsonSonValidator(validJson).creditCard('card').isValid, true);
      expect(JsonSonValidator(invalidJson).creditCard('card').isValid, false);
    });

    test('dateRange validates date within range', () {
      final json = JsonSon({'date': '2024-06-15'});
      final min = DateTime(2024, 1, 1);
      final max = DateTime(2024, 12, 31);

      expect(
          JsonSonValidator(json).dateRange('date', min: min, max: max).isValid,
          true);
    });

    test('when applies conditional validation', () {
      final json = JsonSon({'type': 'business', 'company': null});

      final validator = JsonSonValidator(json)
          .when('type', (v) => v == 'business', (v) => v.required('company'));

      expect(validator.isValid, false);
      expect(validator.errors.containsKey('company'), true);
    });

    test('requiredWhen validates conditional requirement', () {
      final json = JsonSon({'type': 'business', 'company': null});

      final validator =
          JsonSonValidator(json).requiredWhen('company', 'type', 'business');

      expect(validator.isValid, false);
    });

    test('unique validates array uniqueness', () {
      final validJson = JsonSon({
        'tags': ['a', 'b', 'c']
      });
      final invalidJson = JsonSon({
        'tags': ['a', 'b', 'a']
      });

      expect(JsonSonValidator(validJson).unique('tags').isValid, true);
      expect(JsonSonValidator(invalidJson).unique('tags').isValid, false);
    });

    test('between validates number range', () {
      final validJson = JsonSon({'age': 25});
      final invalidJson = JsonSon({'age': 150});

      expect(JsonSonValidator(validJson).between('age', 0, 120).isValid, true);
      expect(
          JsonSonValidator(invalidJson).between('age', 0, 120).isValid, false);
    });

    test('contains validates substring', () {
      final validJson = JsonSon({'email': 'test@example.com'});
      final invalidJson = JsonSon({'email': 'invalid'});

      expect(JsonSonValidator(validJson).contains('email', '@').isValid, true);
      expect(
          JsonSonValidator(invalidJson).contains('email', '@').isValid, false);
    });

    test('startsWith validates prefix', () {
      final validJson = JsonSon({'url': 'https://example.com'});
      final invalidJson = JsonSon({'url': 'ftp://example.com'});

      expect(JsonSonValidator(validJson).startsWith('url', 'https://').isValid,
          true);
      expect(
          JsonSonValidator(invalidJson).startsWith('url', 'https://').isValid,
          false);
    });

    test('endsWith validates suffix', () {
      final validJson = JsonSon({'file': 'document.pdf'});
      final invalidJson = JsonSon({'file': 'document.txt'});

      expect(
          JsonSonValidator(validJson).endsWith('file', '.pdf').isValid, true);
      expect(JsonSonValidator(invalidJson).endsWith('file', '.pdf').isValid,
          false);
    });

    test('minItems validates minimum array length', () {
      final validJson = JsonSon({
        'items': [1, 2, 3]
      });
      final invalidJson = JsonSon({
        'items': [1]
      });

      expect(JsonSonValidator(validJson).minItems('items', 2).isValid, true);
      expect(JsonSonValidator(invalidJson).minItems('items', 2).isValid, false);
    });

    test('maxItems validates maximum array length', () {
      final validJson = JsonSon({
        'items': [1, 2]
      });
      final invalidJson = JsonSon({
        'items': [1, 2, 3, 4, 5]
      });

      expect(JsonSonValidator(validJson).maxItems('items', 3).isValid, true);
      expect(JsonSonValidator(invalidJson).maxItems('items', 3).isValid, false);
    });

    test('equals validates field equality', () {
      final validJson = JsonSon({'password': 'secret', 'confirm': 'secret'});
      final invalidJson =
          JsonSon({'password': 'secret', 'confirm': 'different'});

      expect(JsonSonValidator(validJson).equals('confirm', 'password').isValid,
          true);
      expect(
          JsonSonValidator(invalidJson).equals('confirm', 'password').isValid,
          false);
    });

    test('different validates field inequality', () {
      final validJson = JsonSon({'old': 'abc', 'new': 'xyz'});
      final invalidJson = JsonSon({'old': 'abc', 'new': 'abc'});

      expect(JsonSonValidator(validJson).different('new', 'old').isValid, true);
      expect(
          JsonSonValidator(invalidJson).different('new', 'old').isValid, false);
    });
  });
}
