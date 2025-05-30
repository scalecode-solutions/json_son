import 'package:json_son/json_son.dart';

void main() {
  // Sample API response with common patterns
  final Map<String, dynamic> apiResponse = {
    'status': 'success',
    'code': 200,
    'data': {
      'user': {
        'id': '1001',
        'first_name': 'Jane',
        'last_name': 'Doe',
        'email': 'jane.doe@example.com',
        'avatar_url': 'https://example.com/avatars/jane.jpg',
        'is_active': 'true',
        'created_at': '2023-01-15T09:30:00Z',
        'updated_at': '2023-05-20T14:45:00Z',
        'preferences': {
          'theme': 'dark',
          'notifications': {
            'email': 1,
            'push': 'false',
            'sms': null
          }
        }
      },
      'posts': [
        {
          'id': '101',
          'title': 'Getting Started with JsonSon',
          'likes': '42',
          'tags': 'dart, json, api',
          'published': 1,
          'created_at': '2023-02-10T10:15:00Z'
        },
        {
          'id': '102',
          'title': 'Advanced JsonSon Techniques',
          'likes': '27',
          'tags': 'dart, advanced, tutorial',
          'published': 'true',
          'created_at': '2023-03-22T15:30:00Z'
        }
      ],
      'pagination': {
        'total': '150',
        'page': 1,
        'per_page': '10',
        'has_more': true
      }
    }
  };

  print('=== Enhanced JsonSon Features ===\n');
  
  // Create JsonSon instance with error tracking
  final json = JsonSon.fromMap(apiResponse);
  
  // 1. Error Tracking
  print('--- Error Tracking ---');
  try {
    // Access a path that doesn't exist to generate an error
    json.getPath('data.nonexistent.field');
    
    // Check if there are errors
    if (json.hasErrors) {
      print('Errors occurred:');
      for (final error in json.errors) {
        print('  - $error');
      }
    }
    
    // Clear errors for next operations
    json.clearErrors();
  } catch (e) {
    print('Unexpected error: $e');
  }
  
  // 2. Advanced Path-Based Access
  print('\n--- Advanced Path-Based Access ---');
  final userName = json.getStringPath('data.user.first_name');
  final userEmail = json.getStringPath('data.user.email');
  final isActive = json.getBoolPath('data.user.is_active');
  final emailNotifications = json.getBoolPath('data.user.preferences.notifications.email');
  
  print('User: $userName ($userEmail)');
  print('Active: $isActive');
  print('Email notifications: $emailNotifications');
  
  // Check if paths exist
  print('\nChecking paths:');
  print('Has user data: ${json.hasPath('data.user')}');
  print('Has payment info: ${json.hasPath('data.payment')}');
  
  // 3. Batch Operations
  print('\n--- Batch Operations ---');
  
  // Get multiple values at once
  final userData = json.getObject('data')?.getObject('user');
  if (userData != null) {
    final userFields = userData.getStrings(['first_name', 'last_name', 'email', 'nonexistent']);
    print('User fields: $userFields');
  }
  
  // Fallback keys for handling API inconsistencies
  final firstPost = json.getObjectPath('data.posts.0');
  if (firstPost != null) {
    final postId = firstPost.getIntWithFallbacks(['id', 'post_id', 'postId']);
    final isPublished = firstPost.getBoolWithFallbacks(['published', 'is_published', 'isPublished']);
    print('Post #$postId (published: $isPublished)');
  }
  
  // 4. Required Keys/Paths Validation
  print('\n--- Required Keys/Paths Validation ---');
  
  final requiredUserPaths = [
    'data.user.id',
    'data.user.email',
    'data.user.first_name'
  ];
  
  if (json.hasRequiredPaths(requiredUserPaths)) {
    print('All required user data is present');
  } else {
    print('Missing required user data:');
    for (final error in json.errors) {
      print('  - $error');
    }
    json.clearErrors();
  }
  
  // 5. Transformations
  print('\n--- Transformations ---');
  
  // Transform all string values to uppercase
  final uppercaseJson = json.transformValues(
    (key, value) => value is String, 
    (key, value) => (value as String).toUpperCase()
  );
  
  print('Transformed user name: ${uppercaseJson.getStringPath('data.user.first_name')}');
  
  // Filter keys
  final userJson = json.getObjectPath('data.user');
  if (userJson != null) {
    final basicUserInfo = userJson.filterKeys(
      (key, value) => ['id', 'first_name', 'last_name', 'email'].contains(key)
    );
    
    print('Basic user info: ${basicUserInfo.rawData}');
  }
  
  // 6. Map Extensions
  print('\n--- Map Extensions ---');
  
  // Use extension methods directly on maps
  final userMap = apiResponse['data']['user'] as Map<String, dynamic>;
  final userId = userMap.getInt('id');
  final userFirstName = userMap.getString('first_name');
  
  print('Using map extensions - User #$userId: $userFirstName');
  
  // 7. API Pattern Support
  print('\n--- API Pattern Support ---');
  
  // Extract pagination info
  final paginationInfo = json.getObjectPath('data')?.getPaginationInfo();
  if (paginationInfo != null) {
    print('Pagination: Page ${paginationInfo.page} of ${paginationInfo.totalPages}');
    print('Total items: ${paginationInfo.total}, Limit: ${paginationInfo.limit}');
    print('Has more pages: ${paginationInfo.hasNextPage}');
  }
  
  // Extract user info with common field variations
  final userInfo = json.getObjectPath('data')?.getObject('user')?.getUserInfo();
  if (userInfo != null) {
    print('User Info:');
    print('  ID: ${userInfo.id}');
    print('  Name: ${userInfo.fullName}');
    print('  Email: ${userInfo.email}');
    print('  Avatar: ${userInfo.avatar}');
  }
  
  // Extract timestamp info
  final timestamps = json.getObjectPath('data.user')?.getTimestampInfo();
  if (timestamps != null) {
    print('Timestamps:');
    print('  Created: ${timestamps.createdAt}');
    print('  Updated: ${timestamps.updatedAt}');
    print('  Age: ${timestamps.age?.inDays} days');
  }
  
  // 8. Validation Framework
  print('\n--- Validation Framework ---');
  
  // Create a validator for a post
  final post = json.getObjectPath('data.posts.0');
  if (post != null) {
    final validator = JsonSonValidator(post)
      ..required('id')
      ..required('title')
      ..string('title')
      ..integer('likes')
      ..minLength('title', 5)
      ..maxLength('title', 100)
      ..min('likes', 0);
    
    if (validator.isValid) {
      print('Post validation passed');
    } else {
      print('Post validation failed:');
      for (final entry in validator.errors.entries) {
        print('  - ${entry.key}: ${entry.value}');
      }
    }
  }
  
  // Validate user data with nested validation
  final user = json.getObjectPath('data.user');
  if (user != null) {
    final userValidator = JsonSonValidator(user)
      ..required('id')
      ..required('email')
      ..email('email')
      ..nested('preferences', (prefsValidator) {
        prefsValidator
          ..required('theme')
          ..oneOf('theme', ['light', 'dark', 'system']);
      });
    
    if (userValidator.isValid) {
      print('User validation passed');
    } else {
      print('User validation failed:');
      for (final entry in userValidator.errors.entries) {
        print('  - ${entry.key}: ${entry.value}');
      }
    }
  }
  
  // 9. Error Handling in Constructors
  print('\n--- Error Handling in Constructors ---');
  
  // Try to parse invalid JSON
  final invalidJson = JsonSon.fromJson('{invalid: json}');
  if (invalidJson.hasErrors) {
    print('Error parsing JSON:');
    for (final error in invalidJson.errors) {
      print('  - $error');
    }
  }
  
  // Try to parse from an invalid API response
  final invalidResponse = JsonSon.fromApiResponse(42);
  if (invalidResponse.hasErrors) {
    print('Error parsing API response:');
    for (final error in invalidResponse.errors) {
      print('  - $error');
    }
  }
}
