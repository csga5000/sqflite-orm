library sqflite_orm;

enum RelationshipType {
  hasOne,
  hasMany,
  belongsTo,
}
class Relationship {
  String relatedTo;
  RelationshipType relationship;
  String fromKey;
  String toKey;

  Relationship({this.relatedTo, this.relationship, this.fromKey, this.toKey});
}