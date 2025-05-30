import 'dart:convert';
import 'package:test/test.dart';
import 'package:json_son/json_son.dart';

void main() {
  group('JsonSon Class', () {
    late Map<String, dynamic> testData;
    late JsonSon json;

    setUp(() {
      testData = {
        'id': '123',
        'name': 'Product XYZ',
        'price': '29.99',
        'isActive': 'true',
        'tags': 'electronics, gadget, new',
        'created_at': '2023-10-26T10:30:00Z',
        'ratings': [4, '5', 3.5, '2'],
        'metadata': null,
        'stock': {
          'count': '42',
          'locations': ['Store A', 'Store B', 'Warehouse'],
          'lastUpdated': 1698316200000
        },
        'variants': [
          {'id': '101', 'color': 'Red', 'inStock': 1},
          {'id': '102', 'color': 'Blue', 'inStock': 0}
        ]
      };
      json = JsonSon(testData);
    });

    group('Constructors', () {
      test('creates instance from Map', () {
        final instance = JsonSon(testData);
        expect(instance, isA<JsonSon>());
        expect(instance.rawData, equals(testData));
      });

      test('creates instance using fromMap static constructor', () {
        final instance = JsonSon.fromMap(testData);
        expect(instance, isA<JsonSon>());
        expect(instance.rawData, equals(testData));
      });

      test('creates instance using fromJson static constructor', () {
        final jsonString = jsonEncode(testData);
        final instance = JsonSon.fromJson(jsonString);
        expect(instance, isA<JsonSon>());
        expect(instance.rawData, equals(testData));
      });
    });

    group('Basic Type Getters', () {
      test('getInt retrieves integer values', () {
        expect(json.getInt('id'), equals(123));
        expect(json.getInt('nonexistent'), isNull);
      });

      test('getString retrieves string values', () {
        expect(json.getString('name'), equals('Product XYZ'));
        expect(json.getString('nonexistent'), isNull);
      });

      test('getDouble retrieves double values', () {
        expect(json.getDouble('price'), equals(29.99));
        expect(json.getDouble('nonexistent'), isNull);
      });

      test('getBool retrieves boolean values', () {
        expect(json.getBool('isActive'), isTrue);
        expect(json.getBool('nonexistent'), isNull);
      });

      test('getDateTime retrieves DateTime values', () {
        final dateTime = json.getDateTime('created_at');
        expect(dateTime, isA<DateTime>());
        expect(dateTime!.toIso8601String(), equals('2023-10-26T10:30:00.000Z'));
        expect(json.getDateTime('nonexistent'), isNull);
      });

      test('getNum retrieves num values', () {
        expect(json.getNum('price'), equals(29.99));
        expect(json.getNum('id'), equals(123));
        expect(json.getNum('nonexistent'), isNull);
      });

      test('getUri retrieves Uri values', () {
        testData['website'] = 'https://example.com';
        expect(
            json.getUri('website')?.toString(), equals('https://example.com'));
        expect(json.getUri('nonexistent'), isNull);
      });
    });

    group('Default Value Getters', () {
      test('getIntOrDefault provides default for missing or null values', () {
        expect(json.getIntOrDefault('id', 0), equals(123));
        expect(json.getIntOrDefault('nonexistent', 0), equals(0));
        expect(json.getIntOrDefault('metadata', 0), equals(0));
      });

      test('getStringOrDefault provides default for missing or null values',
          () {
        expect(
            json.getStringOrDefault('name', 'Default'), equals('Product XYZ'));
        expect(json.getStringOrDefault('nonexistent', 'Default'),
            equals('Default'));
        expect(
            json.getStringOrDefault('metadata', 'Default'), equals('Default'));
      });

      test('getDoubleOrDefault provides default for missing or null values',
          () {
        expect(json.getDoubleOrDefault('price', 0.0), equals(29.99));
        expect(json.getDoubleOrDefault('nonexistent', 0.0), equals(0.0));
        expect(json.getDoubleOrDefault('metadata', 0.0), equals(0.0));
      });

      test('getBoolOrDefault provides default for missing or null values', () {
        expect(json.getBoolOrDefault('isActive', false), isTrue);
        expect(json.getBoolOrDefault('nonexistent', false), isFalse);
        expect(json.getBoolOrDefault('metadata', false), isFalse);
      });

      test('getNumOrDefault provides default for missing or null values', () {
        expect(json.getNumOrDefault('price', 0), equals(29.99));
        expect(json.getNumOrDefault('nonexistent', 0), equals(0));
        expect(json.getNumOrDefault('metadata', 0), equals(0));
      });
    });

    group('String Normalization', () {
      test('getTrimmedString trims whitespace', () {
        testData['description'] = '  Trimmed description  ';
        expect(json.getTrimmedString('description'),
            equals('Trimmed description'));
        expect(json.getTrimmedString('nonexistent'), isNull);
      });

      test('getLowerString converts to lowercase', () {
        testData['category'] = '  ELECTRONICS  ';
        expect(json.getLowerString('category'), equals('electronics'));
        expect(json.getLowerString('nonexistent'), isNull);
      });

      test('getUpperString converts to uppercase', () {
        testData['sku'] = '  product-abc  ';
        expect(json.getUpperString('sku'), equals('PRODUCT-ABC'));
        expect(json.getUpperString('nonexistent'), isNull);
      });
    });

    group('Nested Objects', () {
      test('getObject retrieves nested JsonSon objects', () {
        final stock = json.getObject('stock');
        expect(stock, isA<JsonSon>());
        expect(stock?.getInt('count'), equals(42));
        expect(json.getObject('nonexistent'), isNull);
      });

      test('getObjectList retrieves list of JsonSon objects', () {
        final variants = json.getObjectList('variants');
        expect(variants, isA<List<JsonSon>>());
        expect(variants?.length, equals(2));
        expect(variants?.first.getString('color'), equals('Red'));
        expect(variants?.last.getString('color'), equals('Blue'));
        expect(json.getObjectList('nonexistent'), isNull);
      });
    });

    group('Lists', () {
      test('getList retrieves list of values', () {
        final ratings = json.getList<num>('ratings', flexibleNumFromJson);
        expect(ratings, isA<List<num?>>());
        expect(ratings, equals([4, 5, 3.5, 2]));
        expect(json.getList<String>('nonexistent', flexibleStringFromJson),
            isNull);
      });

      test('getListOrEmpty retrieves non-null list of values', () {
        final ratings =
            json.getListOrEmpty<num>('ratings', flexibleNumFromJson);
        expect(ratings, isA<List<num>>());
        expect(ratings, equals([4, 5, 3.5, 2]));

        final emptyList =
            json.getListOrEmpty<String>('nonexistent', flexibleStringFromJson);
        expect(emptyList, isA<List<String>>());
        expect(emptyList, isEmpty);
      });

      test('getCommaSeparatedList parses comma-separated strings', () {
        final tags = json.getCommaSeparatedList('tags');
        expect(tags, isA<List<String>>());
        expect(tags, equals(['electronics', 'gadget', 'new']));
        expect(json.getCommaSeparatedList('nonexistent'), isNull);
      });
    });

    group('Path-based Access', () {
      test('getPath retrieves values using dot notation', () {
        expect(json.getPath('stock.count'), equals('42'));
        expect(json.getPath('stock.locations.0'), equals('Store A'));
        expect(json.getPath('variants.0.color'), equals('Red'));
        expect(json.getPath('nonexistent.path'), isNull);
      });

      test('getIntPath retrieves int values using dot notation', () {
        expect(json.getIntPath('stock.count'), equals(42));
        expect(json.getIntPath('variants.0.id'), equals(101));
        expect(json.getIntPath('nonexistent.path'), isNull);
      });

      test('getStringPath retrieves string values using dot notation', () {
        expect(json.getStringPath('variants.0.color'), equals('Red'));
        expect(json.getStringPath('stock.locations.0'), equals('Store A'));
        expect(json.getStringPath('nonexistent.path'), isNull);
      });

      test('getDoublePath retrieves double values using dot notation', () {
        expect(json.getDoublePath('price'), equals(29.99));
        expect(json.getDoublePath('nonexistent.path'), isNull);
      });

      test('getBoolPath retrieves boolean values using dot notation', () {
        expect(json.getBoolPath('isActive'), isTrue);
        expect(json.getBoolPath('variants.0.inStock'), isTrue);
        expect(json.getBoolPath('variants.1.inStock'), isFalse);
        expect(json.getBoolPath('nonexistent.path'), isNull);
      });

      test('getDateTimePath retrieves DateTime values using dot notation', () {
        final dateTime = json.getDateTimePath('created_at');
        expect(dateTime, isA<DateTime>());
        expect(dateTime!.toIso8601String(), equals('2023-10-26T10:30:00.000Z'));

        final stockUpdateTime = json.getDateTimePath('stock.lastUpdated');
        expect(stockUpdateTime, isA<DateTime>());
        expect(stockUpdateTime!.millisecondsSinceEpoch, equals(1698316200000));

        expect(json.getDateTimePath('nonexistent.path'), isNull);
      });

      test('getNumPath retrieves num values using dot notation', () {
        expect(json.getNumPath('price'), equals(29.99));
        expect(json.getNumPath('id'), equals(123));
        expect(json.getNumPath('nonexistent.path'), isNull);
      });

      test('getObjectPath retrieves JsonSon objects using dot notation', () {
        final variant = json.getObjectPath('variants.0');
        expect(variant, isA<JsonSon>());
        expect(variant?.getString('color'), equals('Red'));
        expect(json.getObjectPath('nonexistent.path'), isNull);
      });
    });

    group('Path-based Default Value Getters', () {
      test('getIntPathOrDefault provides default for missing or null values',
          () {
        expect(json.getIntPathOrDefault('stock.count', 0), equals(42));
        expect(json.getIntPathOrDefault('nonexistent.path', 0), equals(0));
      });

      test('getStringPathOrDefault provides default for missing or null values',
          () {
        expect(json.getStringPathOrDefault('variants.0.color', 'Default'),
            equals('Red'));
        expect(json.getStringPathOrDefault('nonexistent.path', 'Default'),
            equals('Default'));
      });

      test('getDoublePathOrDefault provides default for missing or null values',
          () {
        expect(json.getDoublePathOrDefault('price', 0.0), equals(29.99));
        expect(
            json.getDoublePathOrDefault('nonexistent.path', 0.0), equals(0.0));
      });

      test('getBoolPathOrDefault provides default for missing or null values',
          () {
        expect(json.getBoolPathOrDefault('isActive', false), isTrue);
        expect(json.getBoolPathOrDefault('nonexistent.path', false), isFalse);
      });

      test('getNumPathOrDefault provides default for missing or null values',
          () {
        expect(json.getNumPathOrDefault('price', 0), equals(29.99));
        expect(json.getNumPathOrDefault('nonexistent.path', 0), equals(0));
      });
    });

    group('Map Operations', () {
      test('mapValues transforms map values', () {
        final simpleMap = JsonSon({'a': '1', 'b': '2', 'c': 'not a number'});

        final intMap = simpleMap.mapValues<String, int>((key, value) {
          final intValue = int.tryParse(value.toString());
          return intValue != null ? MapEntry(key, intValue) : null;
        });

        expect(intMap, isA<Map<String, int>?>());
        expect(intMap, equals({'a': 1, 'b': 2}));
      });

      test('mapValuesOrEmpty transforms map values and never returns null', () {
        final simpleMap = JsonSon({'a': '1', 'b': '2', 'c': 'not a number'});

        final intMap = simpleMap.mapValuesOrEmpty<String, int>((key, value) {
          final intValue = int.tryParse(value.toString());
          return intValue != null ? MapEntry(key, intValue) : null;
        });

        expect(intMap, isA<Map<String, int>>());
        expect(intMap, equals({'a': 1, 'b': 2}));

        final emptyMap =
            JsonSon({}).mapValuesOrEmpty<String, int>((key, value) {
          return null;
        });

        expect(emptyMap, isA<Map<String, int>>());
        expect(emptyMap, isEmpty);
      });
    });

    group('Utility Methods', () {
      test('hasKey checks if key exists', () {
        expect(json.hasKey('id'), isTrue);
        expect(json.hasKey('nonexistent'), isFalse);
      });

      test('keys returns all keys in the map', () {
        expect(
            json.keys,
            containsAll(
                ['id', 'name', 'price', 'isActive', 'stock', 'variants']));
        expect(json.keys.length, equals(testData.keys.length));
      });

      test('rawData returns the underlying map', () {
        expect(json.rawData, equals(testData));
      });

      test('select returns a new JsonSon with only specified keys', () {
        final selected = json.select(['id', 'name', 'price']);
        expect(selected, isA<JsonSon>());
        expect(selected.keys.length, equals(3));
        expect(selected.hasKey('id'), isTrue);
        expect(selected.hasKey('name'), isTrue);
        expect(selected.hasKey('price'), isTrue);
        expect(selected.hasKey('stock'), isFalse);
      });

      test('exclude returns a new JsonSon without specified keys', () {
        final excluded = json.exclude(['stock', 'variants']);
        expect(excluded, isA<JsonSon>());
        expect(excluded.hasKey('id'), isTrue);
        expect(excluded.hasKey('name'), isTrue);
        expect(excluded.hasKey('stock'), isFalse);
        expect(excluded.hasKey('variants'), isFalse);
      });

      test('toJson converts to JSON string', () {
        final jsonString = json.toJson();
        expect(jsonString, isA<String>());

        final decoded = jsonDecode(jsonString);
        expect(decoded, equals(testData));
      });

      test('toString returns a string representation', () {
        expect(json.toString(), startsWith('JsonSon('));
        expect(json.toString(), contains('id'));
        expect(json.toString(), contains('name'));
      });
    });

    group('Error Tracking', () {
      test('tracks errors during path access', () {
        final json = JsonSon({
          'data': {
            'user': {'name': 'John'}
          }
        });

        // Access a non-existent path
        final result = json.getPath('data.user.nonexistent');

        expect(result, isNull);
        expect(json.hasErrors, isTrue);
        expect(json.errors, isNotEmpty);
        expect(json.errors.first, contains('not found'));
      });

      test('clears errors', () {
        final json = JsonSon({
          'data': {
            'user': {'name': 'John'}
          }
        });

        // Generate an error
        json.getPath('data.user.nonexistent');
        expect(json.hasErrors, isTrue);

        // Clear errors
        json.clearErrors();
        expect(json.hasErrors, isFalse);
        expect(json.errors, isEmpty);
      });

      test('tracks errors for invalid array indices', () {
        final json = JsonSon({
          'data': {
            'items': [1, 2, 3]
          }
        });

        // Access an out-of-bounds index
        final result = json.getPath('data.items.5');

        expect(result, isNull);
        expect(json.hasErrors, isTrue);
        expect(json.errors.first, contains('out of bounds'));
      });
    });

    group('Advanced Constructors', () {
      test('fromJson handles valid JSON string', () {
        final jsonString = '{"name":"John","age":30}';
        final json = JsonSon.fromJson(jsonString);

        expect(json.getString('name'), equals('John'));
        expect(json.getInt('age'), equals(30));
        expect(json.hasErrors, isFalse);
      });

      test('fromJson handles invalid JSON string', () {
        final invalidJson = '{name:John}';
        final json = JsonSon.fromJson(invalidJson);

        expect(json.hasErrors, isTrue);
        expect(json.errors.first, contains('Failed to parse JSON'));
      });

      test('fromApiResponse handles Map response', () {
        final response = {'name': 'John', 'age': 30};
        final json = JsonSon.fromApiResponse(response);

        expect(json.getString('name'), equals('John'));
        expect(json.hasErrors, isFalse);
      });

      test('fromApiResponse handles String response', () {
        final response = '{"name":"John","age":30}';
        final json = JsonSon.fromApiResponse(response);

        expect(json.getString('name'), equals('John'));
        expect(json.hasErrors, isFalse);
      });

      test('fromApiResponse handles invalid response type', () {
        final response = 42;
        final json = JsonSon.fromApiResponse(response);

        expect(json.hasErrors, isTrue);
        expect(json.errors.first, contains('Invalid response type'));
      });

      test('fromMapSafe handles valid Map', () {
        final map = {'name': 'John'};
        final json = JsonSon.fromMapSafe(map);

        expect(json, isNotNull);
        expect(json?.getString('name'), equals('John'));
      });

      test('fromMapSafe handles non-Map input', () {
        final notAMap = 'not a map';
        final json = JsonSon.fromMapSafe(notAMap);

        expect(json, isNull);
      });
    });

    group('Path Operations', () {
      test('hasPath checks if path exists', () {
        final json = JsonSon({
          'user': {
            'profile': {'name': 'John'},
            'posts': [
              {'title': 'Hello'},
              {'title': 'World'}
            ]
          }
        });

        expect(json.hasPath('user.profile.name'), isTrue);
        expect(json.hasPath('user.posts.0.title'), isTrue);
        expect(json.hasPath('user.nonexistent'), isFalse);
        expect(json.hasPath('user.posts.5'), isFalse);
      });

      test('hasRequiredPaths validates multiple paths', () {
        final json = JsonSon({
          'user': {'id': 1, 'name': 'John', 'email': 'john@example.com'}
        });

        expect(json.hasRequiredPaths(['user.id', 'user.name']), isTrue);
        expect(json.hasRequiredPaths(['user.id', 'user.nonexistent']), isFalse);
        expect(json.hasErrors, isTrue);
        expect(json.errors.first, contains('Missing required paths'));
      });

      test('hasRequiredKeys validates multiple keys', () {
        final json = JsonSon({'id': 1, 'name': 'John', 'email': null});

        expect(json.hasRequiredKeys(['id', 'name']), isTrue);
        expect(json.hasRequiredKeys(['id', 'email']), isFalse); // email is null
        expect(json.hasErrors, isTrue);
        expect(json.errors.first, contains('Missing required keys'));
      });
    });

    group('Batch Operations', () {
      test('getMultiple retrieves multiple values with type safety', () {
        final json = JsonSon(
            {'id': '123', 'name': 'John', 'active': true, 'missing': null});

        final strings = json
            .getMultiple<String>(['id', 'name', 'nonexistent'], json.getString);

        expect(strings, isA<Map<String, String?>>());
        expect(strings['id'], equals('123'));
        expect(strings['name'], equals('John'));
        expect(strings['nonexistent'], isNull);
      });

      test('getStrings retrieves multiple string values', () {
        final json = JsonSon({
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'john@example.com'
        });

        final strings =
            json.getStrings(['first_name', 'last_name', 'nonexistent']);

        expect(strings['first_name'], equals('John'));
        expect(strings['last_name'], equals('Doe'));
        expect(strings['nonexistent'], isNull);
      });

      test('getInts retrieves multiple int values', () {
        final json = JsonSon({'id': '123', 'age': 30, 'score': '95'});

        final ints = json.getInts(['id', 'age', 'score', 'nonexistent']);

        expect(ints['id'], equals(123));
        expect(ints['age'], equals(30));
        expect(ints['score'], equals(95));
        expect(ints['nonexistent'], isNull);
      });
    });

    group('Fallback Keys', () {
      test('getWithFallbacks tries multiple keys in order', () {
        final json = JsonSon({'user_id': '123', 'display_name': 'John Doe'});

        final id =
            json.getWithFallbacks(['id', 'userId', 'user_id'], json.getString);
        final name = json.getWithFallbacks(
            ['name', 'displayName', 'display_name'], json.getString);
        final email =
            json.getWithFallbacks(['email', 'emailAddress'], json.getString);

        expect(id, equals('123'));
        expect(name, equals('John Doe'));
        expect(email, isNull);
      });

      test('getStringWithFallbacks gets string with fallbacks', () {
        final json = JsonSon({'display_name': 'John Doe'});

        final name = json
            .getStringWithFallbacks(['name', 'displayName', 'display_name']);

        expect(name, equals('John Doe'));
      });

      test('getIntWithFallbacks gets int with fallbacks', () {
        final json = JsonSon({'user_id': '123'});

        final id = json.getIntWithFallbacks(['id', 'userId', 'user_id']);

        expect(id, equals(123));
      });
    });

    group('Transformation Methods', () {
      test('transform applies a function to JsonSon', () {
        final json = JsonSon({'name': 'John', 'age': '30'});

        final result = json.transform((j) => {
              'fullName': j.getString('name'),
              'isAdult': j.getInt('age')! >= 18
            });

        expect(result, isA<Map>());
        expect(result['fullName'], equals('John'));
        expect(result['isAdult'], isTrue);
      });

      test('transformValues transforms values matching a condition', () {
        final json =
            JsonSon({'name': 'john', 'email': 'JOHN@EXAMPLE.COM', 'age': 30});

        // Transform all string values to uppercase
        final upperJson = json.transformValues((key, value) => value is String,
            (key, value) => (value as String).toUpperCase());

        expect(upperJson.getString('name'), equals('JOHN'));
        expect(upperJson.getString('email'), equals('JOHN@EXAMPLE.COM'));
        expect(upperJson.getInt('age'), equals(30)); // Not transformed
      });

      test('filterKeys filters keys based on a condition', () {
        final json = JsonSon({
          'id': 123,
          'name': 'John',
          'email': 'john@example.com',
          'password': 'secret',
          'token': 'abc123'
        });

        // Filter out sensitive fields
        final filtered = json
            .filterKeys((key, value) => !['password', 'token'].contains(key));

        expect(filtered.hasKey('id'), isTrue);
        expect(filtered.hasKey('name'), isTrue);
        expect(filtered.hasKey('email'), isTrue);
        expect(filtered.hasKey('password'), isFalse);
        expect(filtered.hasKey('token'), isFalse);
      });

      test('merge combines two JsonSon objects', () {
        final json1 = JsonSon({'id': 1, 'name': 'John'});
        final json2 =
            JsonSon({'email': 'john@example.com', 'name': 'John Doe'});

        final merged = json1.merge(json2);

        expect(merged.getInt('id'), equals(1));
        expect(merged.getString('name'),
            equals('John Doe')); // json2 takes precedence
        expect(merged.getString('email'), equals('john@example.com'));
      });
    });

    group('Edge Cases', () {
      test('handles empty data gracefully', () {
        final emptyJson = JsonSon({});
        expect(emptyJson.getInt('id'), isNull);
        expect(emptyJson.getString('name'), isNull);
        expect(emptyJson.getObject('stock'), isNull);
        expect(emptyJson.keys, isEmpty);
      });

      test('handles invalid path access gracefully', () {
        final emptyJson = JsonSon({});
        expect(emptyJson.getIntPath('some.path'), isNull);
        expect(emptyJson.getStringPath('some.path'), isNull);
        expect(emptyJson.getObjectPath('some.path'), isNull);
        expect(emptyJson.getIntPathOrDefault('some.path', 42), equals(42));
      });

      test('handles deep nested paths gracefully', () {
        // Valid deep path
        expect(json.getStringPath('stock.locations.0'), equals('Store A'));

        // Invalid deep paths
        expect(json.getStringPath('stock.locations.999'), isNull);
        expect(json.getStringPath('stock.nonexistent.field'), isNull);
        expect(json.getStringPath('a.very.deep.nonexistent.path'), isNull);
      });

      test('handles type mismatches gracefully', () {
        // Trying to get an object as a primitive
        expect(json.getInt('stock'), isNull);

        // Trying to get a primitive as an object
        expect(json.getObject('id'), isNull);

        // Trying to get a list as an object
        expect(json.getObject('ratings'), isNull);
      });
    });
  });
}
