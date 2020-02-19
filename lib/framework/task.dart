import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:isolate';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_spider_fx/framework/index.dart';

enum TaskState {
  stop,
  running,
  pause,
}

class TaskConfig {
  String name;
  Map<String, dynamic> _config = {};

  TaskConfig(this.name) {
    var jsonStr = Persistence.preferences.getString(name);
    if (jsonStr != null) _config = jsonDecode(jsonStr);
  }

  void save() {
    Persistence.preferences.setString(name, jsonEncode(_config));
  }

  void set(String key, dynamic value) => _config[key] = value;

  dynamic get(String key) {
    if (_config.containsKey(key)) return _config[key];
    return null;
  }

  bool containsKey(String key) => _config.containsKey(key);
}

class SpiderTask {
  BuildContext context;
  int index;
  String name;
  TaskState state = TaskState.stop;
  TaskConfig config;
  CatLogging logging;

  SpiderTask(this.context, this.name, {void outputSlot(String content), void callback()}) {
    logging = CatLogging(logTag: name, outputSlot: outputSlot, callback: callback);
    config = TaskConfig(name);
    init();
  }

  init() {
    logging.verbose('Task $name init.');
  }

  start() async {
    state = TaskState.running;
    logging.verbose('Task $name run!');
  }

  resume() {
    state = TaskState.running;
    logging.verbose('Task $name resume');
  }

  stop() {
    // 停止任务的时候要保存
    config.save();
    state = TaskState.stop;
    logging.verbose('Task $name stop!');
  }

  pause() {
    state = TaskState.pause;
    logging.verbose('Task $name pause!');
  }

  /// 导出日志
  exportLog({String filename = 'log.json'}) {
    var filepath = path.join(Persistence.externalStorageDirectory, name, filename);
    var jsonStr = jsonEncode(logging.logs);
    File(filepath).writeAsStringSync(jsonStr);
  }

  /// 导出配置
  exportConfig({String filename = 'config.json'}) {
    var filepath = path.join(Persistence.externalStorageDirectory, name, filename);
    var jsonStr = jsonEncode(config._config);
    File(filepath).writeAsStringSync(jsonStr);
  }
}

void main() {
  var data = List<int>();
  print(identical(data, List<int>()));
  print(data is List<int>);
}
