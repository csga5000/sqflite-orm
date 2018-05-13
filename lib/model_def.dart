import 'orm.dart';
import 'relationship.dart';
import 'field_def.dart';

/// Defines a model, it's fields, and it's relationships
class ModelDef {
  String name;
  String tableName;
  FieldDef primaryKey;
  Map<String, FieldDef> fieldDefsMap = {};
  List<FieldDef> get fieldDefs => fieldDefsMap.values.toList();
  set fieldDefs(List<FieldDef> fieldDefs) => fieldDefs.forEach((fd) => fieldDefsMap[fd.key] = fd);
  List<Relationship> relationships;

  /// Creates a model definition
  /// `name` is used for other model defs
  /// `tableName` defaults to `name+'s'`, and is used for sql queries
  /// `primaryKey` the column def for the primary key
  /// `fieldDefs` defines all the datapoints to be stored in this model (and the DB) (except foreign keys, which are generated from relationships)
  /// `relationships` is an array of relationships to other tables
  ModelDef({this.name, this.tableName, this.primaryKey, List<FieldDef> fieldDefs = const [], this.relationships = const []}) {
    this.fieldDefs = fieldDefs;
    this.tableName = this.tableName ?? (this.name+'s');
  }

  String createScript() {
    var create = [
      "CREATE TABLE $tableName (\n",
      _fieldSql(),
      _fkSql()
    ].join('');
    //Remove ,\n add \n);
    return create.replaceRange(create.length-2, create.length, '\n);');
  }

  String _fieldSql() {
    var fieldSql = [primaryKey.key, _fieldTypeFor(primaryKey), 'PRIMARY KEY'].join("\t")+',\n';
    this.fieldDefs.forEach((f) {
      fieldSql += [f.key, _fieldTypeFor(f)].join("\t")+',\n';
    });
    return fieldSql;
  }

  String _fieldTypeFor(FieldDef field) {
    // If I'm not mistaken, in sqlite it doesn't really matter what you say, everything becomes one of the following: null, integer, real, text, or blob
    switch(field.type) {
      case FieldType.bool:
      case FieldType.int:
      case FieldType.datetime:
        return 'integer';
      case FieldType.double:
        return 'real';
      case FieldType.string:
        return 'text';
      default:
        return 'text';
    }
  }
  String _fkSql() {
    var fkSql = '';
    relationships.forEach((r) {
      if (r.relationship == RelationshipType.belongsTo) {
        //TODO: Lookup other model, and get it's it's fieldDef for the key provided
        //Except if not defined
        //Use that to build column,
        //Add FOREIGN KEY(other_id) REFERENCES other(id)
        ModelDef relatedTo = Orm.modelDefsMap[r.relatedTo];
        FieldDef related = relatedTo.primaryKey.key == r.toKey ? relatedTo.primaryKey : relatedTo.fieldDefsMap[r.toKey];
        fkSql += "${r.fromKey}\t${_fieldTypeFor(related)},\n";
        if (r.useForeignKey)
          fkSql += "FOREIGN KEY(${r.fromKey}) REFERENCES other(${r.toKey}),\n";
      }
    });
    return fkSql;
  }

  //Todo:  We can make migrations easy by allowing re-creation of tables
  //Though, we can allow "keeping" data during that process, we'll need to recursively traverse all related models, load them in memory, and then drop them for the purpose of avoiding foreign key errors
  //We could perhaps take in a Map of changed models Map<String, transformFunc>, and perform transformations on that data
  //Perhaps warn keeping data is expensive, especially with large datasets, due to the nature of sqlite
}
