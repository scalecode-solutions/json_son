import 'package:json_son/json_son.dart';

void main() {
  // Sample JSON data
  final Map<String, dynamic> jsonData = {
    'id': '123',
    'name': 'Product XYZ',
    'price': '29.99',
    'isActive': 'true',
    'tags': 'electronics, gadget, new',
    'created_at': '2023-10-26T10:30:00Z',
    'ratings': [4, '5', 3.5, '2'],
    'metadata': null,
    'stock': {
      'count': '42',
      'locations': ['Store A', 'Store B', 'Warehouse'],
      'lastUpdated': 1698316200000
    },
    'variants': [
      {'id': '101', 'color': 'Red', 'inStock': 1},
      {'id': '102', 'color': 'Blue', 'inStock': 0}
    ]
  };

  // Create a JsonSon instance
  final json = JsonSon(jsonData);

  print('=== Basic Property Access ===');
  print('ID: ${json.getInt('id')}');
  print('Name: ${json.getString('name')}');
  print('Price: ${json.getDouble('price')}');
  print('Is Active: ${json.getBool('isActive')}');
  print('Created At: ${json.getDateTime('created_at')}');

  // Using default values
  print('\n=== Default Values ===');
  print(
      'Metadata (with default): ${json.getStringOrDefault('metadata', 'No metadata available')}');
  print('Discount (with default): ${json.getDoubleOrDefault('discount', 0.0)}');

  // Working with lists
  print('\n=== Lists ===');
  final ratings = json.getList<num>('ratings', flexibleNumFromJson);
  print('Ratings: $ratings');

  final tags = json.getCommaSeparatedList('tags');
  print('Tags: $tags');

  // Nested objects
  print('\n=== Nested Objects ===');
  final stock = json.getObject('stock');
  if (stock != null) {
    print('Stock Count: ${stock.getInt('count')}');
    print(
        'Stock Locations: ${stock.getList<String>('locations', flexibleStringFromJson)}');
    print('Last Updated: ${stock.getDateTime('lastUpdated')}');
  }

  // Path-based access
  print('\n=== Path-Based Access ===');
  print('Stock Count (path): ${json.getIntPath('stock.count')}');
  print('First Location (path): ${json.getStringPath('stock.locations.0')}');

  // Working with arrays of objects
  print('\n=== Arrays of Objects ===');
  final variants = json.getObjectList('variants');
  if (variants != null) {
    for (int i = 0; i < variants.length; i++) {
      final variant = variants[i];
      print('Variant ${i + 1}:');
      print('  ID: ${variant.getString('id')}');
      print('  Color: ${variant.getString('color')}');
      print('  In Stock: ${variant.getBool('inStock')}');
    }
  }

  // Utility methods
  print('\n=== Utility Methods ===');
  print('Has "price" key: ${json.hasKey('price')}');
  print('Has "discount" key: ${json.hasKey('discount')}');
  print('All keys: ${json.keys}');

  // Creating a subset of the data
  print('\n=== Data Filtering ===');
  final basicInfo = json.select(['id', 'name', 'price']);
  print('Basic Info: ${basicInfo.rawData}');

  final withoutStock = json.exclude(['stock', 'variants']);
  print('Without Stock Info: ${withoutStock.rawData}');

  // Map transformation
  print('\n=== Map Transformation ===');
  final stringMap = json.mapValuesOrEmpty<String, String>((key, value) {
    final stringValue = flexibleStringFromJson(value);
    if (stringValue != null) {
      return MapEntry(key, stringValue);
    }
    return MapEntry(key, ''); // Provide a default empty string
  });
  print('All values as strings: $stringMap');

  // Comparison with functional approach
  print('\n=== Comparison with Functional Approach ===');
  print('Class-based: ${json.getIntPath('stock.count')}');
  print('Functional: ${flexibleIntFromJson(jsonData['stock']?['count'])}');

  print(
      'Class-based: ${json.getObjectList('variants')?.first.getString('color')}');

  // Functional equivalent requires more verbose code:
  String? firstVariantColor;
  final variantData = jsonData['variants'];
  if (variantData is List && variantData.isNotEmpty) {
    if (variantData.first is Map<String, dynamic>) {
      final firstVariant = variantData.first as Map<String, dynamic>;
      if (firstVariant.containsKey('color')) {
        firstVariantColor = flexibleStringFromJson(firstVariant['color']);
      }
    }
  }
  print('Functional: $firstVariantColor');
}
