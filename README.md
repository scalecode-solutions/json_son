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

These functions are designed to be used with JSON deserialization, often in conjunction with code generation libraries like `json_serializable` (used by `freezed`), by annotating DTO fields with `@JsonKey(fromJson: ...)`.

## Features

- Convert dynamic JSON values to `int?`, `double?`, `num?`, `bool?`, `String?`, `DateTime?`, `Uri?`, `List<T?>?`, or `List<T>`.
- Parse comma-separated strings into `List<String>?`.
- Normalize strings (trimming, case conversion).
- Gracefully handles `null`s, empty strings, and parsing failures by returning `null` (or an empty list for non-null list helpers).
- Supports common alternative representations (e.g., "true" or 1 for boolean `true`, numeric strings for numbers, ISO 8601 or timestamps for `DateTime`).
- Handles APIs that may return a single item where a list is expected.
- Converts input to lowercase if not already in lowercase.

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  json_son: ^0.1.22 # Or the latest version
```

Then, run `flutter pub get` or `dart pub get`.

### Usage

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

## Available Helper Functions

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

## Contributing

Feel free to open an issue or submit a pull request if you have suggestions or find bugs.

## Additional information

- **Source Code**: You can find the source code on https://github.com/scalecode-solutions/json_son.
- **Issue Tracker**: If you encounter any bugs or have feature requests, please file an issue on our https://github.com/scalecode-solutions/json_son/issues.
- **License**: This package is licensed under the MIT License. See the `LICENSE` file for more details.
- **Contributions**: We welcome contributions! Please feel free to submit a pull request or open an issue. We generally respond to issues and pull requests within a few business days, but response times may vary.
- **Further Information**: For more detailed information on specific functions and their behavior, please refer to the inline documentation within the source code.
