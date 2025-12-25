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

/// Parses a [dynamic] value into a non-nullable [int].
/// Similar to [flexibleIntFromJson], but returns 0 instead of null.
/// Useful when you need to guarantee a non-null int value.
int flexibleRequiredIntFromJson(dynamic value) {
  return flexibleIntFromJson(value) ?? 0;
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

/// Parses a [dynamic] value into a non-nullable [double].
/// Similar to [flexibleDoubleFromJson], but returns 0.0 instead of null.
/// Useful when you need to guarantee a non-null double value.
double flexibleRequiredDoubleFromJson(dynamic value) {
  return flexibleDoubleFromJson(value) ?? 0.0;
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

/// Parses a [dynamic] value into a non-nullable [bool].
/// Similar to [flexibleBoolFromJson], but returns false instead of null.
/// Useful when you need to guarantee a non-null boolean value.
bool flexibleRequiredBoolFromJson(dynamic value) {
  return flexibleBoolFromJson(value) ?? false;
}

/// Parses a [dynamic] value into a [String]?.
/// Handles `null` and `String`. Converts other types (like `int`, `double`, `bool`)
/// to their string representation using `.toString()`.
String? flexibleStringFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    return value;
  }
  return value.toString();
}

/// Parses a [dynamic] value into a non-nullable [String].
/// Similar to [flexibleStringFromJson], but returns an empty string instead of null.
/// Useful when you need to guarantee a non-null string value.
String flexibleRequiredStringFromJson(dynamic value) {
  return flexibleStringFromJson(value) ?? '';
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
/// If the value is an `int`:
///   - Values less than 10000000000 are treated as seconds since epoch (Unix timestamp).
///   - Values >= 10000000000 are treated as milliseconds since epoch.
/// If the value is a `String`:
///   - Tries direct parsing via `DateTime.tryParse` (for ISO 8601 and similar).
///   - If direct parsing fails and the string is purely numeric,
///     applies the same seconds/milliseconds heuristic as integers.
/// An empty string or unparseable string format will result in `null`.
DateTime? flexibleDateTimeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    return _parseEpochTimestamp(value);
  }
  if (value is String) {
    if (value.isEmpty) return null;
    // Try standard ISO 8601 parsing first
    DateTime? dt = DateTime.tryParse(value);
    if (dt != null) return dt;

    // If it's a purely numeric string, try parsing as epoch timestamp
    final intValue = int.tryParse(value);
    if (intValue != null) {
      return _parseEpochTimestamp(intValue);
    }
  }
  return null;
}

/// Helper to parse epoch timestamps, detecting seconds vs milliseconds.
/// Timestamps before Sept 2001 in milliseconds (10000000000) are treated as seconds.
DateTime _parseEpochTimestamp(int value) {
  // Heuristic: if value is less than 10 billion, it's likely seconds
  // 10000000000 ms = Sept 9, 2001, which is a reasonable cutoff
  // Most modern timestamps in seconds are ~1.7 billion (2024)
  if (value < 10000000000) {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
  }
  return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
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

// ============================================================================
// COLLECTION HANDLING
// ============================================================================

/// Ensures result is always a List, even if API returns single item or null.
/// Useful for APIs that inconsistently return arrays vs single items for a field.
/// Returns `null` if the input `value` is null or if the `itemParser`
/// results in `null` for a single item input.
/// Filters out `null` items from the list if the input is a list.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: (v) => flexibleListFromJson(v, flexibleIntFromJson))
/// List<int?>? numbers;
/// ```
List<T?>? flexibleListFromJson<T>(
  dynamic value,
  T? Function(dynamic) itemParser,
) {
  if (value == null) return null;
  if (value is List) {
    return value
        .map((item) => itemParser(item))
        .where((parsedItem) => parsedItem != null)
        .toList();
  }
  // Single item? Wrap it in a list if the parsed item is not null.
  final T? parsedSingleItem = itemParser(value);
  return parsedSingleItem != null ? [parsedSingleItem] : null;
}

/// For when APIs return empty arrays as null, or you want to guarantee a non-null list.
/// Returns empty list instead of null if the input is null or if parsing results in nulls.
/// Filters out `null` items from the list if the input is a list.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: (v) => flexibleListNotNullFromJson(v, flexibleStringFromJson))
/// List<String> tags; // Guarantees a List<String>, never null.
/// ```
List<T> flexibleListNotNullFromJson<T>(
  dynamic value,
  T? Function(dynamic) itemParser,
) {
  if (value == null) return <T>[];
  if (value is List) {
    final List<T> result = [];
    for (final item in value) {
      final parsedItem = itemParser(item);
      if (parsedItem != null) {
        result.add(parsedItem);
      }
    }
    return result;
  }
  // Single item? Wrap it in a list if the parsed item is not null.
  final T? parsedSingleItem = itemParser(value);
  return parsedSingleItem != null ? [parsedSingleItem] : <T>[];
}

/// Alias for [flexibleListNotNullFromJson] to provide a consistent naming convention
/// with other required functions.
/// Returns an empty list if the input is null or if parsing results in all nulls.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: (v) => flexibleRequiredListFromJson(v, flexibleIntFromJson))
/// List<int> scores; // Guarantees a List<int>, never null.
/// ```
List<T> flexibleRequiredListFromJson<T>(
  dynamic value,
  T? Function(dynamic) itemParser,
) {
  return flexibleListNotNullFromJson<T>(value, itemParser);
}

/// Parses comma-separated strings into a list of strings.
/// Handles `null` input.
/// If input is already a list, its elements are converted to strings.
/// Trims whitespace from each part and filters out empty strings after splitting.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: flexibleCommaSeparatedListFromJson)
/// List<String>? tags; // Input "food, travel , code " -> ["food", "travel", "code"]
/// ```
List<String>? flexibleCommaSeparatedListFromJson(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  if (value is String) {
    if (value.trim().isEmpty) return null;
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return null;
}

// ============================================================================
// STRING NORMALIZATION
// ============================================================================

/// Trims whitespace from the input string (if it's a string) and
/// treats empty or whitespace-only strings as `null`.
/// If the input is not a string but not null, it's converted via `.toString()` first.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: flexibleTrimmedStringFromJson)
/// String? description; // Input "  hello  " -> "hello"; Input "   " -> null
/// ```
String? flexibleTrimmedStringFromJson(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  final trimmed = str.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Normalizes a string to lowercase after trimming and handling null/empty strings.
/// Uses `flexibleTrimmedStringFromJson` internally.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: flexibleLowerStringFromJson)
/// String? category; // Input "  Electronics  " -> "electronics"
/// ```
String? flexibleLowerStringFromJson(dynamic value) {
  final str = flexibleTrimmedStringFromJson(value);
  return str?.toLowerCase();
}

/// Normalizes a string to uppercase after trimming and handling null/empty strings.
/// Uses `flexibleTrimmedStringFromJson` internally.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: flexibleUpperStringFromJson)
/// String? productCode; // Input "  abc-123  " -> "ABC-123"
/// ```
String? flexibleUpperStringFromJson(dynamic value) {
  return flexibleTrimmedStringFromJson(value)?.toUpperCase();
}

/// Transforms a map by applying a transformation function to each key-value pair.
/// Handles `null` input by returning `null`.
/// The [mapper] function can return `null` to skip entries.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: (v) => flexibleMapFromJson(v, (k, v) =>
///   k != null ? MapEntry(k, int.tryParse(v)) : null))
/// Map<String, int>? counts; // Input {"a": "1", "b": "2"} -> {"a": 1, "b": 2}
/// ```
Map<K, V>? flexibleMapFromJson<K, V>(
  dynamic value,
  MapEntry<K, V>? Function(dynamic key, dynamic value) mapper,
) {
  if (value == null) return null;

  final result = <K, V>{};
  if (value is Map) {
    value.forEach((key, value) {
      final entry = mapper(key, value);
      if (entry != null) {
        result[entry.key] = entry.value;
      }
    });
  }
  return result;
}

/// Similar to [flexibleMapFromJson] but returns an empty map instead of `null` for `null` input.
/// The [mapper] function can return `null` to skip entries.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: (v) => flexibleMapNotNullFromJson(v, (k, v) =>
///   k != null ? MapEntry(k, int.tryParse(v)) : null))
/// Map<String, int> counts; // Input {"a": "1", "b": "x"} -> {"a": 1}
/// ```
Map<K, V> flexibleMapNotNullFromJson<K, V>(
  dynamic value,
  MapEntry<K, V>? Function(dynamic key, dynamic value) mapper,
) {
  if (value == null) return <K, V>{};

  final result = <K, V>{};
  if (value is Map) {
    value.forEach((key, value) {
      final entry = mapper(key, value);
      if (entry != null) {
        result[entry.key] = entry.value;
      }
    });
  }
  return result;
}
