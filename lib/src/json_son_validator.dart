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
}
