import 'package:test/test.dart';

import 'package:sqflite_orm/orm.dart';
import 'package:sqflite_orm/model_def.dart';
import 'package:sqflite_orm/field_def.dart';
import 'package:sqflite_orm/relationship.dart';

void main() {
  test('adds one to input values', () {
    ModelDef company = new ModelDef(
      name: 'company',
      primaryKey: new FieldDef(
        key: 'id',
        type: FieldType.int,
      ),
      fieldDefs: <FieldDef> [
        new FieldDef(
          key: 'name',
          type: FieldType.string,
        ),
      ],
    );
    ModelDef user = new ModelDef(
      name: 'user',
      primaryKey: new FieldDef(
        key: 'id',
        type: FieldType.int,
      ),
      fieldDefs: <FieldDef> [
        new FieldDef(
          key: 'email',
          type: FieldType.string,
        ),
        new FieldDef(
          key: 'password',
          type: FieldType.string,
        ),
      ],
      relationships: <Relationship> [
        new Relationship(
          relatedTo: 'company',
          relationship: RelationshipType.belongsTo,
        ),
      ]
    );
    Orm.registerModelDefs([company, user]);
    expect(user.createScript(), "CREATE TABLE users (\n"+
      "id\tinteger\tPRIMARY KEY,\n" +
      "email\ttext,\n" +
      "password\ttext,\n" +
      "company_id\tinteger,\n" +
      "FOREIGN KEY(company_id) REFERENCES other(id)\n" +
    ");");
    print(user.createScript());
  });
}
