import 'package:meta/meta.dart';
import 'orm.dart';

enum RelationshipType {
  hasOne,
  hasMany,
  belongsTo,
}
class Relationship {
  String relatedTo;
  RelationshipType relationship;
  String objectKey;
  String fromKey;
  String toKey;
  bool useForeignKey;

  /// Defines a relationship between to model definitions
  /// `relatedTo` is the other model's name
  /// `relationship` is the type of relationship
  /// `fromKey` is the key on the table with this relationship.  Only applies to belongs to. detauls to `relatedTo+'_id'`
  /// `objectKey` is the key where the loaded object resides (or is null).  Defaults to `relatedTo`, or `relatedTo+'s'` depending on the relationship
  /// `toKey` is the key on the related table.  Defaults to id or `relatedTo+'_id'` depending on relationship
  /// `useForeignKey` can be used to override what was configured with the ORM for using foreign keys
  Relationship({@required this.relatedTo, @required this.relationship, this.fromKey, this.objectKey, this.toKey, this.useForeignKey}) {
    if (fromKey == null && (relationship == RelationshipType.belongsTo))
      fromKey = relatedTo+'_id';

    if (objectKey == null)
      objectKey = this.relatedTo + (relationship == RelationshipType.hasMany ? 's' : '');

    if (toKey == null)
      toKey = relationship == RelationshipType.belongsTo ? 'id' : (relatedTo+'_id');

    this.useForeignKey = this.useForeignKey ?? Orm.useForiegnKeys;
  }
}