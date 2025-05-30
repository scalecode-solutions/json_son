import 'package:json_son/json_son.dart';

void main() {
  final errorJson = JsonSon({
    'error': {'code': 'AUTH_FAILED', 'message': 'Authentication failed'}
  });

  final error = errorJson.getApiError();

  print('Error object: $error');
  print('Error code: ${error?.code}');
  print('Error message: ${error?.message}');
  print('Error userMessage: ${error?.userMessage}');
  print('Error toString(): ${error.toString()}');

  print('JsonSon path value: ${errorJson.getStringPath('error.message')}');
}
