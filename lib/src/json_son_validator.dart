import 'package:json_son/json_son.dart';

/// A fluent validator for JsonSon objects
class JsonSonValidator {
  final JsonSon _json;
  final Map<String, String> _errors = {};

  /// Create a validator for a JsonSon object
  JsonSonValidator(this._json);

  /// Get all validation errors
  Map<String, String> get errors => Map.unmodifiable(_errors);

  /// Check if validation passed
  bool get isValid => _errors.isEmpty;

  /// Validate that a key exists and is not null
  JsonSonValidator required(String key, {String? message}) {
    if (!_json.hasKey(key) || _json.rawData[key] == null) {
      _errors[key] = message ?? 'Field "$key" is required';
    }
    return this;
  }

  /// Validate that a path exists and is not null
  JsonSonValidator requiredPath(String path, {String? message}) {
    if (!_json.hasPath(path) || _json.getPath(path) == null) {
      _errors[path] = message ?? 'Path "$path" is required';
    }
    return this;
  }

  /// Validate that a key is a string
  JsonSonValidator string(String key, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value == null) {
        _errors[key] = message ?? 'Field "$key" must be a string';
      }
    }
    return this;
  }

  /// Validate that a key is an integer
  JsonSonValidator integer(String key, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getInt(key);
      if (value == null) {
        _errors[key] = message ?? 'Field "$key" must be an integer';
      }
    }
    return this;
  }

  /// Validate that a key is a boolean
  JsonSonValidator boolean(String key, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getBool(key);
      if (value == null) {
        _errors[key] = message ?? 'Field "$key" must be a boolean';
      }
    }
    return this;
  }

  /// Validate that a key is a double
  JsonSonValidator double(String key, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getDouble(key);
      if (value == null) {
        _errors[key] = message ?? 'Field "$key" must be a number';
      }
    }
    return this;
  }

  /// Validate that a key is a date
  JsonSonValidator date(String key, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getDateTime(key);
      if (value == null) {
        _errors[key] = message ?? 'Field "$key" must be a valid date';
      }
    }
    return this;
  }

  /// Validate that a key is an array
  JsonSonValidator array(String key, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.rawData[key];
      if (value is! List) {
        _errors[key] = message ?? 'Field "$key" must be an array';
      }
    }
    return this;
  }

  /// Validate that a key is an object
  JsonSonValidator object(String key, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.rawData[key];
      if (value is! Map) {
        _errors[key] = message ?? 'Field "$key" must be an object';
      }
    }
    return this;
  }

  /// Validate that a string has a minimum length
  JsonSonValidator minLength(String key, int length, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value != null && value.length < length) {
        _errors[key] =
            message ?? 'Field "$key" must be at least $length characters long';
      }
    }
    return this;
  }

  /// Validate that a string has a maximum length
  JsonSonValidator maxLength(String key, int length, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value != null && value.length > length) {
        _errors[key] =
            message ?? 'Field "$key" must be at most $length characters long';
      }
    }
    return this;
  }

  /// Validate that a number is at least a minimum value
  JsonSonValidator min(String key, num minValue, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getNum(key);
      if (value != null && value < minValue) {
        _errors[key] = message ?? 'Field "$key" must be at least $minValue';
      }
    }
    return this;
  }

  /// Validate that a number is at most a maximum value
  JsonSonValidator max(String key, num maxValue, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getNum(key);
      if (value != null && value > maxValue) {
        _errors[key] = message ?? 'Field "$key" must be at most $maxValue';
      }
    }
    return this;
  }

  /// Validate that a string matches a pattern
  JsonSonValidator pattern(String key, RegExp pattern, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value != null && !pattern.hasMatch(value)) {
        _errors[key] = message ?? 'Field "$key" has an invalid format';
      }
    }
    return this;
  }

  /// Validate that a string is a valid email
  JsonSonValidator email(String key, {String? message}) {
    return pattern(
        key, RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
        message: message ?? 'Field "$key" must be a valid email address');
  }

  /// Validate that a string is a valid URL
  JsonSonValidator url(String key, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value != null) {
        final uri = _json.getUri(key);
        if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
          _errors[key] = message ?? 'Field "$key" must be a valid URL';
        }
      }
    }
    return this;
  }

  /// Validate that a value is one of a list of allowed values
  JsonSonValidator oneOf<T>(String key, List<T> allowedValues,
      {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.rawData[key];
      if (!allowedValues.contains(value)) {
        _errors[key] = message ??
            'Field "$key" must be one of: ${allowedValues.join(', ')}';
      }
    }
    return this;
  }

  /// Add a custom validation rule
  JsonSonValidator custom(String key, bool Function(dynamic value) validator,
      {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.rawData[key];
      if (!validator(value)) {
        _errors[key] = message ?? 'Field "$key" is invalid';
      }
    }
    return this;
  }

  /// Validate a nested object using a callback
  JsonSonValidator nested(
      String key, void Function(JsonSonValidator validator) validatorFn,
      {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final nestedJson = _json.getObject(key);
      if (nestedJson != null) {
        final nestedValidator = JsonSonValidator(nestedJson);
        validatorFn(nestedValidator);

        // Add nested errors with prefix
        for (final entry in nestedValidator.errors.entries) {
          _errors['$key.${entry.key}'] = entry.value;
        }
      } else {
        _errors[key] = message ?? 'Field "$key" must be an object';
      }
    }
    return this;
  }

  /// Validate each item in an array
  JsonSonValidator eachItem(String key,
      void Function(JsonSonValidator validator, int index) validatorFn,
      {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.rawData[key];
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          if (value[i] is Map<String, dynamic>) {
            final itemJson = JsonSon(value[i] as Map<String, dynamic>);
            final itemValidator = JsonSonValidator(itemJson);
            validatorFn(itemValidator, i);

            // Add array item errors with index
            for (final entry in itemValidator.errors.entries) {
              _errors['$key[$i].${entry.key}'] = entry.value;
            }
          }
        }
      } else {
        _errors[key] = message ?? 'Field "$key" must be an array';
      }
    }
    return this;
  }

  /// Validate that a string is a valid phone number (basic check for digits)
  JsonSonValidator phone(String key,
      {String? message, int? minDigits, int? maxDigits}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value != null) {
        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
        final min = minDigits ?? 7;
        final max = maxDigits ?? 15;
        if (digits.length < min || digits.length > max) {
          _errors[key] = message ?? 'Field "$key" must be a valid phone number';
        }
      }
    }
    return this;
  }

  /// Validate that a string is a valid UUID (v1-v5)
  JsonSonValidator uuid(String key, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value != null) {
        final uuidRegex = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          caseSensitive: false,
        );
        if (!uuidRegex.hasMatch(value)) {
          _errors[key] = message ?? 'Field "$key" must be a valid UUID';
        }
      }
    }
    return this;
  }

  /// Validate that a string is a valid credit card number (Luhn algorithm)
  JsonSonValidator creditCard(String key, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value != null) {
        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
        if (digits.length < 13 || digits.length > 19 || !_luhnCheck(digits)) {
          _errors[key] =
              message ?? 'Field "$key" must be a valid credit card number';
        }
      }
    }
    return this;
  }

  /// Luhn algorithm check for credit card validation
  static bool _luhnCheck(String digits) {
    int sum = 0;
    bool alternate = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// Validate that a date is within a range
  JsonSonValidator dateRange(String key,
      {DateTime? min, DateTime? max, String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getDateTime(key);
      if (value != null) {
        if (min != null && value.isBefore(min)) {
          _errors[key] =
              message ?? 'Field "$key" must be after ${min.toIso8601String()}';
          return this;
        }
        if (max != null && value.isAfter(max)) {
          _errors[key] =
              message ?? 'Field "$key" must be before ${max.toIso8601String()}';
        }
      }
    }
    return this;
  }

  /// Validate that a date is in the past
  JsonSonValidator pastDate(String key, {String? message}) {
    return dateRange(key,
        max: DateTime.now(),
        message: message ?? 'Field "$key" must be in the past');
  }

  /// Validate that a date is in the future
  JsonSonValidator futureDate(String key, {String? message}) {
    return dateRange(key,
        min: DateTime.now(),
        message: message ?? 'Field "$key" must be in the future');
  }

  /// Conditional validation - validate field B only if field A meets a condition
  JsonSonValidator when(
    String conditionKey,
    bool Function(dynamic value) condition,
    void Function(JsonSonValidator validator) validatorFn,
  ) {
    final conditionValue = _json.rawData[conditionKey];
    if (condition(conditionValue)) {
      validatorFn(this);
    }
    return this;
  }

  /// Validate that field B is required when field A has a specific value
  JsonSonValidator requiredWhen(
      String key, String conditionKey, dynamic conditionValue,
      {String? message}) {
    return when(conditionKey, (v) => v == conditionValue, (v) {
      v.required(key,
          message: message ??
              'Field "$key" is required when "$conditionKey" is "$conditionValue"');
    });
  }

  /// Validate that field B is required when field A exists and is not null
  JsonSonValidator requiredWith(String key, String otherKey,
      {String? message}) {
    return when(otherKey, (v) => v != null, (v) {
      v.required(key,
          message: message ??
              'Field "$key" is required when "$otherKey" is present');
    });
  }

  /// Validate that field B is required when field A does not exist or is null
  JsonSonValidator requiredWithout(String key, String otherKey,
      {String? message}) {
    return when(otherKey, (v) => v == null, (v) {
      v.required(key,
          message: message ??
              'Field "$key" is required when "$otherKey" is not present');
    });
  }

  /// Validate that array items are unique
  JsonSonValidator unique(String key,
      {String? message, dynamic Function(dynamic)? by}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.rawData[key];
      if (value is List) {
        final seen = <dynamic>{};
        for (final item in value) {
          final compareValue = by != null ? by(item) : item;
          if (seen.contains(compareValue)) {
            _errors[key] = message ?? 'Field "$key" must contain unique values';
            break;
          }
          seen.add(compareValue);
        }
      }
    }
    return this;
  }

  /// Validate that a number is between min and max (inclusive)
  JsonSonValidator between(String key, num minValue, num maxValue,
      {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getNum(key);
      if (value != null && (value < minValue || value > maxValue)) {
        _errors[key] =
            message ?? 'Field "$key" must be between $minValue and $maxValue';
      }
    }
    return this;
  }

  /// Validate that a string contains a substring
  JsonSonValidator contains(String key, String substring,
      {String? message, bool caseSensitive = true}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value != null) {
        final haystack = caseSensitive ? value : value.toLowerCase();
        final needle = caseSensitive ? substring : substring.toLowerCase();
        if (!haystack.contains(needle)) {
          _errors[key] = message ?? 'Field "$key" must contain "$substring"';
        }
      }
    }
    return this;
  }

  /// Validate that a string starts with a prefix
  JsonSonValidator startsWith(String key, String prefix, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value != null && !value.startsWith(prefix)) {
        _errors[key] = message ?? 'Field "$key" must start with "$prefix"';
      }
    }
    return this;
  }

  /// Validate that a string ends with a suffix
  JsonSonValidator endsWith(String key, String suffix, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.getString(key);
      if (value != null && !value.endsWith(suffix)) {
        _errors[key] = message ?? 'Field "$key" must end with "$suffix"';
      }
    }
    return this;
  }

  /// Validate that an array has a minimum number of items
  JsonSonValidator minItems(String key, int count, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.rawData[key];
      if (value is List && value.length < count) {
        _errors[key] =
            message ?? 'Field "$key" must have at least $count items';
      }
    }
    return this;
  }

  /// Validate that an array has a maximum number of items
  JsonSonValidator maxItems(String key, int count, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.rawData[key];
      if (value is List && value.length > count) {
        _errors[key] = message ?? 'Field "$key" must have at most $count items';
      }
    }
    return this;
  }

  /// Validate that a value equals another field's value
  JsonSonValidator equals(String key, String otherKey, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.rawData[key];
      final otherValue = _json.rawData[otherKey];
      if (value != otherValue) {
        _errors[key] = message ?? 'Field "$key" must equal "$otherKey"';
      }
    }
    return this;
  }

  /// Validate that a value is different from another field's value
  JsonSonValidator different(String key, String otherKey, {String? message}) {
    if (_json.hasKey(key) && _json.rawData[key] != null) {
      final value = _json.rawData[key];
      final otherValue = _json.rawData[otherKey];
      if (value == otherValue) {
        _errors[key] =
            message ?? 'Field "$key" must be different from "$otherKey"';
      }
    }
    return this;
  }
}
