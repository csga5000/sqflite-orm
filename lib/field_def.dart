import 'package:meta/meta.dart';

/// Database and code type of field
enum FieldType {
  string,
  int,
  double,
  bool,
  datetime,
}
/// Defines a field on a model
class FieldDef {
  String key;
  FieldType type;

  bool required = false;

  FieldDef({@required this.key, @required this.type, this.required});
  // Consider adding: validators
}