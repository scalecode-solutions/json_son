import 'dart:convert';

import 'package:json_son/json_son.dart';

/// A class-based wrapper for the json_son package that provides a more fluent
/// and powerful API for handling inconsistent JSON data types.
class JsonSon {
  /// The underlying JSON data
  final Map<String, dynamic> _data;

  /// Tracks errors that occur during JSON parsing operations
  final List<String> _errors = [];

  /// Creates a new [JsonSon] instance from a [Map].
  JsonSon(this._data);

  /// Creates a new [JsonSon] instance from a [Map].
  static JsonSon fromMap(Map<String, dynamic> map) => JsonSon(map);

  /// Creates a new [JsonSon] instance from a JSON string.
  static JsonSon fromJson(String json) {
    try {
      return JsonSon(jsonDecode(json));
    } catch (e) {
      final result = JsonSon({});
      result._addError('Failed to parse JSON: $e');
      return result;
    }
  }

  /// Creates a [JsonSon] instance from an API response which could be a JSON string or a Map.
  static JsonSon fromApiResponse(dynamic response) {
    if (response is String) {
      return JsonSon.fromJson(response);
    } else if (response is Map<String, dynamic>) {
      return JsonSon.fromMap(response);
    }
    final result = JsonSon({});
    result._addError(
        'Invalid response type: expected String or Map<String, dynamic>, got ${response.runtimeType}');
    return result;
  }

  /// Safely creates a [JsonSon] instance from a dynamic value that might be a Map.
  /// Returns null if the input is not a `Map<String, dynamic>`.
  static JsonSon? fromMapSafe(dynamic data) {
    if (data is Map<String, dynamic>) {
      return JsonSon(data);
    }
    return null;
  }

  /// Error handling methods

  /// Get all errors that occurred during JSON operations
  List<String> get errors => List.unmodifiable(_errors);

  /// Check if any errors occurred during JSON operations
  bool get hasErrors => _errors.isNotEmpty;

  /// Clear all errors
  void clearErrors() => _errors.clear();

  /// Add an error to the error list
  void _addError(String error) => _errors.add(error);

  // Basic type getters
  /// Gets an [int] value for the given [key], handling type conversion.
  int? getInt(String key) => flexibleIntFromJson(_data[key]);

  /// Gets a [String] value for the given [key], handling type conversion.
  String? getString(String key) => flexibleStringFromJson(_data[key]);

  /// Gets a [double] value for the given [key], handling type conversion.
  double? getDouble(String key) => flexibleDoubleFromJson(_data[key]);

  /// Gets a [bool] value for the given [key], handling type conversion.
  bool? getBool(String key) => flexibleBoolFromJson(_data[key]);

  /// Gets a [DateTime] value for the given [key], handling type conversion.
  DateTime? getDateTime(String key) => flexibleDateTimeFromJson(_data[key]);

  /// Gets a [num] value for the given [key], handling type conversion.
  num? getNum(String key) => flexibleNumFromJson(_data[key]);

  /// Gets a [Uri] value for the given [key], handling type conversion.
  Uri? getUri(String key) => flexibleUriFromJson(_data[key]);

  /// Gets a [Duration] value for the given [key], handling type conversion.
  Duration? getDuration(String key) => flexibleDurationFromJson(_data[key]);

  /// Gets a [BigInt] value for the given [key], handling type conversion.
  BigInt? getBigInt(String key) => flexibleBigIntFromJson(_data[key]);

  /// Gets a [CurrencyValue] for the given [key], handling type conversion.
  CurrencyValue? getCurrency(String key) =>
      flexibleCurrencyFromJson(_data[key]);

  /// Gets an enum value for the given [key], handling type conversion.
  T? getEnum<T extends Enum>(String key, List<T> values, {T? fallback}) =>
      flexibleEnumFromJson(_data[key], values, fallback: fallback);

  /// Gets a normalized phone number for the given [key].
  String? getPhone(String key) => flexiblePhoneFromJson(_data[key]);

  /// Gets a URL-safe slug for the given [key].
  String? getSlug(String key) => flexibleSlugFromJson(_data[key]);

  // With default values
  /// Gets an [int] value for the given [key], or returns [defaultValue] if null.
  int getIntOrDefault(String key, int defaultValue) =>
      getInt(key) ?? defaultValue;

  /// Gets a [String] value for the given [key], or returns [defaultValue] if null.
  String getStringOrDefault(String key, String defaultValue) =>
      getString(key) ?? defaultValue;

  /// Gets a [double] value for the given [key], or returns [defaultValue] if null.
  double getDoubleOrDefault(String key, double defaultValue) =>
      getDouble(key) ?? defaultValue;

  /// Gets a [bool] value for the given [key], or returns [defaultValue] if null.
  bool getBoolOrDefault(String key, bool defaultValue) =>
      getBool(key) ?? defaultValue;

  /// Gets a [num] value for the given [key], or returns [defaultValue] if null.
  num getNumOrDefault(String key, num defaultValue) =>
      getNum(key) ?? defaultValue;

  /// Gets a [DateTime] value for the given [key], or returns [defaultValue] if null.
  DateTime getDateTimeOrDefault(String key, DateTime defaultValue) =>
      getDateTime(key) ?? defaultValue;

  /// Gets a [Uri] value for the given [key], or returns [defaultValue] if null.
  Uri getUriOrDefault(String key, Uri defaultValue) =>
      getUri(key) ?? defaultValue;

  // String normalization
  /// Gets a trimmed [String] value for the given [key], handling type conversion.
  String? getTrimmedString(String key) =>
      flexibleTrimmedStringFromJson(_data[key]);

  /// Gets a lowercase [String] value for the given [key], handling type conversion.
  String? getLowerString(String key) => flexibleLowerStringFromJson(_data[key]);

  /// Gets an uppercase [String] value for the given [key], handling type conversion.
  String? getUpperString(String key) => flexibleUpperStringFromJson(_data[key]);

  // Nested objects
  /// Gets a nested [JsonSon] object for the given [key].
  JsonSon? getObject(String key) {
    final value = _data[key];
    if (value is Map<String, dynamic>) {
      return JsonSon(value);
    }
    return null;
  }

  // Lists
  /// Gets a [List] of values for the given [key], applying the [converter] to each item.
  List<T>? getList<T>(String key, T? Function(dynamic) converter) =>
      flexibleListFromJson<T>(_data[key], converter);

  /// Gets a non-null [List] of values for the given [key], applying the [converter] to each item.
  List<T> getListOrEmpty<T>(String key, T? Function(dynamic) converter) =>
      flexibleListNotNullFromJson<T>(_data[key], converter);

  /// Gets a [List] of [String] values from a comma-separated string for the given [key].
  List<String>? getCommaSeparatedList(String key) =>
      flexibleCommaSeparatedListFromJson(_data[key]);

  /// Gets a [List] of [JsonSon] objects for the given [key].
  List<JsonSon>? getObjectList(String key) {
    return getList<JsonSon>(key, (item) {
      if (item is Map<String, dynamic>) {
        return JsonSon(item);
      }
      return null;
    });
  }

  // Path-based access (dot notation)
  /// Gets a value at the given [path] using dot notation.
  dynamic getPath(String path) {
    if (path.isEmpty) {
      _addError('Path cannot be empty');
      return null;
    }

    final parts = path.split('.');
    dynamic current = _data;
    String currentPath = '';

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      currentPath = currentPath.isEmpty ? part : '$currentPath.$part';

      if (current == null) {
        _addError('Path "$currentPath" resolved to null');
        return null;
      }

      if (current is Map) {
        if (!current.containsKey(part)) {
          _addError('Key "$part" not found in path "$currentPath"');
          return null;
        }
        current = current[part];
      } else if (current is List) {
        // Try to parse the part as an index
        final index = int.tryParse(part);
        if (index == null) {
          _addError('Invalid array index "$part" in path "$currentPath"');
          return null;
        }
        if (index < 0 || index >= current.length) {
          _addError(
              'Array index $index out of bounds (0-${current.length - 1}) in path "$currentPath"');
          return null;
        }
        current = current[index];
      } else {
        _addError(
            'Cannot access property "$part" on non-object value at path "$currentPath"');
        return null;
      }
    }

    return current;
  }

  /// Checks if a path exists in the JSON data.
  bool hasPath(String path) {
    try {
      final parts = path.split('.');
      dynamic current = _data;

      for (final part in parts) {
        if (current is Map) {
          if (!current.containsKey(part)) {
            return false;
          }
          current = current[part];
        } else if (current is List) {
          final index = int.tryParse(part);
          if (index == null || index < 0 || index >= current.length) {
            return false;
          }
          current = current[index];
        } else {
          return false;
        }
      }

      return true;
    } catch (e) {
      _addError('Error checking path "$path": $e');
      return false;
    }
  }

  /// Gets an [int] value at the given [path] using dot notation.
  int? getIntPath(String path) => flexibleIntFromJson(getPath(path));

  /// Gets a [String] value at the given [path] using dot notation.
  String? getStringPath(String path) => flexibleStringFromJson(getPath(path));

  /// Gets a [double] value at the given [path] using dot notation.
  double? getDoublePath(String path) => flexibleDoubleFromJson(getPath(path));

  /// Gets a [bool] value at the given [path] using dot notation.
  bool? getBoolPath(String path) => flexibleBoolFromJson(getPath(path));

  /// Gets a [DateTime] value at the given [path] using dot notation.
  DateTime? getDateTimePath(String path) =>
      flexibleDateTimeFromJson(getPath(path));

  /// Gets a [num] value at the given [path] using dot notation.
  num? getNumPath(String path) => flexibleNumFromJson(getPath(path));

  /// Gets a [Uri] value at the given [path] using dot notation.
  Uri? getUriPath(String path) => flexibleUriFromJson(getPath(path));

  /// Gets a nested [JsonSon] object at the given [path] using dot notation.
  JsonSon? getObjectPath(String path) {
    final value = getPath(path);
    if (value is Map<String, dynamic>) {
      return JsonSon(value);
    }
    return null;
  }

  /// Gets a [Duration] value at the given [path] using dot notation.
  Duration? getDurationPath(String path) =>
      flexibleDurationFromJson(getPath(path));

  /// Gets a [BigInt] value at the given [path] using dot notation.
  BigInt? getBigIntPath(String path) => flexibleBigIntFromJson(getPath(path));

  /// Gets a [List] of values at the given [path], applying the [converter] to each item.
  List<T>? getListPath<T>(String path, T? Function(dynamic) converter) {
    final value = getPath(path);
    return flexibleListFromJson<T>(value, converter);
  }

  /// Gets a non-null [List] of values at the given [path], applying the [converter] to each item.
  List<T> getListPathOrEmpty<T>(String path, T? Function(dynamic) converter) {
    final value = getPath(path);
    return flexibleListNotNullFromJson<T>(value, converter);
  }

  // With default values for path-based access
  /// Gets an [int] value at the given [path], or returns [defaultValue] if null.
  int getIntPathOrDefault(String path, int defaultValue) =>
      getIntPath(path) ?? defaultValue;

  /// Gets a [String] value at the given [path], or returns [defaultValue] if null.
  String getStringPathOrDefault(String path, String defaultValue) =>
      getStringPath(path) ?? defaultValue;

  /// Gets a [double] value at the given [path], or returns [defaultValue] if null.
  double getDoublePathOrDefault(String path, double defaultValue) =>
      getDoublePath(path) ?? defaultValue;

  /// Gets a [bool] value at the given [path], or returns [defaultValue] if null.
  bool getBoolPathOrDefault(String path, bool defaultValue) =>
      getBoolPath(path) ?? defaultValue;

  /// Gets a [num] value at the given [path], or returns [defaultValue] if null.
  num getNumPathOrDefault(String path, num defaultValue) =>
      getNumPath(path) ?? defaultValue;

  /// Gets a [DateTime] value at the given [path], or returns [defaultValue] if null.
  DateTime getDateTimePathOrDefault(String path, DateTime defaultValue) =>
      getDateTimePath(path) ?? defaultValue;

  /// Gets a [Uri] value at the given [path], or returns [defaultValue] if null.
  Uri getUriPathOrDefault(String path, Uri defaultValue) =>
      getUriPath(path) ?? defaultValue;

  // Map operations
  /// Transforms the underlying map using the [mapper] function.
  Map<K, V>? mapValues<K, V>(
      MapEntry<K, V>? Function(String key, dynamic value) mapper) {
    return flexibleMapFromJson<K, V>(_data, (key, value) {
      if (key is String) {
        return mapper(key, value);
      }
      return null;
    });
  }

  /// Transforms the underlying map using the [mapper] function, never returning null.
  Map<K, V> mapValuesOrEmpty<K, V>(
      MapEntry<K, V>? Function(String key, dynamic value) mapper) {
    return flexibleMapNotNullFromJson<K, V>(_data, (key, value) {
      if (key is String) {
        return mapper(key, value);
      }
      return null;
    });
  }

  // Advanced operations

  /// Get multiple values at once with type safety
  Map<String, T?> getMultiple<T>(
      List<String> keys, T? Function(String) getter) {
    final result = <String, T?>{};
    for (final key in keys) {
      result[key] = getter(key);
    }
    return result;
  }

  /// Get multiple strings at once
  Map<String, String?> getStrings(List<String> keys) =>
      getMultiple<String?>(keys, (key) => getString(key));

  /// Get multiple ints at once
  Map<String, int?> getInts(List<String> keys) =>
      getMultiple<int?>(keys, (key) => getInt(key));

  /// Get multiple booleans at once
  Map<String, bool?> getBools(List<String> keys) =>
      getMultiple<bool?>(keys, (key) => getBool(key));

  /// Get a value with multiple fallback keys
  T? getWithFallbacks<T>(List<String> keys, T? Function(String) getter) {
    for (final key in keys) {
      final value = getter(key);
      if (value != null) return value;
    }
    return null;
  }

  /// String with fallback keys (useful for API inconsistencies)
  String? getStringWithFallbacks(List<String> keys) =>
      getWithFallbacks<String?>(keys, getString);

  /// Int with fallback keys
  int? getIntWithFallbacks(List<String> keys) =>
      getWithFallbacks<int?>(keys, getInt);

  /// Boolean with fallback keys
  bool? getBoolWithFallbacks(List<String> keys) =>
      getWithFallbacks<bool?>(keys, getBool);

  /// Check if all required keys exist and have non-null values
  bool hasRequiredKeys(List<String> keys) {
    final missing = <String>[];
    for (final key in keys) {
      if (!hasKey(key) || _data[key] == null) {
        missing.add(key);
      }
    }
    if (missing.isNotEmpty) {
      _addError('Missing required keys: ${missing.join(', ')}');
      return false;
    }
    return true;
  }

  /// Check if all required paths exist and have non-null values
  bool hasRequiredPaths(List<String> paths) {
    final missing = <String>[];
    for (final path in paths) {
      if (!hasPath(path) || getPath(path) == null) {
        missing.add(path);
      }
    }
    if (missing.isNotEmpty) {
      _addError('Missing required paths: ${missing.join(', ')}');
      return false;
    }
    return true;
  }

  /// Transform this JsonSon using a builder function
  T transform<T>(T Function(JsonSon) transformer) => transformer(this);

  /// Apply a transformation to all values matching a condition
  JsonSon transformValues(bool Function(String key, dynamic value) condition,
      dynamic Function(String key, dynamic value) transformer) {
    final transformed = <String, dynamic>{};
    for (final entry in _data.entries) {
      if (condition(entry.key, entry.value)) {
        transformed[entry.key] = transformer(entry.key, entry.value);
      } else {
        transformed[entry.key] = entry.value;
      }
    }
    return JsonSon(transformed);
  }

  /// Filter keys based on a condition
  JsonSon filterKeys(bool Function(String key, dynamic value) condition) {
    final filtered = <String, dynamic>{};
    for (final entry in _data.entries) {
      if (condition(entry.key, entry.value)) {
        filtered[entry.key] = entry.value;
      }
    }
    return JsonSon(filtered);
  }

  /// Merge with another JsonSon (other takes precedence)
  JsonSon merge(JsonSon other) {
    final merged = Map<String, dynamic>.from(_data);
    merged.addAll(other._data);
    return JsonSon(merged);
  }

  /// Deep merge with another JsonSon (recursively merges nested objects)
  JsonSon deepMerge(JsonSon other) {
    return JsonSon(_deepMergeMap(_data, other._data));
  }

  static Map<String, dynamic> _deepMergeMap(
    Map<String, dynamic> base,
    Map<String, dynamic> override,
  ) {
    final result = Map<String, dynamic>.from(base);
    for (final entry in override.entries) {
      if (result.containsKey(entry.key) &&
          result[entry.key] is Map<String, dynamic> &&
          entry.value is Map<String, dynamic>) {
        result[entry.key] = _deepMergeMap(
          result[entry.key] as Map<String, dynamic>,
          entry.value as Map<String, dynamic>,
        );
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Compare with another JsonSon and return the differences
  /// Returns a map with keys: 'added', 'removed', 'changed'
  Map<String, dynamic> diff(JsonSon other) {
    final added = <String, dynamic>{};
    final removed = <String, dynamic>{};
    final changed = <String, Map<String, dynamic>>{};

    // Find added and changed keys
    for (final entry in other._data.entries) {
      if (!_data.containsKey(entry.key)) {
        added[entry.key] = entry.value;
      } else if (_data[entry.key] != entry.value) {
        changed[entry.key] = {
          'from': _data[entry.key],
          'to': entry.value,
        };
      }
    }

    // Find removed keys
    for (final entry in _data.entries) {
      if (!other._data.containsKey(entry.key)) {
        removed[entry.key] = entry.value;
      }
    }

    return {
      'added': added,
      'removed': removed,
      'changed': changed,
    };
  }

  /// Pick values at nested paths (like select but supports dot notation)
  JsonSon pick(List<String> paths) {
    final result = <String, dynamic>{};
    for (final path in paths) {
      final value = getPath(path);
      if (value != null) {
        _setNestedValue(result, path.split('.'), value);
      }
    }
    return JsonSon(result);
  }

  static void _setNestedValue(
    Map<String, dynamic> map,
    List<String> keys,
    dynamic value,
  ) {
    if (keys.isEmpty) return;
    if (keys.length == 1) {
      map[keys.first] = value;
      return;
    }
    final key = keys.first;
    map[key] ??= <String, dynamic>{};
    if (map[key] is Map<String, dynamic>) {
      _setNestedValue(map[key] as Map<String, dynamic>, keys.sublist(1), value);
    }
  }

  /// Flatten nested objects to dot-notation keys
  /// Example: {'a': {'b': 1}} -> {'a.b': 1}
  Map<String, dynamic> flatten({String separator = '.'}) {
    final result = <String, dynamic>{};
    _flattenMap(_data, '', separator, result);
    return result;
  }

  static void _flattenMap(
    Map<String, dynamic> map,
    String prefix,
    String separator,
    Map<String, dynamic> result,
  ) {
    for (final entry in map.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix$separator${entry.key}';
      if (entry.value is Map<String, dynamic>) {
        _flattenMap(
            entry.value as Map<String, dynamic>, key, separator, result);
      } else if (entry.value is List) {
        for (int i = 0; i < (entry.value as List).length; i++) {
          final item = (entry.value as List)[i];
          if (item is Map<String, dynamic>) {
            _flattenMap(item, '$key$separator$i', separator, result);
          } else {
            result['$key$separator$i'] = item;
          }
        }
      } else {
        result[key] = entry.value;
      }
    }
  }

  /// Unflatten dot-notation keys to nested objects
  /// Example: {'a.b': 1} -> {'a': {'b': 1}}
  static JsonSon unflatten(Map<String, dynamic> flatMap,
      {String separator = '.'}) {
    final result = <String, dynamic>{};
    for (final entry in flatMap.entries) {
      final keys = entry.key.split(separator);
      _setNestedValue(result, keys, entry.value);
    }
    return JsonSon(result);
  }

  /// Get a value only if a condition is met
  T? getIf<T>(String key, T? Function(String) getter,
      bool Function(dynamic) condition) {
    final rawValue = _data[key];
    if (rawValue != null && condition(rawValue)) {
      return getter(key);
    }
    return null;
  }

  /// Get an int only if it meets a condition
  int? getIntIf(String key, bool Function(int) condition) {
    final value = getInt(key);
    return value != null && condition(value) ? value : null;
  }

  /// Get a string only if it meets a condition
  String? getStringIf(String key, bool Function(String) condition) {
    final value = getString(key);
    return value != null && condition(value) ? value : null;
  }

  /// Convert to URL query string
  /// Example: {'a': 1, 'b': 'hello'} -> 'a=1&b=hello'
  String toQueryString({bool encode = true}) {
    final params = <String>[];
    _flattenForQuery(_data, '', params, encode);
    return params.join('&');
  }

  static void _flattenForQuery(
    Map<String, dynamic> map,
    String prefix,
    List<String> params,
    bool encode,
  ) {
    for (final entry in map.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix[${entry.key}]';
      if (entry.value is Map<String, dynamic>) {
        _flattenForQuery(
            entry.value as Map<String, dynamic>, key, params, encode);
      } else if (entry.value is List) {
        for (int i = 0; i < (entry.value as List).length; i++) {
          final item = (entry.value as List)[i];
          final arrayKey = '$key[$i]';
          if (item is Map<String, dynamic>) {
            _flattenForQuery(item, arrayKey, params, encode);
          } else {
            final value =
                encode ? Uri.encodeComponent(item.toString()) : item.toString();
            params.add('$arrayKey=$value');
          }
        }
      } else if (entry.value != null) {
        final value = encode
            ? Uri.encodeComponent(entry.value.toString())
            : entry.value.toString();
        params.add('$key=$value');
      }
    }
  }

  // Utility methods
  /// Checks if the given [key] exists in the underlying map.
  bool hasKey(String key) => _data.containsKey(key);

  /// Gets all keys in the underlying map.
  List<String> get keys => _data.keys.cast<String>().toList();

  /// Gets the raw underlying map.
  Map<String, dynamic> get rawData => _data;

  /// Returns a new [JsonSon] instance with only the specified [keys].
  JsonSon select(List<String> keys) {
    final Map<String, dynamic> result = {};
    for (final key in keys) {
      if (_data.containsKey(key)) {
        result[key] = _data[key];
      }
    }
    return JsonSon(result);
  }

  /// Returns a new [JsonSon] instance without the specified [keys].
  JsonSon exclude(List<String> keys) {
    final Map<String, dynamic> result = Map.from(_data);
    for (final key in keys) {
      result.remove(key);
    }
    return JsonSon(result);
  }

  /// Converts the [JsonSon] instance to a JSON string.
  String toJson() => jsonEncode(_data);

  @override
  String toString() => 'JsonSon($_data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonSon &&
          runtimeType == other.runtimeType &&
          _mapEquals(_data, other._data);

  @override
  int get hashCode => _data.hashCode;

  static bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
