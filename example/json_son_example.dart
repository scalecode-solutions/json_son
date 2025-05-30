import 'package:json_son/json_son.dart';

void main() {
  // Example 1: Parsing an integer
  // API might send "123", 123, or 123.0
  print('--- Integer Parsing ---');
  dynamic intJsonValue = '123';
  int? parsedInt = flexibleIntFromJson(intJsonValue);
  print('Parsed int from String "$intJsonValue": $parsedInt');

  intJsonValue = 123;
  parsedInt = flexibleIntFromJson(intJsonValue);
  print('Parsed int from int $intJsonValue: $parsedInt');

  intJsonValue = 123.45;
  parsedInt = flexibleIntFromJson(intJsonValue);
  print('Parsed int from double $intJsonValue: $parsedInt (truncated)');

  intJsonValue = 'abc'; // Unparseable
  parsedInt = flexibleIntFromJson(intJsonValue);
  print('Parsed int from String "$intJsonValue": $parsedInt');

  intJsonValue = null;
  parsedInt = flexibleIntFromJson(intJsonValue);
  print('Parsed int from null: $parsedInt');

  // Example 2: Parsing a boolean
  // API might send "true", "false", "1", "0", true, false, 1, 0
  print('\n--- Boolean Parsing ---');
  dynamic boolJsonValue = 'true';
  bool? parsedBool = flexibleBoolFromJson(boolJsonValue);
  print('Parsed bool from String "$boolJsonValue": $parsedBool');

  boolJsonValue = '0';
  parsedBool = flexibleBoolFromJson(boolJsonValue);
  print('Parsed bool from String "$boolJsonValue": $parsedBool');

  boolJsonValue = 1;
  parsedBool = flexibleBoolFromJson(boolJsonValue);
  print('Parsed bool from int $boolJsonValue: $parsedBool');

  boolJsonValue = false;
  parsedBool = flexibleBoolFromJson(boolJsonValue);
  print('Parsed bool from bool $boolJsonValue: $parsedBool');

  boolJsonValue = 'yes'; // Unhandled
  parsedBool = flexibleBoolFromJson(boolJsonValue);
  print('Parsed bool from String "$boolJsonValue": $parsedBool');

  boolJsonValue = null;
  parsedBool = flexibleBoolFromJson(boolJsonValue);
  print('Parsed bool from null: $parsedBool');

  // Example 3: Parsing a List of nullable integers
  // API might send a list, a single item, or null
  print('\n--- List<int?> Parsing ---');
  dynamic listJsonValue = ['1', 2, '3.0', 'four', null, 5];
  List<int?>? parsedIntList =
      flexibleListFromJson<int>(listJsonValue, flexibleIntFromJson);
  print('Parsed List<int?> from List $listJsonValue: $parsedIntList');

  listJsonValue = '42'; // Single item
  parsedIntList = flexibleListFromJson<int>(listJsonValue, flexibleIntFromJson);
  print(
      'Parsed List<int?> from single String "$listJsonValue": $parsedIntList');

  listJsonValue = 'invalid'; // Single invalid item
  parsedIntList = flexibleListFromJson<int>(listJsonValue, flexibleIntFromJson);
  print(
      'Parsed List<int?> from single invalid String "$listJsonValue": $parsedIntList');

  listJsonValue = null;
  parsedIntList = flexibleListFromJson<int>(listJsonValue, flexibleIntFromJson);
  print('Parsed List<int?> from null: $parsedIntList');

  // Example 4: Parsing a List of non-null strings
  // API might send a list, a single item, or null. Guarantees a non-null list.
  print('\n--- List<String> (non-null) Parsing ---');
  dynamic nonNullListJsonValue = ['apple', 123, 'banana', null, 'cherry', true];
  List<String> parsedNonNullStringList = flexibleListNotNullFromJson<String>(
      nonNullListJsonValue, flexibleStringFromJson);
  print(
      'Parsed List<String> from List $nonNullListJsonValue: $parsedNonNullStringList');

  nonNullListJsonValue = 'single_item';
  parsedNonNullStringList = flexibleListNotNullFromJson<String>(
      nonNullListJsonValue, flexibleStringFromJson);
  print(
      'Parsed List<String> from single item "$nonNullListJsonValue": $parsedNonNullStringList');

  nonNullListJsonValue = null;
  parsedNonNullStringList = flexibleListNotNullFromJson<String>(
      nonNullListJsonValue, flexibleStringFromJson);
  print('Parsed List<String> from null: $parsedNonNullStringList');

  // Example 5: Parsing a DateTime
  // API might send ISO string, timestamp as int, or timestamp as string
  print('\n--- DateTime Parsing ---');
  dynamic dateTimeJsonValue = '2023-10-26T10:30:00Z';
  DateTime? parsedDateTime = flexibleDateTimeFromJson(dateTimeJsonValue);
  print(
      'Parsed DateTime from ISO String "$dateTimeJsonValue": $parsedDateTime');

  dateTimeJsonValue = 1698316200000; // Milliseconds since epoch
  parsedDateTime = flexibleDateTimeFromJson(dateTimeJsonValue);
  print(
      'Parsed DateTime from int timestamp $dateTimeJsonValue: $parsedDateTime');

  dateTimeJsonValue = '1698316200000'; // Milliseconds since epoch as string
  parsedDateTime = flexibleDateTimeFromJson(dateTimeJsonValue);
  print(
      'Parsed DateTime from string timestamp "$dateTimeJsonValue": $parsedDateTime');

  dateTimeJsonValue = 'Oct 26, 2023'; // Unparseable by default
  parsedDateTime = flexibleDateTimeFromJson(dateTimeJsonValue);
  print('Parsed DateTime from String "$dateTimeJsonValue": $parsedDateTime');

  dateTimeJsonValue = null;
  parsedDateTime = flexibleDateTimeFromJson(dateTimeJsonValue);
  print('Parsed DateTime from null: $parsedDateTime');

  // Example 6: Parsing a comma-separated list
  // API might send "tag1,tag2, tag3 ", null, or an actual list
  print('\n--- Comma-Separated List Parsing ---');
  dynamic csvJsonValue = 'apple, banana, cherry ,, orange ';
  List<String>? parsedCsvList =
      flexibleCommaSeparatedListFromJson(csvJsonValue);
  print('Parsed CSV List from String "$csvJsonValue": $parsedCsvList');

  csvJsonValue = ['one', 'two', null, ' three ']; // Already a list
  parsedCsvList = flexibleCommaSeparatedListFromJson(csvJsonValue);
  print('Parsed CSV List from List $csvJsonValue: $parsedCsvList');

  csvJsonValue = null;
  parsedCsvList = flexibleCommaSeparatedListFromJson(csvJsonValue);
  print('Parsed CSV List from null: $parsedCsvList');

  csvJsonValue = '  '; // Empty string
  parsedCsvList = flexibleCommaSeparatedListFromJson(csvJsonValue);
  print('Parsed CSV List from empty String "$csvJsonValue": $parsedCsvList');

  // Example 7: String Normalization
  print('\n--- String Normalization ---');
  dynamic stringNormValue = '  Hello World!  ';
  print('Original String: "$stringNormValue"');
  print('Trimmed: "${flexibleTrimmedStringFromJson(stringNormValue)}"');
  print('Lowercase: "${flexibleLowerStringFromJson(stringNormValue)}"');
  print('Uppercase: "${flexibleUpperStringFromJson(stringNormValue)}"');

  stringNormValue = '   ';
  print('Original String (whitespace only): "$stringNormValue"');
  print('Trimmed: "${flexibleTrimmedStringFromJson(stringNormValue)}"');

  stringNormValue = null;
  print('Original String (null): "$stringNormValue"');
  print('Trimmed: "${flexibleTrimmedStringFromJson(stringNormValue)}"');

  // You can also use these in a Map, simulating a JSON object
  print('\n--- Simulating JSON Object Deserialization ---');
  Map<String, dynamic> jsonData = {
    'id': ' 789 ',
    'isActive': 'TRUE',
    'price': '19.99',
    'created_at': '2024-01-01T12:00:00.000Z',
    'tags_string': ' new, featured, popular item  ',
    'values_list': ['10', 20, '30.5', null, 'forty'],
    'maybeANumber': null,
    'singleValueAsList': 'itemA'
  };

  print(
      'Raw ID: ${jsonData['id']} -> Parsed int: ${flexibleIntFromJson(jsonData['id'])}');
  print(
      'Raw isActive: ${jsonData['isActive']} -> Parsed bool: ${flexibleBoolFromJson(jsonData['isActive'])}');
  print(
      'Raw price: ${jsonData['price']} -> Parsed double: ${flexibleDoubleFromJson(jsonData['price'])}');
  print(
      'Raw created_at: ${jsonData['created_at']} -> Parsed DateTime: ${flexibleDateTimeFromJson(jsonData['created_at'])}');
  print(
      'Raw tags_string: ${jsonData['tags_string']} -> Parsed List<String>: ${flexibleCommaSeparatedListFromJson(jsonData['tags_string'])}');
  print(
      'Raw values_list: ${jsonData['values_list']} -> Parsed List<num?>: ${flexibleListFromJson<num>(jsonData['values_list'], flexibleNumFromJson)}');
  print(
      'Raw maybeANumber: ${jsonData['maybeANumber']} -> Parsed int: ${flexibleIntFromJson(jsonData['maybeANumber'])}');
  print(
      'Raw singleValueAsList: ${jsonData['singleValueAsList']} -> Parsed List<String>: ${flexibleListNotNullFromJson<String>(jsonData['singleValueAsList'], flexibleStringFromJson)}');
}
