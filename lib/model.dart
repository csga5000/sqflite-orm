import 'dart:async';

import 'package:meta/meta.dart';

import 'orm.dart';
import 'model_def.dart';

class Model {
  ModelDef def;
  Map<String, dynamic> data;

  bool fromLocalDb;

  Model({@required this.def, this.data = const {}, this.fromLocalDb = false}) {
    validate();
  }

  dynamic get id => data[def.primaryKey.key];

  void validate() {
    List<String> errors = [];
    if (data[def.primaryKey.key] == null)
      errors.add('Primary key must be defined!');

    errors.addAll(def.fieldDefs.where((fd) => fd.isRequired && data[fd.key] == null)
        .map((fd) => '`${fd.key}` must be defined!'));

    if (errors.length > 0)
      throw ArgumentError(errors.join("\n"));
  }

  Future<bool> exists() async {
    return (await Orm.database.query(def.tableName, where: '${def.primaryKey.key} = ?', whereArgs: [id])).length > 0;
  }

  void save() async {
    //TODO: If this fails due to too many keys being provided, we'll need to add a way to get only actual fields.
    if (fromLocalDb && id != null && await exists())
      await Orm.database.update(def.tableName, data, where: '${def.primaryKey.key} = ?', whereArgs: [id]);
    else
      await Orm.database.insert(def.tableName, data);
  }

  operator [](String key) => data[key];
  operator []=(String key, dynamic value) => data[key] = value;
}