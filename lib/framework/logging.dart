import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

enum LogLevel { verbose, debug, info, warning, error }

/// Dart 提供的log工具
void devLog(String message, {DateTime time, int sequenceNumber, int level: 0, String name: '', Zone zone, Object error, StackTrace stackTrace}) {
  developer.log(message, time: time, sequenceNumber: sequenceNumber, level: level, name: name, zone: zone, error: error, stackTrace: stackTrace);
}

class Log {
  LogLevel level;
  String tag;
  String content;
  DateTime dateTime;

  Log({this.level, this.tag, this.content, this.dateTime});

  Map<String, dynamic> toJson() => {'level': level.toString(), 'tag': tag, 'content': content, 'dateTime': dateTime.toString()};

  @override
  String toString() => jsonEncode(toJson());
}

class CatLogging {
  List<Log> logs = [];
  int bufferSize;
  bool logOutput;
  String logTag;

  /// 输出槽，应该传入一个widget内控制输出显示的函数
  Function(String) outputSlot;

  /// 日志更新回调
  Function callback;
  static const LogLevel defaultLevel = LogLevel.debug;

  CatLogging({this.bufferSize = 1024, this.logOutput = true, this.logTag, this.outputSlot, this.callback});

  _log(LogLevel level, String tag, String content) {
    // 缓冲区满了就删掉一条
    if (logs.length >= bufferSize) logs.removeAt(0);
    if (logOutput) devLog('[CatLogging] ${level.toString()} - $tag - ${DateTime.now().toString()} - $content', level: level.index);
    if (outputSlot != null) outputSlot('$tag - $content');
    if (callback != null) callback();
    logs.add(Log(level: level, tag: tag ?? '', content: content, dateTime: DateTime.now()));
  }

  verbose(String content, {String tag}) => _log(LogLevel.verbose, tag ?? logTag ?? '', content);

  debug(String content, {String tag}) => _log(LogLevel.debug, tag ?? logTag ?? '', content);

  info(String content, {String tag}) => _log(LogLevel.info, tag ?? logTag ?? '', content);

  warning(String content, {String tag}) => _log(LogLevel.warning, tag ?? logTag ?? '', content);

  error(String content, {String tag}) => _log(LogLevel.error, tag ?? logTag ?? '', content);
}