import 'model_def.dart';

class Model {
  ModelDef def;
  Map<String, dynamic> data;

  Model({this.def, this.data});

  operator [](String key) => data[key];
  operator []=(String key, dynamic value) => data[key] = value;
}