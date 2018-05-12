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

  /// Defines a relationship between to model definitions
  /// `relatedTo` is the other model's name
  /// `relationship` is the type of relationship
  /// `fromKey` is the key on the table with this relationship.  Only applies to belongs to
  /// `toKey` is the key on the related table.  Defaults to id or `relatedTo+'_id'` depending on relationship
  Relationship({this.relatedTo, this.relationship, this.fromKey, this.toKey}) {
    if (fromKey == null && (relationship == RelationshipType.belongsTo)) {
      fromKey = relatedTo+'_id';
    }
    if (toKey == null) {
      toKey = relationship == RelationshipType.belongsTo ? 'id' : (relatedTo+'_id');
    }
  }
}