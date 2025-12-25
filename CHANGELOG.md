## 0.4.2

- Added `copyWith` methods to helper classes:
  - `PaginationInfo.copyWith`
  - `ApiError.copyWith`
  - `UserInfo.copyWith`
  - `TimestampInfo.copyWith`
- Enables immutable updates for all data classes

## 0.4.1

- Added `==` and `hashCode` operators to data classes:
  - `JsonSon`
  - `PaginationInfo`
  - `ApiError`
  - `UserInfo`
  - `TimestampInfo`
- Improves testability and enables use in collections like `Set` and `Map` keys

## 0.4.0

### Breaking Changes
- **BREAKING**: Changed `flexibleListFromJson` return type from `List<T?>?` to `List<T>?`
  - The function already filtered out null values, so the return type now accurately reflects this
  - **Migration**: Update type annotations from `List<T?>?` to `List<T>?`
- Updated `JsonSon.getList` method to match the new signature
- Simplified `JsonSon.getObjectList` implementation

## 0.3.10

- Added missing `OrDefault` methods to `JsonSon` class:
  - `getDateTimeOrDefault(String key, DateTime defaultValue)`
  - `getUriOrDefault(String key, Uri defaultValue)`
  - `getDateTimePathOrDefault(String path, DateTime defaultValue)`
  - `getUriPathOrDefault(String path, Uri defaultValue)`
- Completes the `OrDefault` method set for all supported types

## 0.3.9

- Enhanced `flexibleDateTimeFromJson` with automatic seconds vs milliseconds detection:
  - Values < 10 billion are treated as seconds since epoch (Unix timestamp)
  - Values >= 10 billion are treated as milliseconds since epoch
  - Improves compatibility with APIs that use Unix timestamps in seconds

## 0.3.8

- Internal refactor: removed duplicate function implementations from `json_son.dart`
- Functions are now only defined in `json_son_base.dart` and properly re-exported
- No functional changes

## 0.3.7

- Added comprehensive tests for all new features

## 0.3.6

- Added non-nullable versions of flexible functions that return default values instead of null:
- `flexibleRequiredBoolFromJson`: Returns false if null
- `flexibleRequiredListFromJson`: Returns empty list if null (alias for flexibleListNotNullFromJson)

## 0.3.5

- Added non-nullable versions of flexible functions that return default values instead of null:
  - `flexibleRequiredIntFromJson`: Returns 0 if null
  - `flexibleRequiredDoubleFromJson`: Returns 0.0 if null
  - `flexibleRequiredStringFromJson`: Returns empty string if null

## 0.3.4

- Ran dart format on the codebase

## 0.3.3

- Fixed documentation comments to properly escape angle brackets in type references

## 0.3.2

### Enhanced JsonSon Class
- Added error tracking with detailed path information for debugging and validation
- Implemented advanced constructors for different data sources:
  - `fromApiResponse`: Handle API responses that might be strings or maps
  - `fromMapSafe`: Safely create JsonSon instances with error handling
- Added batch operations for processing multiple keys or paths at once
- Implemented fallback keys to try multiple keys in sequence until a value is found
- Added transformation methods for mapping and merging JSON data
- Implemented validation methods for checking required keys and paths

### Extensions
- Created `JsonSonMapExtension` for direct access to JsonSon methods from Map objects
- Developed `JsonSonApiExtension` for common API patterns including:
  - Pagination information extraction
  - Error handling with code and message extraction
  - User information normalization
  - Timestamp handling

### Validation Framework
- Implemented `JsonSonValidator` with a fluent API for complex validation logic
- Added type validation for strings, integers, booleans, etc.
- Added format validation for emails, URLs, and custom patterns
- Implemented range validation for numeric values and string lengths
- Added support for custom validation rules
- Added nested validation for objects and array items

### Testing
- Added comprehensive test suite for all new features
- Created tests for extensions and the validation framework
- Ensured all tests pass with proper error handling

### Documentation
- Updated README with detailed examples and API documentation
- Added code examples for all new features
- Provided comprehensive API reference for all classes

## 0.2.0

- Added new class-based API with `JsonSon` class for more fluent and powerful JSON handling
- Added comprehensive example for the class-based approach
- Maintained full backward compatibility with the functional approach

## 0.1.22

- Added `flexibleMapFromJson` and `flexibleMapNotNullFromJson` functions for flexible map transformations

## 0.1.21

- Added comprehensive tests for `flexibleListFromJson` and `flexibleListNotNullFromJson`

## 0.1.20

- Added comprehensive tests for `flexibleLowerStringFromJson` and `flexibleUpperStringFromJson`

## 0.1.19

- Added comprehensive tests for `flexibleTrimmedStringFromJson`

## 0.1.18

- Added comprehensive tests for `flexibleUriFromJson`
- Fixed test expectations for `flexibleUriFromJson` to match actual behavior

## 0.1.17

- Added comprehensive tests for `flexibleDateTimeFromJson`

## 0.1.16

- Added comprehensive tests for `flexibleNumFromJson`

## 0.1.15

- Added comprehensive tests for `flexibleStringFromJson`

## 0.1.14

- Added comprehensive tests for `flexibleBoolFromJson`

## 0.1.13

- Added comprehensive tests for `flexibleDoubleFromJson`

## 0.1.12

- Added comprehensive tests for `flexibleIntFromJson`

## 0.1.11

- Ran dart format on the codebase
- Code formatting and documentation improvements across the codebase
- Removed unnecessary TODOs and improved code comments
- Enhanced code style consistency in method parameters and documentation

## 0.1.10

- Removed unused import.

## 0.1.9

- Renamed package to Just Straightens Out Nonsense (JSON) and to keep it short, made it json_son.

## 0.1.8

- Added `flexibleUpperStringFromJson` for converting strings to uppercase after trimming.

## 0.1.7

- Added `flexibleLowerStringFromJson` for converting strings to lowercase after trimming.

## 0.1.6

- Added `flexibleTrimmedStringFromJson` for trimming whitespace and converting empty strings to null.

## 0.1.5

- Added `flexibleCommaSeparatedListFromJson` for parsing comma-separated strings into `List<String>?`.

## 0.1.4

- Added `flexibleListNotNullFromJson` for guaranteeing a non-null list, even if the API returns null or a single item. Returns an empty list for null inputs.

## 0.1.3

- Added `flexibleListFromJson` for handling APIs that may return a single item instead of a list, or for parsing list items with a flexible item parser.

## 0.1.2

- Updated flexible JSON decoder functions:
  - `flexibleNumFromJson`
  - `flexibleDateTimeFromJson`
  - `flexibleUriFromJson`

## 0.1.1

- Initial release.
- Added flexible JSON decoder functions:
  - `flexibleIntFromJson`
  - `flexibleDoubleFromJson`
  - `flexibleBoolFromJson`
  - `flexibleStringFromJson`
  - Basic package setup including `pubspec.yaml`, `README.md`, and `LICENSE`.

## 0.1.0

- Initial version.

