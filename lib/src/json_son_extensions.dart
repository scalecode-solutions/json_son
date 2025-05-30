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
}
