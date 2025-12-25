<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# json_son (Just Straightens Out Nonsense)

A Dart utility package providing helper functions to flexibly parse JSON values that might have inconsistent data types. This is especially useful when dealing with APIs that might send numbers as strings, booleans as strings/integers, dates in various formats, single items instead of lists, comma-separated string lists, or strings with leading/trailing whitespace.

This package offers two approaches:

1. **Functional Approach**: Helper functions designed to be used with JSON deserialization, often in conjunction with code generation libraries like `json_serializable` (used by `freezed`), by annotating DTO fields with `@JsonKey(fromJson: ...)`.

2. **Class-Based Approach**: A fluent `JsonSon` class that wraps a JSON object and provides methods for type-safe access, making it easier to work with complex nested structures.

## Features

### Core Features
- Convert dynamic JSON values to `int?`, `double?`, `num?`, `bool?`, `String?`, `DateTime?`, `Uri?`, `List<T>?`, or `List<T>`.
- Parse comma-separated strings into `List<String>?`.
- Normalize strings (trimming, case conversion).
- Gracefully handles `null`s, empty strings, and parsing failures by returning `null` (or an empty list for non-null list helpers).
- Supports common alternative representations (e.g., "true" or 1 for boolean `true`, numeric strings for numbers, ISO 8601 or timestamps for `DateTime`).
- Handles APIs that may return a single item where a list is expected.
- **NEW in 0.5.0**: Parse enums, BigInt, Duration, phone numbers, slugs, and currency values.

### Enhanced JsonSon Class
- **Error Tracking**: Detailed error tracking with path information for debugging and validation.
- **Advanced Constructors**: Multiple constructors for different data sources:
  - `fromApiResponse`: Handle API responses that might be strings or maps
  - `fromMapSafe`: Safely create JsonSon instances with error handling
- **Path-Based Access**: Access nested values using dot notation (e.g., `user.address.city`)
- **Batch Operations**: Process multiple keys or paths at once
- **Fallback Keys**: Try multiple keys in sequence until a value is found
- **Transformation Methods**: Transform JSON data with mapping functions
- **Validation**: Check for required keys and paths with detailed error messages
- **NEW in 0.5.0**: Deep merge, diff, pick, flatten/unflatten, conditional getters, query string conversion

### Extensions
- **Map Extensions**: Direct access to JsonSon methods from Map objects
- **API Extensions**: Support for common API patterns including:
  - Pagination information extraction
  - Error handling with code and message extraction
  - User information normalization
  - Timestamp handling

### Validation Framework
- **Fluent Validation API**: Chain validation rules for complex validation logic
- **Type Validation**: Validate types (string, integer, boolean, etc.)
- **Format Validation**: Validate formats (email, URL, patterns)
- **Range Validation**: Validate numeric ranges and string lengths
- **Custom Validation**: Create custom validation rules
- **Nested Validation**: Validate nested objects and array items
- **NEW in 0.5.0**: Phone, UUID, credit card, date range, conditional validation, array uniqueness

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  json_son: ^0.5.0 # Or the latest version
```

Then, run `flutter pub get` or `dart pub get`.

### Usage

#### Functional Approach

Import the library and use the helper functions in your DTOs:

```dart
import 'package:json_son/json_son.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_model.freezed.dart';
part 'my_model.g.dart';

@freezed
abstract class MyModel with _$MyModel {
  const factory MyModel({
    @JsonKey(fromJson: flexibleIntFromJson) int? anInt,
    @JsonKey(fromJson: flexibleDoubleFromJson) double? aDouble,
    @JsonKey(fromJson: flexibleNumFromJson) num? aNum,
    @JsonKey(fromJson: flexibleBoolFromJson) bool? aBool,
    @JsonKey(fromJson: flexibleStringFromJson) String? aString,
    @JsonKey(fromJson: flexibleDateTimeFromJson) DateTime? aDateTime,
    @JsonKey(fromJson: flexibleUriFromJson) Uri? aUri,
    @JsonKey(fromJson: (json) => flexibleListFromJson<int>(json, flexibleIntFromJson)) List<int?>? nullableIntList,
    @JsonKey(fromJson: (json) => flexibleListNotNullFromJson<String>(json, flexibleStringFromJson)) List<String> nonNullStringList,
    @JsonKey(fromJson: flexibleCommaSeparatedListFromJson) List<String>? tags,
    @JsonKey(fromJson: flexibleTrimmedStringFromJson) String? description,
    @JsonKey(fromJson: flexibleLowerStringFromJson) String? category,
    @JsonKey(fromJson: flexibleUpperStringFromJson) String? productCode,
    String? normallyAString, // No helper needed if type is consistent
  }) = _MyModel;

  factory MyModel.fromJson(Map<String, dynamic> json) => _$MyModelFromJson(json);
}
```

Make sure to run your build runner after adding these annotations:
`flutter pub run build_runner build --delete-conflicting-outputs`

#### Class-Based Approach

Use the enhanced `JsonSon` class for a more fluent API with advanced features:

```dart
import 'package:json_son/json_son.dart';

// Parse JSON data with error tracking
final Map<String, dynamic> jsonData = getJsonFromSomewhere();
final json = JsonSon(jsonData);

// Basic property access with type conversion
final id = json.getInt('id');
final name = json.getString('name');
final isActive = json.getBool('isActive');

// With default values
final count = json.getIntOrDefault('count', 0);
final status = json.getStringOrDefault('status', 'pending');

// Access nested objects
final user = json.getObject('user');
if (user != null) {
  final firstName = user.getString('firstName');
  final lastName = user.getString('lastName');
  
  // Access nested objects within nested objects
  final address = user.getObject('address');
  if (address != null) {
    final city = address.getString('city');
    final zipCode = address.getString('zipCode');
  }
}

// Path-based access with dot notation
final city = json.getStringPath('user.address.city');
final zipCode = json.getStringPath('user.address.zipCode');
final isVerified = json.getBoolPath('user.account.isVerified');

// List handling
final scores = json.getList<int>('scores', flexibleIntFromJson);

// Error tracking
if (json.hasErrors) {
  print('Errors occurred: ${json.errors}');
}

// Advanced constructors
final apiJson = JsonSon.fromApiResponse(responseBody);
final safeJson = JsonSon.fromMapSafe(potentiallyInvalidMap);

// Batch operations
final userInfo = json.getBatch(['id', 'name', 'email']);
final addressInfo = json.getPathBatch(['user.address.street', 'user.address.city']);

// Fallback keys (try multiple keys in sequence)
final userId = json.getIntWithFallbacks(['id', 'userId', 'user_id']);
final userName = json.getStringWithFallbacks(['name', 'username', 'displayName']);

// Required fields validation
final requiredFields = ['id', 'name', 'email'];
if (!json.hasRequiredKeys(requiredFields)) {
  print('Missing required fields: ${json.getMissingKeys(requiredFields)}');
}

// Transform data
final transformedJson = json.transform((key, value) {
  if (key == 'dates') return value is List ? value.map((d) => DateTime.parse(d)).toList() : null;
  return value;
});
```

#### Extensions

Use the Map extensions for quick access to JsonSon methods:

```dart
import 'package:json_son/json_son.dart';

final Map<String, dynamic> userData = {'id': '123', 'name': 'John', 'active': 'true'};

// Direct access to JsonSon methods from Map
final id = userData.getInt('id'); // 123
final name = userData.getString('name'); // 'John'
final isActive = userData.getBool('active'); // true

// Convert to JsonSon instance
final json = userData.json;
```

#### API Pattern Extensions

Use specialized extensions for common API patterns:

```dart
import 'package:json_son/json_son.dart';

// Pagination information
final paginationJson = JsonSon({
  'total': 100,
  'page': 2,
  'per_page': 25,
  'has_more': true
});

final pagination = paginationJson.getPaginationInfo();
print('Page ${pagination.page} of ${pagination.totalPages}');
print('Has next page: ${pagination.hasNextPage}');

// API error handling
final errorJson = JsonSon({
  'error': {
    'code': 'AUTH_FAILED',
    'message': 'Authentication failed'
  }
});

final error = errorJson.getApiError();
if (error != null) {
  print('Error: ${error.userMessage}');
  if (error.hasErrorCode('AUTH_FAILED')) {
    // Handle authentication error
  }
}

// User information
final userJson = JsonSon({
  'id': 1001,
  'first_name': 'Jane',
  'last_name': 'Doe',
  'email': 'jane.doe@example.com'
});

final user = userJson.getUserInfo();
print('Full name: ${user.fullName}'); // 'Jane Doe'
```

#### New Type Parsers (v0.5.0)

Parse enums, durations, BigInt, and more:

```dart
import 'package:json_son/json_son.dart';

enum Status { pending, active, completed }

// Enum parsing (case-insensitive string or index)
final status = flexibleEnumFromJson('active', Status.values); // Status.active
final statusByIndex = flexibleEnumFromJson(1, Status.values); // Status.active
final statusWithFallback = flexibleEnumFromJson('invalid', Status.values, fallback: Status.pending);

// BigInt for large numbers
final bigNum = flexibleBigIntFromJson('12345678901234567890');

// Duration parsing (ISO 8601, human-readable, or map)
final duration1 = flexibleDurationFromJson('PT1H30M'); // 1 hour 30 minutes
final duration2 = flexibleDurationFromJson('2h 30m'); // 2 hours 30 minutes
final duration3 = flexibleDurationFromJson({'hours': 2, 'minutes': 30});
final duration4 = flexibleDurationFromJson(5000); // 5000 milliseconds

// Phone number normalization
final phone = flexiblePhoneFromJson('(555) 123-4567'); // '5551234567'
final intlPhone = flexiblePhoneFromJson('+1 555 123 4567'); // '+15551234567'

// URL-safe slug generation
final slug = flexibleSlugFromJson('Hello World! 123'); // 'hello-world-123'

// Currency parsing
final price = flexibleCurrencyFromJson('\$1,234.56'); // CurrencyValue(1234.56, 'USD')
final euroPrice = flexibleCurrencyFromJson('€100'); // CurrencyValue(100.0, 'EUR')
final priceFromMap = flexibleCurrencyFromJson({'amount': 50.0, 'currency': 'GBP'});
```

#### Advanced JsonSon Operations (v0.5.0)

Use the new advanced operations for complex data manipulation:

```dart
import 'package:json_son/json_son.dart';

final json = JsonSon({
  'user': {
    'name': 'John',
    'settings': {'theme': 'dark', 'notifications': true}
  },
  'scores': [85, 92, 78]
});

// New type getters
final duration = json.getDuration('timeout');
final bigId = json.getBigInt('largeId');
final price = json.getCurrency('price');
final status = json.getEnum('status', Status.values);
final phone = json.getPhone('phone');
final slug = json.getSlug('title');

// Path-based list access
final scores = json.getListPath<int>('data.scores', flexibleIntFromJson);

// Deep merge (recursively merges nested objects)
final base = JsonSon({'a': 1, 'nested': {'b': 2, 'c': 3}});
final override = JsonSon({'nested': {'c': 30, 'd': 4}});
final merged = base.deepMerge(override);
// Result: {'a': 1, 'nested': {'b': 2, 'c': 30, 'd': 4}}

// Diff (compare two JsonSon objects)
final original = JsonSon({'a': 1, 'b': 2});
final modified = JsonSon({'a': 1, 'b': 20, 'c': 3});
final diff = original.diff(modified);
// diff['added'] = {'c': 3}
// diff['changed'] = {'b': {'from': 2, 'to': 20}}

// Pick (select nested paths)
final picked = json.pick(['user.name', 'user.settings.theme']);
// Result: {'user': {'name': 'John', 'settings': {'theme': 'dark'}}}

// Flatten/Unflatten
final flat = json.flatten(); // {'user.name': 'John', 'user.settings.theme': 'dark', ...}
final nested = JsonSon.unflatten({'a.b.c': 1}); // {'a': {'b': {'c': 1}}}

// Conditional getters
final age = json.getIntIf('age', (v) => v >= 18); // Only returns if >= 18
final name = json.getStringIf('name', (v) => v.length >= 3);

// Convert to query string
final queryJson = JsonSon({'page': 1, 'search': 'hello world'});
final queryString = queryJson.toQueryString(); // 'page=1&search=hello%20world'
```

#### Enhanced Validation (v0.5.0)

New validation methods for common patterns:

```dart
import 'package:json_son/json_son.dart';

final json = JsonSon({
  'phone': '555-123-4567',
  'uuid': '550e8400-e29b-41d4-a716-446655440000',
  'card': '4532015112830366',
  'birthDate': '1990-05-15',
  'type': 'business',
  'company': 'Acme Inc',
  'tags': ['a', 'b', 'c'],
  'password': 'secret123',
  'confirmPassword': 'secret123',
  'url': 'https://example.com/page'
});

final validator = JsonSonValidator(json)
  // Format validators
  ..phone('phone')
  ..uuid('uuid')
  ..creditCard('card')
  
  // Date validators
  ..dateRange('birthDate', min: DateTime(1900), max: DateTime.now())
  ..pastDate('birthDate')
  
  // Conditional validation
  ..requiredWhen('company', 'type', 'business') // company required when type is 'business'
  ..requiredWith('confirmPassword', 'password') // confirmPassword required when password exists
  
  // Array validators
  ..unique('tags') // All items must be unique
  ..minItems('tags', 1)
  ..maxItems('tags', 10)
  
  // Comparison validators
  ..between('age', 0, 120)
  ..equals('confirmPassword', 'password') // Must match password field
  ..different('newPassword', 'oldPassword')
  
  // String validators
  ..contains('email', '@')
  ..startsWith('url', 'https://')
  ..endsWith('file', '.pdf');

if (!validator.isValid) {
  print('Errors: ${validator.errors}');
}
```

#### Validation Framework

Use the fluent validation API for complex validations:

```dart
import 'package:json_son/json_son.dart';

final json = JsonSon({
  'username': 'johndoe',
  'email': 'john@example.com',
  'age': 25,
  'password': 'pass123',
  'role': 'user',
  'address': {
    'city': 'New York',
    'zipcode': '10001'
  }
});

final validator = JsonSonValidator(json)
  // Required fields
  ..required('username')
  ..required('email')
  ..required('password')
  
  // Type validation
  ..string('username')
  ..integer('age')
  
  // Format validation
  ..email('email')
  ..pattern('zipcode', RegExp(r'^\d{5}(-\d{4})?$'))
  
  // Range validation
  ..min('age', 18)
  ..minLength('password', 8)
  ..maxLength('username', 20)
  
  // Allowed values
  ..oneOf('role', ['user', 'admin', 'moderator'])
  
  // Nested validation
  ..nested('address', (addressValidator) {
    addressValidator
      ..required('city')
      ..required('zipcode');
  });

if (!validator.isValid) {
  print('Validation errors:');
  validator.errors.forEach((field, error) {
    print('$field: $error');
  });
}
```

## Available Classes and APIs

### JsonSon Class

The `JsonSon` class is the core of the class-based approach, providing a fluent API for working with JSON data:

```dart
class JsonSon {
  // Constructors
  JsonSon(Map<String, dynamic> data);
  JsonSon.empty();
  factory JsonSon.fromApiResponse(dynamic response);
  factory JsonSon.fromMapSafe(dynamic map);
  
  // Basic getters
  Map<String, dynamic> get rawData;
  bool get hasErrors;
  List<String> get errors;
  
  // Type-safe access methods
  int? getInt(String key);
  double? getDouble(String key);
  num? getNum(String key);
  bool? getBool(String key);
  String? getString(String key);
  DateTime? getDateTime(String key);
  Uri? getUri(String key);
  JsonSon? getObject(String key);
  List<T>? getList<T>(String key, T? Function(dynamic) itemParser);
  
  // With default values
  int getIntOrDefault(String key, int defaultValue);
  double getDoubleOrDefault(String key, double defaultValue);
  bool getBoolOrDefault(String key, bool defaultValue);
  String getStringOrDefault(String key, String defaultValue);
  
  // Path-based access
  dynamic getPath(String path);
  int? getIntPath(String path);
  double? getDoublePath(String path);
  bool? getBoolPath(String path);
  String? getStringPath(String path);
  DateTime? getDateTimePath(String path);
  Uri? getUriPath(String path);
  JsonSon? getObjectPath(String path);
  
  // Batch operations
  Map<String, dynamic> getBatch(List<String> keys);
  Map<String, dynamic> getPathBatch(List<String> paths);
  
  // Fallback keys
  T? getWithFallbacks<T>(List<String> keys, T? Function(dynamic) getter);
  int? getIntWithFallbacks(List<String> keys);
  double? getDoubleWithFallbacks(List<String> keys);
  bool? getBoolWithFallbacks(List<String> keys);
  String? getStringWithFallbacks(List<String> keys);
  
  // Validation
  bool hasKey(String key);
  bool hasPath(String path);
  bool hasRequiredKeys(List<String> keys);
  bool hasRequiredPaths(List<String> paths);
  List<String> getMissingKeys(List<String> keys);
  List<String> getMissingPaths(List<String> paths);
  
  // Transformation
  JsonSon transform(dynamic Function(String key, dynamic value) transformer);
  JsonSon merge(JsonSon other, {bool overwrite = true});
}
```

### JsonSonValidator

The `JsonSonValidator` class provides a fluent API for validating JSON data:

```dart
class JsonSonValidator {
  JsonSonValidator(JsonSon json);
  
  Map<String, String> get errors;
  bool get isValid;
  
  // Basic validation
  JsonSonValidator required(String key, {String? message});
  JsonSonValidator requiredPath(String path, {String? message});
  
  // Type validation
  JsonSonValidator string(String key, {String? message});
  JsonSonValidator integer(String key, {String? message});
  JsonSonValidator double(String key, {String? message});
  JsonSonValidator boolean(String key, {String? message});
  JsonSonValidator date(String key, {String? message});
  JsonSonValidator array(String key, {String? message});
  JsonSonValidator object(String key, {String? message});
  
  // Format validation
  JsonSonValidator email(String key, {String? message});
  JsonSonValidator url(String key, {String? message});
  JsonSonValidator pattern(String key, RegExp pattern, {String? message});
  
  // Range validation
  JsonSonValidator min(String key, num minValue, {String? message});
  JsonSonValidator max(String key, num maxValue, {String? message});
  JsonSonValidator minLength(String key, int minLength, {String? message});
  JsonSonValidator maxLength(String key, int maxLength, {String? message});
  
  // Value validation
  JsonSonValidator oneOf(String key, List<dynamic> allowedValues, {String? message});
  JsonSonValidator custom(String key, bool Function(dynamic) validator, {String? message});
  
  // Nested validation
  JsonSonValidator nested(String key, void Function(JsonSonValidator) validator);
  JsonSonValidator eachItem(String key, void Function(JsonSonValidator, int) itemValidator);
  
  // New in v0.5.0
  
  // Format validators
  JsonSonValidator phone(String key, {String? message, int? minDigits, int? maxDigits});
  JsonSonValidator uuid(String key, {String? message});
  JsonSonValidator creditCard(String key, {String? message});
  
  // Date validators
  JsonSonValidator dateRange(String key, {DateTime? min, DateTime? max, String? message});
  JsonSonValidator pastDate(String key, {String? message});
  JsonSonValidator futureDate(String key, {String? message});
  
  // Conditional validators
  JsonSonValidator when(String conditionKey, bool Function(dynamic) condition, void Function(JsonSonValidator) validatorFn);
  JsonSonValidator requiredWhen(String key, String conditionKey, dynamic conditionValue, {String? message});
  JsonSonValidator requiredWith(String key, String otherKey, {String? message});
  JsonSonValidator requiredWithout(String key, String otherKey, {String? message});
  
  // Array validators
  JsonSonValidator unique(String key, {String? message, dynamic Function(dynamic)? by});
  JsonSonValidator minItems(String key, int count, {String? message});
  JsonSonValidator maxItems(String key, int count, {String? message});
  
  // Comparison validators
  JsonSonValidator between(String key, num minValue, num maxValue, {String? message});
  JsonSonValidator equals(String key, String otherKey, {String? message});
  JsonSonValidator different(String key, String otherKey, {String? message});
  
  // String validators
  JsonSonValidator contains(String key, String substring, {String? message, bool caseSensitive});
  JsonSonValidator startsWith(String key, String prefix, {String? message});
  JsonSonValidator endsWith(String key, String suffix, {String? message});
}
```

### Helper Classes

```dart
// Currency value helper (new in v0.5.0)
class CurrencyValue {
  final double amount;
  final String? currencyCode;
  
  String toString() => currencyCode != null ? '$currencyCode ${amount.toStringAsFixed(2)}' : amount.toStringAsFixed(2);
}

// Pagination information helper
class PaginationInfo {
  final int? total;
  final int? page;
  final int? limit;
  final bool? hasMore;
  final int? nextPage;
  
  int? get totalPages => total != null && limit != null ? (total / limit).ceil() : null;
  bool get hasNextPage => hasMore == true || (nextPage != null) || (page != null && totalPages != null && page < totalPages);
}

// API error helper
class ApiError {
  final String? message;
  final String? code;
  final String? details;
  final List<String>? errors;
  
  String get userMessage => message ?? (errors?.isNotEmpty == true ? errors!.first : 'An unknown error occurred');
  bool hasErrorCode(String errorCode) => code == errorCode;
}

// User information helper
class UserInfo {
  final int? id;
  final String? name;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  
  String? get fullName => firstName != null && lastName != null ? '$firstName $lastName' : name;
}

// Timestamp information helper
class TimestampInfo {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  
  bool get isDeleted => deletedAt != null;
  Duration? get age => createdAt != null ? DateTime.now().difference(createdAt!) : null;
  Duration? get timeSinceUpdate => updatedAt != null ? DateTime.now().difference(updatedAt!) : null;
}
```

### Functional API

- `int? flexibleIntFromJson(dynamic value)`
  - Parses to `int?`. Handles `null`, `int`, `double` (truncates), `String`.
  - Empty or unparseable string results in `null`.

- `double? flexibleDoubleFromJson(dynamic value)`
  - Parses to `double?`. Handles `null`, `double`, `int`, `String`.
  - Empty or unparseable string results in `null`.

- `num? flexibleNumFromJson(dynamic value)`
  - Parses to `num?` (can be `int` or `double`). Handles `null`, `num`, `String`.
  - Empty or unparseable string results in `null`.

- `bool? flexibleBoolFromJson(dynamic value)`
  - Parses to `bool?`. Handles `null`, `bool`, `String` ("true", "false", "1", "0", case-insensitive), `int` (1, 0).
  - Empty string or unhandled values result in `null`.

- `String? flexibleStringFromJson(dynamic value)`
  - Parses to `String?`. Handles `null`, `String`. Converts other types (e.g., `int`, `bool`) to string via `.toString()`.

- `DateTime? flexibleDateTimeFromJson(dynamic value)`
  - Parses to `DateTime?` (UTC). Handles `null`.
  - If `int`: assumes milliseconds since epoch.
  - If `String`: tries ISO 8601, then numeric string as milliseconds since epoch.
  - Empty or unparseable string results in `null`.

- `Uri? flexibleUriFromJson(dynamic value)`
  - Parses to `Uri?`. Handles `null`, `String`.
  - Empty or unparseable string results in `null`.

- `List<T?>? flexibleListFromJson<T>(dynamic value, T? Function(dynamic) itemParser)`
  - Ensures result is a `List<T?>?`. Handles `null` input, or a single item being returned by API instead of a list.
  - Parses each item in the list using the provided `itemParser`.
  - Filters out items that parse to `null`.
  - Returns `null` if the input is `null`, or if a single item input parses to `null`.

- `List<T> flexibleListNotNullFromJson<T>(dynamic value, T? Function(dynamic) itemParser)`
  - Ensures result is a non-nullable `List<T>`. Handles `null` input or a single item.
  - Parses each item in the list using the provided `itemParser`.
  - Filters out items that parse to `null`.
  - Returns an empty list if the input is `null` or if all items parse to `null`.

- `int flexibleRequiredIntFromJson(dynamic value)`
  - Non-nullable version of `flexibleIntFromJson`.
  - Returns `0` instead of `null` when the input is `null` or cannot be parsed as an integer.
  - Useful when you need to guarantee a non-null integer value.

- `double flexibleRequiredDoubleFromJson(dynamic value)`
  - Non-nullable version of `flexibleDoubleFromJson`.
  - Returns `0.0` instead of `null` when the input is `null` or cannot be parsed as a double.
  - Useful when you need to guarantee a non-null double value.

- `String flexibleRequiredStringFromJson(dynamic value)`
  - Non-nullable version of `flexibleStringFromJson`.
  - Returns an empty string (`""`) instead of `null` when the input is `null`.
  - Useful when you need to guarantee a non-null string value.

- `bool flexibleRequiredBoolFromJson(dynamic value)`
  - Non-nullable version of `flexibleBoolFromJson`.
  - Returns `false` instead of `null` when the input is `null` or cannot be parsed as a boolean.
  - Useful when you need to guarantee a non-null boolean value.

- `List<T> flexibleRequiredListFromJson<T>(dynamic value, T? Function(dynamic) itemParser)`
  - Alias for `flexibleListNotNullFromJson` to provide a consistent naming convention.
  - Returns an empty list if the input is `null` or if all items parse to `null`.
  - Useful when you need to guarantee a non-null list.

- `List<String>? flexibleCommaSeparatedListFromJson(dynamic value)`
  - Parses comma-separated strings (e.g., "apple, banana, cherry") into `List<String>?`.
  - Trims whitespace from each item and filters out empty strings.
  - Handles `null` input. If input is already a list, its elements are stringified and trimmed.

- `String? flexibleTrimmedStringFromJson(dynamic value)`
  - Converts input to string, trims whitespace. Returns `null` if the result is empty, otherwise the trimmed string.

- `String? flexibleLowerStringFromJson(dynamic value)`
  - Converts input to string, trims it, then converts to lowercase. Returns `null` if the trimmed string is empty.

- `String? flexibleUpperStringFromJson(dynamic value)`
  - Converts input to string, trims it, then converts to uppercase. Returns `null` if the trimmed string is empty.

- `Map<K, V>? flexibleMapFromJson<K, V>(dynamic value, MapEntry<K, V>? Function(dynamic key, dynamic value) mapper)`
  - Transforms a map by applying a transformation function to each key-value pair.
  - Handles `null` input by returning `null`.
  - The `mapper` function can return `null` to skip entries.
  - Example: Converts `{"a": "1", "b": "2"}` to `{"a": 1, "b": 2}` when used with `int.tryParse`.

- `Map<K, V> flexibleMapNotNullFromJson<K, V>(dynamic value, MapEntry<K, V>? Function(dynamic key, dynamic value) mapper)`
  - Similar to `flexibleMapFromJson` but returns an empty map instead of `null` for `null` input.
  - The `mapper` function can return `null` to skip entries.
  - Example: Converts `{"a": "1", "b": "x"}` to `{"a": 1}` when used with `int.tryParse`.

#### New in v0.5.0

- `T? flexibleEnumFromJson<T extends Enum>(dynamic value, List<T> values, {T? fallback})`
  - Parses to an enum value. Handles `String` (case-insensitive name matching) and `int` (index).
  - Returns `fallback` if parsing fails or value is null.

- `T flexibleRequiredEnumFromJson<T extends Enum>(dynamic value, List<T> values, T fallback)`
  - Non-nullable version that always returns the fallback if parsing fails.

- `BigInt? flexibleBigIntFromJson(dynamic value)`
  - Parses to `BigInt?`. Handles `null`, `int`, `String`, and `BigInt`.
  - Useful for large integers that overflow int64.

- `Duration? flexibleDurationFromJson(dynamic value)`
  - Parses to `Duration?`. Handles:
    - `int` as milliseconds
    - ISO 8601 format (e.g., "PT1H30M", "P1D")
    - Human-readable format (e.g., "1h 30m", "2d 5h", "90s", "500ms")
    - `Map` with keys like "hours", "minutes", "seconds"

- `String? flexiblePhoneFromJson(dynamic value)`
  - Normalizes phone numbers by stripping non-digit characters (preserves leading +).
  - Example: "(555) 123-4567" → "5551234567"

- `String? flexibleSlugFromJson(dynamic value)`
  - Converts strings to URL-safe slugs.
  - Example: "Hello World! 123" → "hello-world-123"

- `CurrencyValue? flexibleCurrencyFromJson(dynamic value)`
  - Parses currency values from various formats.
  - Handles: "$1,234.56", "100.00 USD", "€100", `Map` with amount/currency.
  - Returns `CurrencyValue` with `amount` and optional `currencyCode`.

### Class-Based API

The `JsonSon` class provides a more fluent interface for working with JSON data:

#### Constructors

- `JsonSon(Map<String, dynamic> data)` - Creates a new instance from a Map
- `JsonSon.fromMap(Map<String, dynamic> map)` - Static constructor from a Map
- `JsonSon.fromJson(String json)` - Static constructor from a JSON string

#### Basic Type Getters

- `getInt(String key)` - Gets an int value
- `getString(String key)` - Gets a String value
- `getDouble(String key)` - Gets a double value
- `getBool(String key)` - Gets a bool value
- `getDateTime(String key)` - Gets a DateTime value
- `getNum(String key)` - Gets a num value
- `getUri(String key)` - Gets a Uri value

#### With Default Values

- `getIntOrDefault(String key, int defaultValue)` - Gets an int with a default value
- `getStringOrDefault(String key, String defaultValue)` - Gets a String with a default value
- `getDoubleOrDefault(String key, double defaultValue)` - Gets a double with a default value
- `getBoolOrDefault(String key, bool defaultValue)` - Gets a bool with a default value
- `getNumOrDefault(String key, num defaultValue)` - Gets a num with a default value

#### String Normalization

- `getTrimmedString(String key)` - Gets a trimmed String
- `getLowerString(String key)` - Gets a lowercase String
- `getUpperString(String key)` - Gets an uppercase String

#### Nested Objects

- `getObject(String key)` - Gets a nested JsonSon object
- `getObjectList(String key)` - Gets a List of JsonSon objects

#### Lists

- `getList<T>(String key, T? Function(dynamic) converter)` - Gets a List of values
- `getListOrEmpty<T>(String key, T? Function(dynamic) converter)` - Gets a non-null List of values
- `getCommaSeparatedList(String key)` - Gets a List of Strings from a comma-separated string

#### Path-Based Access

- `getPath(String path)` - Gets a value using dot notation
- `getIntPath(String path)` - Gets an int using dot notation
- `getStringPath(String path)` - Gets a String using dot notation
- `getDoublePath(String path)` - Gets a double using dot notation
- `getBoolPath(String path)` - Gets a bool using dot notation
- `getDateTimePath(String path)` - Gets a DateTime using dot notation
- `getNumPath(String path)` - Gets a num using dot notation
- `getUriPath(String path)` - Gets a Uri using dot notation
- `getObjectPath(String path)` - Gets a nested JsonSon object using dot notation
- `getDurationPath(String path)` - Gets a Duration using dot notation
- `getBigIntPath(String path)` - Gets a BigInt using dot notation
- `getListPath<T>(String path, T? Function(dynamic) converter)` - Gets a List at a path
- `getListPathOrEmpty<T>(String path, T? Function(dynamic) converter)` - Gets a non-null List at a path

#### New Type Getters (v0.5.0)

- `getDuration(String key)` - Gets a Duration value
- `getBigInt(String key)` - Gets a BigInt value
- `getCurrency(String key)` - Gets a CurrencyValue
- `getEnum<T>(String key, List<T> values, {T? fallback})` - Gets an enum value
- `getPhone(String key)` - Gets a normalized phone number
- `getSlug(String key)` - Gets a URL-safe slug

#### Advanced Operations (v0.5.0)

- `deepMerge(JsonSon other)` - Recursively merges nested objects
- `diff(JsonSon other)` - Compares and returns added/removed/changed keys
- `pick(List<String> paths)` - Selects values at nested paths
- `flatten({String separator})` - Converts nested objects to dot-notation keys
- `unflatten(Map<String, dynamic> flatMap, {String separator})` - Converts dot-notation to nested
- `getIf<T>(String key, T? Function(String) getter, bool Function(dynamic) condition)` - Conditional getter
- `getIntIf(String key, bool Function(int) condition)` - Gets int only if condition met
- `getStringIf(String key, bool Function(String) condition)` - Gets string only if condition met
- `toQueryString({bool encode})` - Converts to URL query string

#### Utility Methods

- `hasKey(String key)` - Checks if a key exists
- `keys` - Gets all keys in the underlying map
- `rawData` - Gets the raw underlying map
- `select(List<String> keys)` - Returns a new JsonSon with only the specified keys
- `exclude(List<String> keys)` - Returns a new JsonSon without the specified keys
- `toJson()` - Converts to a JSON string

## Contributing

Feel free to open an issue or submit a pull request if you have suggestions or find bugs.

## Additional information

- **Source Code**: You can find the source code on https://github.com/scalecode-solutions/json_son.
- **Issue Tracker**: If you encounter any bugs or have feature requests, please file an issue on our https://github.com/scalecode-solutions/json_son/issues.
- **License**: This package is licensed under the MIT License. See the `LICENSE` file for more details.
- **Contributions**: We welcome contributions! Please feel free to submit a pull request or open an issue. We generally respond to issues and pull requests within a few business days, but response times may vary.
- **Further Information**: For more detailed information on specific functions and their behavior, please refer to the inline documentation within the source code.


MV❤️