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

