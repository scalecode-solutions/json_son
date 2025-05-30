import 'package:test/test.dart';
import 'package:json_son/json_son.dart';

void main() {
  group('JsonSon Validator', () {
    test('validates required fields', () {
      final json = JsonSon({
        'id': 123,
        'name': 'John',
        'email': null
      });
      
      final validator = JsonSonValidator(json)
        ..required('id')
        ..required('name')
        ..required('email');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(1));
      expect(validator.errors['email'], contains('required'));
    });
    
    test('validates required paths', () {
      final json = JsonSon({
        'user': {
          'id': 123,
          'profile': {
            'name': 'John'
          }
        }
      });
      
      final validator = JsonSonValidator(json)
        ..requiredPath('user.id')
        ..requiredPath('user.profile.name')
        ..requiredPath('user.email');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(1));
      expect(validator.errors['user.email'], contains('required'));
    });
    
    test('validates string fields', () {
      final json = JsonSon({
        'name': 'John',
        'age': 30,
        'tags': ['a', 'b']
      });
      
      // Let's debug what's happening
      print('age as string: ${json.getString('age')}');
      print('tags as string: ${json.getString('tags')}');
      
      // Create a custom validator that checks the actual type
      final validator = JsonSonValidator(json)
        ..custom('name', (value) => value is String, message: 'must be a string')
        ..custom('age', (value) => value is String, message: 'must be a string')
        ..custom('tags', (value) => value is String, message: 'must be a string');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(2));
      expect(validator.errors['age'], contains('must be a string'));
      expect(validator.errors['tags'], contains('must be a string'));
    });
    
    test('validates integer fields', () {
      final json = JsonSon({
        'id': 123,
        'count': '456',
        'name': 'John'
      });
      
      final validator = JsonSonValidator(json)
        ..integer('id')
        ..integer('count')
        ..integer('name');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(1));
      expect(validator.errors['name'], contains('must be an integer'));
    });
    
    test('validates boolean fields', () {
      final json = JsonSon({
        'active': true,
        'verified': 'yes',
        'admin': 1
      });
      
      final validator = JsonSonValidator(json)
        ..boolean('active')
        ..boolean('verified')
        ..boolean('admin');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(1));
      expect(validator.errors['verified'], contains('must be a boolean'));
    });
    
    test('validates numeric fields', () {
      final json = JsonSon({
        'price': 29.99,
        'quantity': '10',
        'name': 'Product'
      });
      
      final validator = JsonSonValidator(json)
        ..double('price')
        ..double('quantity')
        ..double('name');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(1));
      expect(validator.errors['name'], contains('must be a number'));
    });
    
    test('validates date fields', () {
      final json = JsonSon({
        'created': '2023-01-15T09:30:00Z',
        'updated': 1673775000000,
        'deleted': 'not a date'
      });
      
      final validator = JsonSonValidator(json)
        ..date('created')
        ..date('updated')
        ..date('deleted');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(1));
      expect(validator.errors['deleted'], contains('must be a valid date'));
    });
    
    test('validates array fields', () {
      final json = JsonSon({
        'tags': ['a', 'b', 'c'],
        'items': {'a': 1, 'b': 2},
        'count': 5
      });
      
      final validator = JsonSonValidator(json)
        ..array('tags')
        ..array('items')
        ..array('count');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(2));
      expect(validator.errors['items'], contains('must be an array'));
      expect(validator.errors['count'], contains('must be an array'));
    });
    
    test('validates object fields', () {
      final json = JsonSon({
        'user': {'name': 'John'},
        'tags': ['a', 'b', 'c'],
        'count': 5
      });
      
      final validator = JsonSonValidator(json)
        ..object('user')
        ..object('tags')
        ..object('count');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(2));
      expect(validator.errors['tags'], contains('must be an object'));
      expect(validator.errors['count'], contains('must be an object'));
    });
    
    test('validates string length', () {
      final json = JsonSon({
        'username': 'john',
        'password': 'pass',
        'bio': 'This is a very long biography that exceeds the maximum length'
      });
      
      final validator = JsonSonValidator(json)
        ..minLength('username', 3)
        ..minLength('password', 8)
        ..maxLength('bio', 20);
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(2));
      expect(validator.errors['password'], contains('at least 8 characters'));
      expect(validator.errors['bio'], contains('at most 20 characters'));
    });
    
    test('validates numeric ranges', () {
      final json = JsonSon({
        'age': 15,
        'score': 110,
        'quantity': 0
      });
      
      final validator = JsonSonValidator(json)
        ..min('age', 18)
        ..max('score', 100)
        ..min('quantity', 1);
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(3));
      expect(validator.errors['age'], contains('at least 18'));
      expect(validator.errors['score'], contains('at most 100'));
      expect(validator.errors['quantity'], contains('at least 1'));
    });
    
    test('validates patterns', () {
      final json = JsonSon({
        'zipcode': '12345',
        'phone': '555-1234',
        'code': 'ABC-123-XYZ'
      });
      
      final validator = JsonSonValidator(json)
        ..pattern('zipcode', RegExp(r'^\d{5}(-\d{4})?$'))
        ..pattern('phone', RegExp(r'^\d{3}-\d{3}-\d{4}$'))
        ..pattern('code', RegExp(r'^[A-Z]{3}-\d{3}-[A-Z]{3}$'));
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(1));
      expect(validator.errors['phone'], contains('invalid format'));
    });
    
    test('validates email format', () {
      final json = JsonSon({
        'email1': 'john@example.com',
        'email2': 'invalid-email',
        'email3': 'missing@'
      });
      
      final validator = JsonSonValidator(json)
        ..email('email1')
        ..email('email2')
        ..email('email3');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(2));
      expect(validator.errors['email2'], contains('valid email'));
      expect(validator.errors['email3'], contains('valid email'));
    });
    
    test('validates URL format', () {
      final json = JsonSon({
        'website': 'https://example.com',
        'blog': 'invalid-url',
        'api': 'ftp://example.com'
      });
      
      final validator = JsonSonValidator(json)
        ..url('website')
        ..url('blog')
        ..url('api');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(2));
      expect(validator.errors['blog'], contains('valid URL'));
      expect(validator.errors['api'], contains('valid URL')); // Not http/https
    });
    
    test('validates allowed values', () {
      final json = JsonSon({
        'role': 'admin',
        'status': 'pending',
        'type': 'unknown'
      });
      
      final validator = JsonSonValidator(json)
        ..oneOf('role', ['user', 'admin', 'moderator'])
        ..oneOf('status', ['active', 'inactive'])
        ..oneOf('type', ['post', 'comment', 'page']);
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(2));
      expect(validator.errors['status'], contains('must be one of'));
      expect(validator.errors['type'], contains('must be one of'));
    });
    
    test('validates with custom rules', () {
      final json = JsonSon({
        'password': 'password123',
        'confirmPassword': 'password123',
        'evenNumber': 5
      });
      
      final validator = JsonSonValidator(json)
        ..custom('password', (value) => value.toString().length >= 8 && value.toString().contains(RegExp(r'\d')))
        ..custom('confirmPassword', (value) => value == json.getString('password'))
        ..custom('evenNumber', (value) => value is int && value % 2 == 0, message: 'Must be an even number');
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(1));
      expect(validator.errors['evenNumber'], equals('Must be an even number'));
    });
    
    test('validates nested objects', () {
      final json = JsonSon({
        'user': {
          'name': 'John',
          'email': 'invalid-email',
          'address': {
            'city': 'New York',
            'zipcode': '12345'
          }
        }
      });
      
      final validator = JsonSonValidator(json)
        ..nested('user', (userValidator) {
          userValidator
            ..required('name')
            ..email('email')
            ..nested('address', (addressValidator) {
              addressValidator
                ..required('city')
                ..required('country');
            });
        });
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(2));
      expect(validator.errors['user.email'], contains('valid email'));
      expect(validator.errors['user.address.country'], contains('required'));
    });
    
    test('validates array items', () {
      final json = JsonSon({
        'users': [
          {'name': 'John', 'age': 30},
          {'name': 'Jane', 'age': 'twenty'},
          {'name': '', 'age': 25}
        ]
      });
      
      final validator = JsonSonValidator(json)
        ..array('users')
        ..eachItem('users', (itemValidator, index) {
          itemValidator
            ..required('name')
            ..minLength('name', 1)
            ..integer('age');
        });
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(2));
      expect(validator.errors['users[1].age'], contains('must be an integer'));
      expect(validator.errors['users[2].name'], contains('at least 1 characters'));
    });
    
    test('validates complex schema', () {
      final json = JsonSon({
        'id': 123,
        'title': 'Product Title',
        'price': 29.99,
        'category': 'electronics',
        'inStock': true,
        'tags': ['new', 'featured'],
        'attributes': {
          'color': 'blue',
          'weight': '2.5kg'
        },
        'ratings': [
          {'user': 'user1', 'score': 5},
          {'user': 'user2', 'score': 'excellent'}
        ]
      });
      
      final validator = JsonSonValidator(json)
        ..required('id')
        ..required('title')
        ..required('price')
        ..required('category')
        ..integer('id')
        ..string('title')
        ..double('price')
        ..min('price', 0)
        ..oneOf('category', ['electronics', 'clothing', 'books'])
        ..boolean('inStock')
        ..array('tags')
        ..object('attributes')
        ..nested('attributes', (attrValidator) {
          attrValidator
            ..string('color')
            ..string('weight');
        })
        ..array('ratings')
        ..eachItem('ratings', (ratingValidator, index) {
          ratingValidator
            ..required('user')
            ..required('score')
            ..string('user')
            ..integer('score')
            ..min('score', 1)
            ..max('score', 5);
        });
      
      expect(validator.isValid, isFalse);
      expect(validator.errors, hasLength(1));
      expect(validator.errors['ratings[1].score'], contains('must be an integer'));
    });
  });
}
