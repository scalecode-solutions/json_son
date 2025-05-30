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

