// ============================================================================
// BASIC TYPE PARSING
// ============================================================================

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
/// List<int>? numbers;
/// ```
List<T>? flexibleListFromJson<T>(
  dynamic value,
  T? Function(dynamic) itemParser,
) {
  if (value == null) return null;
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

// ============================================================================
// ENUM PARSING
// ============================================================================

/// Parses a [dynamic] value into an enum value of type [T].
/// Handles `null`, `String` (case-insensitive name matching), and `int` (index).
/// Returns [fallback] if parsing fails or value is null.
///
/// Example:
/// ```dart
/// enum Status { pending, active, completed }
///
/// @JsonKey(fromJson: (v) => flexibleEnumFromJson(v, Status.values))
/// Status status;
/// ```
T? flexibleEnumFromJson<T extends Enum>(
  dynamic value,
  List<T> values, {
  T? fallback,
}) {
  if (value == null) return fallback;

  if (value is String) {
    if (value.isEmpty) return fallback;
    final lowerValue = value.toLowerCase();
    for (final enumValue in values) {
      if (enumValue.name.toLowerCase() == lowerValue) {
        return enumValue;
      }
    }
    return fallback;
  }

  if (value is int) {
    if (value >= 0 && value < values.length) {
      return values[value];
    }
    return fallback;
  }

  return fallback;
}

/// Parses a [dynamic] value into a non-nullable enum value.
/// Returns [fallback] if parsing fails.
///
/// Example:
/// ```dart
/// enum Status { pending, active, completed }
///
/// @JsonKey(fromJson: (v) => flexibleRequiredEnumFromJson(v, Status.values, Status.pending))
/// Status status;
/// ```
T flexibleRequiredEnumFromJson<T extends Enum>(
  dynamic value,
  List<T> values,
  T fallback,
) {
  return flexibleEnumFromJson(value, values, fallback: fallback) ?? fallback;
}

// ============================================================================
// BIGINT PARSING
// ============================================================================

/// Parses a [dynamic] value into a [BigInt]?.
/// Handles `null`, `int`, `String`, and `BigInt` representations.
/// Useful for handling large integers that overflow int64.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: flexibleBigIntFromJson)
/// BigInt? largeNumber;
/// ```
BigInt? flexibleBigIntFromJson(dynamic value) {
  if (value == null) return null;
  if (value is BigInt) return value;
  if (value is int) return BigInt.from(value);
  if (value is String) {
    if (value.isEmpty) return null;
    return BigInt.tryParse(value);
  }
  return null;
}

/// Parses a [dynamic] value into a non-nullable [BigInt].
/// Returns [BigInt.zero] if parsing fails.
BigInt flexibleRequiredBigIntFromJson(dynamic value) {
  return flexibleBigIntFromJson(value) ?? BigInt.zero;
}

// ============================================================================
// DURATION PARSING
// ============================================================================

/// Parses a [dynamic] value into a [Duration]?.
/// Handles:
/// - `null` -> null
/// - `int` -> milliseconds
/// - `String` in ISO 8601 format (e.g., "PT1H30M", "P1D")
/// - `String` in human format (e.g., "1h 30m", "2d 5h", "90s")
/// - `Map` with keys like "hours", "minutes", "seconds", "milliseconds"
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: flexibleDurationFromJson)
/// Duration? timeout;
/// ```
Duration? flexibleDurationFromJson(dynamic value) {
  if (value == null) return null;

  if (value is int) {
    return Duration(milliseconds: value);
  }

  if (value is Duration) return value;

  if (value is Map) {
    final days = flexibleIntFromJson(value['days']) ??
        flexibleIntFromJson(value['d']) ??
        0;
    final hours = flexibleIntFromJson(value['hours']) ??
        flexibleIntFromJson(value['h']) ??
        0;
    final minutes = flexibleIntFromJson(value['minutes']) ??
        flexibleIntFromJson(value['m']) ??
        0;
    final seconds = flexibleIntFromJson(value['seconds']) ??
        flexibleIntFromJson(value['s']) ??
        0;
    final milliseconds = flexibleIntFromJson(value['milliseconds']) ??
        flexibleIntFromJson(value['ms']) ??
        0;
    return Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  if (value is String) {
    if (value.isEmpty) return null;

    // Try ISO 8601 duration format (PT1H30M, P1DT2H, etc.)
    final iso8601 = _parseIso8601Duration(value);
    if (iso8601 != null) return iso8601;

    // Try human-readable format (1h 30m, 2d 5h, 90s, etc.)
    final human = _parseHumanDuration(value);
    if (human != null) return human;

    // Try parsing as milliseconds
    final ms = int.tryParse(value);
    if (ms != null) return Duration(milliseconds: ms);
  }

  return null;
}

/// Parses ISO 8601 duration format (e.g., "PT1H30M", "P1D", "P1DT2H30M15S")
Duration? _parseIso8601Duration(String value) {
  final regex = RegExp(
    r'^P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
    caseSensitive: false,
  );
  final match = regex.firstMatch(value.toUpperCase());
  if (match == null) return null;

  final days = int.tryParse(match.group(1) ?? '') ?? 0;
  final hours = int.tryParse(match.group(2) ?? '') ?? 0;
  final minutes = int.tryParse(match.group(3) ?? '') ?? 0;
  final secondsStr = match.group(4);
  final seconds = secondsStr != null ? double.tryParse(secondsStr) ?? 0 : 0;

  return Duration(
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds.floor(),
    milliseconds: ((seconds - seconds.floor()) * 1000).round(),
  );
}

/// Parses human-readable duration format (e.g., "1h 30m", "2d 5h", "90s")
Duration? _parseHumanDuration(String value) {
  // Match ms first (before m and s), then other units
  final regex = RegExp(r'(\d+)\s*(ms|d|h|m|s)', caseSensitive: false);
  final matches = regex.allMatches(value.toLowerCase());
  if (matches.isEmpty) return null;

  int days = 0, hours = 0, minutes = 0, seconds = 0, milliseconds = 0;

  for (final match in matches) {
    final num = int.tryParse(match.group(1) ?? '') ?? 0;
    final unit = match.group(2)?.toLowerCase();
    switch (unit) {
      case 'd':
        days += num;
        break;
      case 'h':
        hours += num;
        break;
      case 'm':
        minutes += num;
        break;
      case 's':
        seconds += num;
        break;
      case 'ms':
        milliseconds += num;
        break;
    }
  }

  if (days == 0 &&
      hours == 0 &&
      minutes == 0 &&
      seconds == 0 &&
      milliseconds == 0) {
    return null;
  }

  return Duration(
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

/// Parses a [dynamic] value into a non-nullable [Duration].
/// Returns [Duration.zero] if parsing fails.
Duration flexibleRequiredDurationFromJson(dynamic value) {
  return flexibleDurationFromJson(value) ?? Duration.zero;
}

// ============================================================================
// PHONE NUMBER PARSING
// ============================================================================

/// Parses a [dynamic] value into a normalized phone number string.
/// Strips all non-digit characters except leading +.
/// Returns `null` for empty or invalid input.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: flexiblePhoneFromJson)
/// String? phone; // Input "(555) 123-4567" -> "+15551234567" or "5551234567"
/// ```
String? flexiblePhoneFromJson(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  if (str.isEmpty) return null;

  // Preserve leading + if present
  final hasPlus = str.startsWith('+');

  // Remove all non-digit characters
  final digits = str.replaceAll(RegExp(r'[^\d]'), '');

  if (digits.isEmpty) return null;

  return hasPlus ? '+$digits' : digits;
}

// ============================================================================
// SLUG PARSING
// ============================================================================

/// Converts a [dynamic] value into a URL-safe slug.
/// Converts to lowercase, replaces spaces and special chars with hyphens,
/// removes consecutive hyphens, and trims leading/trailing hyphens.
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: flexibleSlugFromJson)
/// String? slug; // Input "Hello World! 123" -> "hello-world-123"
/// ```
String? flexibleSlugFromJson(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  if (str.isEmpty) return null;

  return str
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special chars except hyphen
      .replaceAll(
          RegExp(r'[\s_]+'), '-') // Replace spaces/underscores with hyphen
      .replaceAll(RegExp(r'-+'), '-') // Remove consecutive hyphens
      .replaceAll(RegExp(r'^-+|-+$'), ''); // Trim leading/trailing hyphens
}

// ============================================================================
// CURRENCY PARSING
// ============================================================================

/// Represents a parsed currency value with amount and optional currency code.
class CurrencyValue {
  final double amount;
  final String? currencyCode;

  const CurrencyValue(this.amount, [this.currencyCode]);

  @override
  String toString() => currencyCode != null
      ? '$currencyCode ${amount.toStringAsFixed(2)}'
      : amount.toStringAsFixed(2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyValue &&
          amount == other.amount &&
          currencyCode == other.currencyCode;

  @override
  int get hashCode => amount.hashCode ^ currencyCode.hashCode;
}

/// Parses a [dynamic] value into a [CurrencyValue]?.
/// Handles formats like "$1,234.56", "1234.56 USD", "€100", "100.00".
///
/// Example:
/// ```dart
/// @JsonKey(fromJson: flexibleCurrencyFromJson)
/// CurrencyValue? price; // Input "$1,234.56" -> CurrencyValue(1234.56, "USD")
/// ```
CurrencyValue? flexibleCurrencyFromJson(dynamic value) {
  if (value == null) return null;

  if (value is num) {
    return CurrencyValue(value.toDouble());
  }

  if (value is Map) {
    final amount = flexibleDoubleFromJson(value['amount']) ??
        flexibleDoubleFromJson(value['value']);
    if (amount == null) return null;
    final currency = flexibleStringFromJson(value['currency']) ??
        flexibleStringFromJson(value['currencyCode']);
    return CurrencyValue(amount, currency);
  }

  final str = value.toString().trim();
  if (str.isEmpty) return null;

  // Common currency symbols to codes
  const symbolToCode = {
    '\$': 'USD',
    '€': 'EUR',
    '£': 'GBP',
    '¥': 'JPY',
    '₹': 'INR',
    '₽': 'RUB',
    '₿': 'BTC',
  };

  String? currencyCode;
  String amountStr = str;

  // Check for currency symbol at start
  for (final entry in symbolToCode.entries) {
    if (str.startsWith(entry.key)) {
      currencyCode = entry.value;
      amountStr = str.substring(entry.key.length).trim();
      break;
    }
  }

  // Check for currency code at end (e.g., "100.00 USD")
  final codeMatch = RegExp(r'\s+([A-Z]{3})$').firstMatch(amountStr);
  if (codeMatch != null) {
    currencyCode = codeMatch.group(1);
    amountStr = amountStr.substring(0, codeMatch.start).trim();
  }

  // Remove thousands separators and parse
  amountStr = amountStr.replaceAll(',', '').replaceAll(' ', '');
  final amount = double.tryParse(amountStr);

  if (amount == null) return null;
  return CurrencyValue(amount, currencyCode);
}
