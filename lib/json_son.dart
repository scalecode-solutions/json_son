/// A Dart utility package providing helper functions to flexibly parse JSON values
/// that might have inconsistent data types (e.g., strings to numbers,
/// strings/numbers to booleans, or dates in various formats).
///
/// These functions are designed to be used with JSON deserialization, often in
/// conjunction with code generation libraries like `json_serializable` (used by `freezed`),
/// by annotating DTO fields with `@JsonKey(fromJson: ...)`.
library;

export 'src/json_son_base.dart';

export 'src/json_son_base.dart'
    show flexibleMapFromJson, flexibleMapNotNullFromJson;

/// Parses a [dynamic] value into an [int]?.
/// Handles `null`, `int`, `double` (truncates), and `String` representations.
/// An empty string or a string that fails to parse will result in `null`.
int? flexibleIntFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt(); // Truncates decimal part
  if (value is String) {
    if (value.isEmpty) return null; // Treat empty string as null
    return int.tryParse(value); // Returns null if parsing fails
  }
  return null; // Fallback for other unexpected types
}

/// Parses a [dynamic] value into a [double]?.
/// Handles `null`, `double`, `int`, and `String` representations.
/// An empty string or a string that fails to parse will result in `null`.
double? flexibleDoubleFromJson(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble(); // Converts int to double
  if (value is String) {
    if (value.isEmpty) return null; // Treat empty string as null
    return double.tryParse(value); // Returns null if parsing fails
  }
  return null; // Fallback for other unexpected types
}

/// Parses a [dynamic] value into a [bool]?.
/// Handles `null`, `bool`, `String` (e.g., "true", "false", "1", "0", case-insensitive),
/// and `int` (1 for true, 0 for false) representations.
/// An empty string or unhandled string/int values will result in `null`.
bool? flexibleBoolFromJson(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) {
    final lowerValue = value.toLowerCase();
    if (lowerValue == 'true' || lowerValue == '1') return true;
    if (lowerValue == 'false' || lowerValue == '0') return false;
    if (lowerValue.isEmpty) return null; // Treat empty string as null
  }
  if (value is int) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  return null; // Fallback for other unexpected types or unhandled values
}

/// Parses a [dynamic] value into a [String]?.
/// Handles `null` and `String`. Converts other types (like `int`, `double`, `bool`)
/// to their string representation using `.toString()`.
String? flexibleStringFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    // Optional: if you want to treat "null" string literals as actual null
    // if (value.toLowerCase() == 'null') return null;
    return value;
  }
  // For numbers, booleans, or other types, convert to their string representation.
  return value.toString();
}

/// Parses a [dynamic] value into a [num]? (int or double).
/// Handles `null`, `num` (and its subtypes `int`, `double`), and `String` representations.
/// An empty string or a string that fails to parse will result in `null`.
num? flexibleNumFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value; // Handles int and double
  if (value is String) {
    if (value.isEmpty) return null;
    return num.tryParse(value);
  }
  return null;
}

/// Parses a [dynamic] value into a [DateTime]?.
/// Handles `null`.
/// If the value is an `int`, assumes it's milliseconds since epoch (UTC).
/// If the value is a `String`:
///   - Tries direct parsing via `DateTime.tryParse` (for ISO 8601 and similar).
///   - If direct parsing fails and the string is purely numeric,
///     treats it as milliseconds since epoch.
/// An empty string or unparseable string format will result in `null`.
DateTime? flexibleDateTimeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    // Assume milliseconds since epoch if it's an integer
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  if (value is String) {
    if (value.isEmpty) return null;
    // Try standard ISO 8601 parsing first
    DateTime? dt = DateTime.tryParse(value);
    if (dt != null) return dt;

    // If it's a purely numeric string, try parsing as milliseconds since epoch
    final intValue = int.tryParse(value);
    if (intValue != null) {
      return DateTime.fromMillisecondsSinceEpoch(intValue, isUtc: true);
    }
  }
  return null;
}

/// Parses a [dynamic] value (expected to be a String) into a [Uri]?.
/// Handles `null` and `String` representations of a URI.
/// An empty string or an unparseable URI string will result in `null`.
Uri? flexibleUriFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    if (value.isEmpty) return null;
    return Uri.tryParse(value);
  }
  // If the value is already a Uri, though less common from raw JSON
  if (value is Uri) return value;
  return null;
}
