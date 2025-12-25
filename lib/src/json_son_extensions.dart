import 'package:json_son/json_son.dart';

/// Extension methods on `Map<String, dynamic>` for quick JsonSon access
extension JsonSonMapExtension on Map<String, dynamic> {
  /// Convert this map to a JsonSon instance
  JsonSon get json => JsonSon(this);

  /// Quick access to common getters without creating JsonSon instance
  int? getInt(String key) => flexibleIntFromJson(this[key]);
  String? getString(String key) => flexibleStringFromJson(this[key]);
  bool? getBool(String key) => flexibleBoolFromJson(this[key]);
  double? getDouble(String key) => flexibleDoubleFromJson(this[key]);
  DateTime? getDateTime(String key) => flexibleDateTimeFromJson(this[key]);
}

/// Extension methods on JsonSon for API pattern support
extension JsonSonApiExtension on JsonSon {
  /// Extract common pagination information from API responses
  PaginationInfo? getPaginationInfo({
    String totalKey = 'total',
    String pageKey = 'page',
    String limitKey = 'limit',
    String perPageKey = 'per_page',
    String hasMoreKey = 'has_more',
    String nextPageKey = 'next_page',
  }) {
    final total = getInt(totalKey);
    final page = getInt(pageKey);
    final limit = getInt(limitKey) ?? getInt(perPageKey);
    final hasMore = getBool(hasMoreKey);
    final nextPage = getInt(nextPageKey);

    if (total != null ||
        page != null ||
        limit != null ||
        hasMore != null ||
        nextPage != null) {
      return PaginationInfo(
        total: total,
        page: page,
        limit: limit,
        hasMore: hasMore,
        nextPage: nextPage,
      );
    }
    return null;
  }

  /// Extract error information from API responses
  ApiError? getApiError({
    String messageKey = 'message',
    String errorKey = 'error',
    String codeKey = 'code',
    String detailsKey = 'details',
    String errorsKey = 'errors',
  }) {
    // Try different common error patterns
    final message = getString(messageKey) ??
        getString(errorKey) ??
        getStringPath('error.message');

    final code = getString(codeKey) ??
        getStringPath('error.code') ??
        getInt(codeKey)?.toString() ??
        getIntPath('error.code')?.toString();

    final details = getString(detailsKey) ?? getStringPath('error.details');

    // Check for errors array
    List<String>? errorsList;
    final errors = getPath(errorsKey);
    if (errors is List) {
      errorsList = errors
          .map((e) =>
              e is String ? e : (e is Map ? e['message']?.toString() : null))
          .where((e) => e != null)
          .cast<String>()
          .toList();
    }

    if (message != null || code != null || errorsList != null) {
      return ApiError(
        message: message,
        code: code,
        details: details,
        errors: errorsList,
      );
    }
    return null;
  }

  /// Extract user information with common field variations
  UserInfo? getUserInfo() {
    return UserInfo(
      id: getIntWithFallbacks(['id', 'userId', 'user_id']),
      name: getStringWithFallbacks(
          ['name', 'username', 'displayName', 'display_name']),
      email: getStringWithFallbacks(['email', 'emailAddress', 'email_address']),
      firstName: getStringWithFallbacks(['firstName', 'first_name', 'fname']),
      lastName: getStringWithFallbacks(['lastName', 'last_name', 'lname']),
      avatar: getStringWithFallbacks([
        'avatar',
        'avatarUrl',
        'avatar_url',
        'profilePicture',
        'profile_picture'
      ]),
    );
  }

  /// Extract timestamp information with various formats
  TimestampInfo getTimestampInfo({
    String createdKey = 'created_at',
    String updatedKey = 'updated_at',
    String deletedKey = 'deleted_at',
  }) {
    return TimestampInfo(
      createdAt:
          getDateTime(createdKey) ?? getDateTimePath('timestamps.created'),
      updatedAt:
          getDateTime(updatedKey) ?? getDateTimePath('timestamps.updated'),
      deletedAt:
          getDateTime(deletedKey) ?? getDateTimePath('timestamps.deleted'),
    );
  }
}

/// Helper class for pagination information
class PaginationInfo {
  final int? total;
  final int? page;
  final int? limit;
  final bool? hasMore;
  final int? nextPage;

  const PaginationInfo({
    this.total,
    this.page,
    this.limit,
    this.hasMore,
    this.nextPage,
  });

  /// Calculate the total number of pages if possible
  int? get totalPages {
    if (total != null && limit != null && limit! > 0) {
      return (total! / limit!).ceil();
    }
    return null;
  }

  /// Check if there are more pages
  bool get hasNextPage {
    if (hasMore != null) return hasMore!;
    if (nextPage != null) return true;
    if (page != null && totalPages != null) {
      return page! < totalPages!;
    }
    return false;
  }

  @override
  String toString() =>
      'PaginationInfo(total: $total, page: $page, limit: $limit, hasMore: $hasMore, nextPage: $nextPage)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationInfo &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          page == other.page &&
          limit == other.limit &&
          hasMore == other.hasMore &&
          nextPage == other.nextPage;

  @override
  int get hashCode =>
      total.hashCode ^
      page.hashCode ^
      limit.hashCode ^
      hasMore.hashCode ^
      nextPage.hashCode;

  /// Creates a copy of this PaginationInfo with the given fields replaced
  PaginationInfo copyWith({
    int? total,
    int? page,
    int? limit,
    bool? hasMore,
    int? nextPage,
  }) {
    return PaginationInfo(
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      nextPage: nextPage ?? this.nextPage,
    );
  }
}

/// Helper class for API error information
class ApiError {
  final String? message;
  final String? code;
  final String? details;
  final List<String>? errors;

  const ApiError({
    this.message,
    this.code,
    this.details,
    this.errors,
  });

  /// Get a user-friendly error message
  String get userMessage {
    if (message != null) return message!;
    if (errors != null && errors!.isNotEmpty) return errors!.first;
    return 'An unknown error occurred';
  }

  /// Check if this is a specific error type by code
  bool hasErrorCode(String errorCode) => code == errorCode;

  @override
  String toString() => 'ApiError(code: $code, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code &&
          details == other.details &&
          _listEquals(errors, other.errors);

  @override
  int get hashCode =>
      message.hashCode ^ code.hashCode ^ details.hashCode ^ errors.hashCode;

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Creates a copy of this ApiError with the given fields replaced
  ApiError copyWith({
    String? message,
    String? code,
    String? details,
    List<String>? errors,
  }) {
    return ApiError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      errors: errors ?? this.errors,
    );
  }
}

/// Helper class for user information
class UserInfo {
  final int? id;
  final String? name;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? avatar;

  const UserInfo({
    this.id,
    this.name,
    this.email,
    this.firstName,
    this.lastName,
    this.avatar,
  });

  /// Get the full name if available
  String? get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return name;
  }

  @override
  String toString() => 'UserInfo(id: $id, name: $name, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          avatar == other.avatar;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      avatar.hashCode;

  /// Creates a copy of this UserInfo with the given fields replaced
  UserInfo copyWith({
    int? id,
    String? name,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) {
    return UserInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
    );
  }
}

/// Helper class for timestamp information
class TimestampInfo {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const TimestampInfo({
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Check if the record is deleted
  bool get isDeleted => deletedAt != null;

  /// Get the age of the record
  Duration? get age {
    if (createdAt == null) return null;
    return DateTime.now().difference(createdAt!);
  }

  /// Get the time since last update
  Duration? get timeSinceUpdate {
    if (updatedAt == null) return null;
    return DateTime.now().difference(updatedAt!);
  }

  @override
  String toString() =>
      'TimestampInfo(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimestampInfo &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode =>
      createdAt.hashCode ^ updatedAt.hashCode ^ deletedAt.hashCode;

  /// Creates a copy of this TimestampInfo with the given fields replaced
  TimestampInfo copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TimestampInfo(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
