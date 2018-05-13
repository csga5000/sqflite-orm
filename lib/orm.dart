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
  static List<ModelDef> get modelDefs {
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

  /// Lists all models
  /// `table` specifies the name of the model def that corresponds to the data you're loading
  /// `include` specifies related tables to include, in format like `['relatedTable', {'tableWithExtraRelations': ['thisTablesRelations']}, {'someOtherTable': ['someRelation', 'someRelation']}]`
  /// `where` Where clause
  /// `whereArgs` Where args
  static Future<List<Model>> list({@required String table, List<dynamic> include, String where, List<String> whereArgs}) async {
    ModelDef queryTable = modelDefsMap[table];
    List<Map<String, dynamic>> res = (await database.query(queryTable.name, where: where, whereArgs: whereArgs));
    List<Model> models = res.map((m) => new Model(
      data: new Map<String, dynamic>.from(m),
      def: queryTable,
    ));

    if (include == null || include.length < 1)
    Map<dynamic, Model> modelsMap = {};
    for (var m in models) {
      modelsMap[m[queryTable.primaryKey.key]] = m;
    }

    List<dynamic> ids = models.map((m) => m[queryTable.primaryKey.key]);

    for(var i in include) {
      Relationship includeRelationship = queryTable.relationships.firstWhere((r) => r.relatedTo == i);
      String includeName;
      List<String> recursiveIncludes;
      if (i is String)
        includeName = i;
      else {
        var map = i as Map;
        includeName = map.keys.first;
        recursiveIncludes = map[includeName];
      }
      List<Model> includes = await list(table: i, include: recursiveIncludes, where: "${includeRelationship.toKey} in (?)", whereArgs: [_sanatizeArray(ids)]);
      includes.forEach((i) {
        //TODO: Finish
      });
    }

    return models;
  }
  static String _sanatizeArray(List<dynamic> items) {
    //Numbers and such should serialize fine, strings jsut need quotes
    return items.map((i) => i is String ? "'$i+'" : i.toString())
      .join(', ');
  }
 }