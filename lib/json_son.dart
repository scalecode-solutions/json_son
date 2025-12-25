/// A Dart utility package providing helper functions to flexibly parse JSON values
/// that might have inconsistent data types (e.g., strings to numbers,
/// strings/numbers to booleans, or dates in various formats).
///
/// These functions are designed to be used with JSON deserialization, often in
/// conjunction with code generation libraries like `json_serializable` (used by `freezed`),
/// by annotating DTO fields with `@JsonKey(fromJson: ...)`.
///
/// This package also provides a class-based API through the `JsonSon` class,
/// which offers a more fluent interface for working with inconsistent JSON data.
///
/// The enhanced version includes:
/// - Error tracking and validation
/// - Advanced path-based access
/// - Batch operations and fallback keys
/// - API pattern support through extensions
/// - Fluent validation framework
library;

export 'src/json_son_base.dart';
export 'src/json_son_class.dart';
export 'src/json_son_extensions.dart';
export 'src/json_son_validator.dart';
