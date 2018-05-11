enum ModelFieldType {
  string,
  int,
  double,
  bool,
  datetime,
}
/// Defines a field on a model
class ModelField {
  String key;
  ModelFieldType type;

  // Consider adding: validators
}