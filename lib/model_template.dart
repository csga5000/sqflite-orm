library sqflite_orm;

import 'relationship.dart';
import 'model_field.dart';

/// Defines a model, it's fields, and it's relationships
class ModelTemplate {
  String name;

  List<ModelField> fields;

  List<Relationship> relationships;
}
