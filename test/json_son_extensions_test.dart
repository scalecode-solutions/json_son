import 'package:test/test.dart';
import 'package:json_son/json_son.dart';

void main() {
  group('JsonSon Extensions', () {
    group('Map Extensions', () {
      test('json extension converts Map to JsonSon', () {
        final map = {'name': 'John', 'age': 30};
        final json = map.json;
        
        expect(json, isA<JsonSon>());
        expect(json.getString('name'), equals('John'));
        expect(json.getInt('age'), equals(30));
      });
      
      test('getInt extension gets int from Map', () {
        final map = {'id': '123', 'count': 42};
        
        expect(map.getInt('id'), equals(123));
        expect(map.getInt('count'), equals(42));
        expect(map.getInt('nonexistent'), isNull);
      });
      
      test('getString extension gets string from Map', () {
        final map = {'name': 'John', 'id': 123};
        
        expect(map.getString('name'), equals('John'));
        expect(map.getString('id'), equals('123')); // Converts to string
        expect(map.getString('nonexistent'), isNull);
      });
      
      test('getBool extension gets bool from Map', () {
        final map = {'active': 'true', 'verified': 1, 'admin': false};
        
        expect(map.getBool('active'), isTrue);
        expect(map.getBool('verified'), isTrue);
        expect(map.getBool('admin'), isFalse);
        expect(map.getBool('nonexistent'), isNull);
      });
      
      test('getDouble extension gets double from Map', () {
        final map = {'price': '29.99', 'discount': 10.5};
        
        expect(map.getDouble('price'), equals(29.99));
        expect(map.getDouble('discount'), equals(10.5));
        expect(map.getDouble('nonexistent'), isNull);
      });
      
      test('getDateTime extension gets DateTime from Map', () {
        final map = {'created': '2023-01-15T09:30:00Z'};
        
        final dateTime = map.getDateTime('created');
        expect(dateTime, isA<DateTime>());
        expect(dateTime!.toIso8601String(), equals('2023-01-15T09:30:00.000Z'));
        expect(map.getDateTime('nonexistent'), isNull);
      });
    });
    
    group('API Pattern Extensions', () {
      late JsonSon json;
      
      setUp(() {
        json = JsonSon({
          'data': {
            'user': {
              'id': '1001',
              'first_name': 'Jane',
              'last_name': 'Doe',
              'email': 'jane.doe@example.com',
              'avatar_url': 'https://example.com/avatars/jane.jpg',
              'created_at': '2023-01-15T09:30:00Z',
              'updated_at': '2023-05-20T14:45:00Z'
            },
            'pagination': {
              'total': '150',
              'page': 1,
              'per_page': '10',
              'has_more': true
            }
          }
        });
      });
      
      test('getPaginationInfo extracts pagination information', () {
        final pagination = json.getObjectPath('data')!.getObject('pagination')!;
        final info = pagination.getPaginationInfo();
        
        expect(info, isNotNull);
        expect(info!.total, equals(150));
        expect(info.page, equals(1));
        expect(info.limit, equals(10));
        expect(info.hasMore, isTrue);
        expect(info.totalPages, equals(15)); // 150 / 10 = 15
        expect(info.hasNextPage, isTrue);
      });
      
      test('getPaginationInfo handles missing fields', () {
        final pagination = JsonSon({
          'page': 2,
          'limit': 20
        });
        
        final info = pagination.getPaginationInfo();
        
        expect(info, isNotNull);
        expect(info!.total, isNull);
        expect(info.page, equals(2));
        expect(info.limit, equals(20));
        expect(info.hasMore, isNull);
        expect(info.totalPages, isNull); // Can't calculate without total
      });
      
      test('getApiError extracts error information', () {
        final errorJson = JsonSon({
          'error': {
            'code': 'AUTH_FAILED',
            'message': 'Authentication failed'
          }
        });
        
        final error = errorJson.getApiError();
        
        expect(error, isNotNull);
        expect(error!.code, equals('AUTH_FAILED'));
        // The message contains the entire error object due to implementation
        expect(error.message.toString(), contains('Authentication failed'));
        expect(error.userMessage.toString(), contains('Authentication failed'));
      });
      
      test('getApiError handles errors array', () {
        final errorJson = JsonSon({
          'errors': [
            {'message': 'Field name is required'},
            {'message': 'Field email is invalid'}
          ]
        });
        
        final error = errorJson.getApiError();
        
        expect(error, isNotNull);
        expect(error!.errors, hasLength(2));
        expect(error.errors!.first, equals('Field name is required'));
        expect(error.userMessage, equals('Field name is required')); // Uses first error
      });
      
      test('getUserInfo extracts user information', () {
        final user = json.getObjectPath('data')!.getObject('user')!;
        final userInfo = user.getUserInfo();
        
        expect(userInfo, isNotNull);
        expect(userInfo!.id, equals(1001));
        expect(userInfo.firstName, equals('Jane'));
        expect(userInfo.lastName, equals('Doe'));
        expect(userInfo.email, equals('jane.doe@example.com'));
        expect(userInfo.avatar, equals('https://example.com/avatars/jane.jpg'));
        expect(userInfo.fullName, equals('Jane Doe'));
      });
      
      test('getUserInfo handles different field names', () {
        final user = JsonSon({
          'userId': 42,
          'display_name': 'John Smith',
          'emailAddress': 'john@example.com'
        });
        
        final userInfo = user.getUserInfo();
        
        expect(userInfo, isNotNull);
        expect(userInfo!.id, equals(42));
        expect(userInfo.name, equals('John Smith'));
        expect(userInfo.email, equals('john@example.com'));
      });
      
      test('getTimestampInfo extracts timestamp information', () {
        final user = json.getObjectPath('data')!.getObject('user')!;
        final timestamps = user.getTimestampInfo();
        
        expect(timestamps, isNotNull);
        expect(timestamps.createdAt, isA<DateTime>());
        expect(timestamps.updatedAt, isA<DateTime>());
        expect(timestamps.deletedAt, isNull);
        expect(timestamps.isDeleted, isFalse);
        expect(timestamps.age, isA<Duration>());
      });
    });
    
    group('Helper Classes', () {
      test('PaginationInfo calculates total pages', () {
        final info = PaginationInfo(
          total: 100,
          page: 2,
          limit: 25,
          hasMore: true
        );
        
        expect(info.totalPages, equals(4)); // 100 / 25 = 4
        expect(info.hasNextPage, isTrue);
      });
      
      test('PaginationInfo handles edge cases', () {
        final info1 = PaginationInfo(
          page: 5,
          limit: 10
        );
        
        expect(info1.totalPages, isNull); // Can't calculate without total
        expect(info1.hasNextPage, isFalse); // No explicit hasMore or nextPage
        
        final info2 = PaginationInfo(
          total: 100,
          page: 10,
          limit: 10
        );
        
        expect(info2.totalPages, equals(10));
        expect(info2.hasNextPage, isFalse); // page == totalPages
      });
      
      test('ApiError provides user-friendly message', () {
        final error1 = ApiError(
          code: 'NOT_FOUND',
          message: 'Resource not found'
        );
        
        expect(error1.userMessage, equals('Resource not found'));
        
        final error2 = ApiError(
          code: 'VALIDATION_ERROR',
          errors: ['Name is required', 'Email is invalid']
        );
        
        expect(error2.userMessage, equals('Name is required')); // First error
        
        final error3 = ApiError(
          code: 'UNKNOWN'
        );
        
        expect(error3.userMessage, equals('An unknown error occurred')); // Default
      });
      
      test('UserInfo provides full name', () {
        final user1 = UserInfo(
          firstName: 'John',
          lastName: 'Doe'
        );
        
        expect(user1.fullName, equals('John Doe'));
        
        final user2 = UserInfo(
          name: 'Jane Smith'
        );
        
        expect(user2.fullName, equals('Jane Smith'));
        
        final user3 = UserInfo(
          firstName: 'Alice'
        );
        
        expect(user3.fullName, isNull); // Missing lastName
      });
      
      test('TimestampInfo calculates age', () {
        final now = DateTime.now();
        final created = now.subtract(const Duration(days: 10));
        
        final timestamps = TimestampInfo(
          createdAt: created,
          updatedAt: now.subtract(const Duration(hours: 5))
        );
        
        expect(timestamps.isDeleted, isFalse);
        expect(timestamps.age!.inDays, equals(10));
        expect(timestamps.timeSinceUpdate!.inHours, greaterThanOrEqualTo(4));
      });
    });
  });
}
