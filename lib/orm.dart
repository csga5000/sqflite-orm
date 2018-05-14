library sqflite_orm;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'relationship.dart';
import 'model_def.dart';
import 'model.dart';

class Orm {
  static bool useForiegnKeys = true;
  static Database database;

  static Map<String, ModelDef> modelDefsMap = {};
  static Iterable<ModelDef> get modelDefs {
    return modelDefsMap.values;
  }

  static void configure({Database database}) {
    Orm.database = database;
  }

  static void registerModelDef(ModelDef md) {
    modelDefsMap[md.name] = md;
  }
  static void registerModelDefs(List<ModelDef> mds) {
    mds.forEach((md) => registerModelDef(md));
  }

  // SQL getting functions

  static Iterable<String> createAllScripts() {
    return modelDefs.map((m) => m.createScript());
  }

  /// Lists all models
  /// `table` specifies the name of the model def that corresponds to the data you're loading
  /// `include` specifies related tables to include, in format like `['relatedTable', {'tableWithExtraRelations': ['thisTablesRelations']}, {'someOtherTable': ['someRelation', 'someRelation']}]`
  /// `where` Where clause
  /// `whereArgs` Where args
  static Future<Iterable<Model>> list({@required String table, List<dynamic> include, String where, List<String> whereArgs}) async {
    ModelDef queryTable = modelDefsMap[table];
    Iterable<Map<String, dynamic>> res = (await database.query(queryTable.tableName, where: where, whereArgs: whereArgs));
    Iterable<Model> models = res.map((m) => new Model(
      data: new Map<String, dynamic>.from(m),
      def: queryTable,
      fromLocalDb: true,
    ));

    if (include != null && include.length > 0 && models.length > 0) {
      Map<dynamic, Model> modelsMap = {};
      for (var m in models) {
        modelsMap[m[queryTable.primaryKey.key]] = m;
      }

      Iterable<dynamic> ids = models.map((m) => m[queryTable.primaryKey.key]);

      for(var i in include) {
        Relationship includeRelationship = queryTable.relationships.firstWhere((r) => r.relatedTo == i);
        String includeName;
        List<String> recursiveIncludes;
        String toKey = includeRelationship.toKey;
        if (i is String)
          includeName = i;
        else {
          var map = i as Map;
          includeName = map.keys.first;
          recursiveIncludes = map[includeName];
        }
        List<Model> includes = await list(table: i, include: recursiveIncludes, where: "$toKey in (?)", whereArgs: [_sanatizeArray(ids)]);
        includes.forEach((i) {
          var m = modelsMap[i.data[toKey]];
          if (includeRelationship.relationship == RelationshipType.hasMany) {
            if (m[includeRelationship.objectKey] == null)
              m[includeRelationship.objectKey] = [i];
            else
              (m[includeRelationship.objectKey] as List<Model>).add(i);
          }
          else
            m[includeRelationship.objectKey] = i;
        });
      }
    }

    return models;
  }
  static String _sanatizeArray(List<dynamic> items) {
    //Numbers and such should serialize fine, strings jsut need quotes
    return items.map((i) => i is String ? "'$i+'" : i.toString())
      .join(', ');
  }
 }