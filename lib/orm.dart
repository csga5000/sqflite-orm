library sqflite_orm;

import 'package:sqflite/sqflite.dart';
import 'model_def.dart';

class Orm {
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
 }