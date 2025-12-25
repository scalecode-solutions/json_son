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
  List<T?>? getList<T>(String key, T? Function(dynamic) converter) =>
      flexibleListFromJson<T>(_data[key], converter);

  /// Gets a non-null [List] of values for the given [key], applying the [converter] to each item.
  List<T> getListOrEmpty<T>(String key, T? Function(dynamic) converter) =>
      flexibleListNotNullFromJson<T>(_data[key], converter);

  /// Gets a [List] of [String] values from a comma-separated string for the given [key].
  List<String>? getCommaSeparatedList(String key) =>
      flexibleCommaSeparatedListFromJson(_data[key]);

  /// Gets a [List] of [JsonSon] objects for the given [key].
  List<JsonSon>? getObjectList(String key) {
    final list = getList<JsonSon>(key, (item) {
      if (item is Map<String, dynamic>) {
        return JsonSon(item);
      }
      return null;
    });

    // Convert List<JsonSon?>? to List<JsonSon>?
    if (list == null) return null;
    return list.whereType<JsonSon>().toList();
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
}
