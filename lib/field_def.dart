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

  FieldDef({this.key, this.type});
  // Consider adding: validators
}